// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get id; String get status; double get itemTotal; double get deliveryFee; double get platformFee; double get taxAmount; double get discountAmount; double get grandTotal; DeliveryAddress? get deliveryAddress; String? get paymentMethod; String get paymentStatus; String? get specialInstructions; String? get estimatedDeliveryTime; DateTime? get actualDeliveryTime; String? get otpCode; DateTime get createdAt; DateTime get updatedAt; List<OrderItem> get items;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime)&&(identical(other.actualDeliveryTime, actualDeliveryTime) || other.actualDeliveryTime == actualDeliveryTime)&&(identical(other.otpCode, otpCode) || other.otpCode == otpCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,itemTotal,deliveryFee,platformFee,taxAmount,discountAmount,grandTotal,deliveryAddress,paymentMethod,paymentStatus,specialInstructions,estimatedDeliveryTime,actualDeliveryTime,otpCode,createdAt,updatedAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Order(id: $id, status: $status, itemTotal: $itemTotal, deliveryFee: $deliveryFee, platformFee: $platformFee, taxAmount: $taxAmount, discountAmount: $discountAmount, grandTotal: $grandTotal, deliveryAddress: $deliveryAddress, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, specialInstructions: $specialInstructions, estimatedDeliveryTime: $estimatedDeliveryTime, actualDeliveryTime: $actualDeliveryTime, otpCode: $otpCode, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String status, double itemTotal, double deliveryFee, double platformFee, double taxAmount, double discountAmount, double grandTotal, DeliveryAddress? deliveryAddress, String? paymentMethod, String paymentStatus, String? specialInstructions, String? estimatedDeliveryTime, DateTime? actualDeliveryTime, String? otpCode, DateTime createdAt, DateTime updatedAt, List<OrderItem> items
});


