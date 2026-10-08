// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeData {

 List<BannerItem> get banners; List<HomeCategory> get categories; List<HomeFood> get featuredFoods; List<HomeFood> get bestsellers; List<HomeFood> get healthyPicks;
/// Create a copy of HomeData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDataCopyWith<HomeData> get copyWith => _$HomeDataCopyWithImpl<HomeData>(this as HomeData, _$identity);

  /// Serializes this HomeData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeData&&const DeepCollectionEquality().equals(other.banners, banners)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.featuredFoods, featuredFoods)&&const DeepCollectionEquality().equals(other.bestsellers, bestsellers)&&const DeepCollectionEquality().equals(other.healthyPicks, healthyPicks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(banners),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(featuredFoods),const DeepCollectionEquality().hash(bestsellers),const DeepCollectionEquality().hash(healthyPicks));

@override
String toString() {
  return 'HomeData(banners: $banners, categories: $categories, featuredFoods: $featuredFoods, bestsellers: $bestsellers, healthyPicks: $healthyPicks)';
}


}

/// @nodoc
abstract mixin class $HomeDataCopyWith<$Res>  {
  factory $HomeDataCopyWith(HomeData value, $Res Function(HomeData) _then) = _$HomeDataCopyWithImpl;
@useResult
$Res call({
 List<BannerItem> banners, List<HomeCategory> categories, List<HomeFood> featuredFoods, List<HomeFood> bestsellers, List<HomeFood> healthyPicks
});




}
/// @nodoc
class _$HomeDataCopyWithImpl<$Res>
    implements $HomeDataCopyWith<$Res> {
  _$HomeDataCopyWithImpl(this._self, this._then);

  final HomeData _self;
  final $Res Function(HomeData) _then;

/// Create a copy of HomeData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? banners = null,Object? categories = null,Object? featuredFoods = null,Object? bestsellers = null,Object? healthyPicks = null,}) {
  return _then(HomeData(
banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<BannerItem>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<HomeCategory>,featuredFoods: null == featuredFoods ? _self.featuredFoods : featuredFoods // ignore: cast_nullable_to_non_nullable
as List<HomeFood>,bestsellers: null == bestsellers ? _self.bestsellers : bestsellers // ignore: cast_nullable_to_non_nullable
as List<HomeFood>,healthyPicks: null == healthyPicks ? _self.healthyPicks : healthyPicks // ignore: cast_nullable_to_non_nullable
as List<HomeFood>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeData].
extension HomeDataPatterns on HomeData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeData value)  $default,){
final _that = this;
switch (_that) {
case _HomeData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeData value)?  $default,){
final _that = this;
switch (_that) {
case _HomeData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BannerItem> banners,  List<HomeCategory> categories,  List<HomeFood> featuredFoods,  List<HomeFood> bestsellers,  List<HomeFood> healthyPicks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeData() when $default != null:
return $default(_that.banners,_that.categories,_that.featuredFoods,_that.bestsellers,_that.healthyPicks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BannerItem> banners,  List<HomeCategory> categories,  List<HomeFood> featuredFoods,  List<HomeFood> bestsellers,  List<HomeFood> healthyPicks)  $default,) {final _that = this;
switch (_that) {
case _HomeData():
return $default(_that.banners,_that.categories,_that.featuredFoods,_that.bestsellers,_that.healthyPicks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BannerItem> banners,  List<HomeCategory> categories,  List<HomeFood> featuredFoods,  List<HomeFood> bestsellers,  List<HomeFood> healthyPicks)?  $default,) {final _that = this;
switch (_that) {
case _HomeData() when $default != null:
return $default(_that.banners,_that.categories,_that.featuredFoods,_that.bestsellers,_that.healthyPicks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeData implements HomeData {
  const _HomeData({ List<BannerItem> banners = const [],  List<HomeCategory> categories = const [],  List<HomeFood> featuredFoods = const [],  List<HomeFood> bestsellers = const [],  List<HomeFood> healthyPicks = const []}): _banners = banners,_categories = categories,_featuredFoods = featuredFoods,_bestsellers = bestsellers,_healthyPicks = healthyPicks;
  factory _HomeData.fromJson(Map<String, dynamic> json) => _$HomeDataFromJson(json);

 final  List<BannerItem> _banners;
@override@JsonKey() List<BannerItem> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

 final  List<HomeCategory> _categories;
@override@JsonKey() List<HomeCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<HomeFood> _featuredFoods;
@override@JsonKey() List<HomeFood> get featuredFoods {
  if (_featuredFoods is EqualUnmodifiableListView) return _featuredFoods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_featuredFoods);
}

 final  List<HomeFood> _bestsellers;
@override@JsonKey() List<HomeFood> get bestsellers {
  if (_bestsellers is EqualUnmodifiableListView) return _bestsellers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bestsellers);
}

 final  List<HomeFood> _healthyPicks;
@override@JsonKey() List<HomeFood> get healthyPicks {
  if (_healthyPicks is EqualUnmodifiableListView) return _healthyPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_healthyPicks);
}


/// Create a copy of HomeData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDataCopyWith<_HomeData> get copyWith => __$HomeDataCopyWithImpl<_HomeData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeData&&const DeepCollectionEquality().equals(other._banners, _banners)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._featuredFoods, _featuredFoods)&&const DeepCollectionEquality().equals(other._bestsellers, _bestsellers)&&const DeepCollectionEquality().equals(other._healthyPicks, _healthyPicks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_banners),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_featuredFoods),const DeepCollectionEquality().hash(_bestsellers),const DeepCollectionEquality().hash(_healthyPicks));

@override
String toString() {
  return 'HomeData(banners: $banners, categories: $categories, featuredFoods: $featuredFoods, bestsellers: $bestsellers, healthyPicks: $healthyPicks)';
}


}

/// @nodoc
abstract mixin class _$HomeDataCopyWith<$Res> implements $HomeDataCopyWith<$Res> {
  factory _$HomeDataCopyWith(_HomeData value, $Res Function(_HomeData) _then) = __$HomeDataCopyWithImpl;
@override @useResult
$Res call({
 List<BannerItem> banners, List<HomeCategory> categories, List<HomeFood> featuredFoods, List<HomeFood> bestsellers, List<HomeFood> healthyPicks
});




}
/// @nodoc
class __$HomeDataCopyWithImpl<$Res>
    implements _$HomeDataCopyWith<$Res> {
  __$HomeDataCopyWithImpl(this._self, this._then);

  final _HomeData _self;
  final $Res Function(_HomeData) _then;

/// Create a copy of HomeData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? banners = null,Object? categories = null,Object? featuredFoods = null,Object? bestsellers = null,Object? healthyPicks = null,}) {
  return _then(_HomeData(
banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<BannerItem>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<HomeCategory>,featuredFoods: null == featuredFoods ? _self._featuredFoods : featuredFoods // ignore: cast_nullable_to_non_nullable
as List<HomeFood>,bestsellers: null == bestsellers ? _self._bestsellers : bestsellers // ignore: cast_nullable_to_non_nullable
as List<HomeFood>,healthyPicks: null == healthyPicks ? _self._healthyPicks : healthyPicks // ignore: cast_nullable_to_non_nullable
as List<HomeFood>,
  ));
}


}


/// @nodoc
mixin _$BannerItem {

 String get id; String? get title; String? get imageUrl; String? get link;
/// Create a copy of BannerItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerItemCopyWith<BannerItem> get copyWith => _$BannerItemCopyWithImpl<BannerItem>(this as BannerItem, _$identity);

  /// Serializes this BannerItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,link);

@override
String toString() {
  return 'BannerItem(id: $id, title: $title, imageUrl: $imageUrl, link: $link)';
}


}

/// @nodoc
abstract mixin class $BannerItemCopyWith<$Res>  {
  factory $BannerItemCopyWith(BannerItem value, $Res Function(BannerItem) _then) = _$BannerItemCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? imageUrl, String? link
});




}
/// @nodoc
class _$BannerItemCopyWithImpl<$Res>
    implements $BannerItemCopyWith<$Res> {
  _$BannerItemCopyWithImpl(this._self, this._then);

  final BannerItem _self;
  final $Res Function(BannerItem) _then;

/// Create a copy of BannerItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? imageUrl = freezed,Object? link = freezed,}) {
  return _then(BannerItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BannerItem].
extension BannerItemPatterns on BannerItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerItem value)  $default,){
final _that = this;
switch (_that) {
case _BannerItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerItem value)?  $default,){
final _that = this;
switch (_that) {
case _BannerItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? imageUrl,  String? link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerItem() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? imageUrl,  String? link)  $default,) {final _that = this;
switch (_that) {
case _BannerItem():
return $default(_that.id,_that.title,_that.imageUrl,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? imageUrl,  String? link)?  $default,) {final _that = this;
switch (_that) {
case _BannerItem() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.link);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerItem implements BannerItem {
  const _BannerItem({required this.id, this.title, this.imageUrl, this.link});
  factory _BannerItem.fromJson(Map<String, dynamic> json) => _$BannerItemFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? imageUrl;
@override final  String? link;

/// Create a copy of BannerItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerItemCopyWith<_BannerItem> get copyWith => __$BannerItemCopyWithImpl<_BannerItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,link);

@override
String toString() {
  return 'BannerItem(id: $id, title: $title, imageUrl: $imageUrl, link: $link)';
}


}

/// @nodoc
abstract mixin class _$BannerItemCopyWith<$Res> implements $BannerItemCopyWith<$Res> {
  factory _$BannerItemCopyWith(_BannerItem value, $Res Function(_BannerItem) _then) = __$BannerItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? imageUrl, String? link
});




}
/// @nodoc
class __$BannerItemCopyWithImpl<$Res>
    implements _$BannerItemCopyWith<$Res> {
  __$BannerItemCopyWithImpl(this._self, this._then);

  final _BannerItem _self;
  final $Res Function(_BannerItem) _then;

/// Create a copy of BannerItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? imageUrl = freezed,Object? link = freezed,}) {
  return _then(_BannerItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HomeCategory {

 String get id; String get name; String? get icon; String? get imageUrl; int get foodCount;
/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCategoryCopyWith<HomeCategory> get copyWith => _$HomeCategoryCopyWithImpl<HomeCategory>(this as HomeCategory, _$identity);

  /// Serializes this HomeCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.foodCount, foodCount) || other.foodCount == foodCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,imageUrl,foodCount);

@override
String toString() {
  return 'HomeCategory(id: $id, name: $name, icon: $icon, imageUrl: $imageUrl, foodCount: $foodCount)';
}


}

/// @nodoc
abstract mixin class $HomeCategoryCopyWith<$Res>  {
  factory $HomeCategoryCopyWith(HomeCategory value, $Res Function(HomeCategory) _then) = _$HomeCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? icon, String? imageUrl, int foodCount
});




}
/// @nodoc
class _$HomeCategoryCopyWithImpl<$Res>
    implements $HomeCategoryCopyWith<$Res> {
  _$HomeCategoryCopyWithImpl(this._self, this._then);

  final HomeCategory _self;
  final $Res Function(HomeCategory) _then;

/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? imageUrl = freezed,Object? foodCount = null,}) {
  return _then(HomeCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,foodCount: null == foodCount ? _self.foodCount : foodCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeCategory].
extension HomeCategoryPatterns on HomeCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeCategory value)  $default,){
final _that = this;
switch (_that) {
case _HomeCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeCategory value)?  $default,){
final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? icon,  String? imageUrl,  int foodCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.imageUrl,_that.foodCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? icon,  String? imageUrl,  int foodCount)  $default,) {final _that = this;
switch (_that) {
case _HomeCategory():
return $default(_that.id,_that.name,_that.icon,_that.imageUrl,_that.foodCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? icon,  String? imageUrl,  int foodCount)?  $default,) {final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.imageUrl,_that.foodCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeCategory implements HomeCategory {
  const _HomeCategory({required this.id, required this.name, this.icon, this.imageUrl, this.foodCount = 0});
  factory _HomeCategory.fromJson(Map<String, dynamic> json) => _$HomeCategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? icon;
@override final  String? imageUrl;
@override@JsonKey() final  int foodCount;

/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeCategoryCopyWith<_HomeCategory> get copyWith => __$HomeCategoryCopyWithImpl<_HomeCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.foodCount, foodCount) || other.foodCount == foodCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,imageUrl,foodCount);

@override
String toString() {
  return 'HomeCategory(id: $id, name: $name, icon: $icon, imageUrl: $imageUrl, foodCount: $foodCount)';
}


}

