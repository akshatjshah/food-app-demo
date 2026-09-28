import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../home/presentation/avatar_provider.dart';
import '../../home/presentation/avatar_selection_page.dart';
import '../../subscription/data/models/subscription.dart';
import '../../subscription/presentation/subscription_provider.dart';

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
        child: Column(
          children: [
            _buildProfileCard(context, ref, authState, activePlanName),
            const SizedBox(height: AppSpacing.s24),
            _buildSettingsList(context, ref, themeMode),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, AuthState state, String? activePlanName) {
    final avatarId = ref.watch(avatarProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 72,
                height: 72,
                child: SvgPicture.asset(
                  AvatarSelectionPage.assetForStatic(avatarId),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.user?.fullName ?? 'Rohan Patel',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.user?.phoneNumber ?? '9876543210',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.user?.role == 'guest' ? 'Guest Account' : (activePlanName ?? 'No Active Subscription'),
                    style: TextStyle(
                      color: state.user?.role == 'guest' ? Colors.grey : AppColors.accent,
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return Card(
      child: Column(
        children: [
          // Dark Mode Switch
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Addresses Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/addresses'),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text('Saved Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.card_membership_rounded),
            title: const Text('My Subscriptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help & Chat Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth');
            },
          ),
        ],
      ),
    );
  }
}
