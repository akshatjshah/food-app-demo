import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Single source of truth for customer order-status presentation.
///
/// REJECTED orders must NEVER disappear: they stay visible in BOTH the
/// Ongoing list (so a just-rejected order is still on screen when the
/// customer returns to Orders) and History. Backend and repository layers
/// must not filter/exclude any status; this split is display-only.
class OrderStatusUi {
  static const ongoingStatuses = <String>{
    'pending_payment',
    'placed',
    'confirmed',
    'preparing',
    'ready',
    'rider_assigned',
    'picked_up',
    'out_for_delivery',
  };

  static const historyStatuses = <String>{
    'delivered',
    'cancelled',
    'rejected',
  };

  /// True for live orders AND rejected ones (rejected stays on screen).
  static bool isOngoing(String status) =>
      ongoingStatuses.contains(status) || status == 'rejected';

  /// True for terminal/unknown statuses. Unknown statuses fall back to
  /// history so they can never disappear from the UI.
  static bool isHistory(String status) =>
      historyStatuses.contains(status) || !ongoingStatuses.contains(status);

  /// Cancel / Track actions are only valid while the order is live.
  /// Rejected (and other terminal) orders must not offer them.
  static bool canCancel(String status) =>
      status == 'placed' || status == 'confirmed';

  static bool canTrack(String status) => ongoingStatuses.contains(status);

  static String label(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Pending Payment';
      case 'placed':
        return 'Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'rider_assigned':
        return 'Rider Assigned';
      case 'picked_up':
        return 'Picked Up';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  /// Placed=blue, Confirmed/Delivered=green, Rejected/Cancelled=red.
  static Color color(String status) {
    switch (status) {
      case 'placed':
        return Colors.blue;
      case 'confirmed':
      case 'delivered':
        return AppColors.success;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.teal;
      case 'rider_assigned':
      case 'picked_up':
      case 'out_for_delivery':
        return AppColors.primary;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}
