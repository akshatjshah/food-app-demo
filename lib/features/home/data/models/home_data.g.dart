// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeData _$HomeDataFromJson(Map<String, dynamic> json) => _HomeData(
  banners:
      (json['banners'] as List<dynamic>?)
          ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  featuredFoods:
      (json['featuredFoods'] as List<dynamic>?)
          ?.map((e) => HomeFood.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  bestsellers:
      (json['bestsellers'] as List<dynamic>?)
          ?.map((e) => HomeFood.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  healthyPicks:
      (json['healthyPicks'] as List<dynamic>?)
          ?.map((e) => HomeFood.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HomeDataToJson(_HomeData instance) => <String, dynamic>{
  'banners': instance.banners,
  'categories': instance.categories,
  'featuredFoods': instance.featuredFoods,
  'bestsellers': instance.bestsellers,
  'healthyPicks': instance.healthyPicks,
};

_BannerItem _$BannerItemFromJson(Map<String, dynamic> json) => _BannerItem(
  id: json['id'] as String,
  title: json['title'] as String?,
  imageUrl: json['imageUrl'] as String?,
  link: json['link'] as String?,
);

Map<String, dynamic> _$BannerItemToJson(_BannerItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'link': instance.link,
    };

_HomeCategory _$HomeCategoryFromJson(Map<String, dynamic> json) =>
    _HomeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      imageUrl: json['imageUrl'] as String?,
      foodCount: (json['foodCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$HomeCategoryToJson(_HomeCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'imageUrl': instance.imageUrl,
      'foodCount': instance.foodCount,
    };

_HomeFood _$HomeFoodFromJson(Map<String, dynamic> json) => _HomeFood(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  rating: (json['rating'] as num?)?.toDouble(),
  isVeg: json['isVeg'] as bool? ?? true,
  isBestseller: json['isBestseller'] as bool? ?? false,
);

Map<String, dynamic> _$HomeFoodToJson(_HomeFood instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'imageUrls': instance.imageUrls,
  'rating': instance.rating,
  'isVeg': instance.isVeg,
  'isBestseller': instance.isBestseller,
};
