import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../authentication/presentation/auth_provider.dart';

/// Privacy & Security — static policy content plus real account/session
/// info from the authenticated user. There is no backend delete-account
/// endpoint, so account deletion is NOT offered as a fake action.
class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_user_outlined,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName?.isNotEmpty == true
                                ? user!.fullName!
                                : 'Parabdi Customer',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Signed in with OTP-secured login',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Card(
              child: Column(
                children: [
                  ExpansionTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.s16, 0,
                            AppSpacing.s16, AppSpacing.s16),
                        child: Text(
                          'Parabdi collects only what is needed to run your food orders: '
                          'your phone number for OTP login, delivery addresses you save, '
                          'and order history. We never sell your data. Payment details '
                          'are processed securely by Razorpay and never stored on our servers. '
                          'You can review or update your profile and addresses anytime from the app.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  ExpansionTile(
                    leading:
                        const Icon(Icons.description_outlined),
                    title: const Text('Terms & Conditions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.s16, 0,
                            AppSpacing.s16, AppSpacing.s16),
                        child: Text(
                          'By using Parabdi you agree to order pure-veg Gujarati meals for '
                          'personal consumption within our delivery zones. Prices and '
                          'delivery slots shown at checkout are final. Subscriptions can be '
                          'paused or skipped as described on the plan. Misuse, fraud, or '
                          'abuse of offers may lead to account review.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('Login & Sessions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text(
                        'OTP login • sessions stay on this device until logout',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Logout from this device',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text(
                          'You will need an OTP to sign in again.'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/auth');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
