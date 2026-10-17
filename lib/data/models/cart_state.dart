import 'package:flutter/foundation.dart';
import 'catalog_models.dart';

class CartItem {
  final ProductItem product;
  final ProductVariant variant;
  int quantity;

  CartItem({
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  String get key => '${product.id}_${variant.id}';
  double get totalRate => variant.displayRate * quantity;
  double get totalMrp => variant.printedMrp * quantity;
  double get totalSavings => totalMrp - totalRate;
}

class CartController extends ChangeNotifier {
  static final CartController instance = CartController._internal();
  CartController._internal();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  int get totalCount {
    int count = 0;
    for (final item in _items.values) {
      count += item.quantity;
    }
    return count;
  }

  double get subtotal {
    double sum = 0;
    for (final item in _items.values) {
      sum += item.totalRate;
    }
    return sum;
  }

  double get totalMrp {
    double sum = 0;
    for (final item in _items.values) {
      sum += item.totalMrp;
    }
    return sum;
  }

  double get totalSavings => totalMrp - subtotal;

  static const double freeShippingThreshold = 500.0;
  bool get hasFreeShipping => subtotal >= freeShippingThreshold;
  double get amountNeededForFreeShipping =>
      (freeShippingThreshold - subtotal).clamp(0.0, freeShippingThreshold);
  double get freeShippingProgress =>
      (subtotal / freeShippingThreshold).clamp(0.0, 1.0);

  int getQuantity(String productId, String variantId) {
    final key = '${productId}_$variantId';
    return _items[key]?.quantity ?? 0;
  }

  void addItem(ProductItem product, ProductVariant variant, [int quantity = 1]) {
    final key = '${product.id}_${variant.id}';
    if (_items.containsKey(key)) {
      _items[key]!.quantity += quantity;
    } else {
      _items[key] = CartItem(product: product, variant: variant, quantity: quantity);
    }
    notifyListeners();
  }

  void increment(String key) {
    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
      notifyListeners();
    }
  }

  void decrement(String key) {
    if (_items.containsKey(key)) {
      if (_items[key]!.quantity > 1) {
        _items[key]!.quantity--;
      } else {
        _items.remove(key);
      }
      notifyListeners();
    }
  }

  void removeItem(String key) {
    if (_items.remove(key) != null) {
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
