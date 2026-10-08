// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_food.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuFoodImpl _$$MenuFoodImplFromJson(
  Map<String, dynamic> json,
) => _$MenuFoodImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  rating: (json['rating'] as num?)?.toDouble(),
  reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
  isVeg: json['isVeg'] as bool? ?? true,
  isBestseller: json['isBestseller'] as bool? ?? false,
  isFeatured: json['isFeatured'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  isAvailable: json['isAvailable'] as bool? ?? true,
  categoryId: json['categoryId'] as String?,
  categoryName: json['categoryName'] as String?,
  subcategory: json['subcategory'] as String?,
  mealTags:
      (json['mealTags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  customizationGroups:
      (json['customizationGroups'] as List<dynamic>?)
          ?.map((e) => CustomizationGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MenuFoodImplToJson(_$MenuFoodImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'imageUrls': instance.imageUrls,
      'rating': instance.rating,
      'reviewsCount': instance.reviewsCount,
      'isVeg': instance.isVeg,
      'isBestseller': instance.isBestseller,
      'isFeatured': instance.isFeatured,
      'isActive': instance.isActive,
      'isAvailable': instance.isAvailable,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'subcategory': instance.subcategory,
      'mealTags': instance.mealTags,
      'customizationGroups': instance.customizationGroups,
    };

_$CustomizationGroupImpl _$$CustomizationGroupImplFromJson(
  Map<String, dynamic> json,
) => _$CustomizationGroupImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  minSelect: (json['minSelections'] as num?)?.toInt() ?? 0,
  maxSelect: (json['maxSelections'] as num?)?.toInt() ?? 1,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CustomizationItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$CustomizationGroupImplToJson(
  _$CustomizationGroupImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'minSelections': instance.minSelect,
  'maxSelections': instance.maxSelect,
  'items': instance.items,
};

_$CustomizationItemImpl _$$CustomizationItemImplFromJson(
  Map<String, dynamic> json,
) => _$CustomizationItemImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0.0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$CustomizationItemImplToJson(
  _$CustomizationItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'additionalPrice': instance.additionalPrice,
  'isActive': instance.isActive,
};
