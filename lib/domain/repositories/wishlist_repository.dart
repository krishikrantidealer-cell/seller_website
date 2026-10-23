import '../entities/wishlist_entity.dart';

abstract class WishlistRepository {
  Future<WishlistEntity> getWishlist();
  Future<WishlistEntity> addVariant(String variantId);
  Future<WishlistEntity> removeVariant(String variantId);
  Future<void> clearWishlist();
}
