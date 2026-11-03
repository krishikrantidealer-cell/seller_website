import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/services/category_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../../logic/category/category_bloc.dart';
import '../../logic/category/category_event.dart';
import '../../logic/category/category_state.dart';
import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';
import '../widgets/app_product_image.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/mobile_navigation_drawer.dart';
import '../widgets/web_footer.dart';
import '../product_detail/product_detail_view.dart';
import '../category/category_detail_view.dart';

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

  @override
  void initState() {
    super.initState();
    CategoryController.instance.addListener(_onCatalogUpdated);
    ProductController.instance.addListener(_onCatalogUpdated);

    final categoryBloc = context.read<CategoryBloc?>();
    if (categoryBloc != null) {
      categoryBloc.add(const InitializeCategories());
    } else {
      CategoryController.instance.fetchCategories();
    }

    final productBloc = context.read<ProductBloc?>();
    if (productBloc != null) {
      productBloc.add(const InitializeProducts());
    } else {
      ProductController.instance.fetchProducts();
    }
  }

  @override
  void dispose() {
    CategoryController.instance.removeListener(_onCatalogUpdated);
    ProductController.instance.removeListener(_onCatalogUpdated);
    super.dispose();
  }

  void _onCatalogUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  List<ProductItem> _getFilteredProducts(List<ProductItem> allProducts, List<CategoryItem> categories) {
    final hasAnyBestSeller = allProducts.any((p) => p.isBestSeller);
    return allProducts.where((p) {
      if (!p.isAvailable) return false;
      final matchesBestSeller = _selectedCategory == 'all'
          ? (hasAnyBestSeller ? p.isBestSeller : true)
          : true;
      final currentCategoryItem = categories.cast<CategoryItem?>().firstWhere(
        (c) => c?.id == _selectedCategory || c?.backendId == _selectedCategory,
        orElse: () => null,
      );
      final matchesCategory = _selectedCategory == 'all' ||
          (currentCategoryItem != null && currentCategoryItem.matchesProduct(p)) ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSubcategory = _selectedSubcategory == null ||
          (currentCategoryItem != null &&
              currentCategoryItem.matchesSubcategory(p, _selectedSubcategory!)) ||
          p.title.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.category.toLowerCase().contains(_selectedSubcategory!.toLowerCase());
      final matchesSearch = _searchFilter.isEmpty ||
          p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchFilter.toLowerCase());
      return matchesBestSeller && matchesCategory && matchesSubcategory && matchesSearch;
    }).toList();
  }

  /// Returns products belonging to a Level 0 [category] (including its Level 1 & Level 2 descendants),
  /// respecting any active search filter on the Home screen.
  List<ProductItem> _getProductsForLevel0Category(CategoryItem category, List<ProductItem> allProducts) {
    return allProducts.where((p) {
      if (!p.isAvailable) return false;
      if (!category.matchesProduct(p)) return false;
      if (_searchFilter.isNotEmpty) {
        final q = _searchFilter.toLowerCase();
        return p.title.toLowerCase().contains(q) ||
            p.technicalName.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  String _getCategoryTitle(String catId) {
    if (catId == 'all') return 'All Categories';
    final match = CategoryController.instance.findCategory(catId) ??
        CategoryItem(id: catId, name: catId, icon: '');
    return match.name;
  }

  void _openCategoryDetail(String categoryId, String? subcategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailView(
          initialCategoryId: categoryId,
          initialSubcategory: subcategory,
        ),
      ),
    );
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
    final categoryBloc = context.watch<CategoryBloc?>();
    final productBloc = context.watch<ProductBloc?>();

    final categories = categoryBloc?.state.effectiveCategories.isNotEmpty == true
        ? categoryBloc!.state.effectiveCategories
        : CategoryController.instance.categories;

    final allProducts = productBloc?.state.products.isNotEmpty == true
        ? productBloc!.state.products
        : ProductController.instance.products;

    final isCatalogLoading = (categoryBloc?.state.status == CategoryStatus.loading ||
            productBloc?.state.status == ProductStatus.loading) &&
        categories.isEmpty &&
        allProducts.isEmpty;

    final isCatalogError = (categoryBloc?.state.status == CategoryStatus.error ||
            productBloc?.state.status == ProductStatus.error) &&
        categories.isEmpty &&
        allProducts.isEmpty;

    final filtered = _getFilteredProducts(allProducts, categories);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildMobileNavigationDrawer(context),
      endDrawer: const QuickCartDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight <= 1.0 || constraints.maxWidth <= 1.0) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              // Sticky Top Navigation Header with Drop Shadow
              Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Bar
                const TopInfoBar(),

                // Main Header with interactive cart tap and mobile menu tap
                MainNavHeader(
                  onMenuTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  onCartTap: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  onSearch: (query) {
                    setState(() => _searchFilter = query);
                  },
                ),

                // Category Ribbon with Dropdowns (Desktop only - on mobile, single clean header with hamburger drawer is used)
                if (isDesktop)
                  CategoryRibbon(
                    selectedCategoryId: _selectedCategory,
                    selectedSubcategory: _selectedSubcategory,
                    onCategorySelected: (catId, subcategory) {
                      _openCategoryDetail(catId, subcategory);
                    },
                  ),
              ],
            ),
          ),

          // Scrollable Page Content
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  CategoryRibbon.dismissActiveOverlay?.call();
                }
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                  // Hero Promotion Carousel
                  const HeroBannerCarousel(),

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
                          // Modern Best Sellers Section Header
                          _buildBestSellersHeader(filtered, isMobile),
                          SizedBox(height: isMobile ? 10 : 14),

                          // Loading State
                          if (isCatalogLoading)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 32 : 56),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Loading EBS BioCrop Catalog & Categories...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Connecting to live MongoDB database...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Error State (e.g. backend offline)
                          else if (isCatalogError)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 24 : 36),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cloud_off_rounded,
                                      size: 36,
                                      color: AppColors.primaryCrimson,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Backend Server Offline or Unreachable',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF991B1B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'The website is attempting to load live categories and products from:\n${AppConstants.apiBaseUrl}\n\nPlease start the Spring Boot backend server (ebs_biocrop_backend) on port 8080.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: const Color(0xFF7F1D1D),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final catB = context.read<CategoryBloc?>();
                                      final prodB = context.read<ProductBloc?>();
                                      if (catB != null) {
                                        catB.add(const FetchCategories(isRefresh: true));
                                      } else {
                                        CategoryController.instance.fetchCategories(forceRefresh: true);
                                      }
                                      if (prodB != null) {
                                        prodB.add(const FetchProducts(isRefresh: true));
                                      } else {
                                        ProductController.instance.fetchProducts(forceRefresh: true);
                                      }
                                    },
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text(
                                      'Retry Connection',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Empty Search Results
                          else if (filtered.isEmpty)
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
                                    allProducts.isEmpty
                                        ? 'No products available in the database yet.'
                                        : 'No agricultural products found matching your search.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  if (allProducts.isNotEmpty)
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
                            _buildProductGrid(filtered, constraints, maxItems: 6),

                          // Level 0 Major Category Sections rendered one by one
                          if (!isCatalogLoading && !isCatalogError)
                            ..._buildAllLevel0CategorySections(categories, allProducts, isMobile, constraints),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Integrated Footer with Trust Badges
            const WebFooter(),
          ],
        ),
      ),
    ),
  ),
  ],
);
        },
      ),
    );
  }

  Widget _buildProductGrid(
    List<ProductItem> products,
    BoxConstraints constraints, {
    int maxItems = 6,
  }) {
    int crossAxisCount = 5;
    double childAspectRatio = 0.76;
    double crossAxisSpacing = 14;
    double mainAxisSpacing = 14;

    if (constraints.maxWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.68;
      crossAxisSpacing = 8;
      mainAxisSpacing = 8;
    } else if (constraints.maxWidth < 850) {
      crossAxisCount = 3;
      childAspectRatio = 0.72;
      crossAxisSpacing = 10;
      mainAxisSpacing = 10;
    } else if (constraints.maxWidth < 1180) {
      crossAxisCount = 4;
      childAspectRatio = 0.74;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else if (constraints.maxWidth < 1520) {
      crossAxisCount = 5;
      childAspectRatio = 0.76;
      crossAxisSpacing = 14;
      mainAxisSpacing = 14;
    } else {
      crossAxisCount = 6;
      childAspectRatio = 0.78;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
    }

    final displayedProducts = products.take(maxItems).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: displayedProducts.length,
      itemBuilder: (context, index) {
        final product = displayedProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailView(product: product),
              ),
            );
          },
          onAddToCart: (p, v) => _onAddToCart(p, v),
          onBuyNow: (p, v) => _onBuyNow(p, v),
        );
      },
    );
  }

  List<Widget> _buildAllLevel0CategorySections(
    List<CategoryItem> categories,
    List<ProductItem> allProducts,
    bool isMobile,
    BoxConstraints constraints,
  ) {
    final List<Widget> sections = [];

    for (final category in categories) {
      final categoryProducts = _getProductsForLevel0Category(category, allProducts);
      if (_searchFilter.isNotEmpty && categoryProducts.isEmpty) {
        continue;
      }

      sections.add(
        Padding(
          padding: EdgeInsets.only(top: isMobile ? 20 : 30),
          child: Column(
            key: ValueKey('home_level0_section_${category.id}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevel0CategoryHeader(
                category,
                categoryProducts.length,
                isMobile,
              ),
              SizedBox(height: isMobile ? 10 : 14),
              if (categoryProducts.isNotEmpty)
                _buildProductGrid(categoryProducts, constraints, maxItems: 6)
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 18 : 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'New ${category.name} products are being stocked for this season.',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 12 : 13.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _openCategoryDetail(category.id, null),
                        child: const Text('Explore Category'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLevel0CategoryHeader(
    CategoryItem category,
    int productCount,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 18,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: accent, icon/image, category title, count, subtitle
          Expanded(
            child: Row(
              children: [
                Container(
                  width: isMobile ? 3.5 : 4,
                  height: isMobile ? 18 : 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                if (category.categoryImageUrl != null &&
                    category.categoryImageUrl!.trim().isNotEmpty) ...[
                  AppProductImage(
                    imageUrl: category.categoryImageUrl!,
                    width: isMobile ? 22 : 28,
                    height: isMobile ? 22 : 28,
                    fit: BoxFit.cover,
                    borderRadius: 6,
                  ),
                  const SizedBox(width: 8),
                ] else if (category.icon.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.icon,
                      style: TextStyle(fontSize: isMobile ? 13 : 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 15 : 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 9,
                    vertical: isMobile ? 2 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    isMobile ? '$productCount' : '$productCount Products',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 10.5 : 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.groups.isNotEmpty
                          ? '• ${category.groups.length} Subcategories • 100% Genuine EBS Agricultural Inputs'
                          : '• 100% Genuine Lab Tested EBS Agricultural Inputs',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right corner: Pinned See All Button
          _buildCategorySeeAllButton(
            categoryId: category.id,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySeeAllButton({
    required String categoryId,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCategoryDetail(categoryId, null),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.primaryDarkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 11 : 15,
            vertical: isMobile ? 5 : 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: isMobile ? 10 : 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestSellersHeader(List<ProductItem> filtered, bool isMobile) {
    final bool isFiltered = _selectedCategory != 'all' || _selectedSubcategory != null || _searchFilter.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 18,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 3.5,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Best Sellers',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              '${filtered.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDarkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildViewAllButton(isMobile: true),
                  ],
                ),
                if (isFiltered) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filtered by: ${_getCategoryTitle(_selectedCategory)}${_selectedSubcategory != null ? ' > $_selectedSubcategory' : ''}',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primaryCrimson, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = 'all';
                            _selectedSubcategory = null;
                            _searchFilter = '';
                          });
                        },
                        child: Text(
                          'Reset',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryCrimson),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Accent Bar + Best Sellers + Count + Tagline
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Best Sellers',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${filtered.length} Products',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFiltered
                        ? '• Showing ${_getCategoryTitle(_selectedCategory)}${_selectedSubcategory != null ? ' > $_selectedSubcategory' : ''}'
                        : '• 100% Genuine Lab Tested EBS Bio-Inputs with Nationwide Delivery',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Clear (if filtered) + View All Button
                if (isFiltered) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'all';
                        _selectedSubcategory = null;
                        _searchFilter = '';
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softRose,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.close_rounded, size: 13, color: AppColors.primaryCrimson),
                          const SizedBox(width: 4),
                          Text(
                            'Clear Filter',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryCrimson,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                _buildViewAllButton(isMobile: false),
              ],
            ),
    );
  }

  void _navigateToCategoryDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailView(
          initialCategoryId: _selectedCategory,
          initialSubcategory: _selectedSubcategory,
          isBestSellersOnly: _selectedCategory == 'all',
        ),
      ),
    );
  }

  Widget _buildViewAllButton({required bool isMobile}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToCategoryDetail(context),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.primaryDarkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 11.5 : 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: isMobile ? 11 : 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavigationDrawer(BuildContext context) {
    return MobileNavigationDrawer(
      selectedCategoryId: _selectedCategory,
      selectedSubcategory: _selectedSubcategory,
      onCategorySelected: (catId, sub) {
        _openCategoryDetail(catId, sub);
      },
      onAllProductsSelected: () {
        _openCategoryDetail('all', null);
      },
    );
  }


}
