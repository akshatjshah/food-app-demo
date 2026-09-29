import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notification_item.dart';

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  /// Loads the current customer's notifications (server-scoped by user,
  /// persisted in DB so they survive app restart/login).
  /// Accepts envelope variants: {data: [...]}, {data: {notifications: [...]}},
  /// {notifications: [...]}, or a raw list.
  Future<List<NotificationItem>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    final payload = response.data;
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = (data['notifications'] ?? data['items'] ?? []) as List;
    } else {
      list = const [];
    }
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Real unread count for the orange badge. Returns 0 on any parse issue
  /// instead of breaking the home header.
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('${ApiConstants.notifications}/unread-count');
      final payload = response.data;
      final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
      if (data is Map && data['count'] != null) {
        return (data['count'] as num).toInt();
      }
      if (data is num) return data.toInt();
    } catch (_) {
      // Fall through to list-based fallback below.
    }
    try {
      final items = await getNotifications();
      return items.where((n) => !n.isRead).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch('${ApiConstants.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.patch(ApiConstants.notificationsReadAll);
  }

  /// Deletes ALL notifications of the signed-in customer on the server.
  /// Scoped server-side by user — never touches other customers.
  Future<void> clearAll() async {
    await _dio.delete(ApiConstants.notifications);
  }
}
