// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartFoodItem {

 String get id; String get name; double get price;@JsonKey(name: 'imageUrls') List<String> get imageUrls;@JsonKey(name: 'isVeg') bool get isVeg;@JsonKey(name: 'preparationTimeMinutes') int get preparationTimeMinutes;
/// Create a copy of CartFoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartFoodItemCopyWith<CartFoodItem> get copyWith => _$CartFoodItemCopyWithImpl<CartFoodItem>(this as CartFoodItem, _$identity);

  /// Serializes this CartFoodItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartFoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.preparationTimeMinutes, preparationTimeMinutes) || other.preparationTimeMinutes == preparationTimeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,const DeepCollectionEquality().hash(imageUrls),isVeg,preparationTimeMinutes);

@override
String toString() {
  return 'CartFoodItem(id: $id, name: $name, price: $price, imageUrls: $imageUrls, isVeg: $isVeg, preparationTimeMinutes: $preparationTimeMinutes)';
}


}

/// @nodoc
abstract mixin class $CartFoodItemCopyWith<$Res>  {
  factory $CartFoodItemCopyWith(CartFoodItem value, $Res Function(CartFoodItem) _then) = _$CartFoodItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'imageUrls') List<String> imageUrls,@JsonKey(name: 'isVeg') bool isVeg,@JsonKey(name: 'preparationTimeMinutes') int preparationTimeMinutes
});




}
/// @nodoc
class _$CartFoodItemCopyWithImpl<$Res>
    implements $CartFoodItemCopyWith<$Res> {
  _$CartFoodItemCopyWithImpl(this._self, this._then);

  final CartFoodItem _self;
  final $Res Function(CartFoodItem) _then;

/// Create a copy of CartFoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrls = null,Object? isVeg = null,Object? preparationTimeMinutes = null,}) {
  return _then(CartFoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,preparationTimeMinutes: null == preparationTimeMinutes ? _self.preparationTimeMinutes : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CartFoodItem].
extension CartFoodItemPatterns on CartFoodItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartFoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartFoodItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartFoodItem value)  $default,){
final _that = this;
switch (_that) {
case _CartFoodItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartFoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartFoodItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'imageUrls')  List<String> imageUrls, @JsonKey(name: 'isVeg')  bool isVeg, @JsonKey(name: 'preparationTimeMinutes')  int preparationTimeMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartFoodItem() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.isVeg,_that.preparationTimeMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'imageUrls')  List<String> imageUrls, @JsonKey(name: 'isVeg')  bool isVeg, @JsonKey(name: 'preparationTimeMinutes')  int preparationTimeMinutes)  $default,) {final _that = this;
switch (_that) {
case _CartFoodItem():
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.isVeg,_that.preparationTimeMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price, @JsonKey(name: 'imageUrls')  List<String> imageUrls, @JsonKey(name: 'isVeg')  bool isVeg, @JsonKey(name: 'preparationTimeMinutes')  int preparationTimeMinutes)?  $default,) {final _that = this;
switch (_that) {
case _CartFoodItem() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.isVeg,_that.preparationTimeMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartFoodItem implements CartFoodItem {
  const _CartFoodItem({required this.id, required this.name, required this.price, @JsonKey(name: 'imageUrls')  List<String> imageUrls = const [], @JsonKey(name: 'isVeg') this.isVeg = true, @JsonKey(name: 'preparationTimeMinutes') this.preparationTimeMinutes = 20}): _imageUrls = imageUrls;
  factory _CartFoodItem.fromJson(Map<String, dynamic> json) => _$CartFoodItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
 final  List<String> _imageUrls;
@override@JsonKey(name: 'imageUrls') List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey(name: 'isVeg') final  bool isVeg;
@override@JsonKey(name: 'preparationTimeMinutes') final  int preparationTimeMinutes;

/// Create a copy of CartFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartFoodItemCopyWith<_CartFoodItem> get copyWith => __$CartFoodItemCopyWithImpl<_CartFoodItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartFoodItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartFoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.preparationTimeMinutes, preparationTimeMinutes) || other.preparationTimeMinutes == preparationTimeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,const DeepCollectionEquality().hash(_imageUrls),isVeg,preparationTimeMinutes);

@override
String toString() {
  return 'CartFoodItem(id: $id, name: $name, price: $price, imageUrls: $imageUrls, isVeg: $isVeg, preparationTimeMinutes: $preparationTimeMinutes)';
}


}

/// @nodoc
abstract mixin class _$CartFoodItemCopyWith<$Res> implements $CartFoodItemCopyWith<$Res> {
  factory _$CartFoodItemCopyWith(_CartFoodItem value, $Res Function(_CartFoodItem) _then) = __$CartFoodItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'imageUrls') List<String> imageUrls,@JsonKey(name: 'isVeg') bool isVeg,@JsonKey(name: 'preparationTimeMinutes') int preparationTimeMinutes
});




}
/// @nodoc
class __$CartFoodItemCopyWithImpl<$Res>
    implements _$CartFoodItemCopyWith<$Res> {
  __$CartFoodItemCopyWithImpl(this._self, this._then);

  final _CartFoodItem _self;
  final $Res Function(_CartFoodItem) _then;

/// Create a copy of CartFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrls = null,Object? isVeg = null,Object? preparationTimeMinutes = null,}) {
  return _then(_CartFoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,preparationTimeMinutes: null == preparationTimeMinutes ? _self.preparationTimeMinutes : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CartItem {

 String get id;@JsonKey(name: 'foodItemId') String get foodItemId; int get quantity;@JsonKey(name: 'customizationItems') List<SelectedCustomization> get customizationItems;@JsonKey(name: 'specialInstructions') String? get specialInstructions;@JsonKey(name: 'createdAt') DateTime get createdAt;@JsonKey(name: 'foodItem') CartFoodItem get foodItem;@JsonKey(name: 'unitPrice') double get unitPrice;@JsonKey(name: 'itemTotal') double get itemTotal;@JsonKey(name: 'isAvailable') bool get isAvailable;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.foodItemId, foodItemId) || other.foodItemId == foodItemId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.customizationItems, customizationItems)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.foodItem, foodItem) || other.foodItem == foodItem)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,foodItemId,quantity,const DeepCollectionEquality().hash(customizationItems),specialInstructions,createdAt,foodItem,unitPrice,itemTotal,isAvailable);

