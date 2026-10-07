import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/order_socket.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_refresh.dart';
import '../data/models/order.dart';
import '../data/repositories/order_repository.dart';
import 'providers/orders_provider.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  late final OrderRepository _repo;
  Order? _order;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<OrderStatusEvent>? _socketSub;

  // Final 5-step Parabdi timeline (no pickup step).
  // Legacy internal states (ready/rider_assigned/picked_up) resolve to
  // the Out for Delivery step so stranded orders still render sensibly.
  static const _statusSteps = <String, int>{
    'placed': 0,
    'confirmed': 1,
    'preparing': 2,
    'ready': 3,
    'rider_assigned': 3,
    'picked_up': 3,
    'out_for_delivery': 3,
    'delivered': 4,
    'cancelled': -1,
    'rejected': -2,
  };

  static const _stepLabels = [
    ('Order Placed', 'Your order has been received'),
    ('Order Confirmed', 'Kitchen accepted your order'),
    ('Preparing Meal', 'Chef is preparing your meal'),
    ('Out for Delivery', 'Rider is on the way'),
    ('Delivered', 'Enjoy your meal!'),
  ];

  @override
  void initState() {
    super.initState();
    _repo = OrderRepository(ApiClient.instance);
    _fetchOrder();
    // Genuine realtime: join this order's room and advance the timeline
    // live when the backend broadcasts order_status_update. Event-driven
    // single refetch per status change — no polling, no timers.
    OrderSocket.instance.connect();
    OrderSocket.instance.joinOrder(widget.orderId);
    _socketSub?.cancel();
    _socketSub = OrderSocket.instance.statusStream.listen((event) {
      if (!mounted || event.orderId != widget.orderId) return;
      _onSocketStatus(event.status);
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    OrderSocket.instance.leaveOrder(widget.orderId);
    super.dispose();
  }

  /// Socket event → patch provider (My Orders card) + refetch this order
  /// so the stepper animates to the new stage automatically.
  Future<void> _onSocketStatus(String status) async {
    try {
      ref.read(ordersProvider.notifier).applyRealtimeUpdate(widget.orderId, status);
    } catch (_) {}
    try {
      final order = await _repo.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      // Keep the last known state; header/pull refresh can retry.
    }
  }

  Future<void> _fetchOrder() async {
    try {
      final order = await _repo.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load order details';
        _isLoading = false;
      });
    }
  }

  /// Pull/header refresh: re-fetches live order status from the backend.
  /// Unlike the initial load, a failed refresh never clears the already
  /// shown order — it surfaces a snackbar with Retry instead.
  Future<void> _refreshTracking() async {
    try {
      final order = await _repo.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      showRefreshError(
        context,
        message: 'Could not refresh order status. Showing saved data.',
        onRetry: _refreshTracking,
      );
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repo.cancelOrder(widget.orderId);
      if (!mounted) return;
      await _fetchOrder();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_order != null ? 'Order #${_order!.id.substring(0, 8)}' : 'Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // Header refresh for live status; pull-to-refresh on the content
          // below performs the same backend fetch.
          AppRefreshIconButton(
            tooltip: 'Refresh order status',
            errorMessage:
                'Could not refresh order status. Showing saved data.',
            onRefresh: _refreshTracking,
            hasError: () => _error != null && _order == null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
              const SizedBox(height: AppSpacing.s16),
              Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.s24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() { _isLoading = true; _error = null; });
                  _fetchOrder();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final isCancelled = order.status == 'cancelled';
    final isRejected = order.status == 'rejected';
    final canCancel = order.status == 'placed' || order.status == 'confirmed';

    return Column(
      children: [
        Expanded(
          child: AppPullToRefresh(
            onRefresh: _refreshTracking,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildMapPlaceholder(context),
                  _buildStatusSection(context, order, isCancelled, isRejected),
                  if (order.items.isNotEmpty) _buildOrderItems(context, order),
                  if (order.deliveryAddress != null) _buildDeliveryAddress(context, order),
                  _buildOrderSummary(context, order),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
        if (canCancel) _buildCancelBar(context),
        // Rate & Review ONLY after DELIVERED.
        if (order.status == 'delivered') _buildReviewBar(context, order),
      ],
    );
  }

  Widget _buildReviewBar(BuildContext context, Order order) {
    final meal = order.items.isNotEmpty ? order.items.first.foodItem.name : 'your order';
    final foodId = order.items.isNotEmpty ? order.items.first.foodItem.id : null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: ElevatedButton.icon(
          onPressed: () {
            var target = '/rate/${order.id}?meal=${Uri.encodeComponent(meal)}';
            if (foodId != null) {
              target += '&foodItemId=${Uri.encodeComponent(foodId)}';
            }
            context.push(target);
          },
          icon: const Icon(Icons.star_rate_rounded),
          label: const Text('Rate & Review',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context) {
    return Container(
      height: 220,
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFE3F2FD)
          : const Color(0xFF1E293B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Live tracking coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
      BuildContext context, Order order, bool isCancelled,
      [bool isRejected = false]) {
    final currentStep = _statusSteps[order.status] ?? 0;
    final isDelivered = order.status == 'delivered';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.r24)),
        boxShadow: AppShadows.premiumShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEtaHeader(context, order, isCancelled || isRejected, isDelivered),
          const Divider(height: 32),
          if (isCancelled)
            _buildCancelledBanner(context)
          else if (isRejected)
            _buildRejectedBanner(context)
          else ...[
            _buildTimeline(context, currentStep),
          ],
        ],
      ),
    );
  }

  Widget _buildEtaHeader(BuildContext context, Order order, bool isCancelled, bool isDelivered) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimated Arrival', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                isCancelled
                    ? 'Cancelled'
                    : isDelivered
                        ? 'Delivered!'
                        : order.estimatedDeliveryTime ?? 'Calculating...',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: isCancelled
                      ? AppColors.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (!isCancelled && order.status != 'placed')
          _buildOtpBadge(context, order),
      ],
    );
  }

  Widget _buildOtpBadge(BuildContext context, Order order) {
    if (order.status != 'out_for_delivery' && order.status != 'delivered') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Text(
        'OTP: ${order.otpCode ?? '------'}',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
      ),
    );
  }

  Widget _buildRejectedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: const Row(
        children: [
          Icon(Icons.block_outlined, color: AppColors.error, size: 24),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'This order has been cancelled. It remains in your history.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error, size: 24),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Cancelled',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'This order has been cancelled',
                  style: TextStyle(color: AppColors.error.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, int currentStep) {
    return Column(
      children: List.generate(_stepLabels.length, (index) {
        final (title, subtitle) = _stepLabels[index];
        final isDone = index < currentStep;
        final isCurrent = index == currentStep;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDone || isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            width: 6,
                          )
                        : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (index < _stepLabels.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut,
                    width: 2,
                    height: 32,
                    color: isDone
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w800 : (isDone ? FontWeight.bold : FontWeight.normal),
                      fontSize: 14,
                      color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderItems(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: AppSpacing.s12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.foodItem.isVeg ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.foodItem.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '₹${item.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildDeliveryAddress(BuildContext context, Order order) {
    final addr = order.deliveryAddress!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addr.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${addr.addressLine1}${addr.addressLine2 != null ? ', ${addr.addressLine2}' : ''}, ${addr.city}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildOrderSummary(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Bill Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: AppSpacing.s12),
          _summaryRow('Item Total', '₹${order.itemTotal.toStringAsFixed(0)}'),
          _summaryRow('Delivery Fee', '₹${order.deliveryFee.toStringAsFixed(0)}'),
          _summaryRow('Platform Fee', '₹${order.platformFee.toStringAsFixed(0)}'),
          if (order.taxAmount > 0) _summaryRow('GST', '₹${order.taxAmount.toStringAsFixed(0)}'),
          if (order.discountAmount > 0) _summaryRow('Discount', '-₹${order.discountAmount.toStringAsFixed(0)}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(
                '₹${order.grandTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCancelBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: AppShadows.premiumShadow(),
        ),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _cancelOrder,
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            label: const Text('Cancel Order', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
