import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchProductDetailEvent>(_onFetchProductDetail);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProducts(page: event.page, size: event.size);
      emit(ProductsLoadedState(products: products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onFetchProductDetail(FetchProductDetailEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _productRepository.getProductById(event.productId);
      if (product != null) {
        emit(ProductDetailLoadedState(product));
      } else {
        emit(const ProductErrorState('Product not found'));
      }
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(FilterByCategoryEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProductsByCategory(event.categoryId);
      emit(
        ProductsLoadedState(
          products: products,
          activeCategory: event.categoryId,
          activeSubcategory: event.subcategory,
        ),
      );
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onSearchProducts(SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.searchProducts(event.query);
      emit(
        ProductsLoadedState(
          products: products,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }
}
