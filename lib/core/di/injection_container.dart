import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../network/api_client.dart';
import '../storage/token_storage.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/datasources/order_remote_datasource.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/repositories/order_repository.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/category/category_bloc.dart';
import '../../logic/category/category_event.dart';
import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/cart/cart_bloc.dart';
import '../../logic/cart/cart_event.dart';
import '../../logic/wishlist/wishlist_bloc.dart';
import '../../logic/wishlist/wishlist_event.dart';
import '../../logic/order/order_bloc.dart';
import '../../logic/order/order_event.dart';

class AppBlocProviders extends StatelessWidget {
  final Widget child;

  const AppBlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 1. Core Services
    final httpClient = http.Client();
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(client: httpClient, tokenStorage: tokenStorage);

    // 2. DataSources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    final categoryRemoteDataSource = CategoryRemoteDataSourceImpl(apiClient);
    final productRemoteDataSource = ProductRemoteDataSourceImpl(apiClient);
    final cartRemoteDataSource = CartRemoteDataSourceImpl(apiClient);
    final wishlistRemoteDataSource = WishlistRemoteDataSourceImpl(apiClient);
    final orderRemoteDataSource = OrderRemoteDataSourceImpl(apiClient);

    // 3. Repositories
    final authRepository = AuthRepositoryImpl(authRemoteDataSource, tokenStorage);
    final categoryRepository = CategoryRepositoryImpl(categoryRemoteDataSource);
    final productRepository = ProductRepositoryImpl(productRemoteDataSource);
    final cartRepository = CartRepositoryImpl(cartRemoteDataSource, tokenStorage);
    final wishlistRepository = WishlistRepositoryImpl(wishlistRemoteDataSource, tokenStorage);
    final orderRepository = OrderRepositoryImpl(orderRemoteDataSource, tokenStorage);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepository),
        RepositoryProvider<ProductRepository>.value(value: productRepository),
        RepositoryProvider<CartRepository>.value(value: cartRepository),
        RepositoryProvider<WishlistRepository>.value(value: wishlistRepository),
        RepositoryProvider<OrderRepository>.value(value: orderRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository)..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<CategoryBloc>(
            create: (_) => CategoryBloc(categoryRepository)..add(FetchCategoriesEvent()),
          ),
          BlocProvider<ProductBloc>(
            create: (_) => ProductBloc(productRepository)..add(const FetchProductsEvent()),
          ),
          BlocProvider<CartBloc>(
            create: (_) => CartBloc(cartRepository)..add(LoadCartEvent()),
          ),
          BlocProvider<WishlistBloc>(
            create: (_) => WishlistBloc(wishlistRepository)..add(LoadWishlistEvent()),
          ),
          BlocProvider<OrderBloc>(
            create: (_) => OrderBloc(orderRepository)..add(const FetchCustomerOrdersEvent()),
          ),
        ],
        child: child,
      ),
    );
  }
}
