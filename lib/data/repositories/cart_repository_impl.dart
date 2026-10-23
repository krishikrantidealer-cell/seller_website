import '../../core/storage/token_storage.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/api/cart_dto.dart';
import '../models/catalog_models.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  // Local fallback cart cache
  final Map<String, CartItemEntity> _localItems = {};

  CartRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  CartEntity _buildLocalCart() {
    double totalAmount = 0;
    double finalAmount = 0;
    for (final item in _localItems.values) {
      totalAmount += item.totalMrp;
      finalAmount += item.totalRate;
    }
    return CartEntity(
      id: 'local_cart',
      items: _localItems.values.toList(),
      totalAmount: totalAmount,
      discountAmount: (totalAmount - finalAmount).clamp(0.0, double.infinity),
      finalAmount: finalAmount,
    );
  }

  @override
  Future<CartEntity> getCart() async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.getCart();
        if (data.isNotEmpty) {
          final cart = CartDto.fromJson(data).toEntity();
          // Update local cache
          _localItems.clear();
          for (final item in cart.items) {
            _localItems[item.variantId] = item;
          }
          return cart;
        }
      } catch (_) {}
    }
    return _buildLocalCart();
  }

  @override
  Future<int> getCartCount() async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        return await _remoteDataSource.getCartCount();
      } catch (_) {}
    }
    return _localItems.values.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  @override
  Future<CartEntity> addItem({required String variantId, int quantity = 1}) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.addItem(variantId: variantId, quantity: quantity);
        if (data.isNotEmpty) {
          return CartDto.fromJson(data).toEntity();
        }
      } catch (_) {}
    }

    // Local fallback
    if (_localItems.containsKey(variantId)) {
      final existing = _localItems[variantId]!;
      _localItems[variantId] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      // Find product & variant from samples
      ProductEntity? foundProduct;
      ProductVariantEntity? foundVariant;

      for (final p in ProductItem.sampleProducts) {
        for (final v in p.variants) {
          if (v.id == variantId) {
            foundVariant = ProductVariantEntity(
              id: v.id,
              label: v.label,
              displayRate: v.displayRate,
              printedMrp: v.printedMrp,
            );
            foundProduct = ProductEntity(
              id: p.id,
              sku: 'EBS-${p.id}',
              title: p.title,
              imageUrls: [p.imageUrl],
              categoryId: p.category,
              variants: [foundVariant],
            );
            break;
          }
        }
        if (foundVariant != null) break;
      }

      final price = foundVariant?.displayRate ?? 500.0;
      _localItems[variantId] = CartItemEntity(
        id: 'item_$variantId',
        productId: foundProduct?.id ?? 'prod_$variantId',
        variantId: variantId,
        quantity: quantity,
        price: price,
        product: foundProduct,
        variant: foundVariant,
      );
    }

    return _buildLocalCart();
  }

  @override
  Future<CartEntity> updateQuantity({required String variantId, required int quantity}) async {
    if (quantity <= 0) {
      return removeItem(variantId);
    }

    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.updateQuantity(variantId: variantId, quantity: quantity);
        if (data.isNotEmpty) {
          return CartDto.fromJson(data).toEntity();
        }
      } catch (_) {}
    }

    if (_localItems.containsKey(variantId)) {
      _localItems[variantId] = _localItems[variantId]!.copyWith(quantity: quantity);
    }
    return _buildLocalCart();
  }

  @override
  Future<CartEntity> removeItem(String variantId) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.removeItem(variantId);
        if (data.isNotEmpty) {
          return CartDto.fromJson(data).toEntity();
        }
      } catch (_) {}
    }

    _localItems.remove(variantId);
    return _buildLocalCart();
  }

  @override
  Future<void> clearCart() async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        await _remoteDataSource.clearCart();
      } catch (_) {}
    }
    _localItems.clear();
  }

  @override
  Future<CartEntity> syncCart(List<Map<String, dynamic>> items) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.syncCart(items);
        if (data.isNotEmpty) {
          return CartDto.fromJson(data).toEntity();
        }
      } catch (_) {}
    }
    return _buildLocalCart();
  }
}
