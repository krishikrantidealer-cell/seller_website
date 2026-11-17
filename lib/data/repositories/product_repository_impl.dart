import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/catalog_models.dart';
import '../services/category_api_service.dart';
import '../services/product_api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource? localDataSource;
  List<ProductItem>? _memoryCache;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  List<ProductItem> _resolveAvailableWithCategories(List<ProductItem> items) {
    final categories = CategoryController.instance.categories;
    return items
        .map((p) => p.withResolvedCategory(categories))
        .toList();
  }

  @override
  Future<List<ProductItem>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_memoryCache != null && _memoryCache!.isNotEmpty) {
        _syncInBackground();
        return _resolveAvailableWithCategories(_memoryCache!);
      }
      final cached = await localDataSource?.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        _memoryCache = _resolveAvailableWithCategories(cached);
        _syncInBackground();
        return _memoryCache!;
      }
    }

    try {
      final products = _resolveAvailableWithCategories(await remoteDataSource.getProducts());
      _memoryCache = products;
      await localDataSource?.cacheProducts(products);
      ProductController.instance.syncFromBloc(products);
      return products;
    } catch (_) {
      final cached = await getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      final fallback = _resolveAvailableWithCategories(ProductItem.sampleProducts);
      _memoryCache = fallback;
      ProductController.instance.syncFromBloc(fallback);
      return fallback;
    }
  }

  void _syncInBackground() async {
    try {
      final fresh = _resolveAvailableWithCategories(await remoteDataSource.getProducts());
      _memoryCache = fresh;
      await localDataSource?.cacheProducts(fresh);
      ProductController.instance.syncFromBloc(fresh);
    } catch (_) {}
  }

  @override
  Future<List<ProductItem>?> getCachedProducts() async {
    if (_memoryCache != null && _memoryCache!.isNotEmpty) {
      return _resolveAvailableWithCategories(_memoryCache!);
    }
    final cached = await localDataSource?.getCachedProducts();
    if (cached != null && cached.isNotEmpty) {
      _memoryCache = _resolveAvailableWithCategories(cached);
      return _memoryCache;
    }
    return null;
  }

  @override
  Future<ProductItem> getProductById(String id) async {
    final product = await remoteDataSource.getProductById(id);
    return product.withResolvedCategory(CategoryController.instance.categories);
  }

  @override
  Future<List<ProductItem>> getProductsByCategory(String categoryId) async {
    final products = await remoteDataSource.getProductsByCategory(categoryId);
    return _resolveAvailableWithCategories(products);
  }

  @override
  Future<List<ProductItem>> searchProducts(String query) async {
    final products = await remoteDataSource.searchProducts(query);
    return _resolveAvailableWithCategories(products);
  }
}
