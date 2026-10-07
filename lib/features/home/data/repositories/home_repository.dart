import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/home_data.dart';

/// Single source of truth for customer-facing categories.
///
/// Both Home ("Explore Categories") and Menu (top chips / search browse
/// list) must render exactly the active backend categories in admin order.
/// The backend endpoint already returns only active categories ordered by
/// `displayOrder`, but we also filter + sort the raw payload client-side so
/// a rename / image change / disable / reorder is reflected everywhere after
/// refresh, and a stale record (e.g. "Breads") can never leak through from
/// a cached or out-of-order payload.
List<Map<String, dynamic>> filterAndSortCategoryJson(List<dynamic> raw) {
  final rows = raw.whereType<Map<String, dynamic>>().toList();
  // Only active categories are customer-visible. Missing flag ⇒ active
  // (keeps old payloads/backward-compat working).
  final active =
      rows.where((e) => e['isActive'] == null || e['isActive'] == true).toList();
  // Admin display order. Missing order ⇒ 0 (stable, keeps backend order).
  active.sort((a, b) {
    final ao = (a['displayOrder'] as num?)?.toInt() ?? 0;
    final bo = (b['displayOrder'] as num?)?.toInt() ?? 0;
    return ao.compareTo(bo);
  });
  return active;
}

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<List<BannerItem>> getBanners({int timeoutSeconds = 8, int maxRetries = 1}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) debugPrint('[HomeRepo] banners attempt ${attempt + 1}');
        final response = await _dio.get('/banners', options: Options(receiveTimeout: Duration(seconds: timeoutSeconds)));
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => BannerItem.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (kDebugMode) debugPrint('[HomeRepo] banners: data is not a List');
        return [];
      } on DioException catch (e) {
        if (kDebugMode) debugPrint('[HomeRepo] banners DioException: ${e.type}, status: ${e.response?.statusCode}');
        if (attempt < maxRetries) {
          if (kDebugMode) debugPrint('[HomeRepo] banners retrying...');
          continue;
        }
        if (kDebugMode) debugPrint('[HomeRepo] banners retries exhausted');
        return [];
      } catch (e) {
        if (kDebugMode) debugPrint('[HomeRepo] banners error: $e');
        return [];
      }
    }
    return [];
  }

  Future<List<HomeCategory>> getCategories({int timeoutSeconds = 8, int maxRetries = 1}) async {
    DioException? lastError;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) debugPrint('[HomeRepo] categories attempt ${attempt + 1}');
        final response = await _dio.get('/categories', options: Options(receiveTimeout: Duration(seconds: timeoutSeconds)));
        final data = response.data['data'];
        if (data is List) {
          // Single source of truth: active only, admin display order.
          return filterAndSortCategoryJson(data)
              .map((e) => HomeCategory.fromJson(e))
              .toList();
        }
        if (kDebugMode) debugPrint('[HomeRepo] categories: data is not a List');
        return [];
      } on DioException catch (e) {
        if (kDebugMode) debugPrint('[HomeRepo] categories DioException: ${e.type}, status: ${e.response?.statusCode}');
        lastError = e;
        if (attempt < maxRetries) {
          if (kDebugMode) debugPrint('[HomeRepo] categories retrying...');
          continue;
        }
        if (kDebugMode) debugPrint('[HomeRepo] categories retries exhausted');
        // Surface the failure so Home + Menu show the proper error/retry
        // state instead of silently rendering a stale/fake category list.
        rethrow;
      } catch (e) {
        if (kDebugMode) debugPrint('[HomeRepo] categories error: $e');
        return [];
      }
    }
    if (lastError != null) throw lastError;
    return [];
  }

  Future<List<HomeFood>> getFoods({
    String? categoryId,
    bool? isBestseller,
    bool? isVeg,
    bool? isHealthyPick,
    int? limit,
    int timeoutSeconds = 8,
    int maxRetries = 1,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) debugPrint('[HomeRepo] foods attempt ${attempt + 1}');
        final response = await _dio.get('/foods',
          queryParameters: {
            if (categoryId != null) 'categoryId': categoryId,
            if (isBestseller != null) 'isBestseller': isBestseller,
            if (isVeg != null) 'isVeg': isVeg,
            if (isHealthyPick != null) 'isHealthyPick': isHealthyPick,
            if (limit != null) 'take': limit,
          },
          options: Options(receiveTimeout: Duration(seconds: timeoutSeconds)),
        );
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => HomeFood.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (kDebugMode) debugPrint('[HomeRepo] foods: data is not a List');
        return [];
      } on DioException catch (e) {
        if (kDebugMode) debugPrint('[HomeRepo] foods DioException: ${e.type}, status: ${e.response?.statusCode}');
        if (attempt < maxRetries) {
          if (kDebugMode) debugPrint('[HomeRepo] foods retrying...');
          continue;
        }
        if (kDebugMode) debugPrint('[HomeRepo] foods retries exhausted');
        return [];
      } catch (e) {
        if (kDebugMode) debugPrint('[HomeRepo] foods error: $e');
        return [];
      }
    }
    return [];
  }
}
