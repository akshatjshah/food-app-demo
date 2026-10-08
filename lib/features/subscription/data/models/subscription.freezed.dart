// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSubscription {

 String get id; String get subscriptionId; DateTime get startDate; DateTime get endDate; int get mealsRemaining; String get status; List<String> get skipDates; DateTime get createdAt; SubscriptionPlan? get subscription;
/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSubscriptionCopyWith<UserSubscription> get copyWith => _$UserSubscriptionCopyWithImpl<UserSubscription>(this as UserSubscription, _$identity);

  /// Serializes this UserSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.mealsRemaining, mealsRemaining) || other.mealsRemaining == mealsRemaining)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.skipDates, skipDates)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.subscription, subscription) || other.subscription == subscription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,startDate,endDate,mealsRemaining,status,const DeepCollectionEquality().hash(skipDates),createdAt,subscription);

@override
String toString() {
  return 'UserSubscription(id: $id, subscriptionId: $subscriptionId, startDate: $startDate, endDate: $endDate, mealsRemaining: $mealsRemaining, status: $status, skipDates: $skipDates, createdAt: $createdAt, subscription: $subscription)';
}


}

/// @nodoc
abstract mixin class $UserSubscriptionCopyWith<$Res>  {
  factory $UserSubscriptionCopyWith(UserSubscription value, $Res Function(UserSubscription) _then) = _$UserSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String subscriptionId, DateTime startDate, DateTime endDate, int mealsRemaining, String status, List<String> skipDates, DateTime createdAt, SubscriptionPlan? subscription
});




}
/// @nodoc
class _$UserSubscriptionCopyWithImpl<$Res>
    implements $UserSubscriptionCopyWith<$Res> {
  _$UserSubscriptionCopyWithImpl(this._self, this._then);

  final UserSubscription _self;
  final $Res Function(UserSubscription) _then;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subscriptionId = null,Object? startDate = null,Object? endDate = null,Object? mealsRemaining = null,Object? status = null,Object? skipDates = null,Object? createdAt = null,Object? subscription = freezed,}) {
  return _then(UserSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,mealsRemaining: null == mealsRemaining ? _self.mealsRemaining : mealsRemaining // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,skipDates: null == skipDates ? _self.skipDates : skipDates // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSubscription].
extension UserSubscriptionPatterns on UserSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSubscription value)  $default,){
final _that = this;
switch (_that) {
case _UserSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String subscriptionId,  DateTime startDate,  DateTime endDate,  int mealsRemaining,  String status,  List<String> skipDates,  DateTime createdAt,  SubscriptionPlan? subscription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.startDate,_that.endDate,_that.mealsRemaining,_that.status,_that.skipDates,_that.createdAt,_that.subscription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String subscriptionId,  DateTime startDate,  DateTime endDate,  int mealsRemaining,  String status,  List<String> skipDates,  DateTime createdAt,  SubscriptionPlan? subscription)  $default,) {final _that = this;
switch (_that) {
case _UserSubscription():
return $default(_that.id,_that.subscriptionId,_that.startDate,_that.endDate,_that.mealsRemaining,_that.status,_that.skipDates,_that.createdAt,_that.subscription);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String subscriptionId,  DateTime startDate,  DateTime endDate,  int mealsRemaining,  String status,  List<String> skipDates,  DateTime createdAt,  SubscriptionPlan? subscription)?  $default,) {final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.startDate,_that.endDate,_that.mealsRemaining,_that.status,_that.skipDates,_that.createdAt,_that.subscription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSubscription implements UserSubscription {
  const _UserSubscription({required this.id, required this.subscriptionId, required this.startDate, required this.endDate, this.mealsRemaining = 0, required this.status,  List<String> skipDates = const [], required this.createdAt, this.subscription}): _skipDates = skipDates;
  factory _UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

@override final  String id;
@override final  String subscriptionId;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override@JsonKey() final  int mealsRemaining;
@override final  String status;
 final  List<String> _skipDates;
@override@JsonKey() List<String> get skipDates {
  if (_skipDates is EqualUnmodifiableListView) return _skipDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipDates);
}

@override final  DateTime createdAt;
@override final  SubscriptionPlan? subscription;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSubscriptionCopyWith<_UserSubscription> get copyWith => __$UserSubscriptionCopyWithImpl<_UserSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.mealsRemaining, mealsRemaining) || other.mealsRemaining == mealsRemaining)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._skipDates, _skipDates)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.subscription, subscription) || other.subscription == subscription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,startDate,endDate,mealsRemaining,status,const DeepCollectionEquality().hash(_skipDates),createdAt,subscription);

@override
String toString() {
  return 'UserSubscription(id: $id, subscriptionId: $subscriptionId, startDate: $startDate, endDate: $endDate, mealsRemaining: $mealsRemaining, status: $status, skipDates: $skipDates, createdAt: $createdAt, subscription: $subscription)';
}


}

/// @nodoc
abstract mixin class _$UserSubscriptionCopyWith<$Res> implements $UserSubscriptionCopyWith<$Res> {
  factory _$UserSubscriptionCopyWith(_UserSubscription value, $Res Function(_UserSubscription) _then) = __$UserSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String subscriptionId, DateTime startDate, DateTime endDate, int mealsRemaining, String status, List<String> skipDates, DateTime createdAt, SubscriptionPlan? subscription
});




}
/// @nodoc
class __$UserSubscriptionCopyWithImpl<$Res>
    implements _$UserSubscriptionCopyWith<$Res> {
  __$UserSubscriptionCopyWithImpl(this._self, this._then);

  final _UserSubscription _self;
  final $Res Function(_UserSubscription) _then;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subscriptionId = null,Object? startDate = null,Object? endDate = null,Object? mealsRemaining = null,Object? status = null,Object? skipDates = null,Object? createdAt = null,Object? subscription = freezed,}) {
  return _then(_UserSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,mealsRemaining: null == mealsRemaining ? _self.mealsRemaining : mealsRemaining // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,skipDates: null == skipDates ? _self._skipDates : skipDates // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan?,
  ));
}


}

// dart format on
