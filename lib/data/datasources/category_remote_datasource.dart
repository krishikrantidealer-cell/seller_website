import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../services/category_api_service.dart';

abstract class CategoryRemoteDataSource {
  /// Fetches all active categories across pages from `GET /api/v1/categories`
  Future<List<ApiCategoryRecord>> getCategories({int? level, String? parentId});

  /// Fetches a single active category by ID from `GET /api/v1/categories/{id}`
  Future<ApiCategoryRecord> getCategoryById(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ApiCategoryRecord>> getCategories({int? level, String? parentId}) async {
    final queryParams = <String, String>{
      'page': '0',
      'size': '500',
    };
    if (level != null) queryParams['level'] = level.toString();
    if (parentId != null && parentId.isNotEmpty) queryParams['parentId'] = parentId;

    final firstPageResponse = await apiClient.get(
      ApiEndpoints.categories,
      queryParameters: queryParams,
      requiresAuth: false,
    );

    final rawData = firstPageResponse['data'];
    if (rawData is! Map<String, dynamic>) {
      throw const ApiException(message: 'Unexpected category response format from server.');
    }

    final allRecords = <ApiCategoryRecord>[];
    final content = rawData['content'] as List<dynamic>? ?? [];
    for (final item in content) {
      if (item is Map<String, dynamic>) {
        allRecords.add(ApiCategoryRecord.fromJson(item));
      } else if (item is Map) {
        allRecords.add(ApiCategoryRecord.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final totalPages = (rawData['totalPages'] as num?)?.toInt() ?? 1;
    final isLast = rawData['last'] == true;

    if (!isLast && totalPages > 1) {
      final futures = <Future<Map<String, dynamic>>>[];
      for (int p = 1; p < totalPages; p++) {
        final nextParams = Map<String, String>.from(queryParams);
        nextParams['page'] = p.toString();
        futures.add(
          apiClient.get(
            ApiEndpoints.categories,
            queryParameters: nextParams,
            requiresAuth: false,
          ),
        );
      }

      final results = await Future.wait(futures);
      for (final res in results) {
        final pageData = res['data'];
        if (pageData is Map<String, dynamic>) {
          final pageContent = pageData['content'] as List<dynamic>? ?? [];
          for (final item in pageContent) {
            if (item is Map<String, dynamic>) {
              allRecords.add(ApiCategoryRecord.fromJson(item));
            } else if (item is Map) {
              allRecords.add(ApiCategoryRecord.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
    }

    return allRecords;
  }

  @override
  Future<ApiCategoryRecord> getCategoryById(String id) async {
    final response = await apiClient.get(
      ApiEndpoints.categoryById(id),
      requiresAuth: false,
    );
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return ApiCategoryRecord.fromJson(rawData);
    }
    throw const ApiException(message: 'Category not found.');
  }
}
