import 'package:dio/dio.dart';
import '../models/wishlist_item.dart';

class WishlistRepository {
  final Dio _dio;

  WishlistRepository(this._dio);

  Future<List<WishlistItem>> getWishlist() async {
    final response = await _dio.get('/wishlist');
    final payload = response.data;
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = (data['items'] ?? data['wishlist'] ?? []) as List;
    } else {
      list = const [];
    }
    return list
        .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> toggleWishlist(String foodItemId) async {
    final response = await _dio.post('/wishlist/$foodItemId');
    final payload = response.data;
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
    if (data is Map && data['added'] is bool) return data['added'] as bool;
    return false;
  }
}
