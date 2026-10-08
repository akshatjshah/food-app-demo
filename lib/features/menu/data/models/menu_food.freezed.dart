// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuFood {

 String get id; String get name; String? get description; double get price; double? get originalPrice; List<String> get imageUrls; double? get rating; int get reviewsCount; bool get isVeg; bool get isBestseller; bool get isFeatured; bool get isActive; bool get isAvailable; String? get categoryId; String? get categoryName; String? get subcategory; List<String> get mealTags; List<CustomizationGroup> get customizationGroups;
/// Create a copy of MenuFood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuFoodCopyWith<MenuFood> get copyWith => _$MenuFoodCopyWithImpl<MenuFood>(this as MenuFood, _$identity);

  /// Serializes this MenuFood to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuFood&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.isBestseller, isBestseller) || other.isBestseller == isBestseller)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&const DeepCollectionEquality().equals(other.mealTags, mealTags)&&const DeepCollectionEquality().equals(other.customizationGroups, customizationGroups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,originalPrice,const DeepCollectionEquality().hash(imageUrls),rating,reviewsCount,isVeg,isBestseller,isFeatured,isActive,isAvailable,categoryId,categoryName,subcategory,const DeepCollectionEquality().hash(mealTags),const DeepCollectionEquality().hash(customizationGroups));

@override
String toString() {
  return 'MenuFood(id: $id, name: $name, description: $description, price: $price, originalPrice: $originalPrice, imageUrls: $imageUrls, rating: $rating, reviewsCount: $reviewsCount, isVeg: $isVeg, isBestseller: $isBestseller, isFeatured: $isFeatured, isActive: $isActive, isAvailable: $isAvailable, categoryId: $categoryId, categoryName: $categoryName, subcategory: $subcategory, mealTags: $mealTags, customizationGroups: $customizationGroups)';
}


}

