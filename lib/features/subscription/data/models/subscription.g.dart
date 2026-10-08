// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationDays: (json['durationDays'] as num).toInt(),
      mealsCount: (json['mealsCount'] as num).toInt(),
      price: json['price'],
      pricePerMeal: json['pricePerMeal'],
      mealType: json['mealType'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$SubscriptionPlanToJson(SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'durationDays': instance.durationDays,
      'mealsCount': instance.mealsCount,
      'price': instance.price,
      'pricePerMeal': instance.pricePerMeal,
      'mealType': instance.mealType,
      'isActive': instance.isActive,
    };

_UserSubscription _$UserSubscriptionFromJson(
  Map<String, dynamic> json,
) => _UserSubscription(
  id: json['id'] as String,
  subscriptionId: json['subscriptionId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  mealsRemaining: (json['mealsRemaining'] as num?)?.toInt() ?? 0,
  status: json['status'] as String,
  skipDates:
      (json['skipDates'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  subscription: json['subscription'] == null
      ? null
      : SubscriptionPlan.fromJson(json['subscription'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserSubscriptionToJson(_UserSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscriptionId': instance.subscriptionId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'mealsRemaining': instance.mealsRemaining,
      'status': instance.status,
      'skipDates': instance.skipDates,
      'createdAt': instance.createdAt.toIso8601String(),
      'subscription': instance.subscription,
    };
