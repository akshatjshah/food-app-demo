import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../notifications/presentation/notifications_provider.dart';

/// Per-user notification channel toggles, persisted on-device.
/// There is no backend notification-preferences endpoint, so choices are
/// stored locally and applied to locally-scheduled presentation only.
/// Transactional channels and promotional channels stay visually separated.
class NotificationPrefsState {
  final bool orderUpdates;
  final bool deliveryUpdates;
  final bool subscriptionUpdates;
  final bool offersPromotions;

  const NotificationPrefsState({
    this.orderUpdates = true,
    this.deliveryUpdates = true,
    this.subscriptionUpdates = true,
    this.offersPromotions = true,
  });

  NotificationPrefsState copyWith({
    bool? orderUpdates,
    bool? deliveryUpdates,
    bool? subscriptionUpdates,
    bool? offersPromotions,
  }) {
    return NotificationPrefsState(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      subscriptionUpdates: subscriptionUpdates ?? this.subscriptionUpdates,
      offersPromotions: offersPromotions ?? this.offersPromotions,
    );
  }
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefsState> {
  NotificationPrefsNotifier()
      : super(NotificationPrefsState(
          orderUpdates: LocalStorage.notifOrderUpdates,
          deliveryUpdates: LocalStorage.notifDeliveryUpdates,
          subscriptionUpdates: LocalStorage.notifSubscriptionUpdates,
          offersPromotions: LocalStorage.notifOffersPromotions,
        ));

  /// Re-read the signed-in customer's persisted choices (LocalStorage keys
  /// are per-user). Called when the auth session changes so one customer's
  /// toggles never leak into another customer's view.
  void reload() {
    state = NotificationPrefsState(
      orderUpdates: LocalStorage.notifOrderUpdates,
      deliveryUpdates: LocalStorage.notifDeliveryUpdates,
      subscriptionUpdates: LocalStorage.notifSubscriptionUpdates,
      offersPromotions: LocalStorage.notifOffersPromotions,
    );
  }

  // Each setter applies the new value immediately (so filtering/badge
  // respect it at once), persists it, and on persist failure reverts to
  // the previous switch state and rethrows for the UI error handling.
  Future<void> setOrderUpdates(bool v) async {
    final prev = state;
    state = state.copyWith(orderUpdates: v);
    try {
      await LocalStorage.setNotifOrderUpdates(v);
    } catch (e) {
      state = prev;
      rethrow;
    }
  }

  Future<void> setDeliveryUpdates(bool v) async {
    final prev = state;
    state = state.copyWith(deliveryUpdates: v);
    try {
      await LocalStorage.setNotifDeliveryUpdates(v);
    } catch (e) {
      state = prev;
      rethrow;
    }
  }

  Future<void> setSubscriptionUpdates(bool v) async {
    final prev = state;
    state = state.copyWith(subscriptionUpdates: v);
    try {
      await LocalStorage.setNotifSubscriptionUpdates(v);
    } catch (e) {
      state = prev;
      rethrow;
    }
  }

  Future<void> setOffersPromotions(bool v) async {
    final prev = state;
    state = state.copyWith(offersPromotions: v);
    try {
      await LocalStorage.setNotifOffersPromotions(v);
    } catch (e) {
      state = prev;
      rethrow;
    }
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefsState>(
        (ref) {
  // Rebuild when the signed-in customer changes so each customer gets
  // their own persisted toggles (keys are per-user in LocalStorage).
  ref.watch(authProvider.select((s) => s.user?.id));
  return NotificationPrefsNotifier();
});

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() save,
  ) async {
    try {
      await save();
      // Force the filtered list + badge to re-evaluate immediately so the
      // notification system reflects the new preference without requiring
      // logout, restart, or manual refresh (watchers also update).
      ref.invalidate(filteredNotificationsProvider);
      ref.invalidate(filteredUnreadCountProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not save preference. Try again.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactional',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.s8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Order Updates',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Order placed, confirmed & delivered',
                        style: TextStyle(fontSize: 12)),
                    value: prefs.orderUpdates,
                    onChanged: (v) =>
                        _toggle(context, ref, () => notifier.setOrderUpdates(v)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.delivery_dining_outlined),
                    title: const Text('Delivery Updates',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Rider assigned & on-the-way alerts',
                        style: TextStyle(fontSize: 12)),
                    value: prefs.deliveryUpdates,
                    onChanged: (v) => _toggle(
                        context, ref, () => notifier.setDeliveryUpdates(v)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.card_membership_outlined),
                    title: const Text('Subscription Updates',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Renewals, pauses & skipped meals',
                        style: TextStyle(fontSize: 12)),
                    value: prefs.subscriptionUpdates,
                    onChanged: (v) => _toggle(context, ref,
                        () => notifier.setSubscriptionUpdates(v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Promotional',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.s8),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.local_offer_outlined),
                title: const Text('Offers & Promotions',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Discounts, coupons & new dishes',
                    style: TextStyle(fontSize: 12)),
                value: prefs.offersPromotions,
                onChanged: (v) => _toggle(
                    context, ref, () => notifier.setOffersPromotions(v)),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            const Text(
              'Transactional alerts keep your orders on track. Promotional messages can be switched off anytime without affecting order or delivery updates.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