$DeliveryAddressCopyWith<$Res>? get deliveryAddress;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? itemTotal = null,Object? deliveryFee = null,Object? platformFee = null,Object? taxAmount = null,Object? discountAmount = null,Object? grandTotal = null,Object? deliveryAddress = freezed,Object? paymentMethod = freezed,Object? paymentStatus = null,Object? specialInstructions = freezed,Object? estimatedDeliveryTime = freezed,Object? actualDeliveryTime = freezed,Object? otpCode = freezed,Object? createdAt = null,Object? updatedAt = null,Object? items = null,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,estimatedDeliveryTime: freezed == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as String?,actualDeliveryTime: freezed == actualDeliveryTime ? _self.actualDeliveryTime : actualDeliveryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,otpCode: freezed == otpCode ? _self.otpCode : otpCode // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $DeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  double itemTotal,  double deliveryFee,  double platformFee,  double taxAmount,  double discountAmount,  double grandTotal,  DeliveryAddress? deliveryAddress,  String? paymentMethod,  String paymentStatus,  String? specialInstructions,  String? estimatedDeliveryTime,  DateTime? actualDeliveryTime,  String? otpCode,  DateTime createdAt,  DateTime updatedAt,  List<OrderItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.status,_that.itemTotal,_that.deliveryFee,_that.platformFee,_that.taxAmount,_that.discountAmount,_that.grandTotal,_that.deliveryAddress,_that.paymentMethod,_that.paymentStatus,_that.specialInstructions,_that.estimatedDeliveryTime,_that.actualDeliveryTime,_that.otpCode,_that.createdAt,_that.updatedAt,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  double itemTotal,  double deliveryFee,  double platformFee,  double taxAmount,  double discountAmount,  double grandTotal,  DeliveryAddress? deliveryAddress,  String? paymentMethod,  String paymentStatus,  String? specialInstructions,  String? estimatedDeliveryTime,  DateTime? actualDeliveryTime,  String? otpCode,  DateTime createdAt,  DateTime updatedAt,  List<OrderItem> items)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.status,_that.itemTotal,_that.deliveryFee,_that.platformFee,_that.taxAmount,_that.discountAmount,_that.grandTotal,_that.deliveryAddress,_that.paymentMethod,_that.paymentStatus,_that.specialInstructions,_that.estimatedDeliveryTime,_that.actualDeliveryTime,_that.otpCode,_that.createdAt,_that.updatedAt,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  double itemTotal,  double deliveryFee,  double platformFee,  double taxAmount,  double discountAmount,  double grandTotal,  DeliveryAddress? deliveryAddress,  String? paymentMethod,  String paymentStatus,  String? specialInstructions,  String? estimatedDeliveryTime,  DateTime? actualDeliveryTime,  String? otpCode,  DateTime createdAt,  DateTime updatedAt,  List<OrderItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.status,_that.itemTotal,_that.deliveryFee,_that.platformFee,_that.taxAmount,_that.discountAmount,_that.grandTotal,_that.deliveryAddress,_that.paymentMethod,_that.paymentStatus,_that.specialInstructions,_that.estimatedDeliveryTime,_that.actualDeliveryTime,_that.otpCode,_that.createdAt,_that.updatedAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.status, required this.itemTotal, this.deliveryFee = 30.0, this.platformFee = 2.0, this.taxAmount = 0.0, this.discountAmount = 0.0, required this.grandTotal, this.deliveryAddress, this.paymentMethod, this.paymentStatus = 'pending', this.specialInstructions, this.estimatedDeliveryTime, this.actualDeliveryTime, this.otpCode, required this.createdAt, required this.updatedAt,  List<OrderItem> items = const []}): _items = items;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override final  String status;
@override final  double itemTotal;
@override@JsonKey() final  double deliveryFee;
@override@JsonKey() final  double platformFee;
@override@JsonKey() final  double taxAmount;
@override@JsonKey() final  double discountAmount;
@override final  double grandTotal;
@override final  DeliveryAddress? deliveryAddress;
@override final  String? paymentMethod;
@override@JsonKey() final  String paymentStatus;
@override final  String? specialInstructions;
@override final  String? estimatedDeliveryTime;
@override final  DateTime? actualDeliveryTime;
@override final  String? otpCode;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<OrderItem> _items;
@override@JsonKey() List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime)&&(identical(other.actualDeliveryTime, actualDeliveryTime) || other.actualDeliveryTime == actualDeliveryTime)&&(identical(other.otpCode, otpCode) || other.otpCode == otpCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,itemTotal,deliveryFee,platformFee,taxAmount,discountAmount,grandTotal,deliveryAddress,paymentMethod,paymentStatus,specialInstructions,estimatedDeliveryTime,actualDeliveryTime,otpCode,createdAt,updatedAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Order(id: $id, status: $status, itemTotal: $itemTotal, deliveryFee: $deliveryFee, platformFee: $platformFee, taxAmount: $taxAmount, discountAmount: $discountAmount, grandTotal: $grandTotal, deliveryAddress: $deliveryAddress, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, specialInstructions: $specialInstructions, estimatedDeliveryTime: $estimatedDeliveryTime, actualDeliveryTime: $actualDeliveryTime, otpCode: $otpCode, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, double itemTotal, double deliveryFee, double platformFee, double taxAmount, double discountAmount, double grandTotal, DeliveryAddress? deliveryAddress, String? paymentMethod, String paymentStatus, String? specialInstructions, String? estimatedDeliveryTime, DateTime? actualDeliveryTime, String? otpCode, DateTime createdAt, DateTime updatedAt, List<OrderItem> items
});


@override $DeliveryAddressCopyWith<$Res>? get deliveryAddress;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? itemTotal = null,Object? deliveryFee = null,Object? platformFee = null,Object? taxAmount = null,Object? discountAmount = null,Object? grandTotal = null,Object? deliveryAddress = freezed,Object? paymentMethod = freezed,Object? paymentStatus = null,Object? specialInstructions = freezed,Object? estimatedDeliveryTime = freezed,Object? actualDeliveryTime = freezed,Object? otpCode = freezed,Object? createdAt = null,Object? updatedAt = null,Object? items = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,estimatedDeliveryTime: freezed == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as String?,actualDeliveryTime: freezed == actualDeliveryTime ? _self.actualDeliveryTime : actualDeliveryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,otpCode: freezed == otpCode ? _self.otpCode : otpCode // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $DeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}
}


