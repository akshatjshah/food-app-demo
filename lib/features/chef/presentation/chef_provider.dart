import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../data/repositories/chef_repository.dart';

final chefRepositoryProvider = Provider<ChefRepository>((ref) {
  return ChefRepository(ApiClient.instance);
});

// --- Auth State ---

class ChefAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? chefName;

  ChefAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.chefName,
  });

  ChefAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? chefName,
  }) {
    return ChefAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      chefName: chefName ?? this.chefName,
    );
  }
}

class ChefAuthNotifier extends StateNotifier<ChefAuthState> {
  final ChefRepository _repo;

  ChefAuthNotifier(this._repo) : super(ChefAuthState()) {
    _init();
  }

  void _init() {
    final token = LocalStorage.getAccessToken();
    final role = LocalStorage.getUserRole();
    if (token != null && role == 'chef') {
      state = state.copyWith(
        isAuthenticated: true,
        chefName: LocalStorage.getUserName(),
      );
    }
  }

  Future<bool> login(String phoneNumber, String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repo.login(phoneNumber, pin);
      await LocalStorage.setAccessToken(data['access_token']);
      if (data['refresh_token'] != null) {
        await LocalStorage.setRefreshToken(data['refresh_token']);
      }
      await LocalStorage.setUserId(data['user']?['id'] ?? '');
      await LocalStorage.setUserName(data['user']?['full_name'] ?? 'Chef');
      await LocalStorage.setPhoneNumber(phoneNumber);
      await LocalStorage.setUserRole('chef');

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        chefName: data['user']?['full_name'] ?? 'Chef',
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearAuth();
    await LocalStorage.clearAll();
    state = ChefAuthState();
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data;
      if (data['error'] is Map && data['error']['message'] != null) {
        return data['error']['message'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return e.error?.toString() ?? 'Something went wrong';
  }
}

final chefAuthProvider = StateNotifierProvider<ChefAuthNotifier, ChefAuthState>(
  (ref) {
    final repo = ref.read(chefRepositoryProvider);
    return ChefAuthNotifier(repo);
  },
);

// --- Dashboard State ---

class ChefDashboardData {
  final int totalOrders;
  final int preparingOrders;
  final int readyOrders;

  ChefDashboardData({
    this.totalOrders = 0,
    this.preparingOrders = 0,
    this.readyOrders = 0,
  });
}

final chefDashboardProvider =
    FutureProvider.autoDispose<ChefDashboardData>((ref) async {
  final repo = ref.read(chefRepositoryProvider);
  try {
    final data = await repo.getDashboard();
    return ChefDashboardData(
      totalOrders: data['totalOrders'] ?? 0,
      preparingOrders: data['preparingOrders'] ?? 0,
      readyOrders: data['readyOrders'] ?? 0,
    );
  } catch (_) {
    return ChefDashboardData();
  }
});

// --- Orders State ---

enum OrderTab { incoming, preparing, ready }

final selectedOrderTabProvider = StateProvider<OrderTab>(
  (ref) => OrderTab.incoming,
);

final chefOrdersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, OrderTab>((ref, tab) async {
  final repo = ref.read(chefRepositoryProvider);
  final statusMap = {
    OrderTab.incoming: 'placed',
    OrderTab.preparing: 'preparing',
    // No pickup step: the "Ready" tray lists out-for-delivery orders
    // (markReady advances preparing → out_for_delivery).
    OrderTab.ready: 'out_for_delivery',
  };
  try {
    final data = await repo.getOrders(status: statusMap[tab]);
    return data.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

// --- Inventory State ---

final chefInventoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(chefRepositoryProvider);
  try {
    final data = await repo.getFoodItems();
    return data.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});
