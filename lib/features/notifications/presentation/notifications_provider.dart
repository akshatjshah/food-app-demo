import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../profile/presentation/notification_preferences_screen.dart';
import '../data/models/notification_item.dart';
import '../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ApiClient.instance);
});

/// Full notification list for the signed-in customer (server persisted).
final notificationsFutureProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final repo = ref.read(notificationsRepositoryProvider);
  return repo.getNotifications();
});

/// Real unread count driving the Home bell orange badge.
final unreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(notificationsRepositoryProvider);
  return repo.getUnreadCount();
});

/// Refresh both list and badge together (e.g. after mark-all-read).
void refreshNotifications(WidgetRef ref) {
  ref.invalidate(notificationsFutureProvider);
  ref.invalidate(unreadCountProvider);
  ref.invalidate(filteredNotificationsProvider);
  ref.invalidate(filteredUnreadCountProvider);
}

/// Preference channel for a backend notification `type`. Kept consistent
/// with the category styles in `notifications_screen.dart` so the four
/// Profile → Notification Preferences toggles hide exactly the matching
/// notifications (order/payment, delivery, subscription, offers/promo/menu).
enum NotificationChannel { order, delivery, subscription, offers, other }

NotificationChannel notificationChannelForType(String? type) {
  final t = (type ?? '').trim().toLowerCase();
  if (t.isEmpty) return NotificationChannel.other;
  if (t.contains('subscri')) return NotificationChannel.subscription;
  if (t.contains('deliver') ||
      t.contains('rider') ||
      t == 'order_on_way' ||
      t == 'picked_up' ||
      t == 'out_for_delivery') {
    return NotificationChannel.delivery;
  }
  if (t.contains('offer') ||
      t.contains('coupon') ||
      t.contains('discount') ||
      t.contains('promo') ||
      t.contains('menu') ||
      t.contains('food') ||
      t.contains('dish') ||
      t.contains('announce') ||
      t.contains('broadcast')) {
    return NotificationChannel.offers;
  }
  if (t == 'general' || t == 'default') return NotificationChannel.other;
  // order_*, payment_* and anything else transactional → order channel.
  return NotificationChannel.order;
}

/// Server list filtered by the signed-in customer's preferences.
/// Mark-read / mark-all-read / delete still operate on the real server
/// records via [notificationsRepositoryProvider]; this only controls
/// which notifications are presented locally.
final filteredNotificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final prefs = ref.watch(notificationPrefsProvider);
  final all = await ref.watch(notificationsFutureProvider.future);
  return all.where((n) {
    switch (notificationChannelForType(n.type)) {
      case NotificationChannel.order:
        return prefs.orderUpdates;
      case NotificationChannel.delivery:
        return prefs.deliveryUpdates;
      case NotificationChannel.subscription:
        return prefs.subscriptionUpdates;
      case NotificationChannel.offers:
        return prefs.offersPromotions;
      case NotificationChannel.other:
        return true;
    }
  }).toList();
});

/// Unread badge honoring preferences: counts only visible (non-filtered)
/// unread notifications so switched-off channels don't keep badging.
final filteredUnreadCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(filteredNotificationsProvider.future);
  return list.where((n) => !n.isRead).length;
});
