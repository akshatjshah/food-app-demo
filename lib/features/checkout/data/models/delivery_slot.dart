/// Delivery slot returned by GET /api/v1/delivery-slots.
///
/// Backend shape (Prisma `DeliverySlot`):
/// `{ id, name, startTime, endTime, maxOrders, isActive, displayOrder, createdAt }`
/// The orders API accepts `deliverySlot` as a free-form string, so [value]
/// (a human-readable label) is what gets sent during order creation.
class DeliverySlot {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final int maxOrders;
  final bool isActive;
  final int displayOrder;

  const DeliverySlot({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.maxOrders = 10,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      maxOrders: (json['maxOrders'] as num?)?.toInt() ?? 10,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  /// Human-readable label, e.g. "Lunch (12:00 - 14:00)".
  /// This is the value sent as `deliverySlot` when creating an order.
  String get label {
    if (startTime.isEmpty || endTime.isEmpty) return name;
    return '$name ($startTime - $endTime)';
  }

  /// Alias for [label] — the string persisted on the order row.
  String get value => label;
}
