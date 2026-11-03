import 'package:equatable/equatable.dart';
import '../../data/models/catalog_models.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes products from local cache first, then fetches fresh data from `/api/v1/products`.
class InitializeProducts extends ProductEvent {
  const InitializeProducts();
}

/// Fetches products from the public backend API (`GET /api/v1/products`).
class FetchProducts extends ProductEvent {
  final bool isRefresh;
  final bool isBackground;

  const FetchProducts({
    this.isRefresh = false,
    this.isBackground = false,
  });

  @override
  List<Object?> get props => [isRefresh, isBackground];
}

/// Fetches products for a specific category subtree (`GET /api/v1/products/category/{categoryId}`).
class FetchProductsByCategory extends ProductEvent {
  final String categoryId;

  const FetchProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Searches products (`GET /api/v1/products/search?q={query}`).
class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Internal event triggered when `ProductController` updates products externally.
class ProductsExternalUpdated extends ProductEvent {
  final List<ProductItem> products;

  const ProductsExternalUpdated(this.products);

  @override
  List<Object?> get props => [products];
}
