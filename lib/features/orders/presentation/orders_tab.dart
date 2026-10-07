import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../data/models/order.dart';
import 'order_status_ui.dart';
import 'providers/orders_provider.dart';

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});

  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab> {
  int _activeCategory = 0; // 0: Ongoing, 1: History

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated && next.isAuthenticated) {
        ref.read(ordersProvider.notifier).loadOrders();
      }
    });

    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Orders'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildCategoryToggle(context),
          Expanded(
            child: AppPullToRefresh(
              onRefresh: () => ref.read(ordersProvider.notifier).loadOrders(),
              child: ordersState.isLoading
                  ? _buildLoadingShimmer(context)
                  : ordersState.errorMessage != null
                      ? _buildErrorState(context, ordersState.errorMessage!)
                      : _buildOrderList(context, ordersState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24, vertical: AppSpacing.s12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeCategory = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeCategory == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(
                    color: _activeCategory == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Ongoing',
                  style: TextStyle(
                    color:
                        _activeCategory == 0 ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeCategory = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeCategory == 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(
                    color: _activeCategory == 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'History',
                  style: TextStyle(
                    color:
                        _activeCategory == 1 ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, OrdersState ordersState) {
    final listToDisplay = _activeCategory == 0
        ? ordersState.ongoingOrders
        : ordersState.historyOrders;

    if (listToDisplay.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: listToDisplay.length,
      itemBuilder: (context, index) {
        final order = listToDisplay[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_rounded,
                  size: 64, color: Colors.grey),
              const SizedBox(height: AppSpacing.s16),
              Text(
                _activeCategory == 0
                    ? 'No active orders'
                    : 'No order history yet',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _activeCategory == 0
                    ? 'Your ongoing orders will appear here'
                    : 'Completed orders will appear here',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Divider(height: 24),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(AppRadius.r12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(ordersProvider.notifier).loadOrders(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    // Rejected stays visible with a RED "Rejected" badge — never removed,
    // never relabeled. Same card style (ID, date, items, total) as others.
    // Cancel/Track are invalid after rejection, so rejected cards always use
    // history-style actions even when shown in the Ongoing tab.
    final isRejected = order.status == 'rejected';
    final showLiveActions =
        OrderStatusUi.isOngoing(order.status) && !isRejected;
    final statusColor = OrderStatusUi.color(order.status);
    final statusLabel = OrderStatusUi.label(order.status);
    final itemSummary = order.items
        .map((item) =>
            '${item.foodItem.name} x ${item.quantity}')
        .join(', ');
    final dateStr = DateFormat('dd MMM yyyy, h:mm a')
        .format(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r12),
        onTap: () => context.push('/track/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id.substring(0, 8)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateStr,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11)),
            const Divider(height: 24),
            Text(itemSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.4)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹${order.grandTotal.toStringAsFixed(0)}',
                  style:
                      const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (showLiveActions)
                  Row(
                    children: [
                      if (OrderStatusUi.canCancel(order.status))
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: () =>
                                _showCancelDialog(context, order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(
                                  color: AppColors.error),
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        AppRadius.r12),
                              ),
                            ),
                            child: const Text('Cancel',
                                style:
                                    TextStyle(fontSize: 11)),
                          ),
                        ),
                      if (OrderStatusUi.canTrack(order.status))
                        ElevatedButton(
                          onPressed: () => context
                              .push('/track/${order.id}'),
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      AppRadius.r12),
                            ),
                          ),
                          child: const Text('Track Order',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold)),
                        ),
                    ],
                  )
                else
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Downloading invoice...')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    AppRadius.r12),
                          ),
                        ),
                        child: const Text('Invoice',
                            style:
                                TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _handleReorder(context, order),
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    AppRadius.r12),
                          ),
                        ),
                        child: const Text('Reorder',
                            style:
                                TextStyle(fontSize: 11)),
                      ),
                      // Review is ONLY available after DELIVERED (server also enforces).
                      if (order.status == 'delivered') ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final meal = order.items.isNotEmpty
                                ? order.items.first.foodItem.name
                                : 'your order';
                            final foodId = order.items.isNotEmpty
                                ? order.items.first.foodItem.id
                                : null;
                            var target =
                                '/rate/${order.id}?meal=${Uri.encodeComponent(meal)}';
                            if (foodId != null) {
                              target +=
                                  '&foodItemId=${Uri.encodeComponent(foodId)}';
                            }
                            context.push(target);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppRadius.r12),
                            ),
                          ),
                          child: const Text('Rate & Review',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _handleReorder(BuildContext context, Order order) async {
    try {
      await ref.read(ordersProvider.notifier).reorder(order.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reorder failed: $e')),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
            'Are you sure you want to cancel order #${order.id.substring(0, 8)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(ordersProvider.notifier)
                    .cancelOrder(order.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Order cancelled')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Cancel failed: $e')),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
