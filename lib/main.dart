import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/category_repository.dart';
import 'logic/category/category_bloc.dart';
import 'logic/category/category_event.dart';
import 'presentation/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.instance.init();
  runApp(const SellerWebsiteApp());
}

class SellerWebsiteApp extends StatelessWidget {
  final CategoryRepository? categoryRepository;

  const SellerWebsiteApp({
    super.key,
    this.categoryRepository,
  });

  @override
  Widget build(BuildContext context) {
    final categoryRepo =
        categoryRepository ?? InjectionContainer.instance.categoryRepository;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CategoryRepository>.value(value: categoryRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CategoryBloc>(
            create: (ctx) => CategoryBloc(
              categoryRepository: ctx.read<CategoryRepository>(),
            )..add(const InitializeCategories()),
          ),
        ],
        child: MaterialApp(
          title: 'EBS Essential BioCrop Science | Agriculture E-Commerce',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const HomeView(),
        ),
      ),
    );
  }
}
