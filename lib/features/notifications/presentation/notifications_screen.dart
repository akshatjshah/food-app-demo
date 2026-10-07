import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../data/models/notification_item.dart';
import 'notifications_provider.dart';

/// Category style: distinct icon + icon color + very light circular background.
class _CategoryStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _CategoryStyle(this.icon, this.iconColor, this.bgColor);
}

/// Resolve style from the backend notification `type` first.
/// Falls back to title keywords ONLY when type is missing/unknown.
_CategoryStyle _styleFor(NotificationItem notif) {
  final type = (notif.type ?? '').trim().toLowerCase();

  // ORDER — green (placed / confirmed / preparing / ready / delivered / cancelled / rejected / update)
  const orderTypes = {
    'order',
    'order_update',
    'order_placed',
    'order_confirmed',
    'order_preparing',
    'order_ready',
    'order_delivered',
    'order_cancelled',
    'order_rejected',
  };
  // DELIVERY — blue (rider assigned / on the way / delivery updates)
  const deliveryTypes = {
    'delivery',
    'delivery_update',
    'order_on_way',
    'rider_assigned',
    'out_for_delivery',
    'picked_up',
  };
  // PAYMENT — purple
  const paymentTypes = {
    'payment',
    'payment_success',
    'payment_failed',
    'payment_refunded',
    'payment_refund',
    'payment_pending',
  };
  // SUBSCRIPTION — orange
  const subscriptionTypes = {
    'subscription',
    'subscription_update',
    'subscription_activated',
    'subscription_paused',
    'subscription_renewed',
    'subscription_expiring',
    'subscription_expired',
    'subscription_cancelled',
  };
  // OFFERS — pink/red
  const offerTypes = {
    'offer',
    'coupon',
    'discount',
    'promo',
    'promotion',
  };
  // FOOD / MENU — amber/yellow
  const foodTypes = {
    'menu',
    'menu_update',
    'food',
    'new_dish',
    'special_dish',
    'dish',
  };

  if (orderTypes.contains(type)) {
    return const _CategoryStyle(
      Icons.receipt_long_outlined,
      Color(0xFF16A34A),
      Color(0xFFE7F6EC),
    );
  }
  if (deliveryTypes.contains(type) || type.contains('deliver')) {
    return const _CategoryStyle(
      Icons.delivery_dining_outlined,
      Color(0xFF2563EB),
      Color(0xFFE8F0FE),
    );
  }
  if (paymentTypes.contains(type) || type.contains('payment')) {
    return const _CategoryStyle(
      Icons.payments_outlined,
      Color(0xFF7C3AED),
      Color(0xFFF1EAFE),
    );
  }
  if (subscriptionTypes.contains(type) || type.contains('subscri')) {
    return const _CategoryStyle(
      Icons.card_membership_outlined,
      Color(0xFFEA580C),
      Color(0xFFFFEFE3),
    );
  }
  if (offerTypes.contains(type) || type.contains('offer') || type.contains('coupon') || type.contains('discount') || type.contains('promo')) {
    return const _CategoryStyle(
      Icons.local_offer_outlined,
      Color(0xFFE11D48),
      Color(0xFFFDE7EC),
    );
  }
  if (foodTypes.contains(type) || type.contains('menu') || type.contains('food') || type.contains('dish')) {
    return const _CategoryStyle(
      Icons.restaurant_menu_outlined,
      Color(0xFFD97706),
      Color(0xFFFEF3DC),
    );
  }
  // ADMIN / general announcements — neutral dark + light grey.
  if (type.contains('announce') || type.contains('broadcast') || type.contains('general') || type.contains('notice')) {
    return const _CategoryStyle(
      Icons.campaign_outlined,
      Color(0xFF374151),
      Color(0xFFF1F2F4),
    );
  }

  // Fallback: use title keywords only when type is missing/unknown.
  if (type.isEmpty || type == 'general' || type == 'default') {
    final title = '${notif.title} ${notif.body}'.toLowerCase();
    if (title.contains('rider') || title.contains('on the way') || title.contains('out for delivery') || title.contains('delivery')) {
      return const _CategoryStyle(Icons.delivery_dining_outlined, Color(0xFF2563EB), Color(0xFFE8F0FE));
    }
    if (title.contains('payment') || title.contains('refund') || title.contains('paid')) {
      return const _CategoryStyle(Icons.payments_outlined, Color(0xFF7C3AED), Color(0xFFF1EAFE));
    }
    if (title.contains('subscri')) {
      return const _CategoryStyle(Icons.card_membership_outlined, Color(0xFFEA580C), Color(0xFFFFEFE3));
    }
    if (title.contains('offer') || title.contains('coupon') || title.contains('discount')) {
      return const _CategoryStyle(Icons.local_offer_outlined, Color(0xFFE11D48), Color(0xFFFDE7EC));
    }
    if (title.contains('dish') || title.contains('menu') || title.contains('food')) {
      return const _CategoryStyle(Icons.restaurant_menu_outlined, Color(0xFFD97706), Color(0xFFFEF3DC));
    }
    if (title.contains('order')) {
      return const _CategoryStyle(Icons.receipt_long_outlined, Color(0xFF16A34A), Color(0xFFE7F6EC));
    }
  }

  // Default: admin/neutral.
  return const _CategoryStyle(
    Icons.campaign_outlined,
    Color(0xFF374151),
    Color(0xFFF1F2F4),
  );
}

