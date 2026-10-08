// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wishlist_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WishlistItem {

 String get id;@JsonKey(name: 'food_item') WishlistFoodItem get foodItem;
/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistItemCopyWith<WishlistItem> get copyWith => _$WishlistItemCopyWithImpl<WishlistItem>(this as WishlistItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.foodItem, foodItem) || other.foodItem == foodItem));
}


@override
int get hashCode => Object.hash(runtimeType,id,foodItem);

@override
String toString() {
  return 'WishlistItem(id: $id, foodItem: $foodItem)';
}


}

/// @nodoc
abstract mixin class $WishlistItemCopyWith<$Res>  {
  factory $WishlistItemCopyWith(WishlistItem value, $Res Function(WishlistItem) _then) = _$WishlistItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'food_item') WishlistFoodItem foodItem
});


$WishlistFoodItemCopyWith<$Res> get foodItem;

}
/// @nodoc
class _$WishlistItemCopyWithImpl<$Res>
    implements $WishlistItemCopyWith<$Res> {
  _$WishlistItemCopyWithImpl(this._self, this._then);

  final WishlistItem _self;
  final $Res Function(WishlistItem) _then;

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? foodItem = null,}) {
  return _then(WishlistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,foodItem: null == foodItem ? _self.foodItem : foodItem // ignore: cast_nullable_to_non_nullable
as WishlistFoodItem,
  ));
}
/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WishlistFoodItemCopyWith<$Res> get foodItem {
  
  return $WishlistFoodItemCopyWith<$Res>(_self.foodItem, (value) {
    return _then(_self.copyWith(foodItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [WishlistItem].
extension WishlistItemPatterns on WishlistItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistItem value)  $default,){
final _that = this;
switch (_that) {
case _WishlistItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistItem value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'food_item')  WishlistFoodItem foodItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
return $default(_that.id,_that.foodItem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'food_item')  WishlistFoodItem foodItem)  $default,) {final _that = this;
switch (_that) {
case _WishlistItem():
return $default(_that.id,_that.foodItem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'food_item')  WishlistFoodItem foodItem)?  $default,) {final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
return $default(_that.id,_that.foodItem);case _:
  return null;

}
}

}

/// @nodoc


class _WishlistItem implements WishlistItem {
  const _WishlistItem({required this.id, @JsonKey(name: 'food_item') required this.foodItem});
  

@override final  String id;
@override@JsonKey(name: 'food_item') final  WishlistFoodItem foodItem;

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistItemCopyWith<_WishlistItem> get copyWith => __$WishlistItemCopyWithImpl<_WishlistItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.foodItem, foodItem) || other.foodItem == foodItem));
}


@override
int get hashCode => Object.hash(runtimeType,id,foodItem);

@override
String toString() {
  return 'WishlistItem(id: $id, foodItem: $foodItem)';
}


}

/// @nodoc
abstract mixin class _$WishlistItemCopyWith<$Res> implements $WishlistItemCopyWith<$Res> {
  factory _$WishlistItemCopyWith(_WishlistItem value, $Res Function(_WishlistItem) _then) = __$WishlistItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'food_item') WishlistFoodItem foodItem
});


@override $WishlistFoodItemCopyWith<$Res> get foodItem;

}
/// @nodoc
class __$WishlistItemCopyWithImpl<$Res>
    implements _$WishlistItemCopyWith<$Res> {
  __$WishlistItemCopyWithImpl(this._self, this._then);

  final _WishlistItem _self;
  final $Res Function(_WishlistItem) _then;

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? foodItem = null,}) {
  return _then(_WishlistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,foodItem: null == foodItem ? _self.foodItem : foodItem // ignore: cast_nullable_to_non_nullable
as WishlistFoodItem,
  ));
}

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WishlistFoodItemCopyWith<$Res> get foodItem {
  
  return $WishlistFoodItemCopyWith<$Res>(_self.foodItem, (value) {
    return _then(_self.copyWith(foodItem: value));
  });
}
}

