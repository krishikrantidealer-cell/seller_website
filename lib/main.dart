import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'presentation/home/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SellerWebsiteApp());
}

class SellerWebsiteApp extends StatelessWidget {
  const SellerWebsiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: MaterialApp(
        title: 'EBS Essential BioCrop Science | Agriculture E-Commerce',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeView(),
      ),
    );
  }
}
