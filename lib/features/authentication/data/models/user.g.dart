// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  phoneNumber: json['phoneNumber'] as String,
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
  role: json['role'] as String,
  walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
  isBlocked: json['isBlocked'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'phoneNumber': instance.phoneNumber,
  'fullName': instance.fullName,
  'email': instance.email,
  'role': instance.role,
  'walletBalance': instance.walletBalance,
  'isBlocked': instance.isBlocked,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
