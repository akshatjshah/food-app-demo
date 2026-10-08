import 'package:dio/dio.dart';
import '../../../home/data/repositories/home_repository.dart'
    show filterAndSortCategoryJson;
import '../models/menu_food.dart';
import '../models/menu_category.dart';

class MenuRepository {
  final Dio _dio;

  MenuRepository(this._dio);

  Future<List<MenuFood>> getFoods({
    String? categoryId,
    String? subcategory,
    String? search,
    bool? isVeg,
    bool? isBestseller,
    bool? isFeatured,
    bool? isAvailable,
    String? mealTag,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int take = 200,
    int skip = 0,
  }) async {
    final response = await _dio.get('/foods', queryParameters: {
      if (categoryId != null) 'categoryId': categoryId,
      if (subcategory != null) 'subcategory': subcategory,
      if (search != null && search.isNotEmpty) 'search': search,
      if (isVeg != null) 'isVeg': isVeg,
      if (isBestseller != null) 'isBestseller': isBestseller,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (mealTag != null) 'mealTag': mealTag,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (sort != null) 'sort': sort,
      'take': take,
      'skip': skip,
    });
    final data = response.data['data'];
    if (data is List) {
      return data
          .map((e) => MenuFood.fromJson(normalizeFoodJson(e)))
          .toList();
    }
    return [];
  }

  Future<MenuFood> getFood(String id) async {
    final response = await _dio.get('/foods/$id');
    return MenuFood.fromJson(normalizeFoodJson(response.data['data']));
  }

  /// Maps the raw backend food payload (Prisma camelCase + nested `category`
  /// relation, Decimal-as-string numbers) onto the flat [MenuFood] contract.
  static Map<String, dynamic> normalizeFoodJson(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    if (map['categoryName'] == null && map['category'] is Map) {
      final cat = map['category'] as Map;
      if (cat['name'] != null) map['categoryName'] = cat['name'] as String?;
    }
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    if (map['price'] is String) map['price'] = toDouble(map['price']);
    if (map['originalPrice'] is String) {
      map['originalPrice'] = toDouble(map['originalPrice']);
    }
    if (map['rating'] is String) map['rating'] = toDouble(map['rating']);
    // Older rows may carry a single `imageUrl` string instead of the list.
    if ((map['imageUrls'] == null ||
            (map['imageUrls'] is List &&
                (map['imageUrls'] as List).isEmpty)) &&
        map['imageUrl'] is String &&
        (map['imageUrl'] as String).isNotEmpty) {
      map['imageUrls'] = [map['imageUrl'] as String];
    }
    if (map['mealTags'] == null) map['mealTags'] = const [];
    return map;
  }

  /// Legacy accessor kept for backward compatibility.
  ///
  /// Customer UI (Menu chips, search browse list) reads categories from the
  /// single source of truth — [HomeRepository] via `homeProvider` — so both
  /// Home and Menu always render the same active backend categories in admin
  /// order. This method hits the same `GET /categories` endpoint and applies
  /// the same shared [filterAndSortCategoryJson] step, so it can never
  /// return a stale/hardcoded entry either.
  Future<List<MenuCategory>> getCategories() async {
    final response = await _dio.get('/categories');
    final data = response.data['data'];
    if (data is List) {
      return filterAndSortCategoryJson(data)
          .map((e) => MenuCategory.fromJson(e))
          .toList();
    }
    return [];
  }
}
