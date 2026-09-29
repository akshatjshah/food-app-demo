import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Saved Payments — reflects the real payment stack (Razorpay: UPI, cards,
/// netbanking, wallets at checkout). There is no saved-card vault backend,
/// so no stored instruments are faked; the screen explains how payments
/// work and routes to checkout for real transactions.
class SavedPaymentsScreen extends StatelessWidget {
  const SavedPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Payments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
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
                      child: Icon(Icons.shield_outlined,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Secure payments via Razorpay',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 4),
                          Text(
                            'Parabdi never stores your card or UPI details. Every payment is processed securely at checkout.',
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
                children: const [
                  ListTile(
                    leading: Icon(Icons.bolt_rounded),
                    title: Text('UPI / GPay / PhonePe',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Pay instantly at checkout',
                        style: TextStyle(fontSize: 12)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.credit_card_outlined),
                    title: Text('Credit / Debit Cards',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Visa, Mastercard, RuPay & more',
                        style: TextStyle(fontSize: 12)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.account_balance_outlined),
                    title: Text('Netbanking & Wallets',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('All major banks supported',
                        style: TextStyle(fontSize: 12)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.money_outlined),
                    title: Text('Cash on Delivery',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Where available',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            ElevatedButton(
              onPressed: () => context.push('/cart'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text('Go to Cart',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
