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
import '../widgets/cart_drawer.dart';
import '../widgets/web_footer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedCategory = 'all';
  String? _selectedSubcategory;
  String _searchFilter = '';

  final List<ProductItem> _allProducts = ProductItem.sampleProducts;

  List<ProductItem> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'all' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSubcategory = _selectedSubcategory == null ||
          p.title.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.category.toLowerCase().contains(_selectedSubcategory!.toLowerCase());
      final matchesSearch = _searchFilter.isEmpty ||
          p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_searchFilter.toLowerCase());
      return matchesCategory && matchesSubcategory && matchesSearch;
    }).toList();
  }

  String _getCategoryTitle(String catId) {
    if (catId == 'all') return 'All Categories';
    final match = CategoryItem.sampleCategories.firstWhere(
      (c) => c.id == catId,
      orElse: () => CategoryItem(id: catId, name: catId, icon: '🌿'),
    );
    return match.name;
  }

  void _onAddToCart(ProductItem product, ProductVariant variant) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${product.title} (${variant.label}) to cart',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _onBuyNow(ProductItem product, ProductVariant variant) {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: const QuickCartDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Bar
            const TopInfoBar(),

            // Main Header with interactive cart tap
            MainNavHeader(
              onCartTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              onSearch: (query) {
                setState(() => _searchFilter = query);
              },
            ),

            // Category Ribbon with Dropdowns
            CategoryRibbon(
              selectedCategoryId: _selectedCategory,
              selectedSubcategory: _selectedSubcategory,
              onCategorySelected: (catId, subcategory) {
                setState(() {
                  _selectedCategory = catId;
                  _selectedSubcategory = subcategory;
                });
              },
            ),

            // Hero Promotion Carousel
            const HeroBannerCarousel(),

            // Value Proposition / Guarantee Badges
            const TrustFeaturesSection(),

            // Main Product Catalog Section
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 20,
                    vertical: isMobile ? 12 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Category / Subcategory Filter Badge
                          if (_selectedCategory != 'all' || _selectedSubcategory != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.softRose,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primaryCrimson),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Filtering: ${_getCategoryTitle(_selectedCategory)}${_selectedSubcategory != null ? ' > $_selectedSubcategory' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryCrimson,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = 'all';
                                        _selectedSubcategory = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryCrimson,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Reset',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(Icons.close, size: 12, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Section Title & Filters
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCategory == 'all'
                                        ? 'Trending Agricultural Best-Sellers'
                                        : '${_getCategoryTitle(_selectedCategory)}${_selectedSubcategory != null ? ' - $_selectedSubcategory' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Certified agricultural bio-inputs directly from EBS BioCrop Science with nationwide delivery',
                                    style: GoogleFonts.poppins(
                                      fontSize: isMobile ? 11.5 : 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Showing ${filtered.length} products',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: isMobile ? 11 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 12 : 20),

                          // Product Grid
                          if (filtered.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 24 : 48),
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
                                    'No agricultural products found matching your search.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
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
                            Builder(
                              builder: (context) {
                                int crossAxisCount = 5;
                                double childAspectRatio = 0.63;
                                double crossAxisSpacing = 14;
                                double mainAxisSpacing = 14;

                                if (constraints.maxWidth < 600) {
                                  crossAxisCount = 2;
                                  childAspectRatio = 0.54;
                                  crossAxisSpacing = 8;
                                  mainAxisSpacing = 8;
                                } else if (constraints.maxWidth < 850) {
                                  crossAxisCount = 3;
                                  childAspectRatio = 0.58;
                                  crossAxisSpacing = 10;
                                  mainAxisSpacing = 10;
                                } else if (constraints.maxWidth < 1180) {
                                  crossAxisCount = 4;
                                  childAspectRatio = 0.62;
                                  crossAxisSpacing = 12;
                                  mainAxisSpacing = 12;
                                } else if (constraints.maxWidth < 1520) {
                                  crossAxisCount = 5;
                                  childAspectRatio = 0.63;
                                  crossAxisSpacing = 14;
                                  mainAxisSpacing = 14;
                                } else {
                                  crossAxisCount = 6;
                                  childAspectRatio = 0.64;
                                  crossAxisSpacing = 16;
                                  mainAxisSpacing = 16;
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: mainAxisSpacing,
                                    childAspectRatio: childAspectRatio,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final product = filtered[index];
                                    return ProductCard(
                                      product: product,
                                      onAddToCart: (p, v) => _onAddToCart(p, v),
                                      onBuyNow: (p, v) => _onBuyNow(p, v),
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Footer
            const WebFooter(),
          ],
        ),
      ),
    );
  }
}
