import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'chef_provider.dart';

class ChefOrdersScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const ChefOrdersScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends ConsumerState<ChefOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedOrderTabProvider.notifier).state =
            OrderTab.values[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedOrderTabProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Preparing'),
            Tab(text: 'Ready'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OrderList(tab: OrderTab.incoming),
          _OrderList(tab: OrderTab.preparing),
          _OrderList(tab: OrderTab.ready),
        ],
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final OrderTab tab;

  const _OrderList({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(chefOrdersProvider(tab));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(chefOrdersProvider(tab));
        await ref.read(chefOrdersProvider(tab).future);
      },
      child: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab == OrderTab.incoming
                        ? Icons.notifications_off_rounded
                        : tab == OrderTab.preparing
                            ? Icons.kitchen_rounded
                            : Icons.check_circle_outline_rounded,
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    tab == OrderTab.incoming
                        ? 'No incoming orders'
                        : tab == OrderTab.preparing
                            ? 'Nothing cooking right now'
                            : 'No orders ready for delivery',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _OrderCard(order: orders[index], tab: tab)
                  .animate()
                  .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                  .slideX(begin: 0.02);
            },
          );
        },
        loading: () => ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: 4,
          itemBuilder: (context, index) => Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: AppSpacing.s12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.s12),
              Text('Failed to load orders', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.s12),
              ElevatedButton(
                onPressed: () => ref.invalidate(chefOrdersProvider(tab)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  final OrderTab tab;

  const _OrderCard({required this.order, required this.tab});

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  Timer? _timer;
  late DateTime _placedAt;

  @override
  void initState() {
    super.initState();
    _placedAt = DateTime.tryParse(widget.order['created_at'] ?? '') ?? DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsedTime() {
    final diff = DateTime.now().difference(_placedAt);
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
  }

  Color _elapsedColor() {
    final minutes = DateTime.now().difference(_placedAt).inMinutes;
    if (minutes > 30) return AppColors.error;
    if (minutes > 15) return AppColors.accent;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final items = (order['items'] as List?) ?? [];
    final orderId = order['id'] ?? '';
    final orderNumber = order['order_number'] ?? '#--';
    final customerName = order['customer']?['full_name'] ?? order['customer_name'] ?? 'Customer';
    final total = order['total_amount'] ?? order['total'] ?? 0;
    final currencyTotal = (total is num) ? total.toDouble() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.premiumShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              // Order number badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Text(
                  '$orderNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  customerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: _elapsedColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 14, color: _elapsedColor()),
                    const SizedBox(width: AppSpacing.s4),
                    Text(
                      _elapsedTime(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _elapsedColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s12),

          // Items list
          ...items.take(3).map<Widget>((item) {
            final name = item['food_item']?['name'] ?? item['name'] ?? 'Item';
            final qty = item['quantity'] ?? 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      '$name',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'x$qty',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
          if (items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s4),
              child: Text(
                '+${items.length - 3} more items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          const SizedBox(height: AppSpacing.s12),

          // Footer row
          Row(
            children: [
              Text(
                '₹${currencyTotal.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
              ),
              const Spacer(),
              if (widget.tab == OrderTab.incoming)
                _ActionButton(
                  label: 'Accept Order',
                  icon: Icons.check_rounded,
                  color: AppColors.primary,
                  onPressed: () async {
                    await ref.read(chefRepositoryProvider).acceptOrder(orderId);
                    ref.invalidate(chefOrdersProvider(OrderTab.incoming));
                    ref.invalidate(chefDashboardProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order accepted')),
                      );
                    }
                  },
                )
              else if (widget.tab == OrderTab.preparing)
                _ActionButton(
                  label: 'Mark Ready',
                  icon: Icons.done_all_rounded,
                  color: AppColors.success,
                  onPressed: () async {
                    await ref.read(chefRepositoryProvider).markReady(orderId);
                    ref.invalidate(chefOrdersProvider(OrderTab.preparing));
                    ref.invalidate(chefDashboardProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order marked ready')),
                      );
                    }
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      SizedBox(width: AppSpacing.s4),
                      Text(
                        'Out for delivery',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
