import 'package:flutter/foundation.dart';
import 'catalog_models.dart';

/// Centralized state controller for user liked/wishlist items.
class WishlistController extends ChangeNotifier {
  static final WishlistController instance = WishlistController._internal();
  WishlistController._internal();

  final Map<String, ProductItem> _items = {};

  List<ProductItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get totalCount => _items.length;

  bool isLiked(String productId) => _items.containsKey(productId);

  /// Toggles wishlist status for a product. Returns true if added, false if removed.
  bool toggleWishlist(ProductItem product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
      notifyListeners();
      return false;
    } else {
      _items[product.id] = product;
      notifyListeners();
      return true;
    }
  }

  void add(ProductItem product) {
    if (!_items.containsKey(product.id)) {
      _items[product.id] = product;
      notifyListeners();
    }
  }

  void remove(String productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }
}
