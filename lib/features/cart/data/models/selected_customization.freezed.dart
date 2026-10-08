// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_customization.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectedCustomization {

@JsonKey(name: 'customization_item_id') String get customizationItemId; String get name;@JsonKey(name: 'additional_price') double get additionalPrice;
/// Create a copy of SelectedCustomization
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectedCustomizationCopyWith<SelectedCustomization> get copyWith => _$SelectedCustomizationCopyWithImpl<SelectedCustomization>(this as SelectedCustomization, _$identity);

  /// Serializes this SelectedCustomization to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectedCustomization&&(identical(other.customizationItemId, customizationItemId) || other.customizationItemId == customizationItemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.additionalPrice, additionalPrice) || other.additionalPrice == additionalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customizationItemId,name,additionalPrice);

@override
String toString() {
  return 'SelectedCustomization(customizationItemId: $customizationItemId, name: $name, additionalPrice: $additionalPrice)';
}


}

/// @nodoc
abstract mixin class $SelectedCustomizationCopyWith<$Res>  {
  factory $SelectedCustomizationCopyWith(SelectedCustomization value, $Res Function(SelectedCustomization) _then) = _$SelectedCustomizationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customization_item_id') String customizationItemId, String name,@JsonKey(name: 'additional_price') double additionalPrice
});




}
/// @nodoc
class _$SelectedCustomizationCopyWithImpl<$Res>
    implements $SelectedCustomizationCopyWith<$Res> {
  _$SelectedCustomizationCopyWithImpl(this._self, this._then);

  final SelectedCustomization _self;
  final $Res Function(SelectedCustomization) _then;

/// Create a copy of SelectedCustomization
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customizationItemId = null,Object? name = null,Object? additionalPrice = null,}) {
  return _then(SelectedCustomization(
customizationItemId: null == customizationItemId ? _self.customizationItemId : customizationItemId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,additionalPrice: null == additionalPrice ? _self.additionalPrice : additionalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectedCustomization].
extension SelectedCustomizationPatterns on SelectedCustomization {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectedCustomization value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectedCustomization() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectedCustomization value)  $default,){
final _that = this;
switch (_that) {
case _SelectedCustomization():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectedCustomization value)?  $default,){
final _that = this;
switch (_that) {
case _SelectedCustomization() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customization_item_id')  String customizationItemId,  String name, @JsonKey(name: 'additional_price')  double additionalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectedCustomization() when $default != null:
return $default(_that.customizationItemId,_that.name,_that.additionalPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customization_item_id')  String customizationItemId,  String name, @JsonKey(name: 'additional_price')  double additionalPrice)  $default,) {final _that = this;
switch (_that) {
case _SelectedCustomization():
return $default(_that.customizationItemId,_that.name,_that.additionalPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customization_item_id')  String customizationItemId,  String name, @JsonKey(name: 'additional_price')  double additionalPrice)?  $default,) {final _that = this;
switch (_that) {
case _SelectedCustomization() when $default != null:
return $default(_that.customizationItemId,_that.name,_that.additionalPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelectedCustomization implements SelectedCustomization {
  const _SelectedCustomization({@JsonKey(name: 'customization_item_id') required this.customizationItemId, required this.name, @JsonKey(name: 'additional_price') this.additionalPrice = 0.0});
  factory _SelectedCustomization.fromJson(Map<String, dynamic> json) => _$SelectedCustomizationFromJson(json);

@override@JsonKey(name: 'customization_item_id') final  String customizationItemId;
@override final  String name;
@override@JsonKey(name: 'additional_price') final  double additionalPrice;

/// Create a copy of SelectedCustomization
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectedCustomizationCopyWith<_SelectedCustomization> get copyWith => __$SelectedCustomizationCopyWithImpl<_SelectedCustomization>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectedCustomizationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectedCustomization&&(identical(other.customizationItemId, customizationItemId) || other.customizationItemId == customizationItemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.additionalPrice, additionalPrice) || other.additionalPrice == additionalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customizationItemId,name,additionalPrice);

@override
String toString() {
  return 'SelectedCustomization(customizationItemId: $customizationItemId, name: $name, additionalPrice: $additionalPrice)';
}


}

/// @nodoc
abstract mixin class _$SelectedCustomizationCopyWith<$Res> implements $SelectedCustomizationCopyWith<$Res> {
  factory _$SelectedCustomizationCopyWith(_SelectedCustomization value, $Res Function(_SelectedCustomization) _then) = __$SelectedCustomizationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customization_item_id') String customizationItemId, String name,@JsonKey(name: 'additional_price') double additionalPrice
});




}
/// @nodoc
class __$SelectedCustomizationCopyWithImpl<$Res>
    implements _$SelectedCustomizationCopyWith<$Res> {
  __$SelectedCustomizationCopyWithImpl(this._self, this._then);

  final _SelectedCustomization _self;
  final $Res Function(_SelectedCustomization) _then;

/// Create a copy of SelectedCustomization
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customizationItemId = null,Object? name = null,Object? additionalPrice = null,}) {
  return _then(_SelectedCustomization(
customizationItemId: null == customizationItemId ? _self.customizationItemId : customizationItemId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,additionalPrice: null == additionalPrice ? _self.additionalPrice : additionalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
