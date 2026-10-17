import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'logic/cart/cart_bloc.dart';
import 'logic/catalog/catalog_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SellerWebsiteApp());
}

class SellerWebsiteApp extends StatelessWidget {
  const SellerWebsiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogBloc>(create: (_) => CatalogBloc()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
      ],
      child: MaterialApp.router(
        title: '${AppConstants.appName} — Essential Bio Crop Science',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
