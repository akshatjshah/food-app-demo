import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parabdi/core/theme/app_theme.dart';
import 'package:parabdi/features/orders/presentation/order_status_ui.dart';

void main() {
  group('Rejected orders must remain visible', () {
    test('rejected appears in BOTH Ongoing and History (never filtered)', () {
      expect(OrderStatusUi.isOngoing('rejected'), isTrue);
      expect(OrderStatusUi.isHistory('rejected'), isTrue);
    });

    test('rejected display label is "Cancelled" (backend stays rejected)', () {
      expect(OrderStatusUi.label('rejected'), 'Cancelled');
      expect(OrderStatusUi.label('cancelled'), 'Cancelled');
    });

    test('rejected badge color is red', () {
      expect(OrderStatusUi.color('rejected'), AppColors.error);
    });

    test('placed is blue, confirmed is yellow, delivered is green', () {
      expect(OrderStatusUi.color('placed'), Colors.blue);
      expect(OrderStatusUi.color('confirmed'), const Color(0xFFCA8A04));
      expect(OrderStatusUi.color('delivered'), AppColors.success);
      expect(OrderStatusUi.label('placed'), 'Placed');
      expect(OrderStatusUi.label('confirmed'), 'Confirmed');
    });

    test('rejected disables Cancel and Track actions', () {
      expect(OrderStatusUi.canCancel('rejected'), isFalse);
      expect(OrderStatusUi.canTrack('rejected'), isFalse);
      // Live orders keep their actions.
      expect(OrderStatusUi.canCancel('placed'), isTrue);
      expect(OrderStatusUi.canTrack('placed'), isTrue);
    });

    test('unknown statuses fall back to history (never disappear)', () {
      expect(OrderStatusUi.isHistory('some_future_status'), isTrue);
    });

    test('every live status is ongoing; terminal statuses are history', () {
      for (final s in [
        'pending_payment',
        'placed',
        'confirmed',
        'preparing',
        'ready',
        'rider_assigned',
        'picked_up',
        'out_for_delivery',
      ]) {
        expect(OrderStatusUi.isOngoing(s), isTrue, reason: s);
      }
      for (final s in ['delivered', 'cancelled', 'rejected']) {
        expect(OrderStatusUi.isHistory(s), isTrue, reason: s);
      }
    });

    test('legacy ready states display as Out for Delivery', () {
      expect(OrderStatusUi.label('ready'), 'Out for Delivery');
      expect(OrderStatusUi.label('rider_assigned'), 'Out for Delivery');
      expect(OrderStatusUi.label('picked_up'), 'Out for Delivery');
      expect(OrderStatusUi.label('out_for_delivery'), 'Out for Delivery');
    });
  });
}
