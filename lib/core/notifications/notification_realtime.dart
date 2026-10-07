import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../../features/notifications/data/models/notification_item.dart';
import '../../features/notifications/presentation/notifications_provider.dart';

/// App-wide realtime notification bus.
///
/// Sources (all real backend data, never faked):
/// 1. FCM foreground messages push directly via [pushExternal].
/// 2. Short-interval inbox polling ([start]/[checkNow]) picks up admin
///    broadcasts even when FCM is unavailable (emulator, missing
///    google-services config, token not yet registered).
///
/// On every new notification the notification providers are invalidated so
/// the Home bell badge updates instantly with no manual refresh, and the
/// newest item is emitted on [stream] so Home can show the bell popup.
class NotificationRealtime {
  NotificationRealtime._();
  static final NotificationRealtime instance = NotificationRealtime._();

  final StreamController<NotificationItem> _controller =
      StreamController<NotificationItem>.broadcast();

  Stream<NotificationItem> get stream => _controller.stream;

  ProviderContainer? _container;
  Timer? _timer;
  final Set<String> _seenIds = {};
  bool _primed = false;
  bool _checking = false;

  void attachContainer(ProviderContainer c) => _container = c;

  /// Start automatic polling (called from Home initState). Safe to call
  /// multiple times; only one timer ever runs.
  void start({Duration interval = const Duration(seconds: 12)}) {
    if (_timer?.isActive == true) return;
    // Prime known IDs without emitting popups for old inbox content.
    unawaited(_prime());
    _timer = Timer.periodic(interval, (_) => checkNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// FCM foreground path: invalidate badge + emit popup item.
  void pushExternal(NotificationItem item) {
    _seenIds.add(item.id);
    _invalidate();
    if (!_controller.isClosed) _controller.add(item);
  }

  /// Single poll round: fetch latest inbox, invalidate badge on any change,
  /// emit popup only for genuinely new IDs.
  Future<void> checkNow() async {
    if (_checking) return;
    _checking = true;
    try {
      final token = LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) return;
      Dio client;
      try {
        client = ApiClient.instance;
      } catch (_) {
        return;
      }
      final res = await client.get('/notifications',
          queryParameters: {'take': 10});
      final payload = res.data;
      final dynamic data =
          payload is Map ? payload['data'] ?? payload : payload;
      final List list = data is List ? data : const [];
      if (list.isEmpty) {
        if (!_primed) _primed = true;
        return;
      }
      final items = <NotificationItem>[];
      for (final e in list) {
        try {
          if (e is Map<String, dynamic>) {
            items.add(NotificationItem.fromJson(e));
          } else if (e is Map) {
            items.add(NotificationItem.fromJson(
                Map<String, dynamic>.from(e)));
          }
        } catch (_) {}
      }
      if (!_primed) {
        _seenIds.addAll(items.map((e) => e.id));
        _primed = true;
        return;
      }
      final fresh =
          items.where((e) => !_seenIds.contains(e.id)).toList();
      if (fresh.isEmpty) return;
      for (final e in fresh) {
        _seenIds.add(e.id);
      }
      _invalidate();
      // Newest first (backend returns desc); show the single newest popup.
      fresh.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!_controller.isClosed) _controller.add(fresh.first);
    } catch (_) {
      // Poll failures are silent: badge keeps last known value.
    } finally {
      _checking = false;
    }
  }

  Future<void> _prime() async {
    try {
      await checkNow();
    } catch (_) {}
  }

  void _invalidate() {
    final c = _container;
    if (c == null) return;
    try {
      c.invalidate(notificationsFutureProvider);
      c.invalidate(unreadCountProvider);
      c.invalidate(filteredNotificationsProvider);
      c.invalidate(filteredUnreadCountProvider);
    } catch (_) {}
  }
}
