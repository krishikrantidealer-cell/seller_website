import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catalog_models.dart';
import '../services/category_api_service.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductItem>?> getCachedProducts();
  Future<void> cacheProducts(List<ProductItem> products);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences? _prefs;
  static const String _cacheKey = 'seller_website_live_products_v3';

  List<ProductItem>? _memoryCache;

  ProductLocalDataSourceImpl([this._prefs]);

  @override
  Future<List<ProductItem>?> getCachedProducts() async {
    if (_memoryCache != null && _memoryCache!.isNotEmpty) {
      return _memoryCache;
    }

    try {
      final store = _prefs ?? await SharedPreferences.getInstance();
      final jsonString = store.getString(_cacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final categories = CategoryController.instance.categories;
        _memoryCache = decoded
            .whereType<Map>()
            .map(
              (m) => ProductItem.fromPublicJson(
                Map<String, dynamic>.from(m),
                categories: categories,
              ),
            )
            .toList();
        return _memoryCache;
      }
    } catch (_) {
      await clearCache();
      return null;
    }
    return null;
  }

  @override
  Future<void> cacheProducts(List<ProductItem> products) async {
    _memoryCache = products;
    try {
      final store = _prefs ?? await SharedPreferences.getInstance();
      final jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
      await store.setString(_cacheKey, jsonString);
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    _memoryCache = null;
    try {
      final store = _prefs ?? await SharedPreferences.getInstance();
      await store.remove(_cacheKey);
    } catch (_) {}
  }
}
