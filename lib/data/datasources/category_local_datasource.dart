import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/category_api_service.dart';

abstract class CategoryLocalDataSource {
  Future<List<ApiCategoryRecord>?> getCachedRecords();
  Future<void> cacheRecords(List<ApiCategoryRecord> records);
  Future<void> clearCache();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final SharedPreferences? prefs;
  List<ApiCategoryRecord>? _memoryCache;

  CategoryLocalDataSourceImpl([this.prefs]);

  static const String _categoriesCacheKey = 'seller_website_cached_categories_v1';

  @override
  Future<List<ApiCategoryRecord>?> getCachedRecords() async {
    if (_memoryCache != null && _memoryCache!.isNotEmpty) {
      return _memoryCache;
    }

    final store = prefs ?? await SharedPreferences.getInstance();
    final raw = store.getString(_categoriesCacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _memoryCache = decoded
          .whereType<Map>()
          .map((item) => ApiCategoryRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return _memoryCache;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheRecords(List<ApiCategoryRecord> records) async {
    _memoryCache = records;
    try {
      final store = prefs ?? await SharedPreferences.getInstance();
      final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
      await store.setString(_categoriesCacheKey, encoded);
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    _memoryCache = null;
    try {
      final store = prefs ?? await SharedPreferences.getInstance();
      await store.remove(_categoriesCacheKey);
    } catch (_) {}
  }
}
