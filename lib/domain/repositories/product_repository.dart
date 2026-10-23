import '../entities/product_entity.dart';
import '../entities/collection_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int page = 0, int size = 20});
  Future<ProductEntity?> getProductById(String productId);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId, {int page = 0, int size = 20});
  Future<List<ProductEntity>> searchProducts(String query, {int page = 0, int size = 20});
  Future<List<CollectionEntity>> getCollections();
}
