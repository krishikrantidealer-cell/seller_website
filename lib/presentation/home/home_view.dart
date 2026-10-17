import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/trust_features_section.dart';
import '../widgets/product_card.dart';
import '../widgets/web_footer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedCategory = 'all';
  String _searchFilter = '';
  int _cartCount = 2;

  final List<ProductItem> _allProducts = ProductItem.sampleProducts;

  List<ProductItem> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'all' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSearch = _searchFilter.isEmpty ||
          p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_searchFilter.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _onAddToCart(ProductItem product) {
    setState(() {
      _cartCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "${product.title}" to cart',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Bar
            const TopInfoBar(),

            // Main Header
            MainNavHeader(
              cartItemCount: _cartCount,
              onSearch: (query) {
                setState(() => _searchFilter = query);
              },
            ),

            // Category Ribbon
            CategoryRibbon(
              selectedCategoryId: _selectedCategory,
              onCategorySelected: (catId) {
                setState(() => _selectedCategory = catId);
              },
            ),

            // Hero Banner Carousel
            const HeroBannerCarousel(),

            // Value Proposition / Guarantee Badges
            const TrustFeaturesSection(),

            // Main Product Catalog Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title & Filters
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedCategory == 'all'
                                    ? 'Trending Agricultural Best-Sellers'
                                    : 'Products in $_selectedCategory',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Certified agricultural bio-inputs directly from EBS BioCrop Science with nationwide delivery',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Showing ${filtered.length} products',
                            style: GoogleFonts.poppins(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Product Grid
                      if (filtered.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'No products found matching your filter',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = 'all';
                                    _searchFilter = '';
                                  });
                                },
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 4;
                            if (constraints.maxWidth < 640) {
                              crossAxisCount = 1;
                            } else if (constraints.maxWidth < 900) {
                              crossAxisCount = 2;
                            } else if (constraints.maxWidth < 1200) {
                              crossAxisCount = 3;
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return ProductCard(
                                  product: product,
                                  onAddToCart: () => _onAddToCart(product),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            const WebFooter(),
          ],
        ),
      ),
    );
  }
}
