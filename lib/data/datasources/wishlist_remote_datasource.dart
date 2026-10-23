import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

abstract class WishlistRemoteDataSource {
  Future<Map<String, dynamic>> getWishlist();
  Future<Map<String, dynamic>> addVariant(String variantId);
  Future<Map<String, dynamic>> removeVariant(String variantId);
  Future<void> clearWishlist();
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient _client;

  WishlistRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> getWishlist() async {
    final response = await _client.get(ApiEndpoints.wishlist, requiresAuth: true);
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> addVariant(String variantId) async {
    final response = await _client.put(
      ApiEndpoints.wishlistItem(variantId),
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> removeVariant(String variantId) async {
    final response = await _client.delete(
      ApiEndpoints.wishlistItem(variantId),
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<void> clearWishlist() async {
    await _client.delete(ApiEndpoints.wishlist, requiresAuth: true);
  }
}
