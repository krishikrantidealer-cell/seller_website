import '../../core/storage/token_storage.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';
import '../models/catalog_models.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  final Set<String> _localVariantIds = {};
  final Map<String, ProductEntity> _localProducts = {};

  WishlistRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  WishlistEntity _buildLocalWishlist() {
    return WishlistEntity(
      variantIds: _localVariantIds.toList(),
      products: _localProducts.values.toList(),
    );
  }

  @override
  Future<WishlistEntity> getWishlist() async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.getWishlist();
        if (data.isNotEmpty) {
          final items = data['items'];
          if (items is List) {
            _localVariantIds.clear();
            for (final i in items) {
              if (i is Map && i['variantId'] != null) {
                _localVariantIds.add(i['variantId'].toString());
              }
            }
          }
        }
      } catch (_) {}
    }
    return _buildLocalWishlist();
  }

  @override
  Future<WishlistEntity> addVariant(String variantId) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        await _remoteDataSource.addVariant(variantId);
      } catch (_) {}
    }

    _localVariantIds.add(variantId);

    // Find sample product matching variantId
    for (final p in ProductItem.sampleProducts) {
      if (p.id == variantId || p.variants.any((v) => v.id == variantId)) {
        _localProducts[p.id] = ProductEntity(
          id: p.id,
          sku: 'EBS-${p.id}',
          title: p.title,
          imageUrls: [p.imageUrl],
          categoryId: p.category,
          variants: p.variants
              .map(
                (v) => ProductVariantEntity(
                  id: v.id,
                  label: v.label,
                  displayRate: v.displayRate,
                  printedMrp: v.printedMrp,
                ),
              )
              .toList(),
        );
        break;
      }
    }

    return _buildLocalWishlist();
  }

  @override
  Future<WishlistEntity> removeVariant(String variantId) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        await _remoteDataSource.removeVariant(variantId);
      } catch (_) {}
    }

    _localVariantIds.remove(variantId);
    _localProducts.remove(variantId);
    return _buildLocalWishlist();
  }

  @override
  Future<void> clearWishlist() async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        await _remoteDataSource.clearWishlist();
      } catch (_) {}
    }
    _localVariantIds.clear();
    _localProducts.clear();
  }
}
