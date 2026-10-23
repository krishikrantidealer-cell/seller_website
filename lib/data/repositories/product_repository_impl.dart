import '../../domain/entities/product_entity.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/api/product_dto.dart';
import '../models/api/collection_dto.dart';
import '../models/catalog_models.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  ProductEntity _mapSampleToEntity(ProductItem p) {
    return ProductEntity(
      id: p.id,
      sku: 'EBS-${p.id.toUpperCase()}',
      title: p.title,
      technicalName: p.technicalName,
      vendor: p.vendor,
      description: 'Authentic agricultural inputs formulated for maximum yield.',
      imageUrls: [p.imageUrl],
      categoryId: p.category.toLowerCase().replaceAll(' ', '-'),
      categoryName: p.category,
      isFeatured: p.isBestSeller,
      isAvailable: p.isAvailable,
      variants: p.variants
          .map(
            (v) => ProductVariantEntity(
              id: v.id,
              label: v.label,
              displayRate: v.displayRate,
              printedMrp: v.printedMrp,
              stock: v.inStock ? 100 : 0,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<ProductEntity>> getProducts({int page = 0, int size = 20}) async {
    try {
      final list = await _remoteDataSource.getProducts(page: page, size: size);
      if (list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductDto.fromJson(json).toEntity())
            .toList();
      }
    } catch (_) {}

    return ProductItem.sampleProducts.map(_mapSampleToEntity).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    try {
      final data = await _remoteDataSource.getProductById(productId);
      if (data.isNotEmpty) {
        return ProductDto.fromJson(data).toEntity();
      }
    } catch (_) {}

    final sample = ProductItem.sampleProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductItem.sampleProducts.first,
    );
    return _mapSampleToEntity(sample);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final list = await _remoteDataSource.getProductsByCategory(
        categoryId,
        page: page,
        size: size,
      );
      if (list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductDto.fromJson(json).toEntity())
            .toList();
      }
    } catch (_) {}

    final filtered = ProductItem.sampleProducts.where((p) {
      if (categoryId == 'all') return true;
      return p.category.toLowerCase().contains(categoryId.toLowerCase()) ||
          categoryId.toLowerCase().contains(p.category.toLowerCase());
    }).toList();

    return filtered.map(_mapSampleToEntity).toList();
  }

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    if (query.trim().isEmpty) return getProducts(page: page, size: size);

    try {
      final list = await _remoteDataSource.searchProducts(
        query,
        page: page,
        size: size,
      );
      if (list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductDto.fromJson(json).toEntity())
            .toList();
      }
    } catch (_) {}

    final lower = query.toLowerCase();
    final filtered = ProductItem.sampleProducts.where((p) {
      return p.title.toLowerCase().contains(lower) ||
          p.technicalName.toLowerCase().contains(lower) ||
          p.category.toLowerCase().contains(lower);
    }).toList();

    return filtered.map(_mapSampleToEntity).toList();
  }

  @override
  Future<List<CollectionEntity>> getCollections() async {
    try {
      final list = await _remoteDataSource.getCollections();
      if (list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => CollectionDto.fromJson(json).toEntity())
            .toList();
      }
    } catch (_) {}

    return [
      const CollectionEntity(
        id: 'best-sellers',
        name: 'Best Sellers',
        slug: 'best-sellers',
        description: 'Most popular agricultural inputs trusted by farmers across India.',
      ),
      const CollectionEntity(
        id: 'new-arrivals',
        name: 'New Arrivals',
        slug: 'new-arrivals',
        description: 'Latest crop science technology and biological formulations.',
      ),
    ];
  }
}
