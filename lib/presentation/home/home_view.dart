import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/web_footer.dart';
import '../product_detail/product_detail_view.dart';
import '../category/category_detail_view.dart';
import '../technical/technical_search_view.dart';
import '../profile/farmer_profile_view.dart';
import '../orders/my_orders_view.dart';
import '../../data/models/wishlist_state.dart';
import '../wishlist/wishlist_view.dart';

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
      final matchesBestSeller = _selectedCategory == 'all' ? p.isBestSeller : true;
      final currentCategoryItem = CategoryItem.sampleCategories.cast<CategoryItem?>().firstWhere(
        (c) => c?.id == _selectedCategory,
        orElse: () => null,
      );
      final categoryGroupNames = currentCategoryItem?.groups.map((g) => g.name.toLowerCase()).toList() ?? [];
      final matchesCategory = _selectedCategory == 'all' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          (currentCategoryItem != null && p.category.toLowerCase().contains(currentCategoryItem.name.toLowerCase())) ||
          (currentCategoryItem != null && currentCategoryItem.name.toLowerCase().contains(p.category.toLowerCase())) ||
          categoryGroupNames.any((g) => p.category.toLowerCase().contains(g) || g.contains(p.category.toLowerCase()));
      final matchesSubcategory = _selectedSubcategory == null ||
          p.title.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.category.toLowerCase().contains(_selectedSubcategory!.toLowerCase());
      final matchesSearch = _searchFilter.isEmpty ||
          p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_searchFilter.toLowerCase());
      return matchesBestSeller && matchesCategory && matchesSubcategory && matchesSearch;
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
    final filtered = _filteredProducts;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildMobileNavigationDrawer(context),
      endDrawer: const QuickCartDrawer(),
      body: Column(
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

                                final displayedProducts = filtered.take(6).toList();

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
                              },
                            ),
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
  ],
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
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Brand Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'EBS ',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryCrimson,
                              ),
                            ),
                            TextSpan(
                              text: 'BioCrop',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    tooltip: 'Close Menu',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Menu Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'CATEGORIES',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // All Products
                  ListTile(
                    leading: const Icon(Icons.grid_view_rounded, color: AppColors.primaryGreen),
                    title: Text(
                      'All Products',
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedCategory == 'all' ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13.5,
                        color: _selectedCategory == 'all' ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                      ),
                    ),
                    trailing: _selectedCategory == 'all'
                        ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 18)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _openCategoryDetail('all', null);
                    },
                  ),
                  const Divider(height: 1),

                  // Major Categories
                  ...CategoryItem.sampleCategories.map((cat) {
                    final isCatSelected = _selectedCategory == cat.id;
                    return ExpansionTile(
                      leading: Text(cat.icon, style: const TextStyle(fontSize: 18)),
                      title: Text(
                        cat.name,
                        style: GoogleFonts.poppins(
                          fontWeight: isCatSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13.5,
                          color: isCatSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                        ),
                      ),
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 36, right: 16),
                          title: Text(
                            'All in ${cat.name}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                              fontSize: 12.5,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _openCategoryDetail(cat.id, null);
                          },
                        ),
                        if (cat.groups.isNotEmpty)
                          ...cat.groups.map(
                            (group) => ExpansionTile(
                              dense: true,
                              tilePadding: const EdgeInsets.symmetric(horizontal: 24),
                              leading: group.icon != null
                                  ? Text(group.icon!, style: const TextStyle(fontSize: 15))
                                  : null,
                              title: Text(
                                group.name,
                                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              children: group.subcategories.map(
                                (sub) => ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.only(left: 48, right: 16),
                                  title: Text(sub, style: GoogleFonts.poppins(fontSize: 12)),
                                  trailing: (isCatSelected && _selectedSubcategory == sub)
                                      ? const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openCategoryDetail(cat.id, sub);
                                  },
                                ),
                              ).toList(),
                            ),
                          )
                        else
                          ...cat.subcategories.map(
                            (sub) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.only(left: 36, right: 16),
                              title: Text(sub, style: GoogleFonts.poppins(fontSize: 12.5)),
                              trailing: (isCatSelected && _selectedSubcategory == sub)
                                  ? const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson)
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                _openCategoryDetail(cat.id, sub);
                              },
                            ),
                          ),
                      ],
                    );
                  }),

                  const Divider(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'QUICK DISCOVERY',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primaryCrimson),
                    title: Text(
                      'My Wishlist',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: AnimatedBuilder(
                      animation: WishlistController.instance,
                      builder: (context, _) => Text(
                        '${WishlistController.instance.totalCount} saved farm products',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                    trailing: AnimatedBuilder(
                      animation: WishlistController.instance,
                      builder: (context, _) {
                        final count = WishlistController.instance.totalCount;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WishlistView()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.person_pin_circle_outlined, color: AppColors.primaryGreen),
                    title: Text(
                      'Farmer Profile & Delivery Address',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text('Manage farm depot, village & crop details', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FarmerProfileView()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.science_outlined, color: AppColors.primaryDarkGreen),
                    title: Text(
                      'Search by Technical Name',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TechnicalSearchView()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined, color: AppColors.textPrimary),
                    title: Text(
                      'Track Orders',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyOrdersView()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_in_talk_outlined, color: AppColors.primaryGreen),
                    title: Text(
                      'Helpline: 1800-203-1425',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text('Toll-Free Kisan Advisory', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
