import '../../data/models/catalog_models.dart';

abstract class ProductRepository {
  /// Fetches all public products (`GET /api/v1/products`, no auth required)
  Future<List<ProductItem>> getProducts({bool forceRefresh = false});

  /// Returns cached products immediately if available
  Future<List<ProductItem>?> getCachedProducts();

  /// Fetches a single product by ID (`GET /api/v1/products/{id}`, no auth required)
  Future<ProductItem> getProductById(String id);

  /// Fetches products for a category subtree (`GET /api/v1/products/category/{categoryId}`, no auth required)
  Future<List<ProductItem>> getProductsByCategory(String categoryId);

  /// Searches products (`GET /api/v1/products/search?q={query}`, no auth required)
  Future<List<ProductItem>> searchProducts(String query);
}