/// @nodoc
mixin _$OrderItem {

 String get id; OrderFoodItem get foodItem; int get quantity; double get unitPrice; double get total; List<OrderCustomization> get customizations;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.foodItem, foodItem) || other.foodItem == foodItem)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.customizations, customizations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,foodItem,quantity,unitPrice,total,const DeepCollectionEquality().hash(customizations));

@override
String toString() {
  return 'OrderItem(id: $id, foodItem: $foodItem, quantity: $quantity, unitPrice: $unitPrice, total: $total, customizations: $customizations)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String id, OrderFoodItem foodItem, int quantity, double unitPrice, double total, List<OrderCustomization> customizations
});


$OrderFoodItemCopyWith<$Res> get foodItem;

}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? foodItem = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? customizations = null,}) {
  return _then(OrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,foodItem: null == foodItem ? _self.foodItem : foodItem // ignore: cast_nullable_to_non_nullable
as OrderFoodItem,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,customizations: null == customizations ? _self.customizations : customizations // ignore: cast_nullable_to_non_nullable
as List<OrderCustomization>,
  ));
}
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderFoodItemCopyWith<$Res> get foodItem {
  
  return $OrderFoodItemCopyWith<$Res>(_self.foodItem, (value) {
    return _then(_self.copyWith(foodItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  OrderFoodItem foodItem,  int quantity,  double unitPrice,  double total,  List<OrderCustomization> customizations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.foodItem,_that.quantity,_that.unitPrice,_that.total,_that.customizations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  OrderFoodItem foodItem,  int quantity,  double unitPrice,  double total,  List<OrderCustomization> customizations)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.id,_that.foodItem,_that.quantity,_that.unitPrice,_that.total,_that.customizations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  OrderFoodItem foodItem,  int quantity,  double unitPrice,  double total,  List<OrderCustomization> customizations)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.foodItem,_that.quantity,_that.unitPrice,_that.total,_that.customizations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({required this.id, required this.foodItem, this.quantity = 1, this.unitPrice = 0.0, this.total = 0.0,  List<OrderCustomization> customizations = const []}): _customizations = customizations;
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  String id;
@override final  OrderFoodItem foodItem;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  double unitPrice;
@override@JsonKey() final  double total;
 final  List<OrderCustomization> _customizations;
@override@JsonKey() List<OrderCustomization> get customizations {
  if (_customizations is EqualUnmodifiableListView) return _customizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customizations);
}


/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.foodItem, foodItem) || other.foodItem == foodItem)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._customizations, _customizations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,foodItem,quantity,unitPrice,total,const DeepCollectionEquality().hash(_customizations));

@override
String toString() {
  return 'OrderItem(id: $id, foodItem: $foodItem, quantity: $quantity, unitPrice: $unitPrice, total: $total, customizations: $customizations)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String id, OrderFoodItem foodItem, int quantity, double unitPrice, double total, List<OrderCustomization> customizations
});


@override $OrderFoodItemCopyWith<$Res> get foodItem;

}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? foodItem = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? customizations = null,}) {
  return _then(_OrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,foodItem: null == foodItem ? _self.foodItem : foodItem // ignore: cast_nullable_to_non_nullable
as OrderFoodItem,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,customizations: null == customizations ? _self._customizations : customizations // ignore: cast_nullable_to_non_nullable
as List<OrderCustomization>,
  ));
}

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderFoodItemCopyWith<$Res> get foodItem {
  
  return $OrderFoodItemCopyWith<$Res>(_self.foodItem, (value) {
    return _then(_self.copyWith(foodItem: value));
  });
}
}


