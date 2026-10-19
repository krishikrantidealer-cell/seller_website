import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/web_footer.dart';
import '../product_detail/product_detail_view.dart';

class CategoryDetailView extends StatefulWidget {
  final String initialCategoryId;
  final String? initialSubcategory;
  final String? initialTechnicalName;
  final bool isBestSellersOnly;

  const CategoryDetailView({
    super.key,
    this.initialCategoryId = 'all',
    this.initialSubcategory,
    this.initialTechnicalName,
    this.isBestSellersOnly = false,
  });

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _selectedCategory;
  late String? _selectedSubcategory;
  late String? _selectedTechnicalName;
  late bool _isBestSellersMode;
  String _searchFilter = '';
  String _sortBy = 'featured';

  final List<ProductItem> _allProducts = ProductItem.sampleProducts;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryId;
    _selectedSubcategory = widget.initialSubcategory;
    _selectedTechnicalName = widget.initialTechnicalName;
    _isBestSellersMode = widget.isBestSellersOnly;
  }

  List<ProductItem> get _filteredProducts {
    final list = _allProducts.where((p) {
      final matchesBestSeller = !_isBestSellersMode || p.isBestSeller;
      final matchesCategory = _selectedCategory == 'all' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSubcategory = _selectedSubcategory == null ||
          p.title.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.category.toLowerCase().contains(_selectedSubcategory!.toLowerCase());
      final matchesTechnical = _selectedTechnicalName == null ||
          p.technicalName.toLowerCase().contains(_selectedTechnicalName!.toLowerCase()) ||
          _selectedTechnicalName!.toLowerCase().contains(p.technicalName.toLowerCase());
      final matchesSearch = _searchFilter.isEmpty ||
          p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_searchFilter.toLowerCase());
      return matchesBestSeller && matchesCategory && matchesSubcategory && matchesTechnical && matchesSearch;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.displayRate.compareTo(b.displayRate));
        break;
      case 'price_desc':
        list.sort((a, b) => b.displayRate.compareTo(a.displayRate));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'featured':
      default:
        break;
    }

    return list;
  }

  String _getCategoryTitle(String catId) {
    if (catId == 'all') return 'All Categories';
    final match = CategoryItem.sampleCategories.firstWhere(
      (c) => c.id == catId,
      orElse: () => CategoryItem(id: catId, name: catId, icon: '🌿'),
    );
    return match.name;
  }

  List<String> _getCurrentSubcategories() {
    if (_selectedCategory == 'all') return [];
    final match = CategoryItem.sampleCategories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => CategoryItem(id: _selectedCategory, name: '', icon: ''),
    );
    return match.subcategories;
  }

  void _onAddToCart(ProductItem product, ProductVariant variant) {
    CartController.instance.addItem(product, variant, 1);
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
    CartController.instance.addItem(product, variant, 1);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    final currentSubcategories = _getCurrentSubcategories();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
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

                // Main Header with search and cart tap
                MainNavHeader(
                  onCartTap: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  onSearch: (query) {
                    setState(() => _searchFilter = query);
                  },
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

            // Main Content Area
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: isMobile ? 12 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb & Back Navigation
                          _buildBreadcrumbBar(isMobile),

                          const SizedBox(height: 12),

                          // Header Card with Category Title, Product Count, and Sort Dropdown
                          _buildHeaderCard(filtered.length, isMobile),

                          // Active Technical Formulation Filter Pill
                          if (_selectedTechnicalName != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.science_outlined, size: 18, color: AppColors.primaryDarkGreen),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primaryDarkGreen),
                                        children: [
                                          const TextSpan(text: 'Showing all brands formulated with: '),
                                          TextSpan(
                                            text: _selectedTechnicalName!,
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() => _selectedTechnicalName = null);
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Clear',
                                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDarkGreen),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.close_rounded, size: 14, color: AppColors.primaryDarkGreen),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Category Switcher Pills & Subcategories (only for regular category browsing, NOT in Best Sellers mode)
                          if (!_isBestSellersMode && _selectedTechnicalName == null) ...[
                            const SizedBox(height: 12),
                            _buildCategoryPills(isMobile),
                            if (currentSubcategories.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _buildSubcategoriesRow(currentSubcategories),
                            ],
                          ],

                          const SizedBox(height: 16),

                          // Product Grid
                          if (filtered.isEmpty)
                            _buildEmptyState(isMobile)
                          else
                            _buildProductGrid(filtered, constraints),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Integrated Footer
            const WebFooter(),
          ],
        ),
      ),
    ),
  ],
),
);
}

  Widget _buildBreadcrumbBar(bool isMobile) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Home',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  '  /  ',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                if (!_isBestSellersMode) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'all';
                        _selectedSubcategory = null;
                      });
                    },
                    child: Text(
                      'Categories',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    '  /  ',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
                Text(
                  _selectedTechnicalName != null
                      ? 'Technical Formulations'
                      : (_isBestSellersMode
                          ? 'Best Sellers'
                          : (_selectedCategory == 'all' ? 'All Products' : _getCategoryTitle(_selectedCategory))),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                if (_selectedTechnicalName != null) ...[
                  Text(
                    '  /  ',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    _selectedTechnicalName!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else if (_selectedSubcategory != null) ...[
                  Text(
                    '  /  ',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    _selectedSubcategory!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(int count, bool isMobile) {
    final String pageTitle = _selectedTechnicalName != null
        ? _selectedTechnicalName!
        : (_selectedCategory == 'all'
            ? (_isBestSellersMode ? 'Best Sellers' : 'All Products')
            : _getCategoryTitle(_selectedCategory));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pageTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        _isBestSellersMode && _selectedCategory == 'all'
                            ? '$count Best Sellers'
                            : '$count Products',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort by:',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    _buildSortDropdown(),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pageTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _isBestSellersMode && _selectedCategory == 'all'
                        ? '$count Best Sellers Available'
                        : '$count Products Available',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Sort by: ',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                _buildSortDropdown(),
              ],
            ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: const [
            DropdownMenuItem(value: 'featured', child: Text('Featured')),
            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
            DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
            DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _sortBy = val);
          },
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPill(
            label: 'All Products',
            isSelected: _selectedCategory == 'all',
            onTap: () {
              setState(() {
                _selectedCategory = 'all';
                _selectedSubcategory = null;
              });
            },
          ),
          ...CategoryItem.sampleCategories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildPill(
                label: cat.name,
                iconEmoji: cat.icon,
                isSelected: _selectedCategory == cat.id,
                onTap: () {
                  setState(() {
                    _selectedCategory = cat.id;
                    _selectedSubcategory = null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    String? iconEmoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconEmoji != null) ...[
              Text(iconEmoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
            ] else if (isSelected) ...[
              const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesRow(List<String> subcategories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Subcategories: ',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() => _selectedSubcategory = null);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _selectedSubcategory == null ? AppColors.primaryDarkGreen : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'All in Category',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _selectedSubcategory == null ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          ...subcategories.map((sub) {
            final isSelected = _selectedSubcategory == sub;
            return InkWell(
              onTap: () {
                setState(() => _selectedSubcategory = sub);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDarkGreen : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sub,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Container(
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
            'No products found matching your filter criteria.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedCategory = 'all';
                _selectedSubcategory = null;
                _searchFilter = '';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset All Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductItem> filtered, BoxConstraints constraints) {
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
}