@override
String toString() {
  return 'CartItem(id: $id, foodItemId: $foodItemId, quantity: $quantity, customizationItems: $customizationItems, specialInstructions: $specialInstructions, createdAt: $createdAt, foodItem: $foodItem, unitPrice: $unitPrice, itemTotal: $itemTotal, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'foodItemId') String foodItemId, int quantity,@JsonKey(name: 'customizationItems') List<SelectedCustomization> customizationItems,@JsonKey(name: 'specialInstructions') String? specialInstructions,@JsonKey(name: 'createdAt') DateTime createdAt,@JsonKey(name: 'foodItem') CartFoodItem foodItem,@JsonKey(name: 'unitPrice') double unitPrice,@JsonKey(name: 'itemTotal') double itemTotal,@JsonKey(name: 'isAvailable') bool isAvailable
});


$CartFoodItemCopyWith<$Res> get foodItem;

}
/// @nodoc
class _$CartItemCopyWithImpl<$Res>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? foodItemId = null,Object? quantity = null,Object? customizationItems = null,Object? specialInstructions = freezed,Object? createdAt = null,Object? foodItem = null,Object? unitPrice = null,Object? itemTotal = null,Object? isAvailable = null,}) {
  return _then(CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,foodItemId: null == foodItemId ? _self.foodItemId : foodItemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,customizationItems: null == customizationItems ? _self.customizationItems : customizationItems // ignore: cast_nullable_to_non_nullable
as List<SelectedCustomization>,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,foodItem: null == foodItem ? _self.foodItem : foodItem // ignore: cast_nullable_to_non_nullable
as CartFoodItem,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartFoodItemCopyWith<$Res> get foodItem {
  
  return $CartFoodItemCopyWith<$Res>(_self.foodItem, (value) {
    return _then(_self.copyWith(foodItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItem value)  $default,){
final _that = this;
switch (_that) {
case _CartItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'foodItemId')  String foodItemId,  int quantity, @JsonKey(name: 'customizationItems')  List<SelectedCustomization> customizationItems, @JsonKey(name: 'specialInstructions')  String? specialInstructions, @JsonKey(name: 'createdAt')  DateTime createdAt, @JsonKey(name: 'foodItem')  CartFoodItem foodItem, @JsonKey(name: 'unitPrice')  double unitPrice, @JsonKey(name: 'itemTotal')  double itemTotal, @JsonKey(name: 'isAvailable')  bool isAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.foodItemId,_that.quantity,_that.customizationItems,_that.specialInstructions,_that.createdAt,_that.foodItem,_that.unitPrice,_that.itemTotal,_that.isAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'foodItemId')  String foodItemId,  int quantity, @JsonKey(name: 'customizationItems')  List<SelectedCustomization> customizationItems, @JsonKey(name: 'specialInstructions')  String? specialInstructions, @JsonKey(name: 'createdAt')  DateTime createdAt, @JsonKey(name: 'foodItem')  CartFoodItem foodItem, @JsonKey(name: 'unitPrice')  double unitPrice, @JsonKey(name: 'itemTotal')  double itemTotal, @JsonKey(name: 'isAvailable')  bool isAvailable)  $default,) {final _that = this;
switch (_that) {
case _CartItem():
return $default(_that.id,_that.foodItemId,_that.quantity,_that.customizationItems,_that.specialInstructions,_that.createdAt,_that.foodItem,_that.unitPrice,_that.itemTotal,_that.isAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'foodItemId')  String foodItemId,  int quantity, @JsonKey(name: 'customizationItems')  List<SelectedCustomization> customizationItems, @JsonKey(name: 'specialInstructions')  String? specialInstructions, @JsonKey(name: 'createdAt')  DateTime createdAt, @JsonKey(name: 'foodItem')  CartFoodItem foodItem, @JsonKey(name: 'unitPrice')  double unitPrice, @JsonKey(name: 'itemTotal')  double itemTotal, @JsonKey(name: 'isAvailable')  bool isAvailable)?  $default,) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.foodItemId,_that.quantity,_that.customizationItems,_that.specialInstructions,_that.createdAt,_that.foodItem,_that.unitPrice,_that.itemTotal,_that.isAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItem implements CartItem {
  const _CartItem({required this.id, @JsonKey(name: 'foodItemId') required this.foodItemId, required this.quantity, @JsonKey(name: 'customizationItems')  List<SelectedCustomization> customizationItems = const [], @JsonKey(name: 'specialInstructions') this.specialInstructions, @JsonKey(name: 'createdAt') required this.createdAt, @JsonKey(name: 'foodItem') required this.foodItem, @JsonKey(name: 'unitPrice') required this.unitPrice, @JsonKey(name: 'itemTotal') required this.itemTotal, @JsonKey(name: 'isAvailable') this.isAvailable = true}): _customizationItems = customizationItems;
  factory _CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'foodItemId') final  String foodItemId;
@override final  int quantity;
 final  List<SelectedCustomization> _customizationItems;
@override@JsonKey(name: 'customizationItems') List<SelectedCustomization> get customizationItems {
  if (_customizationItems is EqualUnmodifiableListView) return _customizationItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customizationItems);
}

@override@JsonKey(name: 'specialInstructions') final  String? specialInstructions;
@override@JsonKey(name: 'createdAt') final  DateTime createdAt;
@override@JsonKey(name: 'foodItem') final  CartFoodItem foodItem;
@override@JsonKey(name: 'unitPrice') final  double unitPrice;
@override@JsonKey(name: 'itemTotal') final  double itemTotal;
@override@JsonKey(name: 'isAvailable') final  bool isAvailable;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemCopyWith<_CartItem> get copyWith => __$CartItemCopyWithImpl<_CartItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.foodItemId, foodItemId) || other.foodItemId == foodItemId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other._customizationItems, _customizationItems)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.foodItem, foodItem) || other.foodItem == foodItem)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,foodItemId,quantity,const DeepCollectionEquality().hash(_customizationItems),specialInstructions,createdAt,foodItem,unitPrice,itemTotal,isAvailable);

