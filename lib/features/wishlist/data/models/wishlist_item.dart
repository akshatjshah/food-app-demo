import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';
part 'wishlist_item.g.dart';

@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required String id,
    @JsonKey(name: 'food_item') required WishlistFoodItem foodItem,
  }) = _WishlistItem;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // Backend (Prisma) emits camelCase `foodItem`; older payloads / docs
    // use snake_case `food_item`. Accept both so favorites never break.
    final normalized = Map<String, dynamic>.from(json);
    if (!normalized.containsKey('food_item') &&
        normalized.containsKey('foodItem')) {
      normalized['food_item'] = normalized['foodItem'];
    }
    return _$WishlistItemFromJson(normalized);
  }
}

@freezed
class WishlistFoodItem with _$WishlistFoodItem {
  const factory WishlistFoodItem({
    required String id,
    required String name,
    required double price,
    @JsonKey(name: 'image_urls') @Default([]) List<String> imageUrls,
    double? rating,
    @JsonKey(name: 'is_veg') @Default(true) bool isVeg,
  }) = _WishlistFoodItem;

  factory WishlistFoodItem.fromJson(Map<String, dynamic> json) {
    // Accept camelCase (Prisma) and snake_case (API docs) keys, plus
    // Decimal-as-string numbers from the backend.
    final normalized = Map<String, dynamic>.from(json);
    if (!normalized.containsKey('image_urls') &&
        normalized.containsKey('imageUrls')) {
      normalized['image_urls'] = normalized['imageUrls'];
    }
    if (!normalized.containsKey('is_veg') &&
        normalized.containsKey('isVeg')) {
      normalized['is_veg'] = normalized['isVeg'];
    }
    for (final k in ['price', 'rating']) {
      final v = normalized[k];
      if (v is String) normalized[k] = double.tryParse(v);
    }
    return _$WishlistFoodItemFromJson(normalized);
  }
}
