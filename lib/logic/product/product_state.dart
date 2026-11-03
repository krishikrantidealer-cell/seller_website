import 'package:equatable/equatable.dart';
import '../../data/models/catalog_models.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductItem> products;
  final List<ProductItem>? categoryProducts;
  final List<ProductItem>? searchResults;
  final String? activeCategoryId;
  final String? activeSearchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categoryProducts,
    this.searchResults,
    this.activeCategoryId,
    this.activeSearchQuery,
    this.errorMessage,
  });

  /// Returns all available products belonging to [category] (Level 0 and its Level 1/2 subtree).
  List<ProductItem> productsForCategory(CategoryItem category) {
    return products.where((p) => p.isAvailable && category.matchesProduct(p)).toList();
  }

  /// Returns featured / best-seller products.
  List<ProductItem> get bestSellerProducts {
    final featured = products.where((p) => p.isAvailable && p.isBestSeller).toList();
    if (featured.isNotEmpty) return featured;
    return products.where((p) => p.isAvailable).take(12).toList();
  }

  ProductState copyWith({
    ProductStatus? status,
    List<ProductItem>? products,
    List<ProductItem>? categoryProducts,
    bool clearCategoryProducts = false,
    List<ProductItem>? searchResults,
    bool clearSearchResults = false,
    String? activeCategoryId,
    String? activeSearchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categoryProducts: clearCategoryProducts
          ? null
          : (categoryProducts ?? this.categoryProducts),
      searchResults: clearSearchResults
          ? null
          : (searchResults ?? this.searchResults),
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      activeSearchQuery: activeSearchQuery ?? this.activeSearchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categoryProducts,
        searchResults,
        activeCategoryId,
        activeSearchQuery,
        errorMessage,
      ];
}
