import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();
  Future<int> getCartCount();
  Future<CartEntity> addItem({required String variantId, int quantity = 1});
  Future<CartEntity> updateQuantity({required String variantId, required int quantity});
  Future<CartEntity> removeItem(String variantId);
  Future<void> clearCart();
  Future<CartEntity> syncCart(List<Map<String, dynamic>> items);
}
