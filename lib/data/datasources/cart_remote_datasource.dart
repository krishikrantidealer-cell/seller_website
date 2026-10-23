import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

abstract class CartRemoteDataSource {
  Future<Map<String, dynamic>> getCart();
  Future<int> getCartCount();
  Future<Map<String, dynamic>> addItem({required String variantId, int quantity = 1});
  Future<Map<String, dynamic>> updateQuantity({required String variantId, required int quantity});
  Future<Map<String, dynamic>> removeItem(String variantId);
  Future<void> clearCart();
  Future<Map<String, dynamic>> syncCart(List<Map<String, dynamic>> items);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _client;

  CartRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> getCart() async {
    final response = await _client.get(ApiEndpoints.cart, requiresAuth: true);
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<int> getCartCount() async {
    final response = await _client.get(ApiEndpoints.cartCount, requiresAuth: true);
    if (response is Map && response['data'] != null) {
      return int.tryParse(response['data'].toString()) ?? 0;
    }
    return 0;
  }

  @override
  Future<Map<String, dynamic>> addItem({required String variantId, int quantity = 1}) async {
    final response = await _client.post(
      ApiEndpoints.cartItems,
      body: {
        'variantId': variantId,
        'quantity': quantity,
      },
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateQuantity({required String variantId, required int quantity}) async {
    final response = await _client.put(
      ApiEndpoints.cartItem(variantId),
      body: {'quantity': quantity},
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> removeItem(String variantId) async {
    final response = await _client.delete(
      ApiEndpoints.cartItem(variantId),
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<void> clearCart() async {
    await _client.delete(ApiEndpoints.cart, requiresAuth: true);
  }

  @override
  Future<Map<String, dynamic>> syncCart(List<Map<String, dynamic>> items) async {
    final response = await _client.post(
      ApiEndpoints.cartSync,
      body: {'items': items},
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }
}