/// @nodoc
abstract mixin class _$HomeCategoryCopyWith<$Res> implements $HomeCategoryCopyWith<$Res> {
  factory _$HomeCategoryCopyWith(_HomeCategory value, $Res Function(_HomeCategory) _then) = __$HomeCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? icon, String? imageUrl, int foodCount
});




}
/// @nodoc
class __$HomeCategoryCopyWithImpl<$Res>
    implements _$HomeCategoryCopyWith<$Res> {
  __$HomeCategoryCopyWithImpl(this._self, this._then);

  final _HomeCategory _self;
  final $Res Function(_HomeCategory) _then;

/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? imageUrl = freezed,Object? foodCount = null,}) {
  return _then(_HomeCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,foodCount: null == foodCount ? _self.foodCount : foodCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HomeFood {

 String get id; String get name; double get price;@JsonKey(name: 'imageUrls') List<String> get imageUrls; double? get rating;@JsonKey(name: 'isVeg') bool get isVeg;@JsonKey(name: 'isBestseller') bool get isBestseller;
/// Create a copy of HomeFood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeFoodCopyWith<HomeFood> get copyWith => _$HomeFoodCopyWithImpl<HomeFood>(this as HomeFood, _$identity);

  /// Serializes this HomeFood to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeFood&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.isBestseller, isBestseller) || other.isBestseller == isBestseller));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,const DeepCollectionEquality().hash(imageUrls),rating,isVeg,isBestseller);

@override
String toString() {
  return 'HomeFood(id: $id, name: $name, price: $price, imageUrls: $imageUrls, rating: $rating, isVeg: $isVeg, isBestseller: $isBestseller)';
}


}

/// @nodoc
abstract mixin class $HomeFoodCopyWith<$Res>  {
  factory $HomeFoodCopyWith(HomeFood value, $Res Function(HomeFood) _then) = _$HomeFoodCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'imageUrls') List<String> imageUrls, double? rating,@JsonKey(name: 'isVeg') bool isVeg,@JsonKey(name: 'isBestseller') bool isBestseller
});




}
/// @nodoc
class _$HomeFoodCopyWithImpl<$Res>
    implements $HomeFoodCopyWith<$Res> {
  _$HomeFoodCopyWithImpl(this._self, this._then);

  final HomeFood _self;
  final $Res Function(HomeFood) _then;

/// Create a copy of HomeFood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrls = null,Object? rating = freezed,Object? isVeg = null,Object? isBestseller = null,}) {
  return _then(HomeFood(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,isBestseller: null == isBestseller ? _self.isBestseller : isBestseller // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeFood].
extension HomeFoodPatterns on HomeFood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeFood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeFood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeFood value)  $default,){
final _that = this;
switch (_that) {
case _HomeFood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeFood value)?  $default,){
final _that = this;
switch (_that) {
case _HomeFood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'imageUrls')  List<String> imageUrls,  double? rating, @JsonKey(name: 'isVeg')  bool isVeg, @JsonKey(name: 'isBestseller')  bool isBestseller)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeFood() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.rating,_that.isVeg,_that.isBestseller);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'imageUrls')  List<String> imageUrls,  double? rating, @JsonKey(name: 'isVeg')  bool isVeg, @JsonKey(name: 'isBestseller')  bool isBestseller)  $default,) {final _that = this;
switch (_that) {
case _HomeFood():
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.rating,_that.isVeg,_that.isBestseller);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price, @JsonKey(name: 'imageUrls')  List<String> imageUrls,  double? rating, @JsonKey(name: 'isVeg')  bool isVeg, @JsonKey(name: 'isBestseller')  bool isBestseller)?  $default,) {final _that = this;
switch (_that) {
case _HomeFood() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrls,_that.rating,_that.isVeg,_that.isBestseller);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeFood implements HomeFood {
  const _HomeFood({required this.id, required this.name, required this.price, @JsonKey(name: 'imageUrls')  List<String> imageUrls = const [], this.rating, @JsonKey(name: 'isVeg') this.isVeg = true, @JsonKey(name: 'isBestseller') this.isBestseller = false}): _imageUrls = imageUrls;
  factory _HomeFood.fromJson(Map<String, dynamic> json) => _$HomeFoodFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
 final  List<String> _imageUrls;
@override@JsonKey(name: 'imageUrls') List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  double? rating;
@override@JsonKey(name: 'isVeg') final  bool isVeg;
@override@JsonKey(name: 'isBestseller') final  bool isBestseller;

/// Create a copy of HomeFood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeFoodCopyWith<_HomeFood> get copyWith => __$HomeFoodCopyWithImpl<_HomeFood>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeFoodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeFood&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.isBestseller, isBestseller) || other.isBestseller == isBestseller));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,const DeepCollectionEquality().hash(_imageUrls),rating,isVeg,isBestseller);

@override
String toString() {
  return 'HomeFood(id: $id, name: $name, price: $price, imageUrls: $imageUrls, rating: $rating, isVeg: $isVeg, isBestseller: $isBestseller)';
}


}

/// @nodoc
abstract mixin class _$HomeFoodCopyWith<$Res> implements $HomeFoodCopyWith<$Res> {
  factory _$HomeFoodCopyWith(_HomeFood value, $Res Function(_HomeFood) _then) = __$HomeFoodCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'imageUrls') List<String> imageUrls, double? rating,@JsonKey(name: 'isVeg') bool isVeg,@JsonKey(name: 'isBestseller') bool isBestseller
});




}
/// @nodoc
class __$HomeFoodCopyWithImpl<$Res>
    implements _$HomeFoodCopyWith<$Res> {
  __$HomeFoodCopyWithImpl(this._self, this._then);

  final _HomeFood _self;
  final $Res Function(_HomeFood) _then;

/// Create a copy of HomeFood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrls = null,Object? rating = freezed,Object? isVeg = null,Object? isBestseller = null,}) {
  return _then(_HomeFood(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,isBestseller: null == isBestseller ? _self.isBestseller : isBestseller // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
