import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Single source of truth for customer order-status presentation.
///
/// REJECTED orders must NEVER disappear: they stay visible in BOTH the
/// Ongoing list (so a just-rejected order is still on screen when the
/// customer returns to Orders) and History. Backend and repository layers
/// must not filter/exclude any status; this split is display-only.
class OrderStatusUi {
  // Normal Parabdi flow: placed → confirmed → preparing →
  // out_for_delivery → delivered. Legacy internal states
  // (ready/rider_assigned/picked_up) never appear as distinct labels —
  // they are displayed as "Out for Delivery". Kept in this set only so
  // historically-stranded orders stay visible in Ongoing, never hidden.
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
      // No pickup step exists. Legacy internal states surface
      // as Out for Delivery (matches the 5-step tracking timeline).
      case 'ready':
      case 'rider_assigned':
      case 'picked_up':
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        // Display-only: backend/internal status stays "rejected",
        // but users/admins always see "Cancelled".
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Placed=blue, Confirmed=yellow, Delivered=green, Rejected/Cancelled=red
  /// (displayed as "Cancelled").
  static Color color(String status) {
    switch (status) {
      case 'placed':
        return Colors.blue;
      case 'confirmed':
        // Must be YELLOW (not green): Placed=blue, Confirmed=yellow,
        // Delivered=green, Cancelled(red, incl. backend "rejected")=red.
        return const Color(0xFFCA8A04);
      case 'delivered':
        return AppColors.success;
      case 'preparing':
        return Colors.orange;
      // Legacy ready/rider/picked_up share the delivery color.
      case 'ready':
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
