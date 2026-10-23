import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

abstract class ProductRemoteDataSource {
  Future<List<dynamic>> getProducts({int page = 0, int size = 20});
  Future<Map<String, dynamic>> getProductById(String productId);
  Future<List<dynamic>> getProductsByCategory(String categoryId, {int page = 0, int size = 20});
  Future<List<dynamic>> searchProducts(String query, {int page = 0, int size = 20});
  Future<List<dynamic>> getCollections();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _client;

  ProductRemoteDataSourceImpl(this._client);

  @override
  Future<List<dynamic>> getProducts({int page = 0, int size = 20}) async {
    final response = await _client.get('${ApiEndpoints.products}?page=$page&size=$size');
    if (response is Map && response['data'] is Map && response['data']['content'] is List) {
      return response['data']['content'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final response = await _client.get(ApiEndpoints.productDetail(productId));
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<List<dynamic>> getProductsByCategory(String categoryId, {int page = 0, int size = 20}) async {
    final response = await _client.get(ApiEndpoints.productsByCategory(categoryId, page: page, size: size));
    if (response is Map && response['data'] is Map && response['data']['content'] is List) {
      return response['data']['content'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<List<dynamic>> searchProducts(String query, {int page = 0, int size = 20}) async {
    final response = await _client.get(ApiEndpoints.searchProducts(query, page: page, size: size));
    if (response is Map && response['data'] is Map && response['data']['content'] is List) {
      return response['data']['content'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<List<dynamic>> getCollections() async {
    final response = await _client.get(ApiEndpoints.collections);
    if (response is Map && response['data'] is Map && response['data']['items'] is List) {
      return response['data']['items'] as List<dynamic>;
    }
    return [];
  }
}