@override
String toString() {
  return 'CartItem(id: $id, foodItemId: $foodItemId, quantity: $quantity, customizationItems: $customizationItems, specialInstructions: $specialInstructions, createdAt: $createdAt, foodItem: $foodItem, unitPrice: $unitPrice, itemTotal: $itemTotal, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) = __$CartItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'foodItemId') String foodItemId, int quantity,@JsonKey(name: 'customizationItems') List<SelectedCustomization> customizationItems,@JsonKey(name: 'specialInstructions') String? specialInstructions,@JsonKey(name: 'createdAt') DateTime createdAt,@JsonKey(name: 'foodItem') CartFoodItem foodItem,@JsonKey(name: 'unitPrice') double unitPrice,@JsonKey(name: 'itemTotal') double itemTotal,@JsonKey(name: 'isAvailable') bool isAvailable
});


@override $CartFoodItemCopyWith<$Res> get foodItem;

}
/// @nodoc
class __$CartItemCopyWithImpl<$Res>
    implements _$CartItemCopyWith<$Res> {
  __$CartItemCopyWithImpl(this._self, this._then);

  final _CartItem _self;
  final $Res Function(_CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? foodItemId = null,Object? quantity = null,Object? customizationItems = null,Object? specialInstructions = freezed,Object? createdAt = null,Object? foodItem = null,Object? unitPrice = null,Object? itemTotal = null,Object? isAvailable = null,}) {
  return _then(_CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,foodItemId: null == foodItemId ? _self.foodItemId : foodItemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,customizationItems: null == customizationItems ? _self._customizationItems : customizationItems // ignore: cast_nullable_to_non_nullable
as List<SelectedCustomization>,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,foodItem: null == foodItem ? _self.foodItem : foodItem // ignore: cast_nullable_to_non_nullable
as CartFoodItem,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartFoodItemCopyWith<$Res> get foodItem {
  
  return $CartFoodItemCopyWith<$Res>(_self.foodItem, (value) {
    return _then(_self.copyWith(foodItem: value));
  });
}
}


/// @nodoc
mixin _$Cart {

 String get id; List<CartItem> get items;@JsonKey(name: 'unavailableItems') List<CartItem> get unavailableItems;@JsonKey(name: 'itemTotal') double get itemTotal;@JsonKey(name: 'itemCount') int get itemCount;@JsonKey(name: 'hasUnavailableItems') bool get hasUnavailableItems;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.unavailableItems, unavailableItems)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.hasUnavailableItems, hasUnavailableItems) || other.hasUnavailableItems == hasUnavailableItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(unavailableItems),itemTotal,itemCount,hasUnavailableItems);

