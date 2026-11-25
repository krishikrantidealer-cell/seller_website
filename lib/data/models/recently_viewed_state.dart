import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catalog_models.dart';

class RecentlyViewedController extends ChangeNotifier {
  static final RecentlyViewedController instance = RecentlyViewedController._internal();
  static const String _storageKey = 'seller_website_recently_viewed_v1';
  static const int _maxItems = 12;

  final List<String> _productIds = [];
  bool _clearedExplicitly = false;

  RecentlyViewedController._internal() {
    _hydrate();
  }

  List<String> get productIds => List.unmodifiable(_productIds);

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_clearedExplicitly) {
        await prefs.remove(_storageKey);
        return;
      }
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final hydrated = <String>[];
      for (final item in decoded) {
        final id = item?.toString().trim() ?? '';
        if (id.isNotEmpty && !hydrated.contains(id) && !_productIds.contains(id)) {
          hydrated.add(id);
        }
      }
      if (hydrated.isNotEmpty) {
        _productIds.addAll(hydrated);
        if (_productIds.length > _maxItems) {
          _productIds.removeRange(_maxItems, _productIds.length);
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_productIds));
    } catch (_) {}
  }

  void recordView(ProductItem product) {
    final id = product.id.trim();
    if (id.isEmpty) return;
    _clearedExplicitly = false;
    _productIds.remove(id);
    _productIds.insert(0, id);
    if (_productIds.length > _maxItems) {
      _productIds.removeRange(_maxItems, _productIds.length);
    }
    notifyListeners();
    _persist();
  }

  List<ProductItem> resolveProducts(List<ProductItem> allProducts, {int limit = 6}) {
    if (_productIds.isEmpty || allProducts.isEmpty) return const [];
    final byId = <String, ProductItem>{
      for (final p in allProducts)
        if (p.isInStock) p.id: p,
    };
    final result = <ProductItem>[];
    for (final id in _productIds) {
      final match = byId[id];
      if (match != null) {
        result.add(match);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  void clear() {
    _clearedExplicitly = true;
    _productIds.clear();
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.remove(_storageKey));
  }
}
