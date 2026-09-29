import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Help & Chat Support — real in-app support surface: FAQ answers,
/// order-help deep links into the existing Orders tab flow, and
/// contact rows. No backend ticket API exists, so no fake ticket
/// submission is included.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Chat Support'),
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
                      child: Icon(Icons.support_agent_rounded,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('We are here to help',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 4),
                          Text(
                            'Pure Veg Gujarati cloud kitchen • 9 AM – 9 PM, all days',
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey),
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
                  const ListTile(
                    leading: Icon(Icons.email_outlined),
                    title: Text('support@parabdi.in',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('We reply within a few hours',
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
    );
  }
}
