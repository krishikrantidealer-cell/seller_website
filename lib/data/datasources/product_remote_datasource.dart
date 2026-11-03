import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/catalog_models.dart';
import '../services/category_api_service.dart';

abstract class ProductRemoteDataSource {
  /// Fetches all public products across pages from `GET /api/v1/products` (no auth required)
  Future<List<ProductItem>> getProducts();

  /// Fetches a single public product by ID from `GET /api/v1/products/{id}` (no auth required)
  Future<ProductItem> getProductById(String id);

  /// Fetches public products for a category subtree from `GET /api/v1/products/category/{categoryId}` (no auth required)
  Future<List<ProductItem>> getProductsByCategory(String categoryId);

  /// Searches public products via `GET /api/v1/products/search?q={query}` (no auth required)
  Future<List<ProductItem>> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  List<ProductItem> _parseContentList(List<dynamic> content) {
    final categories = CategoryController.instance.categories;
    final items = <ProductItem>[];
    for (final raw in content) {
      if (raw is Map<String, dynamic>) {
        items.add(ProductItem.fromPublicJson(raw, categories: categories));
      } else if (raw is Map) {
        items.add(
          ProductItem.fromPublicJson(
            Map<String, dynamic>.from(raw),
            categories: categories,
          ),
        );
      }
    }
    return items;
  }

  Future<List<ProductItem>> _fetchAllPages(
    String path, {
    Map<String, String>? extraQuery,
  }) async {
    final queryParams = <String, String>{
      'page': '0',
      'size': '500',
      ...?extraQuery,
    };

    final firstPageResponse = await apiClient.get(
      path,
      queryParameters: queryParams,
      requiresAuth: false,
    );

    final rawData = firstPageResponse['data'];
    if (rawData is List) {
      return _parseContentList(rawData);
    }
    if (rawData is! Map<String, dynamic>) {
      throw const ApiException(message: 'Unexpected product response format from server.');
    }

    final allProducts = <ProductItem>[];
    final content = rawData['content'] as List<dynamic>? ?? [];
    allProducts.addAll(_parseContentList(content));

    final totalPages = (rawData['totalPages'] as num?)?.toInt() ?? 1;
    final isLast = rawData['last'] == true;

    if (!isLast && totalPages > 1) {
      final futures = <Future<Map<String, dynamic>>>[];
      for (int p = 1; p < totalPages && p < 10; p++) {
        final nextParams = Map<String, String>.from(queryParams);
        nextParams['page'] = p.toString();
        futures.add(
          apiClient.get(
            path,
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
          allProducts.addAll(_parseContentList(pageContent));
        }
      }
    }

    return allProducts;
  }

  @override
  Future<List<ProductItem>> getProducts() {
    return _fetchAllPages(ApiEndpoints.products);
  }

  @override
  Future<ProductItem> getProductById(String id) async {
    final response = await apiClient.get(
      ApiEndpoints.productById(id),
      requiresAuth: false,
    );
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return ProductItem.fromPublicJson(
        rawData,
        categories: CategoryController.instance.categories,
      );
    }
    if (rawData is Map) {
      return ProductItem.fromPublicJson(
        Map<String, dynamic>.from(rawData),
        categories: CategoryController.instance.categories,
      );
    }
    throw const ApiException(message: 'Product not found.');
  }

  @override
  Future<List<ProductItem>> getProductsByCategory(String categoryId) {
    return _fetchAllPages(ApiEndpoints.productsByCategory(categoryId));
  }

  @override
  Future<List<ProductItem>> searchProducts(String query) {
    return _fetchAllPages(
      ApiEndpoints.productsSearch,
      extraQuery: {'q': query},
    );
  }
}
