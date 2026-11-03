import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/catalog_models.dart';
import 'category_api_service.dart';

/// Centralized controller and API service for fetching and managing public
/// storefront products from `GET /api/v1/products` (without authentication).
class ProductController extends ChangeNotifier {
  static final ProductController instance = ProductController._internal();

  ProductController._internal() {
    CategoryController.instance.addListener(_onCategoriesChanged);
  }

  List<ProductItem> _products = const [];
  bool _isLoading = false;
  bool _hasLoadedFromApi = false;
  String? _errorMessage;

  /// Current active catalog products loaded from `GET /api/v1/products`.
  List<ProductItem> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasLoadedFromApi => _hasLoadedFromApi;
  String? get errorMessage => _errorMessage;

  void _onCategoriesChanged() {
    if (_products.isNotEmpty && CategoryController.instance.categories.isNotEmpty) {
      final categories = CategoryController.instance.categories;
      _products = _products.map((p) => p.withResolvedCategory(categories)).toList();
      notifyListeners();
    }
  }

  /// Returns all available products belonging to the given Level 0 [category]
  /// (including products assigned to its Level 1 subcategories or Level 2 nested categories).
  List<ProductItem> productsForCategory(CategoryItem category) {
    return _products.where((p) => p.isAvailable && category.matchesProduct(p)).toList();
  }

  /// Finds a product in memory by ID.
  ProductItem? findProductById(String id) {
    final target = id.trim();
    if (target.isEmpty) return null;
    for (final p in _products) {
      if (p.id == target) return p;
    }
    return null;
  }

  /// Fetches all public products across pages from `GET /api/v1/products`
  /// without requiring authentication.
  Future<List<ProductItem>> fetchProducts({
    http.Client? client,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return _products;
    if (_hasLoadedFromApi && !forceRefresh) return _products;

    _isLoading = true;
    _errorMessage = null;

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final List<ProductItem> allProducts = [];
      int currentPage = 0;
      int totalPages = 1;
      final categories = CategoryController.instance.categories;

      while (currentPage < totalPages && currentPage < 10) {
        final uri = Uri.parse(
          '${AppConstants.apiBaseUrl}/products?page=$currentPage&size=500',
        );
        final response = await httpClient
            .get(uri, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 8));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('HTTP ${response.statusCode} when fetching products');
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid product response envelope');
        }

        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            for (final item in content) {
              if (item is Map<String, dynamic>) {
                allProducts.add(
                  ProductItem.fromPublicJson(item, categories: categories),
                );
              } else if (item is Map) {
                allProducts.add(
                  ProductItem.fromPublicJson(
                    Map<String, dynamic>.from(item),
                    categories: categories,
                  ),
                );
              }
            }
          }
          final isLast = data['last'] == true;
          final reportedTotalPages = (data['totalPages'] is num)
              ? (data['totalPages'] as num).toInt()
              : 1;
          totalPages = reportedTotalPages;
          if (isLast || content is! List || content.isEmpty) {
            break;
          }
          currentPage++;
        } else if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              allProducts.add(
                ProductItem.fromPublicJson(item, categories: categories),
              );
            } else if (item is Map) {
              allProducts.add(
                ProductItem.fromPublicJson(
                  Map<String, dynamic>.from(item),
                  categories: categories,
                ),
              );
            }
          }
          break;
        } else {
          break;
        }
      }

      _products = allProducts;
      _hasLoadedFromApi = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
      _isLoading = false;
      notifyListeners();
    }

    return _products;
  }

  /// Synchronizes the controller state when `ProductBloc` emits new products.
  void syncFromBloc(List<ProductItem> items) {
    final categories = CategoryController.instance.categories;
    _products = items.map((p) => p.withResolvedCategory(categories)).toList();
    _hasLoadedFromApi = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets the controller to the built-in sample products (used in widget tests).
  @visibleForTesting
  void resetToSampleProducts() {
    _products = ProductItem.sampleProducts;
    _isLoading = false;
    _hasLoadedFromApi = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Directly sets products for unit/widget testing.
  @visibleForTesting
  void setProductsForTesting(List<ProductItem> items) {
    _products = items;
    _hasLoadedFromApi = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
