import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../home/presentation/avatar_image.dart';
import '../../home/presentation/avatar_provider.dart';
import '../../subscription/data/models/subscription.dart';
import '../../subscription/presentation/subscription_provider.dart';

/// Profile Settings — exact row order:
/// 1 Dark Mode, 2 Addresses Manager, 3 Saved Payments, 4 My Subscriptions,
/// 5 Notification Preferences, 6 My Favorites, 7 Help & Chat Support,
/// 8 Privacy & Security, 9 Rate Parabdi, 10 About Parabdi, 11 Logout.
class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionNotifierProvider.notifier).loadMySubscriptions();
    });
  }

  String? _getActiveSubscriptionName(List<UserSubscription> subs) {
    try {
      final active = subs.firstWhere((s) => s.status == 'active');
      return active.subscription?.name;
    } catch (_) {
      return null;
    }
  }

  /// Profile refresh: re-fetches the subscription badge data via the
  /// existing subscription loader (same call as initState). Auth user and
  /// avatar state are intentionally NOT touched here.
  Future<void> _refreshProfile() async {
    await ref.read(subscriptionNotifierProvider.notifier).loadMySubscriptions();
    if (!mounted) return;
    if (ref.read(subscriptionNotifierProvider).errorMessage != null) {
      showRefreshError(
        context,
        message: 'Could not refresh profile. Showing saved data.',
        onRetry: _refreshProfile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final subState = ref.watch(subscriptionNotifierProvider);
    final activePlanName = _getActiveSubscriptionName(subState.mySubscriptions);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile Settings'),
        automaticallyImplyLeading: false,
      ),
      body: AppPullToRefresh(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
          child: Column(
            children: [
              _buildProfileCard(context, ref, authState, activePlanName),
              const SizedBox(height: AppSpacing.s24),
              _buildSettingsList(context, ref, themeMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref,
      AuthState state, String? activePlanName) {
    final avatarId = ref.watch(avatarProvider);
    final isGuest = state.user?.role == 'guest';
    // Name and phone come only from the authenticated user.
    final displayName = (state.user?.fullName?.isNotEmpty == true)
        ? state.user!.fullName!
        : (isGuest ? 'Guest Foodie' : 'Parabdi Foodie');
    final phone = state.user?.phoneNumber ?? '';
    final planLabel = isGuest
        ? 'Guest Account'
        : (activePlanName ?? 'No Active Subscription');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Row(
          children: [
            // Same portrait treatment as Home: ratio-aware, never cropped.
            AvatarPortrait(
              avatarId: avatarId,
              width: 64,
              borderRadius: 18,
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  // Phone number shown exactly once (never split into
                  // country code + number). Hidden for guests with no number.
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    planLabel,
                    style: TextStyle(
                      color: isGuest || activePlanName == null
                          ? Colors.grey
                          : AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit Profile',
              onPressed: () => context.push('/profile/edit'),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(
      BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    const titleStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    const chevron = Icon(Icons.arrow_forward_ios, size: 14);

    return Card(
      child: Column(
        children: [
          // 1. Dark Mode (switch on the right, no chevron)
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode', style: titleStyle),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(height: 1),

          // 2. Addresses Manager
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Addresses Manager', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/addresses'),
          ),
          const Divider(height: 1),

          // 3. Saved Payments
          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text('Saved Payments', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/profile/saved-payments'),
          ),
          const Divider(height: 1),

          // 4. My Subscriptions
          ListTile(
            leading: const Icon(Icons.card_membership_rounded),
            title: const Text('My Subscriptions', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/my-subscriptions'),
          ),
          const Divider(height: 1),

          // 5. Notification Preferences
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title:
                const Text('Notification Preferences', style: titleStyle),
            trailing: chevron,
            onTap: () =>
                context.push('/profile/notification-preferences'),
          ),
          const Divider(height: 1),

          // 6. My Favorites
          ListTile(
            leading: const Icon(Icons.favorite_border_rounded),
            title: const Text('My Favorites', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/profile/favorites'),
          ),
          const Divider(height: 1),

          // 7. Help & Chat Support
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title:
                const Text('Help & Chat Support', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/profile/help-support'),
          ),
          const Divider(height: 1),

          // 8. Privacy & Security
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy & Security', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/profile/privacy-security'),
          ),
          const Divider(height: 1),

          // 9. Rate Parabdi
          ListTile(
            leading: const Icon(Icons.star_border_rounded),
            title: const Text('Rate Parabdi', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/profile/rate'),
          ),
          const Divider(height: 1),

          // 10. About Parabdi
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About Parabdi', style: titleStyle),
            trailing: chevron,
            onTap: () => context.push('/profile/about'),
          ),
          const Divider(height: 1),

          // 11. Logout (visually distinct, no chevron)
          ListTile(
            leading:
                const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content:
            const Text('You will need an OTP to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/auth');
  }
}
