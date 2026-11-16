import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../models/catalog_models.dart';

/// Public storefront controller for dynamic Technical Names (`GET /api/v1/technical-names`).
class TechnicalNameController extends ChangeNotifier {
  static final TechnicalNameController instance =
      TechnicalNameController._internal();

  TechnicalNameController._internal();

  List<TechnicalItem> _items = const [];
  bool _isLoading = false;
  bool _hasLoadedFromApi = false;

  List<TechnicalItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasLoadedFromApi => _hasLoadedFromApi;

  Future<List<TechnicalItem>> fetchTechnicalNames({
    http.Client? client,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return _items;
    if (_hasLoadedFromApi && !forceRefresh) return _items;

    _isLoading = true;
    notifyListeners();

    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}${ApiEndpoints.technicalNames}',
      );
      final response = await httpClient.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final rawList = decoded is Map ? decoded['data'] : decoded;
        if (rawList is List) {
          _items = rawList
              .whereType<Map>()
              .map((raw) {
                final map = Map<String, dynamic>.from(raw);
                final name = (map['name'] ?? '').toString().trim();
                final category = (map['category'] ?? '').toString().trim();
                return TechnicalItem(
                  name: name,
                  category: category.isNotEmpty ? category : 'Agricultural Input',
                  description: category.isNotEmpty
                      ? 'Category: $category'
                      : 'Active technical formulation',
                );
              })
              .where((item) => item.name.isNotEmpty)
              .toList();
          _hasLoadedFromApi = true;
        }
      }
    } catch (e) {
      debugPrint('Failed to load public technical names: $e');
    } finally {
      _isLoading = false;
      if (client == null) {
        httpClient.close();
      }
      notifyListeners();
    }
    return _items;
  }
}
