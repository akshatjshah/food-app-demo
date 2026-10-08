// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'short_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShortItem {

 String get id; String? get title; String? get description;@JsonKey(name: 'video_url') String? get videoUrl;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'likes_count') int get likesCount;@JsonKey(name: 'views_count') int get viewsCount;@JsonKey(name: 'is_liked') bool get isLiked;
/// Create a copy of ShortItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShortItemCopyWith<ShortItem> get copyWith => _$ShortItemCopyWithImpl<ShortItem>(this as ShortItem, _$identity);

  /// Serializes this ShortItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShortItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,videoUrl,thumbnailUrl,likesCount,viewsCount,isLiked);

@override
String toString() {
  return 'ShortItem(id: $id, title: $title, description: $description, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, likesCount: $likesCount, viewsCount: $viewsCount, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class $ShortItemCopyWith<$Res>  {
  factory $ShortItemCopyWith(ShortItem value, $Res Function(ShortItem) _then) = _$ShortItemCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? description,@JsonKey(name: 'video_url') String? videoUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'is_liked') bool isLiked
});




}
/// @nodoc
class _$ShortItemCopyWithImpl<$Res>
    implements $ShortItemCopyWith<$Res> {
  _$ShortItemCopyWithImpl(this._self, this._then);

  final ShortItem _self;
  final $Res Function(ShortItem) _then;

/// Create a copy of ShortItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? videoUrl = freezed,Object? thumbnailUrl = freezed,Object? likesCount = null,Object? viewsCount = null,Object? isLiked = null,}) {
  return _then(ShortItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShortItem].
extension ShortItemPatterns on ShortItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShortItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShortItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShortItem value)  $default,){
final _that = this;
switch (_that) {
case _ShortItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShortItem value)?  $default,){
final _that = this;
switch (_that) {
case _ShortItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? description, @JsonKey(name: 'video_url')  String? videoUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'is_liked')  bool isLiked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShortItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.videoUrl,_that.thumbnailUrl,_that.likesCount,_that.viewsCount,_that.isLiked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? description, @JsonKey(name: 'video_url')  String? videoUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'is_liked')  bool isLiked)  $default,) {final _that = this;
switch (_that) {
case _ShortItem():
return $default(_that.id,_that.title,_that.description,_that.videoUrl,_that.thumbnailUrl,_that.likesCount,_that.viewsCount,_that.isLiked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? description, @JsonKey(name: 'video_url')  String? videoUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'is_liked')  bool isLiked)?  $default,) {final _that = this;
switch (_that) {
case _ShortItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.videoUrl,_that.thumbnailUrl,_that.likesCount,_that.viewsCount,_that.isLiked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShortItem implements ShortItem {
  const _ShortItem({required this.id, this.title, this.description, @JsonKey(name: 'video_url') this.videoUrl, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'likes_count') this.likesCount = 0, @JsonKey(name: 'views_count') this.viewsCount = 0, @JsonKey(name: 'is_liked') this.isLiked = false});
  factory _ShortItem.fromJson(Map<String, dynamic> json) => _$ShortItemFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? description;
@override@JsonKey(name: 'video_url') final  String? videoUrl;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'likes_count') final  int likesCount;
@override@JsonKey(name: 'views_count') final  int viewsCount;
@override@JsonKey(name: 'is_liked') final  bool isLiked;

/// Create a copy of ShortItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShortItemCopyWith<_ShortItem> get copyWith => __$ShortItemCopyWithImpl<_ShortItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShortItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShortItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,videoUrl,thumbnailUrl,likesCount,viewsCount,isLiked);

@override
String toString() {
  return 'ShortItem(id: $id, title: $title, description: $description, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, likesCount: $likesCount, viewsCount: $viewsCount, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class _$ShortItemCopyWith<$Res> implements $ShortItemCopyWith<$Res> {
  factory _$ShortItemCopyWith(_ShortItem value, $Res Function(_ShortItem) _then) = __$ShortItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? description,@JsonKey(name: 'video_url') String? videoUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'is_liked') bool isLiked
});




}
/// @nodoc
class __$ShortItemCopyWithImpl<$Res>
    implements _$ShortItemCopyWith<$Res> {
  __$ShortItemCopyWithImpl(this._self, this._then);

  final _ShortItem _self;
  final $Res Function(_ShortItem) _then;

/// Create a copy of ShortItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? videoUrl = freezed,Object? thumbnailUrl = freezed,Object? likesCount = null,Object? viewsCount = null,Object? isLiked = null,}) {
  return _then(_ShortItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
