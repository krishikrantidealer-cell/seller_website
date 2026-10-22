import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/mobile_navigation_drawer.dart';
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
    final currentCategoryItem = CategoryItem.sampleCategories.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == _selectedCategory,
      orElse: () => null,
    );
    final categoryGroupNames = currentCategoryItem?.groups.map((g) => g.name.toLowerCase()).toList() ?? [];

    final list = _allProducts.where((p) {
      final matchesBestSeller = !_isBestSellersMode || p.isBestSeller;
      final matchesCategory = _selectedCategory == 'all' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          (currentCategoryItem != null && p.category.toLowerCase().contains(currentCategoryItem.name.toLowerCase())) ||
          (currentCategoryItem != null && currentCategoryItem.name.toLowerCase().contains(p.category.toLowerCase())) ||
          categoryGroupNames.any((g) => p.category.toLowerCase().contains(g) || g.contains(p.category.toLowerCase()));

      final matchesSubcategory = _selectedSubcategory == null ||
          p.category.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          _selectedSubcategory!.toLowerCase().contains(p.category.toLowerCase()) ||
          p.title.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_selectedSubcategory!.toLowerCase());

      final matchesTechnical = _selectedTechnicalName == null ||
          p.technicalName.toLowerCase().contains(_selectedTechnicalName!.toLowerCase()) ||
          _selectedTechnicalName!.toLowerCase().contains(p.technicalName.toLowerCase());

      final matchesSearch = _searchFilter.isEmpty ||
          p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.technicalName.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchFilter.toLowerCase());

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

  List<String> _getCurrentSubcategories() {
    if (_selectedCategory == 'all') return [];
    final match = CategoryItem.sampleCategories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => CategoryItem(id: _selectedCategory, name: '', icon: ''),
    );
    if (_selectedSubcategory != null) {
      final activeGroup = match.groups.cast<CategoryGroup?>().firstWhere(
        (g) => g?.name.toLowerCase() == _selectedSubcategory!.toLowerCase(),
        orElse: () => null,
      );
      if (activeGroup != null) {
        return activeGroup.subcategories;
      }
    }
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

                // Main Header with search and cart tap
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

                // Category Ribbon (Desktop only)
                if (isDesktop)
                  CategoryRibbon(
                    selectedCategoryId: _selectedCategory,
                    selectedSubcategory: _selectedSubcategory,
                    onCategorySelected: (catId, subcategory) {
                      setState(() {
                        _selectedCategory = catId;
                        _selectedSubcategory = subcategory;
                        _selectedTechnicalName = null;
                      });
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
                          horizontal: isMobile ? 8 : 24,
                          vertical: isMobile ? 8 : 20,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1680),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Action Bar: Clean Back button on left, Filter/Sort button on right (zero wasted card space)
                                _buildTopActionBar(isMobile),
                                const SizedBox(height: 8),

                                // Active Technical Formulation Filter Pill
                                if (_selectedTechnicalName != null) ...[
                                  _buildTechnicalActivePill(),
                                  const SizedBox(height: 8),
                                ],

                                // Categories of this Major Category (Rendered in both Mobile & Desktop)
                                if (!_isBestSellersMode && _selectedTechnicalName == null) ...[
                                  _buildCategoryPills(isMobile),
                                  // Subcategories row (Desktop ONLY: !isMobile)
                                  if (!isMobile && currentSubcategories.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _buildSubcategoriesRow(currentSubcategories, isMobile: isMobile),
                                  ],
                                  const SizedBox(height: 10),
                                ],

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

  Widget _buildTopActionBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 6 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 14,
                vertical: isMobile ? 5 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: isMobile ? 14 : 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Button
          _buildFilterSortButton(isMobile),
        ],
      ),
    );
  }

  Widget _buildFilterSortButton(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 12, vertical: isMobile ? 2 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune_rounded, size: isMobile ? 14 : 18, color: AppColors.primaryGreen),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: isMobile ? 14 : 18, color: AppColors.textPrimary),
              items: [
                const DropdownMenuItem(value: 'featured', child: Text('Featured')),
                DropdownMenuItem(value: 'price_asc', child: Text(isMobile ? '₹ Low' : 'Price: Low to High')),
                DropdownMenuItem(value: 'price_desc', child: Text(isMobile ? '₹ High' : 'Price: High to Low')),
                DropdownMenuItem(value: 'rating', child: Text(isMobile ? 'Top' : 'Highest Rated')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _sortBy = val);
              },
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 10.5 : 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalActivePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }





  Widget _buildCategoryPills(bool isMobile) {
    final activeCat = CategoryItem.sampleCategories.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == _selectedCategory,
      orElse: () => null,
    );

    // If a major category is selected, show its categories as the pill row
    if (activeCat != null) {
      final List<Widget> children = [
        _buildPill(
          label: isMobile ? 'All' : 'All in ${activeCat.name}',
          iconEmoji: activeCat.icon,
          isSelected: _selectedSubcategory == null,
          isMobile: isMobile,
          onTap: () {
            setState(() => _selectedSubcategory = null);
          },
        ),
      ];

      if (activeCat.groups.isNotEmpty) {
        for (final group in activeCat.groups) {
          final isGroupSelected = _selectedSubcategory == group.name;
          children.add(
            _buildPill(
              label: group.name,
              iconEmoji: group.icon,
              isSelected: isGroupSelected,
              isMobile: isMobile,
              onTap: () {
                setState(() => _selectedSubcategory = group.name);
              },
            ),
          );
        }
      } else if (activeCat.subcategories.isNotEmpty) {
        for (final sub in activeCat.subcategories) {
          final isSubSelected = _selectedSubcategory == sub;
          children.add(
            _buildPill(
              label: sub,
              isSelected: isSubSelected,
              isMobile: isMobile,
              onTap: () {
                setState(() => _selectedSubcategory = sub);
              },
            ),
          );
        }
      }

      if (children.length <= 1) {
        return const SizedBox.shrink();
      }

      if (isMobile) {
        return SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: children
                .map((p) => Padding(padding: const EdgeInsets.only(right: 6), child: p))
                .toList(),
          ),
        );
      }

      // On desktop / laptop, wrap pills into rows so no category chip is ever cut off
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }

    // When on 'All Products' in mobile view: do not show redundant major categories
    if (isMobile) {
      return const SizedBox.shrink();
    }

    // Default desktop: show major categories
    final defaultChildren = [
      _buildPill(
        label: 'All Products',
        isSelected: _selectedCategory == 'all',
        isMobile: isMobile,
        onTap: () {
          setState(() {
            _selectedCategory = 'all';
            _selectedSubcategory = null;
          });
        },
      ),
      ...CategoryItem.sampleCategories.map((cat) {
        return _buildPill(
          label: cat.name,
          iconEmoji: cat.icon,
          isSelected: _selectedCategory == cat.id,
          isMobile: isMobile,
          onTap: () {
            setState(() {
              _selectedCategory = cat.id;
              _selectedSubcategory = null;
            });
          },
        );
      }),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: defaultChildren,
    );
  }

  Widget _buildPill({
    required String label,
    String? iconEmoji,
    required bool isSelected,
    required VoidCallback onTap,
    bool isMobile = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 11 : 14,
          vertical: isMobile ? 6 : 7,
        ),
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
              Text(iconEmoji, style: TextStyle(fontSize: isMobile ? 12 : 13)),
              SizedBox(width: isMobile ? 4 : 6),
            ] else if (isSelected) ...[
              Icon(Icons.check_circle_rounded, size: isMobile ? 12 : 14, color: Colors.white),
              SizedBox(width: isMobile ? 4 : 6),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 11.5 : 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesRow(List<String> subcategories, {bool isMobile = false}) {
    final chips = subcategories.map((sub) {
      final isSelected = _selectedSubcategory == sub;
      return InkWell(
        onTap: () {
          setState(() => _selectedSubcategory = isSelected ? null : sub);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 9,
            vertical: isMobile ? 3.5 : 4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDarkGreen : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            sub,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 10.5 : 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }).toList();

    if (isMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Text(
                'Subcategories: ',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              ...chips.map((c) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: c,
              )),
            ],
          ),
        ),
      );
    }

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
          ...chips,
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
                // Navigate to "All in that major category"
                if (_selectedCategory == 'all' && widget.initialCategoryId != 'all') {
                  _selectedCategory = widget.initialCategoryId;
                }
                _selectedSubcategory = null;
                _selectedTechnicalName = null;
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

  Widget _buildMobileNavigationDrawer(BuildContext context) {
    return MobileNavigationDrawer(
      selectedCategoryId: _selectedCategory,
      selectedSubcategory: _selectedSubcategory,
      onCategorySelected: (catId, sub) {
        setState(() {
          _selectedCategory = catId;
          _selectedSubcategory = sub;
          _selectedTechnicalName = null;
        });
      },
      onAllProductsSelected: () {
        setState(() {
          _selectedCategory = 'all';
          _selectedSubcategory = null;
          _selectedTechnicalName = null;
        });
      },
    );
  }
}