/// @nodoc
mixin _$OrderFoodItem {

 String get id; String get name; List<String> get imageUrls; bool get isVeg;
/// Create a copy of OrderFoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderFoodItemCopyWith<OrderFoodItem> get copyWith => _$OrderFoodItemCopyWithImpl<OrderFoodItem>(this as OrderFoodItem, _$identity);

  /// Serializes this OrderFoodItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderFoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(imageUrls),isVeg);

@override
String toString() {
  return 'OrderFoodItem(id: $id, name: $name, imageUrls: $imageUrls, isVeg: $isVeg)';
}


}

/// @nodoc
abstract mixin class $OrderFoodItemCopyWith<$Res>  {
  factory $OrderFoodItemCopyWith(OrderFoodItem value, $Res Function(OrderFoodItem) _then) = _$OrderFoodItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> imageUrls, bool isVeg
});




}
/// @nodoc
class _$OrderFoodItemCopyWithImpl<$Res>
    implements $OrderFoodItemCopyWith<$Res> {
  _$OrderFoodItemCopyWithImpl(this._self, this._then);

  final OrderFoodItem _self;
  final $Res Function(OrderFoodItem) _then;

/// Create a copy of OrderFoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? imageUrls = null,Object? isVeg = null,}) {
  return _then(OrderFoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderFoodItem].
extension OrderFoodItemPatterns on OrderFoodItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderFoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderFoodItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderFoodItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderFoodItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderFoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderFoodItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> imageUrls,  bool isVeg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderFoodItem() when $default != null:
return $default(_that.id,_that.name,_that.imageUrls,_that.isVeg);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> imageUrls,  bool isVeg)  $default,) {final _that = this;
switch (_that) {
case _OrderFoodItem():
return $default(_that.id,_that.name,_that.imageUrls,_that.isVeg);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> imageUrls,  bool isVeg)?  $default,) {final _that = this;
switch (_that) {
case _OrderFoodItem() when $default != null:
return $default(_that.id,_that.name,_that.imageUrls,_that.isVeg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderFoodItem implements OrderFoodItem {
  const _OrderFoodItem({required this.id, required this.name,  List<String> imageUrls = const [], this.isVeg = true}): _imageUrls = imageUrls;
  factory _OrderFoodItem.fromJson(Map<String, dynamic> json) => _$OrderFoodItemFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  bool isVeg;

/// Create a copy of OrderFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderFoodItemCopyWith<_OrderFoodItem> get copyWith => __$OrderFoodItemCopyWithImpl<_OrderFoodItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderFoodItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderFoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_imageUrls),isVeg);

@override
String toString() {
  return 'OrderFoodItem(id: $id, name: $name, imageUrls: $imageUrls, isVeg: $isVeg)';
}


}

/// @nodoc
abstract mixin class _$OrderFoodItemCopyWith<$Res> implements $OrderFoodItemCopyWith<$Res> {
  factory _$OrderFoodItemCopyWith(_OrderFoodItem value, $Res Function(_OrderFoodItem) _then) = __$OrderFoodItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> imageUrls, bool isVeg
});




}
/// @nodoc
class __$OrderFoodItemCopyWithImpl<$Res>
    implements _$OrderFoodItemCopyWith<$Res> {
  __$OrderFoodItemCopyWithImpl(this._self, this._then);

  final _OrderFoodItem _self;
  final $Res Function(_OrderFoodItem) _then;

/// Create a copy of OrderFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? imageUrls = null,Object? isVeg = null,}) {
  return _then(_OrderFoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OrderCustomization {

 String get id; String get name; double get additionalPrice;
/// Create a copy of OrderCustomization
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCustomizationCopyWith<OrderCustomization> get copyWith => _$OrderCustomizationCopyWithImpl<OrderCustomization>(this as OrderCustomization, _$identity);

  /// Serializes this OrderCustomization to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderCustomization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.additionalPrice, additionalPrice) || other.additionalPrice == additionalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,additionalPrice);

@override
String toString() {
  return 'OrderCustomization(id: $id, name: $name, additionalPrice: $additionalPrice)';
}


}

/// @nodoc
abstract mixin class $OrderCustomizationCopyWith<$Res>  {
  factory $OrderCustomizationCopyWith(OrderCustomization value, $Res Function(OrderCustomization) _then) = _$OrderCustomizationCopyWithImpl;
@useResult
$Res call({
 String id, String name, double additionalPrice
});




}
/// @nodoc
class _$OrderCustomizationCopyWithImpl<$Res>
    implements $OrderCustomizationCopyWith<$Res> {
  _$OrderCustomizationCopyWithImpl(this._self, this._then);

  final OrderCustomization _self;
  final $Res Function(OrderCustomization) _then;

/// Create a copy of OrderCustomization
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? additionalPrice = null,}) {
  return _then(OrderCustomization(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,additionalPrice: null == additionalPrice ? _self.additionalPrice : additionalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderCustomization].
extension OrderCustomizationPatterns on OrderCustomization {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderCustomization value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderCustomization() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderCustomization value)  $default,){
final _that = this;
switch (_that) {
case _OrderCustomization():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderCustomization value)?  $default,){
final _that = this;
switch (_that) {
case _OrderCustomization() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double additionalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderCustomization() when $default != null:
return $default(_that.id,_that.name,_that.additionalPrice);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double additionalPrice)  $default,) {final _that = this;
switch (_that) {
case _OrderCustomization():
return $default(_that.id,_that.name,_that.additionalPrice);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double additionalPrice)?  $default,) {final _that = this;
switch (_that) {
case _OrderCustomization() when $default != null:
return $default(_that.id,_that.name,_that.additionalPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderCustomization implements OrderCustomization {
  const _OrderCustomization({required this.id, required this.name, this.additionalPrice = 0.0});
  factory _OrderCustomization.fromJson(Map<String, dynamic> json) => _$OrderCustomizationFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  double additionalPrice;

/// Create a copy of OrderCustomization
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCustomizationCopyWith<_OrderCustomization> get copyWith => __$OrderCustomizationCopyWithImpl<_OrderCustomization>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderCustomizationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderCustomization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.additionalPrice, additionalPrice) || other.additionalPrice == additionalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,additionalPrice);

@override
String toString() {
  return 'OrderCustomization(id: $id, name: $name, additionalPrice: $additionalPrice)';
}


}

/// @nodoc
abstract mixin class _$OrderCustomizationCopyWith<$Res> implements $OrderCustomizationCopyWith<$Res> {
  factory _$OrderCustomizationCopyWith(_OrderCustomization value, $Res Function(_OrderCustomization) _then) = __$OrderCustomizationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double additionalPrice
});




}
/// @nodoc
class __$OrderCustomizationCopyWithImpl<$Res>
    implements _$OrderCustomizationCopyWith<$Res> {
  __$OrderCustomizationCopyWithImpl(this._self, this._then);

  final _OrderCustomization _self;
  final $Res Function(_OrderCustomization) _then;

/// Create a copy of OrderCustomization
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? additionalPrice = null,}) {
  return _then(_OrderCustomization(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,additionalPrice: null == additionalPrice ? _self.additionalPrice : additionalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$DeliveryAddress {

 String get id; String get label; String get addressLine1; String? get addressLine2; String get city; String get state; String get postalCode; double get latitude; double get longitude; String get phone;
/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<DeliveryAddress> get copyWith => _$DeliveryAddressCopyWithImpl<DeliveryAddress>(this as DeliveryAddress, _$identity);

  /// Serializes this DeliveryAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,addressLine1,addressLine2,city,state,postalCode,latitude,longitude,phone);

@override
String toString() {
  return 'DeliveryAddress(id: $id, label: $label, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, state: $state, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $DeliveryAddressCopyWith<$Res>  {
  factory $DeliveryAddressCopyWith(DeliveryAddress value, $Res Function(DeliveryAddress) _then) = _$DeliveryAddressCopyWithImpl;
@useResult
$Res call({
 String id, String label, String addressLine1, String? addressLine2, String city, String state, String postalCode, double latitude, double longitude, String phone
});




}
/// @nodoc
class _$DeliveryAddressCopyWithImpl<$Res>
    implements $DeliveryAddressCopyWith<$Res> {
  _$DeliveryAddressCopyWithImpl(this._self, this._then);

  final DeliveryAddress _self;
  final $Res Function(DeliveryAddress) _then;

/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? addressLine1 = null,Object? addressLine2 = freezed,Object? city = null,Object? state = null,Object? postalCode = null,Object? latitude = null,Object? longitude = null,Object? phone = null,}) {
  return _then(DeliveryAddress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryAddress].
extension DeliveryAddressPatterns on DeliveryAddress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryAddress value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryAddress():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryAddress value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String addressLine1,  String? addressLine2,  String city,  String state,  String postalCode,  double latitude,  double longitude,  String phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
return $default(_that.id,_that.label,_that.addressLine1,_that.addressLine2,_that.city,_that.state,_that.postalCode,_that.latitude,_that.longitude,_that.phone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String addressLine1,  String? addressLine2,  String city,  String state,  String postalCode,  double latitude,  double longitude,  String phone)  $default,) {final _that = this;
switch (_that) {
case _DeliveryAddress():
return $default(_that.id,_that.label,_that.addressLine1,_that.addressLine2,_that.city,_that.state,_that.postalCode,_that.latitude,_that.longitude,_that.phone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String addressLine1,  String? addressLine2,  String city,  String state,  String postalCode,  double latitude,  double longitude,  String phone)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
return $default(_that.id,_that.label,_that.addressLine1,_that.addressLine2,_that.city,_that.state,_that.postalCode,_that.latitude,_that.longitude,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryAddress extends DeliveryAddress {
  const _DeliveryAddress({required this.id, required this.label, required this.addressLine1, this.addressLine2, required this.city, required this.state, required this.postalCode, this.latitude = 0.0, this.longitude = 0.0, required this.phone}): super._();
  factory _DeliveryAddress.fromJson(Map<String, dynamic> json) => _$DeliveryAddressFromJson(json);

@override final  String id;
@override final  String label;
@override final  String addressLine1;
@override final  String? addressLine2;
@override final  String city;
@override final  String state;
@override final  String postalCode;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override final  String phone;

/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryAddressCopyWith<_DeliveryAddress> get copyWith => __$DeliveryAddressCopyWithImpl<_DeliveryAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,addressLine1,addressLine2,city,state,postalCode,latitude,longitude,phone);

@override
String toString() {
  return 'DeliveryAddress(id: $id, label: $label, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, state: $state, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$DeliveryAddressCopyWith<$Res> implements $DeliveryAddressCopyWith<$Res> {
  factory _$DeliveryAddressCopyWith(_DeliveryAddress value, $Res Function(_DeliveryAddress) _then) = __$DeliveryAddressCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String addressLine1, String? addressLine2, String city, String state, String postalCode, double latitude, double longitude, String phone
});




}
/// @nodoc
class __$DeliveryAddressCopyWithImpl<$Res>
    implements _$DeliveryAddressCopyWith<$Res> {
  __$DeliveryAddressCopyWithImpl(this._self, this._then);

  final _DeliveryAddress _self;
  final $Res Function(_DeliveryAddress) _then;

/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? addressLine1 = null,Object? addressLine2 = freezed,Object? city = null,Object? state = null,Object? postalCode = null,Object? latitude = null,Object? longitude = null,Object? phone = null,}) {
  return _then(_DeliveryAddress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
