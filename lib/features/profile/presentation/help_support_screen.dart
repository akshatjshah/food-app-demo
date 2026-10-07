import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../settings/presentation/app_content_provider.dart';

/// Help & Chat Support — real in-app support surface: FAQ answers,
/// order-help deep links into the existing Orders tab flow, and
/// contact rows (contact info is dynamic from backend Settings).
/// No backend ticket API exists, so no fake ticket
/// submission is included.
class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  static const _faqs = [
    (
      q: 'How do I track my order?',
      a: 'Open the Orders tab from the bottom navigation to see live status, '
          'or tap any notification about your order to jump straight to tracking.'
    ),
    (
      q: 'How do subscriptions work?',
      a: 'Pick a plan from the Subscription tab, choose your start date, and '
          'fresh meals arrive on schedule. Pause anytime or skip the next meal '
          'from your active plan card.'
    ),
    (
      q: 'How do I change my delivery address?',
      a: 'Go to Profile > Addresses Manager to add, edit, or pick a default '
          'address. You can also choose an address at checkout.'
    ),
    (
      q: 'What payment methods are accepted?',
      a: 'UPI, credit/debit cards, netbanking and wallets via Razorpay, plus '
          'cash on delivery where available.'
    ),
    (
      q: 'How do I report a wrong or missing item?',
      a: 'Open Orders, select the order, and use the Rate flow to leave '
          'feedback. For urgent issues, message us with your order ID.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Always fetch the latest published copy on open — an Admin publish
    // made while the app runs must appear without restart.
    Future.microtask(
        () => ref.read(appContentProvider.notifier).load());
  }

  Future<void> _refresh() async {
    try {
      await ref.read(appContentProvider.notifier).load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic contact info from backend Settings (Admin → Publish).
    // No hardcoded kitchen-hours copy — server value wins.
    final content = ref.watch(appContentProvider);
    final contactInfo = content.values['contact_info'];
    if ((contactInfo == null || contactInfo.isEmpty) &&
        !content.isLoading) {
      Future.microtask(() => ref
          .read(appContentProvider.notifier)
          .refreshKey('contact_info'));
    }
    final contactLine = (contactInfo != null && contactInfo.isNotEmpty)
        ? contactInfo
        : (content.isLoading
            ? 'Loading support info…'
            : 'Support contact has not been published yet.');
    final contactEmail = (contactInfo != null &&
            contactInfo.contains('@'))
        ? RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+')
                .firstMatch(contactInfo)
                ?.group(0) ??
            'support@parabdi.in'
        : 'support@parabdi.in';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Chat Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          AppRefreshIconButton(
            tooltip: 'Refresh support info',
            errorMessage:
                'Could not refresh support info. Showing saved data.',
            onRefresh: _refresh,
            hasError: () => false,
          ),
        ],
      ),
      body: AppPullToRefresh(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      child: Icon(Icons.support_agent_rounded,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('We are here to help',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            contactLine,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
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
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('My Orders',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Track or get help with an order',
                        style: TextStyle(fontSize: 12)),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => context.go('/home'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('My Notifications',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Order & delivery updates',
                        style: TextStyle(fontSize: 12)),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => context.push('/notifications'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(contactEmail,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('We reply within a few hours',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Frequently asked questions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s12),
            ..._faqs.map((faq) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: ExpansionTile(
                    title: Text(faq.q,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s16),
                        child: Text(faq.a,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