/// @nodoc
abstract mixin class $MenuFoodCopyWith<$Res>  {
  factory $MenuFoodCopyWith(MenuFood value, $Res Function(MenuFood) _then) = _$MenuFoodCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, double price, double? originalPrice, List<String> imageUrls, double? rating, int reviewsCount, bool isVeg, bool isBestseller, bool isFeatured, bool isActive, bool isAvailable, String? categoryId, String? categoryName, String? subcategory, List<String> mealTags, List<CustomizationGroup> customizationGroups
});




}
/// @nodoc
class _$MenuFoodCopyWithImpl<$Res>
    implements $MenuFoodCopyWith<$Res> {
  _$MenuFoodCopyWithImpl(this._self, this._then);

  final MenuFood _self;
  final $Res Function(MenuFood) _then;

/// Create a copy of MenuFood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? originalPrice = freezed,Object? imageUrls = null,Object? rating = freezed,Object? reviewsCount = null,Object? isVeg = null,Object? isBestseller = null,Object? isFeatured = null,Object? isActive = null,Object? isAvailable = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? subcategory = freezed,Object? mealTags = null,Object? customizationGroups = null,}) {
  return _then(MenuFood(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,isBestseller: null == isBestseller ? _self.isBestseller : isBestseller // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,mealTags: null == mealTags ? _self.mealTags : mealTags // ignore: cast_nullable_to_non_nullable
as List<String>,customizationGroups: null == customizationGroups ? _self.customizationGroups : customizationGroups // ignore: cast_nullable_to_non_nullable
as List<CustomizationGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuFood].
extension MenuFoodPatterns on MenuFood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuFood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuFood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuFood value)  $default,){
final _that = this;
switch (_that) {
case _MenuFood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuFood value)?  $default,){
final _that = this;
switch (_that) {
case _MenuFood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  double price,  double? originalPrice,  List<String> imageUrls,  double? rating,  int reviewsCount,  bool isVeg,  bool isBestseller,  bool isFeatured,  bool isActive,  bool isAvailable,  String? categoryId,  String? categoryName,  String? subcategory,  List<String> mealTags,  List<CustomizationGroup> customizationGroups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuFood() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.originalPrice,_that.imageUrls,_that.rating,_that.reviewsCount,_that.isVeg,_that.isBestseller,_that.isFeatured,_that.isActive,_that.isAvailable,_that.categoryId,_that.categoryName,_that.subcategory,_that.mealTags,_that.customizationGroups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  double price,  double? originalPrice,  List<String> imageUrls,  double? rating,  int reviewsCount,  bool isVeg,  bool isBestseller,  bool isFeatured,  bool isActive,  bool isAvailable,  String? categoryId,  String? categoryName,  String? subcategory,  List<String> mealTags,  List<CustomizationGroup> customizationGroups)  $default,) {final _that = this;
switch (_that) {
case _MenuFood():
return $default(_that.id,_that.name,_that.description,_that.price,_that.originalPrice,_that.imageUrls,_that.rating,_that.reviewsCount,_that.isVeg,_that.isBestseller,_that.isFeatured,_that.isActive,_that.isAvailable,_that.categoryId,_that.categoryName,_that.subcategory,_that.mealTags,_that.customizationGroups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  double price,  double? originalPrice,  List<String> imageUrls,  double? rating,  int reviewsCount,  bool isVeg,  bool isBestseller,  bool isFeatured,  bool isActive,  bool isAvailable,  String? categoryId,  String? categoryName,  String? subcategory,  List<String> mealTags,  List<CustomizationGroup> customizationGroups)?  $default,) {final _that = this;
switch (_that) {
case _MenuFood() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.originalPrice,_that.imageUrls,_that.rating,_that.reviewsCount,_that.isVeg,_that.isBestseller,_that.isFeatured,_that.isActive,_that.isAvailable,_that.categoryId,_that.categoryName,_that.subcategory,_that.mealTags,_that.customizationGroups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuFood implements MenuFood {
  const _MenuFood({required this.id, required this.name, this.description, required this.price, this.originalPrice,  List<String> imageUrls = const [], this.rating, this.reviewsCount = 0, this.isVeg = true, this.isBestseller = false, this.isFeatured = false, this.isActive = true, this.isAvailable = true, this.categoryId, this.categoryName, this.subcategory,  List<String> mealTags = const [],  List<CustomizationGroup> customizationGroups = const []}): _imageUrls = imageUrls,_mealTags = mealTags,_customizationGroups = customizationGroups;
  factory _MenuFood.fromJson(Map<String, dynamic> json) => _$MenuFoodFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  double price;
@override final  double? originalPrice;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  double? rating;
@override@JsonKey() final  int reviewsCount;
@override@JsonKey() final  bool isVeg;
@override@JsonKey() final  bool isBestseller;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isAvailable;
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? subcategory;
 final  List<String> _mealTags;
@override@JsonKey() List<String> get mealTags {
  if (_mealTags is EqualUnmodifiableListView) return _mealTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mealTags);
}

 final  List<CustomizationGroup> _customizationGroups;
@override@JsonKey() List<CustomizationGroup> get customizationGroups {
  if (_customizationGroups is EqualUnmodifiableListView) return _customizationGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customizationGroups);
}


/// Create a copy of MenuFood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuFoodCopyWith<_MenuFood> get copyWith => __$MenuFoodCopyWithImpl<_MenuFood>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuFoodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuFood&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.isBestseller, isBestseller) || other.isBestseller == isBestseller)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&const DeepCollectionEquality().equals(other._mealTags, _mealTags)&&const DeepCollectionEquality().equals(other._customizationGroups, _customizationGroups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,originalPrice,const DeepCollectionEquality().hash(_imageUrls),rating,reviewsCount,isVeg,isBestseller,isFeatured,isActive,isAvailable,categoryId,categoryName,subcategory,const DeepCollectionEquality().hash(_mealTags),const DeepCollectionEquality().hash(_customizationGroups));

@override
String toString() {
  return 'MenuFood(id: $id, name: $name, description: $description, price: $price, originalPrice: $originalPrice, imageUrls: $imageUrls, rating: $rating, reviewsCount: $reviewsCount, isVeg: $isVeg, isBestseller: $isBestseller, isFeatured: $isFeatured, isActive: $isActive, isAvailable: $isAvailable, categoryId: $categoryId, categoryName: $categoryName, subcategory: $subcategory, mealTags: $mealTags, customizationGroups: $customizationGroups)';
}


}

/// @nodoc
abstract mixin class _$MenuFoodCopyWith<$Res> implements $MenuFoodCopyWith<$Res> {
  factory _$MenuFoodCopyWith(_MenuFood value, $Res Function(_MenuFood) _then) = __$MenuFoodCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, double price, double? originalPrice, List<String> imageUrls, double? rating, int reviewsCount, bool isVeg, bool isBestseller, bool isFeatured, bool isActive, bool isAvailable, String? categoryId, String? categoryName, String? subcategory, List<String> mealTags, List<CustomizationGroup> customizationGroups
});




}
/// @nodoc
class __$MenuFoodCopyWithImpl<$Res>
    implements _$MenuFoodCopyWith<$Res> {
  __$MenuFoodCopyWithImpl(this._self, this._then);

  final _MenuFood _self;
  final $Res Function(_MenuFood) _then;

/// Create a copy of MenuFood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? originalPrice = freezed,Object? imageUrls = null,Object? rating = freezed,Object? reviewsCount = null,Object? isVeg = null,Object? isBestseller = null,Object? isFeatured = null,Object? isActive = null,Object? isAvailable = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? subcategory = freezed,Object? mealTags = null,Object? customizationGroups = null,}) {
  return _then(_MenuFood(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,isBestseller: null == isBestseller ? _self.isBestseller : isBestseller // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,mealTags: null == mealTags ? _self._mealTags : mealTags // ignore: cast_nullable_to_non_nullable
as List<String>,customizationGroups: null == customizationGroups ? _self._customizationGroups : customizationGroups // ignore: cast_nullable_to_non_nullable
as List<CustomizationGroup>,
  ));
}


}