/// @nodoc
mixin _$WishlistFoodItem {

 String get id; String get name; double get price;@JsonKey(name: 'image_urls') List<String> get imageUrls; double? get rating;@JsonKey(name: 'is_veg') bool get isVeg;
/// Create a copy of WishlistFoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistFoodItemCopyWith<WishlistFoodItem> get copyWith => _$WishlistFoodItemCopyWithImpl<WishlistFoodItem>(this as WishlistFoodItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistFoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,price,const DeepCollectionEquality().hash(imageUrls),rating,isVeg);

@override
String toString() {
  return 'WishlistFoodItem(id: $id, name: $name, price: $price, imageUrls: $imageUrls, rating: $rating, isVeg: $isVeg)';
}


}

/// @nodoc
abstract mixin class $WishlistFoodItemCopyWith<$Res>  {
  factory $WishlistFoodItemCopyWith(WishlistFoodItem value, $Res Function(WishlistFoodItem) _then) = _$WishlistFoodItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'image_urls') List<String> imageUrls, double? rating,@JsonKey(name: 'is_veg') bool isVeg
});




}
/// @nodoc
class _$WishlistFoodItemCopyWithImpl<$Res>
    implements $WishlistFoodItemCopyWith<$Res> {
  _$WishlistFoodItemCopyWithImpl(this._self, this._then);

  final WishlistFoodItem _self;
  final $Res Function(WishlistFoodItem) _then;

/// Create a copy of WishlistFoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrls = null,Object? rating = freezed,Object? isVeg = null,}) {
  return _then(WishlistFoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WishlistFoodItem].
extension WishlistFoodItemPatterns on WishlistFoodItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistFoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistFoodItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistFoodItem value)  $default,){
final _that = this;
switch (_that) {
case _WishlistFoodItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistFoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistFoodItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'image_urls')  List<String> imageUrls,  double? rating, @JsonKey(name: 'is_veg')  bool isVeg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistFoodItem() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.rating,_that.isVeg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'image_urls')  List<String> imageUrls,  double? rating, @JsonKey(name: 'is_veg')  bool isVeg)  $default,) {final _that = this;
switch (_that) {
case _WishlistFoodItem():
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.rating,_that.isVeg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price, @JsonKey(name: 'image_urls')  List<String> imageUrls,  double? rating, @JsonKey(name: 'is_veg')  bool isVeg)?  $default,) {final _that = this;
switch (_that) {
case _WishlistFoodItem() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.rating,_that.isVeg);case _:
  return null;

}
}

}

/// @nodoc


class _WishlistFoodItem implements WishlistFoodItem {
  const _WishlistFoodItem({required this.id, required this.name, required this.price, @JsonKey(name: 'image_urls')  List<String> imageUrls = const [], this.rating, @JsonKey(name: 'is_veg') this.isVeg = true}): _imageUrls = imageUrls;
  

@override final  String id;
@override final  String name;
@override final  double price;
 final  List<String> _imageUrls;
@override@JsonKey(name: 'image_urls') List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  double? rating;
@override@JsonKey(name: 'is_veg') final  bool isVeg;

/// Create a copy of WishlistFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistFoodItemCopyWith<_WishlistFoodItem> get copyWith => __$WishlistFoodItemCopyWithImpl<_WishlistFoodItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistFoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,price,const DeepCollectionEquality().hash(_imageUrls),rating,isVeg);

@override
String toString() {
  return 'WishlistFoodItem(id: $id, name: $name, price: $price, imageUrls: $imageUrls, rating: $rating, isVeg: $isVeg)';
}


}

/// @nodoc
abstract mixin class _$WishlistFoodItemCopyWith<$Res> implements $WishlistFoodItemCopyWith<$Res> {
  factory _$WishlistFoodItemCopyWith(_WishlistFoodItem value, $Res Function(_WishlistFoodItem) _then) = __$WishlistFoodItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'image_urls') List<String> imageUrls, double? rating,@JsonKey(name: 'is_veg') bool isVeg
});




}
/// @nodoc
class __$WishlistFoodItemCopyWithImpl<$Res>
    implements _$WishlistFoodItemCopyWith<$Res> {
  __$WishlistFoodItemCopyWithImpl(this._self, this._then);

  final _WishlistFoodItem _self;
  final $Res Function(_WishlistFoodItem) _then;

/// Create a copy of WishlistFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrls = null,Object? rating = freezed,Object? isVeg = null,}) {
  return _then(_WishlistFoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
