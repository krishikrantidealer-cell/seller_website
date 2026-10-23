import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

abstract class CategoryRemoteDataSource {
  Future<List<dynamic>> getRootCategories();
  Future<List<dynamic>> getCategoryChildren(String parentId);
  Future<Map<String, dynamic>> getCategoryById(String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _client;

  CategoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<dynamic>> getRootCategories() async {
    final response = await _client.get(ApiEndpoints.categoryRoots(level: 0));
    if (response is Map && response['data'] is Map && response['data']['content'] is List) {
      return response['data']['content'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<List<dynamic>> getCategoryChildren(String parentId) async {
    final response = await _client.get(ApiEndpoints.categoryChildren(parentId));
    if (response is Map && response['data'] is Map && response['data']['content'] is List) {
      return response['data']['content'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    final response = await _client.get(ApiEndpoints.categoryById(categoryId));
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }
}