/// @nodoc
mixin _$CustomizationGroup {

 String get id; String get name;@JsonKey(name: 'minSelections') int get minSelect;@JsonKey(name: 'maxSelections') int get maxSelect; List<CustomizationItem> get items;
/// Create a copy of CustomizationGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomizationGroupCopyWith<CustomizationGroup> get copyWith => _$CustomizationGroupCopyWithImpl<CustomizationGroup>(this as CustomizationGroup, _$identity);

  /// Serializes this CustomizationGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomizationGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.minSelect, minSelect) || other.minSelect == minSelect)&&(identical(other.maxSelect, maxSelect) || other.maxSelect == maxSelect)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,minSelect,maxSelect,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CustomizationGroup(id: $id, name: $name, minSelect: $minSelect, maxSelect: $maxSelect, items: $items)';
}


}

/// @nodoc
abstract mixin class $CustomizationGroupCopyWith<$Res>  {
  factory $CustomizationGroupCopyWith(CustomizationGroup value, $Res Function(CustomizationGroup) _then) = _$CustomizationGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'minSelections') int minSelect,@JsonKey(name: 'maxSelections') int maxSelect, List<CustomizationItem> items
});




}
/// @nodoc
class _$CustomizationGroupCopyWithImpl<$Res>
    implements $CustomizationGroupCopyWith<$Res> {
  _$CustomizationGroupCopyWithImpl(this._self, this._then);

  final CustomizationGroup _self;
  final $Res Function(CustomizationGroup) _then;

/// Create a copy of CustomizationGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? minSelect = null,Object? maxSelect = null,Object? items = null,}) {
  return _then(CustomizationGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,minSelect: null == minSelect ? _self.minSelect : minSelect // ignore: cast_nullable_to_non_nullable
as int,maxSelect: null == maxSelect ? _self.maxSelect : maxSelect // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CustomizationItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomizationGroup].
extension CustomizationGroupPatterns on CustomizationGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomizationGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomizationGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomizationGroup value)  $default,){
final _that = this;
switch (_that) {
case _CustomizationGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomizationGroup value)?  $default,){
final _that = this;
switch (_that) {
case _CustomizationGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'minSelections')  int minSelect, @JsonKey(name: 'maxSelections')  int maxSelect,  List<CustomizationItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomizationGroup() when $default != null:
return $default(_that.id,_that.name,_that.minSelect,_that.maxSelect,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'minSelections')  int minSelect, @JsonKey(name: 'maxSelections')  int maxSelect,  List<CustomizationItem> items)  $default,) {final _that = this;
switch (_that) {
case _CustomizationGroup():
return $default(_that.id,_that.name,_that.minSelect,_that.maxSelect,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'minSelections')  int minSelect, @JsonKey(name: 'maxSelections')  int maxSelect,  List<CustomizationItem> items)?  $default,) {final _that = this;
switch (_that) {
case _CustomizationGroup() when $default != null:
return $default(_that.id,_that.name,_that.minSelect,_that.maxSelect,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomizationGroup implements CustomizationGroup {
  const _CustomizationGroup({required this.id, required this.name, @JsonKey(name: 'minSelections') this.minSelect = 0, @JsonKey(name: 'maxSelections') this.maxSelect = 1,  List<CustomizationItem> items = const []}): _items = items;
  factory _CustomizationGroup.fromJson(Map<String, dynamic> json) => _$CustomizationGroupFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'minSelections') final  int minSelect;
@override@JsonKey(name: 'maxSelections') final  int maxSelect;
 final  List<CustomizationItem> _items;
@override@JsonKey() List<CustomizationItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of CustomizationGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomizationGroupCopyWith<_CustomizationGroup> get copyWith => __$CustomizationGroupCopyWithImpl<_CustomizationGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomizationGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomizationGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.minSelect, minSelect) || other.minSelect == minSelect)&&(identical(other.maxSelect, maxSelect) || other.maxSelect == maxSelect)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,minSelect,maxSelect,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'CustomizationGroup(id: $id, name: $name, minSelect: $minSelect, maxSelect: $maxSelect, items: $items)';
}


}

