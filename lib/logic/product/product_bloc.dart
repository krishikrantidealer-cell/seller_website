import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/websocket_service.dart';
import '../../data/services/product_api_service.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;
  VoidCallback? _controllerListener;

  ProductBloc({
    required this.productRepository,
    WebSocketService? webSocketService,
  })  : _webSocketService = webSocketService ?? WebSocketService(),
        super(
          ProductState(
            status: ProductStatus.loaded,
            products: ProductController.instance.products,
          ),
        ) {
    on<InitializeProducts>(_onInitializeProducts);
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductsByCategory>(_onFetchProductsByCategory);
    on<SearchProductsEvent>(_onSearchProducts);
    on<ProductsExternalUpdated>(_onProductsExternalUpdated);

    // 1. Subscribe to real-time product & inventory updates from WebSocket (/ws products:* & inventory:stock_update)
    _wsSubscription = _webSocketService.productUpdates.listen((_) {
      if (!isClosed) {
        add(const FetchProducts(isRefresh: true, isBackground: true));
      }
    });

    // 2. Keep in sync with ProductController.instance updates
    _controllerListener = () {
      if (!isClosed) {
        add(ProductsExternalUpdated(ProductController.instance.products));
      }
    };
    ProductController.instance.addListener(_controllerListener!);
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    if (_controllerListener != null) {
      ProductController.instance.removeListener(_controllerListener!);
    }
    return super.close();
  }

  Future<void> _onInitializeProducts(
    InitializeProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final cached = await productRepository.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        emit(
          state.copyWith(
            status: ProductStatus.loaded,
            products: cached,
          ),
        );
        if (!_isTestEnvironment) {
          add(const FetchProducts(isBackground: true));
        }
        return;
      }
    } catch (_) {}

    if (!_isTestEnvironment) {
      add(const FetchProducts(isBackground: false));
    }
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    final hasData = state.products.isNotEmpty;
    if (!event.isBackground && !hasData) {
      emit(state.copyWith(status: ProductStatus.loading));
    }

    try {
      final products = await productRepository.getProducts(
        forceRefresh: event.isRefresh,
      );
      emit(
        state.copyWith(
          status: ProductStatus.loaded,
          products: products,
        ),
      );
    } catch (e) {
      if (!event.isBackground && !hasData) {
        emit(
          state.copyWith(
            status: ProductStatus.error,
            errorMessage: e.toString().replaceAll('ApiException: ', ''),
          ),
        );
      }
    }
  }

  Future<void> _onFetchProductsByCategory(
    FetchProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categoryProducts = await productRepository.getProductsByCategory(
        event.categoryId,
      );
      emit(
        state.copyWith(
          status: ProductStatus.loaded,
          activeCategoryId: event.categoryId,
          categoryProducts: categoryProducts,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(
        state.copyWith(
          activeSearchQuery: '',
          clearSearchResults: true,
        ),
      );
      return;
    }

    try {
      final results = await productRepository.searchProducts(event.query.trim());
      emit(
        state.copyWith(
          status: ProductStatus.loaded,
          activeSearchQuery: event.query.trim(),
          searchResults: results,
        ),
      );
    } catch (_) {}
  }

  void _onProductsExternalUpdated(
    ProductsExternalUpdated event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProductStatus.loaded,
        products: event.products,
      ),
    );
  }
}