/// Navigation helpers — order/delivery/payment with a reference open tracking.
bool _isTrackableType(String? type) {
  const trackable = {
    'order',
    'order_update',
    'order_placed',
    'order_confirmed',
    'order_preparing',
    'order_ready',
    'order_on_way',
    'order_delivered',
    'order_cancelled',
    'delivery',
    'delivery_update',
    'payment',
    'payment_success',
    'payment_failed',
    'payment_refunded',
    'payment_pending',
  };
  return trackable.contains((type ?? '').toLowerCase());
}

bool _isMealType(String? type) {
  const mealTypes = {'menu_update', 'menu', 'food'};
  return mealTypes.contains((type ?? '').toLowerCase());
}

bool _isSubscriptionType(String? type) =>
    (type ?? '').toLowerCase().contains('subscri');

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Presented list honors Profile → Notification Preferences; server
    // mark-read / delete behavior is unchanged (see notifications_provider).
    final notificationsAsync = ref.watch(filteredNotificationsProvider);
    final totalCount =
        ref.watch(notificationsFutureProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      // No AppBar: custom header avoids the old cramped leading Row
      // (back + trash side-by-side in leadingWidth 92) which caused the
      // overflow/clipping glitch. There is no rotated/vertical text anywhere.
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              // Trash visible when server records exist (even if all are
              // hidden by preferences); hidden on loading/error/empty.
              showDelete: totalCount > 0,
              onMarkAllRead: () async {
                await ref
                    .read(notificationsRepositoryProvider)
                    .markAllAsRead();
                refreshNotifications(ref);
              },
              onRemoveAll: () => _confirmRemoveAll(context, ref),
              onBack: () => context.pop(),
            ),
            Expanded(
              child: AppPullToRefresh(
                onRefresh: () async => refreshNotifications(ref),
                child: notificationsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: AppSpacing.s16),
                        const Text('Failed to load notifications',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.s8),
                        TextButton(
                          onPressed: () => refreshNotifications(ref),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      // Centered empty state: icon + title + description +
                      // review CTA as one vertical group. Only the
                      // TextButton is clickable; nothing else navigates.
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s32,
                                      vertical: AppSpacing.s24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                          Icons
                                              .notifications_none_rounded,
                                          size: 80,
                                          color: Colors.grey.shade300),
                                      const SizedBox(
                                          height: AppSpacing.s16),
                                      const Text('No notifications yet',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                      const SizedBox(
                                          height: AppSpacing.s8),
                                      Text(
                                        totalCount > 0
                                            ? 'All caught up — ${totalCount == 1 ? '1 notification is' : '$totalCount notifications are'} hidden by your preferences'
                                            : 'Order updates and offers will appear here',
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                      if (totalCount > 0) ...[
                                        const SizedBox(
                                            height: AppSpacing.s12),
                                        TextButton(
                                          onPressed: () =>
                                              context.push(
                                                  '/profile/notification-preferences'),
                                          child: const Text(
                                              'Review preferences'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    final hiddenCount = totalCount - notifications.length;
                    // Single scrollable keeps pull-to-refresh working.
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s8),
                      itemCount: notifications.length +
                          (hiddenCount > 0 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (hiddenCount > 0 && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s16,
                                vertical: AppSpacing.s8),
                            child: Row(
                              children: [
                                const Icon(Icons.tune_rounded,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$hiddenCount hidden by your preferences',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push(
                                      '/profile/notification-preferences'),
                                  child: const Text('Review',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          );
                        }
                        final notif =
                            notifications[index - (hiddenCount > 0 ? 1 : 0)];
                        return _NotificationTile(
                          notification: notif,
                          onTap: () => _onTap(context, ref, notif),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tap → mark read (badge updates instantly) → open related screen.
  Future<void> _confirmRemoveAll(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove all notifications?'),
        content: const Text(
            'This will permanently delete all your notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(notificationsRepositoryProvider).clearAll();
      refreshNotifications(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications removed')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to remove notifications. Try again.')),
        );
      }
    }
  }

  Future<void> _onTap(
      BuildContext context, WidgetRef ref, NotificationItem notif) async {
    if (!notif.isRead) {
      try {
        await ref
            .read(notificationsRepositoryProvider)
            .markAsRead(notif.id);
      } catch (_) {
        // Still navigate even if the mark-read call fails.
      }
      refreshNotifications(ref);
    }

    if (!context.mounted) return;
    final type = (notif.type ?? '').toLowerCase();
    final refId = notif.referenceId;

    if (refId != null && refId.isNotEmpty && _isTrackableType(type)) {
      context.push('/track/$refId');
    } else if (refId != null &&
        refId.isNotEmpty &&
        _isMealType(type)) {
      context.push('/meal/$refId');
    } else if (_isSubscriptionType(type)) {
      _showDetailSheet(context, notif,
          hint: 'See the Subscription tab for your plans.');
    } else {
      _showDetailSheet(context, notif);
    }
  }

  void _showDetailSheet(BuildContext context, NotificationItem notif,
      {String? hint}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24, AppSpacing.s8, AppSpacing.s24, AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: AppSpacing.s8),
            Text(notif.body, style: const TextStyle(fontSize: 14)),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(hint,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header layout:
/// Row 1: [Back far left] [Notifications title centered] [Mark all read]
/// Row 2: [Red trash directly BELOW back, same x-center] — never beside title.
/// Row 2 is shown only when 1+ notifications exist; hidden when empty.
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRemoveAll;
  final VoidCallback onMarkAllRead;
  final bool showDelete;

  const _Header({
    required this.onBack,
    required this.onRemoveAll,
    required this.onMarkAllRead,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed 48px left rail so trash x-center matches back x-center exactly.
    const double railWidth = 48;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: railWidth,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18),
                  onPressed: onBack,
                ),
              ),
              const Expanded(
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: onMarkAllRead,
                child: const Text('Mark all read'),
              ),
            ],
          ),
          // Red trash directly BELOW back, same x-center — never beside title.
          // Hidden completely when the list is empty (or still loading).
          if (showDelete)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: railWidth,
                  child: IconButton(
                    tooltip: 'Remove all',
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 22, color: AppColors.error),
                    onPressed: onRemoveAll,
                  ),
                ),
                // Intentionally empty: header holds nothing else on this row,
                // so no overflow, clipping, overlap, or stray text can appear.
                const Spacer(),
              ],
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final notif = notification;
    final style = _styleFor(notif);
    final read = notif.isRead;

    // Read items are visually muted vs unread.
    final Color iconColor =
        read ? style.iconColor.withValues(alpha: 0.55) : style.iconColor;
    final Color bgColor =
        read ? style.bgColor.withValues(alpha: 0.55) : style.bgColor;

    return Opacity(
      opacity: read ? 0.62 : 1.0,
      child: ListTile(
        onTap: onTap,
        tileColor: read ? null : bgColor.withValues(alpha: 0.35),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: bgColor,
              child: Icon(style.icon, color: iconColor, size: 20),
            ),
            if (!read)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: read ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif.body,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              _timeAgo(notif.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 18, color: Colors.grey),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