/// @nodoc
abstract mixin class _$CustomizationGroupCopyWith<$Res> implements $CustomizationGroupCopyWith<$Res> {
  factory _$CustomizationGroupCopyWith(_CustomizationGroup value, $Res Function(_CustomizationGroup) _then) = __$CustomizationGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'minSelections') int minSelect,@JsonKey(name: 'maxSelections') int maxSelect, List<CustomizationItem> items
});




}
/// @nodoc
class __$CustomizationGroupCopyWithImpl<$Res>
    implements _$CustomizationGroupCopyWith<$Res> {
  __$CustomizationGroupCopyWithImpl(this._self, this._then);

  final _CustomizationGroup _self;
  final $Res Function(_CustomizationGroup) _then;

/// Create a copy of CustomizationGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? minSelect = null,Object? maxSelect = null,Object? items = null,}) {
  return _then(_CustomizationGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,minSelect: null == minSelect ? _self.minSelect : minSelect // ignore: cast_nullable_to_non_nullable
as int,maxSelect: null == maxSelect ? _self.maxSelect : maxSelect // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CustomizationItem>,
  ));
}


}


/// @nodoc
mixin _$CustomizationItem {

 String get id; String get name; double get additionalPrice; bool get isActive;
/// Create a copy of CustomizationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomizationItemCopyWith<CustomizationItem> get copyWith => _$CustomizationItemCopyWithImpl<CustomizationItem>(this as CustomizationItem, _$identity);

  /// Serializes this CustomizationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomizationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.additionalPrice, additionalPrice) || other.additionalPrice == additionalPrice)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,additionalPrice,isActive);

@override
String toString() {
  return 'CustomizationItem(id: $id, name: $name, additionalPrice: $additionalPrice, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $CustomizationItemCopyWith<$Res>  {
  factory $CustomizationItemCopyWith(CustomizationItem value, $Res Function(CustomizationItem) _then) = _$CustomizationItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, double additionalPrice, bool isActive
});




}
/// @nodoc
class _$CustomizationItemCopyWithImpl<$Res>
    implements $CustomizationItemCopyWith<$Res> {
  _$CustomizationItemCopyWithImpl(this._self, this._then);

  final CustomizationItem _self;
  final $Res Function(CustomizationItem) _then;

/// Create a copy of CustomizationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? additionalPrice = null,Object? isActive = null,}) {
  return _then(CustomizationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,additionalPrice: null == additionalPrice ? _self.additionalPrice : additionalPrice // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomizationItem].
extension CustomizationItemPatterns on CustomizationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomizationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomizationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomizationItem value)  $default,){
final _that = this;
switch (_that) {
case _CustomizationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomizationItem value)?  $default,){
final _that = this;
switch (_that) {
case _CustomizationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double additionalPrice,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomizationItem() when $default != null:
return $default(_that.id,_that.name,_that.additionalPrice,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double additionalPrice,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _CustomizationItem():
return $default(_that.id,_that.name,_that.additionalPrice,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double additionalPrice,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _CustomizationItem() when $default != null:
return $default(_that.id,_that.name,_that.additionalPrice,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomizationItem implements CustomizationItem {
  const _CustomizationItem({required this.id, required this.name, this.additionalPrice = 0.0, this.isActive = true});
  factory _CustomizationItem.fromJson(Map<String, dynamic> json) => _$CustomizationItemFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  double additionalPrice;
@override@JsonKey() final  bool isActive;

/// Create a copy of CustomizationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomizationItemCopyWith<_CustomizationItem> get copyWith => __$CustomizationItemCopyWithImpl<_CustomizationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomizationItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomizationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.additionalPrice, additionalPrice) || other.additionalPrice == additionalPrice)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,additionalPrice,isActive);

@override
String toString() {
  return 'CustomizationItem(id: $id, name: $name, additionalPrice: $additionalPrice, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$CustomizationItemCopyWith<$Res> implements $CustomizationItemCopyWith<$Res> {
  factory _$CustomizationItemCopyWith(_CustomizationItem value, $Res Function(_CustomizationItem) _then) = __$CustomizationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double additionalPrice, bool isActive
});




}
/// @nodoc
class __$CustomizationItemCopyWithImpl<$Res>
    implements _$CustomizationItemCopyWith<$Res> {
  __$CustomizationItemCopyWithImpl(this._self, this._then);

  final _CustomizationItem _self;
  final $Res Function(_CustomizationItem) _then;

/// Create a copy of CustomizationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? additionalPrice = null,Object? isActive = null,}) {
  return _then(_CustomizationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,additionalPrice: null == additionalPrice ? _self.additionalPrice : additionalPrice // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
