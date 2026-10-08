// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_customization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectedCustomization _$SelectedCustomizationFromJson(
  Map<String, dynamic> json,
) => _SelectedCustomization(
  customizationItemId: json['customization_item_id'] as String,
  name: json['name'] as String,
  additionalPrice: (json['additional_price'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$SelectedCustomizationToJson(
  _SelectedCustomization instance,
) => <String, dynamic>{
  'customization_item_id': instance.customizationItemId,
  'name': instance.name,
  'additional_price': instance.additionalPrice,
};