@override
String toString() {
  return 'Cart(id: $id, items: $items, unavailableItems: $unavailableItems, itemTotal: $itemTotal, itemCount: $itemCount, hasUnavailableItems: $hasUnavailableItems)';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
 String id, List<CartItem> items,@JsonKey(name: 'unavailableItems') List<CartItem> unavailableItems,@JsonKey(name: 'itemTotal') double itemTotal,@JsonKey(name: 'itemCount') int itemCount,@JsonKey(name: 'hasUnavailableItems') bool hasUnavailableItems
});




}
/// @nodoc
class _$CartCopyWithImpl<$Res>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? unavailableItems = null,Object? itemTotal = null,Object? itemCount = null,Object? hasUnavailableItems = null,}) {
  return _then(Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,unavailableItems: null == unavailableItems ? _self.unavailableItems : unavailableItems // ignore: cast_nullable_to_non_nullable
as List<CartItem>,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as double,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,hasUnavailableItems: null == hasUnavailableItems ? _self.hasUnavailableItems : hasUnavailableItems // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cart value)  $default,){
final _that = this;
switch (_that) {
case _Cart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cart value)?  $default,){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<CartItem> items, @JsonKey(name: 'unavailableItems')  List<CartItem> unavailableItems, @JsonKey(name: 'itemTotal')  double itemTotal, @JsonKey(name: 'itemCount')  int itemCount, @JsonKey(name: 'hasUnavailableItems')  bool hasUnavailableItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.unavailableItems,_that.itemTotal,_that.itemCount,_that.hasUnavailableItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<CartItem> items, @JsonKey(name: 'unavailableItems')  List<CartItem> unavailableItems, @JsonKey(name: 'itemTotal')  double itemTotal, @JsonKey(name: 'itemCount')  int itemCount, @JsonKey(name: 'hasUnavailableItems')  bool hasUnavailableItems)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.id,_that.items,_that.unavailableItems,_that.itemTotal,_that.itemCount,_that.hasUnavailableItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<CartItem> items, @JsonKey(name: 'unavailableItems')  List<CartItem> unavailableItems, @JsonKey(name: 'itemTotal')  double itemTotal, @JsonKey(name: 'itemCount')  int itemCount, @JsonKey(name: 'hasUnavailableItems')  bool hasUnavailableItems)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.unavailableItems,_that.itemTotal,_that.itemCount,_that.hasUnavailableItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cart implements Cart {
  const _Cart({required this.id,  List<CartItem> items = const [], @JsonKey(name: 'unavailableItems')  List<CartItem> unavailableItems = const [], @JsonKey(name: 'itemTotal') this.itemTotal = 0.0, @JsonKey(name: 'itemCount') this.itemCount = 0, @JsonKey(name: 'hasUnavailableItems') this.hasUnavailableItems = false}): _items = items,_unavailableItems = unavailableItems;
  factory _Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

@override final  String id;
 final  List<CartItem> _items;
@override@JsonKey() List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<CartItem> _unavailableItems;
@override@JsonKey(name: 'unavailableItems') List<CartItem> get unavailableItems {
  if (_unavailableItems is EqualUnmodifiableListView) return _unavailableItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unavailableItems);
}

