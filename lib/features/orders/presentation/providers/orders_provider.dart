import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../order_status_ui.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ApiClient.instance);
});

class OrdersState {
  final List<Order> ongoingOrders;
  final List<Order> historyOrders;
  final bool isLoading;
  final String? errorMessage;

  const OrdersState({
    this.ongoingOrders = const [],
    this.historyOrders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrdersState copyWith({
    List<Order>? ongoingOrders,
    List<Order>? historyOrders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersState(
      ongoingOrders: ongoingOrders ?? this.ongoingOrders,
      historyOrders: historyOrders ?? this.historyOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRepository _repo;

  OrdersNotifier(this._repo) : super(const OrdersState());

  // Display-only split. Nothing is ever filtered out: rejected stays in
  // BOTH lists, unknown statuses fall back to history. Backend + repository
  // return every status unfiltered.
  Future<void> loadOrders() async {
    final token = LocalStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        ongoingOrders: const [],
        historyOrders: const [],
        clearError: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final allOrders = await _repo.getOrders();
      final ongoing =
          allOrders.where((o) => OrderStatusUi.isOngoing(o.status)).toList();
      final history =
          allOrders.where((o) => OrderStatusUi.isHistory(o.status)).toList();
      state = state.copyWith(
        ongoingOrders: ongoing,
        historyOrders: history,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _repo.cancelOrder(orderId);
    await loadOrders();
  }

  /// Live socket path: updates the SAME order card in place when the
  /// backend broadcasts `order_status_update`. No reload, no duplicates,
  /// no card recreation — the affected record is patched and re-split
  /// across ongoing/history (rejected stays visible in both).
  void applyRealtimeUpdate(String orderId, String newStatus) {
    final inOngoing = state.ongoingOrders.any((o) => o.id == orderId);
    final inHistory = state.historyOrders.any((o) => o.id == orderId);
    if (!inOngoing && !inHistory) {
      // Unknown order (e.g. just placed on another device) — refetch once.
      loadOrders();
      return;
    }
    final updatedOngoing = state.ongoingOrders
        .map((o) => o.id == orderId ? o.copyWith(status: newStatus) : o)
        .toList();
    final updatedHistory = state.historyOrders
        .map((o) => o.id == orderId ? o.copyWith(status: newStatus) : o)
        .toList();
    // Re-split so terminal states land in History while rejected stays
    // visible in Ongoing too (display-only split, nothing filtered out).
    final all = <String, Order>{};
    for (final o in [...updatedOngoing, ...updatedHistory]) {
      all[o.id] = o;
    }
    final ongoing =
        all.values.where((o) => OrderStatusUi.isOngoing(o.status)).toList();
    final history =
        all.values.where((o) => OrderStatusUi.isHistory(o.status)).toList();
    state = state.copyWith(
      ongoingOrders: ongoing,
      historyOrders: history,
      clearError: true,
    );
  }

  /// Tracking screen + pull paths: refetch a single order then patch state.
  Future<void> refreshOrder(String orderId) async {
    try {
      final fresh = await _repo.getOrder(orderId);
      applyRealtimeUpdate(fresh.id, fresh.status);
    } catch (_) {
      await loadOrders();
    }
  }

  Future<void> reorder(String orderId) async {
    await _repo.reorder(orderId);
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data;
        if (data['error'] is Map && data['error']['message'] != null) {
          return data['error']['message'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      return e.error?.toString() ?? 'Failed to load orders';
    }
    return e.toString();
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.read(orderRepositoryProvider))..loadOrders();
});
