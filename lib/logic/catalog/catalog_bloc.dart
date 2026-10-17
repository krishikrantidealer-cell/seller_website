import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/mock_catalog_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(const CatalogState()) {
    on<LoadCatalog>(_onLoadCatalog);
    on<SelectCategory>(_onSelectCategory);
    on<SearchTechnicalOrBrand>(_onSearchTechnicalOrBrand);
    on<SelectProductVariant>(_onSelectProductVariant);
  }

  void _onLoadCatalog(LoadCatalog event, Emitter<CatalogState> emit) {
    emit(state.copyWith(status: CatalogStatus.loading));
    try {
      final categories = MockCatalogRepository.categories;
      final products = MockCatalogRepository.products;

      final initialVariants = <String, PackVariant>{};
      for (final product in products) {
        initialVariants[product.id] = product.defaultVariant;
      }

      emit(state.copyWith(
        status: CatalogStatus.loaded,
        categories: categories,
        allProducts: products,
        filteredProducts: products,
        selectedCategoryId: 'all',
        selectedVariants: initialVariants,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        errorMessage: 'Failed to load agricultural catalog: $e',
      ));
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<CatalogState> emit) {
    final filtered = _filterProducts(
      state.allProducts,
      event.categoryId,
      state.searchQuery,
    );
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      filteredProducts: filtered,
    ));
  }

  void _onSearchTechnicalOrBrand(SearchTechnicalOrBrand event, Emitter<CatalogState> emit) {
    final filtered = _filterProducts(
      state.allProducts,
      state.selectedCategoryId,
      event.query,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      filteredProducts: filtered,
    ));
  }

  void _onSelectProductVariant(SelectProductVariant event, Emitter<CatalogState> emit) {
    final updated = Map<String, PackVariant>.from(state.selectedVariants);
    updated[event.productId] = event.variant;
    emit(state.copyWith(selectedVariants: updated));
  }

  List<ProductModel> _filterProducts(List<ProductModel> products, String categoryId, String query) {
    return products.where((product) {
      final matchesCategory = categoryId == 'all' || product.category == categoryId;
      if (!matchesCategory) return false;

      if (query.trim().isEmpty) return true;
      final q = query.toLowerCase().trim();

      final matchesTitle = product.title.toLowerCase().contains(q);
      final matchesBrand = product.brand.toLowerCase().contains(q);
      final matchesTechnical = product.technicalName.toLowerCase().contains(q);
      final matchesPests = product.targetPests.toLowerCase().contains(q);
      final matchesCrops = product.suitableCrops.toLowerCase().contains(q);

      return matchesTitle || matchesBrand || matchesTechnical || matchesPests || matchesCrops;
    }).toList();
  }
}