@override@JsonKey(name: 'itemTotal') final  double itemTotal;
@override@JsonKey(name: 'itemCount') final  int itemCount;
@override@JsonKey(name: 'hasUnavailableItems') final  bool hasUnavailableItems;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartCopyWith<_Cart> get copyWith => __$CartCopyWithImpl<_Cart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._unavailableItems, _unavailableItems)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.hasUnavailableItems, hasUnavailableItems) || other.hasUnavailableItems == hasUnavailableItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_unavailableItems),itemTotal,itemCount,hasUnavailableItems);

@override
String toString() {
  return 'Cart(id: $id, items: $items, unavailableItems: $unavailableItems, itemTotal: $itemTotal, itemCount: $itemCount, hasUnavailableItems: $hasUnavailableItems)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
 String id, List<CartItem> items,@JsonKey(name: 'unavailableItems') List<CartItem> unavailableItems,@JsonKey(name: 'itemTotal') double itemTotal,@JsonKey(name: 'itemCount') int itemCount,@JsonKey(name: 'hasUnavailableItems') bool hasUnavailableItems
});




}
/// @nodoc
class __$CartCopyWithImpl<$Res>
    implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? unavailableItems = null,Object? itemTotal = null,Object? itemCount = null,Object? hasUnavailableItems = null,}) {
  return _then(_Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,unavailableItems: null == unavailableItems ? _self._unavailableItems : unavailableItems // ignore: cast_nullable_to_non_nullable
as List<CartItem>,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as double,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,hasUnavailableItems: null == hasUnavailableItems ? _self.hasUnavailableItems : hasUnavailableItems // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
