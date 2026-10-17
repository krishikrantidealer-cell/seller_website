import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

enum CatalogStatus { initial, loading, loaded, error }

class CatalogState extends Equatable {
  final CatalogStatus status;
  final List<CategoryModel> categories;
  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final String selectedCategoryId;
  final String searchQuery;
  final Map<String, PackVariant> selectedVariants;
  final String? errorMessage;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.categories = const [],
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    this.selectedVariants = const {},
    this.errorMessage,
  });

  PackVariant getSelectedVariant(ProductModel product) {
    return selectedVariants[product.id] ?? product.defaultVariant;
  }

  CatalogState copyWith({
    CatalogStatus? status,
    List<CategoryModel>? categories,
    List<ProductModel>? allProducts,
    List<ProductModel>? filteredProducts,
    String? selectedCategoryId,
    String? searchQuery,
    Map<String, PackVariant>? selectedVariants,
    String? errorMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        allProducts,
        filteredProducts,
        selectedCategoryId,
        searchQuery,
        selectedVariants,
        errorMessage,
      ];
}
