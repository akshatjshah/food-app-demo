import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/models/subscription.dart';
import 'subscription_provider.dart';

class SubscriptionTab extends ConsumerStatefulWidget {
  /// When true (opened from Profile), shows a back button instead of
  /// hiding navigation. Defaults to false for the bottom-tab usage.
  final bool showBackButton;
  const SubscriptionTab({super.key, this.showBackButton = false});

  @override
  ConsumerState<SubscriptionTab> createState() => _SubscriptionTabState();
}

class _SubscriptionTabState extends ConsumerState<SubscriptionTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionNotifierProvider.notifier).loadPlans();
      ref.read(subscriptionNotifierProvider.notifier).loadMySubscriptions();
    });
  }

  UserSubscription? _getActiveSubscription(List<UserSubscription> subs) {
    try {
      return subs.firstWhere((s) => s.status == 'active');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);
    final activeSub = _getActiveSubscription(state.mySubscriptions);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Parabdi Subscriptions'),
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: state.isLoading && state.plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage!,
                          style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(subscriptionNotifierProvider.notifier).loadPlans();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeSub != null) ...[
                        _buildActivePlanCard(context, activeSub),
                        const SizedBox(height: AppSpacing.s32),
                      ],
                      Text(
                        'Explore Subscription Plans',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Enjoy luxury home-cooked style meals daily with zero hassle and free priority delivery.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      ...state.plans.map(
                          (plan) => _buildPlanCard(context, plan)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActivePlanCard(
      BuildContext context, UserSubscription sub) {
    final now = DateTime.now();
    final totalDays = sub.endDate.difference(sub.startDate).inDays;
    final daysRemaining = sub.endDate.difference(now).inDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? daysRemaining / totalDays : 0.0;
    final planName = sub.subscription?.name ?? 'Active Plan';
    final planPrice = sub.subscription?.priceAsDouble ?? 0;

    return Card(
      color: Theme.of(context)
          .colorScheme
          .primary
          .withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r20),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.r12),
                      ),
                      child: Text(
                        sub.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      planName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  '₹${planPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plan Progress',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '$daysRemaining days remaining',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                color: Theme.of(context).colorScheme.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              '${sub.mealsRemaining} meals remaining',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(subscriptionNotifierProvider.notifier)
                          .pause(sub.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Plan paused. You can resume anytime!')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.r12),
                      ),
                    ),
                    child: const Text('Pause Plan',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final tomorrow = DateTime.now()
                          .add(const Duration(days: 1));
                      final dateStr =
                          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
                      await ref
                          .read(subscriptionNotifierProvider.notifier)
                          .skipDay(sub.id, dateStr);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Skipped delivery for $dateStr!'),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.r12),
                      ),
                    ),
                    child: const Text('Skip Next Meal',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s20),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (plan.description != null) ...[
              const SizedBox(height: 4),
              Text(plan.description!,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.s16),
            if (plan.mealType != null)
              _buildInfoRow(Icons.restaurant, plan.mealType!.toUpperCase()),
            _buildInfoRow(Icons.calendar_today,
                '${plan.durationDays} Days'),
            _buildInfoRow(Icons.fastfood, '${plan.mealsCount} Meals'),
            if (plan.pricePerMealAsDouble != null)
              _buildInfoRow(
                  Icons.monetization_on, '₹${plan.pricePerMealAsDouble!.toStringAsFixed(0)} per meal'),
            const SizedBox(height: AppSpacing.s20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${plan.priceAsDouble.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'for ${plan.durationDays} Days',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push('/subscription/${plan.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
