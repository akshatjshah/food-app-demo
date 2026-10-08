// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  status: json['status'] as String,
  itemTotal: (json['itemTotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 30.0,
  platformFee: (json['platformFee'] as num?)?.toDouble() ?? 2.0,
  taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
  grandTotal: (json['grandTotal'] as num).toDouble(),
  deliveryAddress: json['deliveryAddress'] == null
      ? null
      : DeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>,
        ),
  paymentMethod: json['paymentMethod'] as String?,
  paymentStatus: json['paymentStatus'] as String? ?? 'pending',
  specialInstructions: json['specialInstructions'] as String?,
  estimatedDeliveryTime: json['estimatedDeliveryTime'] as String?,
  actualDeliveryTime: json['actualDeliveryTime'] == null
      ? null
      : DateTime.parse(json['actualDeliveryTime'] as String),
  otpCode: json['otpCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'itemTotal': instance.itemTotal,
  'deliveryFee': instance.deliveryFee,
  'platformFee': instance.platformFee,
  'taxAmount': instance.taxAmount,
  'discountAmount': instance.discountAmount,
  'grandTotal': instance.grandTotal,
  'deliveryAddress': instance.deliveryAddress,
  'paymentMethod': instance.paymentMethod,
  'paymentStatus': instance.paymentStatus,
  'specialInstructions': instance.specialInstructions,
  'estimatedDeliveryTime': instance.estimatedDeliveryTime,
  'actualDeliveryTime': instance.actualDeliveryTime?.toIso8601String(),
  'otpCode': instance.otpCode,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'items': instance.items,
};

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: json['id'] as String,
  foodItem: OrderFoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num?)?.toDouble() ?? 0.0,
  customizations:
      (json['customizations'] as List<dynamic>?)
          ?.map((e) => OrderCustomization.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'foodItem': instance.foodItem,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
      'customizations': instance.customizations,
    };

_OrderFoodItem _$OrderFoodItemFromJson(Map<String, dynamic> json) =>
    _OrderFoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isVeg: json['isVeg'] as bool? ?? true,
    );

Map<String, dynamic> _$OrderFoodItemToJson(_OrderFoodItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrls': instance.imageUrls,
      'isVeg': instance.isVeg,
    };

_OrderCustomization _$OrderCustomizationFromJson(Map<String, dynamic> json) =>
    _OrderCustomization(
      id: json['id'] as String,
      name: json['name'] as String,
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$OrderCustomizationToJson(_OrderCustomization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'additionalPrice': instance.additionalPrice,
    };

_DeliveryAddress _$DeliveryAddressFromJson(Map<String, dynamic> json) =>
    _DeliveryAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$DeliveryAddressToJson(_DeliveryAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
    };
