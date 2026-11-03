import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'logic/category/category_bloc.dart';
import 'logic/category/category_event.dart';
import 'logic/product/product_bloc.dart';
import 'logic/product/product_event.dart';
import 'presentation/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.instance.init();
  runApp(const SellerWebsiteApp());
}

class SellerWebsiteApp extends StatelessWidget {
  final CategoryRepository? categoryRepository;
  final ProductRepository? productRepository;

  const SellerWebsiteApp({
    super.key,
    this.categoryRepository,
    this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    final categoryRepo =
        categoryRepository ?? InjectionContainer.instance.categoryRepository;
    final productRepo =
        productRepository ?? InjectionContainer.instance.productRepository;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CategoryRepository>.value(value: categoryRepo),
        RepositoryProvider<ProductRepository>.value(value: productRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CategoryBloc>(
            create: (ctx) => CategoryBloc(
              categoryRepository: ctx.read<CategoryRepository>(),
            )..add(const InitializeCategories()),
          ),
          BlocProvider<ProductBloc>(
            create: (ctx) => ProductBloc(
              productRepository: ctx.read<ProductRepository>(),
            )..add(const InitializeProducts()),
          ),
        ],
        child: MaterialApp(
          title: 'EBS Essential BioCrop Science | Agriculture E-Commerce',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          scrollBehavior: const AppScrollBehavior(),
          home: const HomeView(),
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
