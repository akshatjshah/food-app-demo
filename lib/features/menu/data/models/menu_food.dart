import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_food.freezed.dart';
part 'menu_food.g.dart';

@freezed
class MenuFood with _$MenuFood {
  const factory MenuFood({
    required String id,
    required String name,
    String? description,
    required double price,
    double? originalPrice,
    @Default([]) List<String> imageUrls,
    double? rating,
    @Default(0) int reviewsCount,
    @Default(true) bool isVeg,
    @Default(false) bool isBestseller,
    @Default(false) bool isFeatured,
    @Default(true) bool isActive,
    @Default(true) bool isAvailable,
    String? categoryId,
    String? categoryName,
    String? subcategory,
    @Default([]) List<String> mealTags,
    @Default([])
    List<CustomizationGroup> customizationGroups,
  }) = _MenuFood;

  factory MenuFood.fromJson(Map<String, dynamic> json) =>
      _$MenuFoodFromJson(json);
}

@freezed
class CustomizationGroup with _$CustomizationGroup {
  const factory CustomizationGroup({
    required String id,
    required String name,
    @JsonKey(name: 'minSelections') @Default(0) int minSelect,
    @JsonKey(name: 'maxSelections') @Default(1) int maxSelect,
    @Default([]) List<CustomizationItem> items,
  }) = _CustomizationGroup;

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) =>
      _$CustomizationGroupFromJson(json);
}

@freezed
class CustomizationItem with _$CustomizationItem {
  const factory CustomizationItem({
    required String id,
    required String name,
    @Default(0.0) double additionalPrice,
    @Default(true) bool isActive,
  }) = _CustomizationItem;

  factory CustomizationItem.fromJson(Map<String, dynamic> json) =>
      _$CustomizationItemFromJson(json);
}
