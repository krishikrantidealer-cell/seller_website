import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/auth_state.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/recently_viewed_state.dart';
import '../../data/services/category_api_service.dart';
import '../../data/services/collection_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../../logic/category/category_bloc.dart';
import '../../logic/category/category_event.dart';
import '../../logic/category/category_state.dart';
import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';
import '../widgets/app_product_image.dart';
import '../widgets/category_icon_badge.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/farmer_favourites_section.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/mobile_navigation_drawer.dart';
import '../widgets/web_footer.dart';
import '../product_detail/product_detail_view.dart';
import '../collection/collection_detail_view.dart';
import '../collection/sub_collection_detail_view.dart';
import '../category/category_detail_view.dart';
import '../orders/my_orders_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedCategory = 'all';
  String? _selectedSubcategory;
  String? _selectedCollectionId;
  String? _selectedSubCollectionId;
  static bool _handledFastrrReturn = false;
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _handledFastrrReturn) return;
      final ost = Uri.base.queryParameters['ost']?.toUpperCase() ?? '';
      final oid = Uri.base.queryParameters['oid'] ?? '';
      if (ost == 'SUCCESS' || (oid.isNotEmpty && ost != 'FAILED' && ost != 'CANCELLED')) {
        _handledFastrrReturn = true;
        CartController.instance.clear();
        if (AuthController.instance.isLoggedIn) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyOrdersView()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully! Log in with your phone number to view it in My Orders.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      }
    });
    CategoryController.instance.addListener(_onCatalogUpdated);
    CollectionController.instance.addListener(_onCatalogUpdated);
    ProductController.instance.addListener(_onCatalogUpdated);
    MainNavHeader.globalSearchNotifier.addListener(_onGlobalSearchChanged);

    CollectionController.instance.fetchCollections();

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
    CollectionController.instance.removeListener(_onCatalogUpdated);
    ProductController.instance.removeListener(_onCatalogUpdated);
    MainNavHeader.globalSearchNotifier.removeListener(_onGlobalSearchChanged);
    super.dispose();
  }

  void _onGlobalSearchChanged() {
    if (!mounted) return;
    final next = MainNavHeader.globalSearchNotifier.value.trim();
    if (_searchFilter == next) return;
    setState(() {
      _searchFilter = next;
      if (_searchFilter.isNotEmpty) {
        _selectedCollectionId = null;
        _selectedSubCollectionId = null;
      }
    });
  }

  void _onCatalogUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  List<ProductItem> _getFilteredProducts(List<ProductItem> allProducts, List<CategoryItem> categories) {
    final trimmedQuery = _searchFilter.trim().toLowerCase();
    final isHomeBrowsing = trimmedQuery.isEmpty &&
        _selectedCategory == 'all' &&
        _selectedSubcategory == null;
    final list = allProducts.where((p) {
      if (isHomeBrowsing && !p.isInStock) return false;
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
      final matchesSearch = _matchesProductSearch(p, trimmedQuery);
      return matchesCategory && matchesSubcategory && matchesSearch;
    }).toList();
    if (_selectedCategory != 'all') {
      final currentCat = categories.cast<CategoryItem?>().firstWhere(
        (c) => c?.id == _selectedCategory || c?.backendId == _selectedCategory,
        orElse: () => null,
      );
      final backendKey = currentCat?.backendId ?? _selectedCategory;
      list.sort((a, b) {
        final ao = a.categorySortOrders[backendKey] ?? a.categorySortOrders[_selectedCategory] ?? a.displayOrder;
        final bo = b.categorySortOrders[backendKey] ?? b.categorySortOrders[_selectedCategory] ?? b.displayOrder;
        return ao.compareTo(bo);
      });
    } else {
      list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }
    return ProductItem.sortInStockFirst(list);
  }

  bool _matchesProductSearch(ProductItem p, String trimmedLowerQuery) {
    if (trimmedLowerQuery.isEmpty) return true;
    final searchable = <String>[
      p.title,
      p.technicalName,
      p.category,
      p.vendor,
      p.sku ?? '',
      p.description ?? '',
      ...p.assignedCollections,
    ].join(' ').toLowerCase();
    final tokens = trimmedLowerQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    return tokens.every(searchable.contains);
  }

  /// Returns products belonging to a Level 0 [category] (including its Level 1 & Level 2 descendants),
  /// respecting any active search filter on the Home screen.
  List<ProductItem> _getProductsForLevel0Category(CategoryItem category, List<ProductItem> allProducts) {
    final hasSearch = _searchFilter.trim().isNotEmpty;
    final list = allProducts.where((p) {
      if (!hasSearch && !p.isInStock) return false;
      if (!category.matchesProduct(p)) return false;
      if (hasSearch) {
        final q = _searchFilter.trim().toLowerCase();
        return p.title.toLowerCase().contains(q) ||
            p.technicalName.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
    final backendKey = category.backendId ?? category.id;
    list.sort((a, b) {
      final ao = a.categorySortOrders[backendKey] ?? a.categorySortOrders[category.id] ?? a.displayOrder;
      final bo = b.categorySortOrders[backendKey] ?? b.categorySortOrders[category.id] ?? b.displayOrder;
      return ao.compareTo(bo);
    });
    return ProductItem.sortInStockFirst(list);
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
                style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w500),
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
        margin: const EdgeInsets.fromLTRB(16, 0, 84, 16),
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

    final isCatalogError = (categoryBloc?.state.status == CategoryStatus.error ||
            productBloc?.state.status == ProductStatus.error) &&
        categories.isEmpty &&
        allProducts.isEmpty;

    final isCatalogLoading = categories.isEmpty && !isCatalogError;

    if (!CollectionController.instance.hasFetched &&
        !CollectionController.instance.isLoading &&
        CollectionController.instance.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CollectionController.instance.fetchCollections();
        }
      });
    }

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
                  searchQuery: _searchFilter,
                  onSearch: (query) {
                    MainNavHeader.globalSearchNotifier.value = query.trim();
                    setState(() {
                      _searchFilter = query.trim();
                      if (_searchFilter.isNotEmpty) {
                        _selectedCollectionId = null;
                        _selectedSubCollectionId = null;
                      }
                    });
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
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () => _refreshCatalog(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                    style: GoogleFonts.mukta(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Connecting to live MongoDB database...',
                                    style: GoogleFonts.mukta(
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
                                    style: GoogleFonts.mukta(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF991B1B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'The website is attempting to load live categories and products from:\n${AppConstants.apiBaseUrl}\n\nPlease check network connectivity or retry in a few moments.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.mukta(
                                      fontSize: 12.5,
                                      color: const Color(0xFF7F1D1D),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    onPressed: () => _refreshCatalog(context),
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text(
                                      'Retry Connection',
                                      style: GoogleFonts.mukta(
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
                          // Active Collection Filter View
                          else if (_selectedCollectionId != null) ...[
                            ..._buildSelectedCollectionSection(
                              CollectionController.instance.collections,
                              allProducts,
                              isMobile,
                              constraints,
                            ),
                          ]
                          // Active Search or Category Filter View
                          else if (_selectedCategory != 'all' || _searchFilter.isNotEmpty) ...[
                            _buildBestSellersHeader(filtered, isMobile),
                            SizedBox(height: isMobile ? 10 : 14),
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
                                      allProducts.isEmpty
                                          ? 'No products available in the database yet.'
                                          : 'No agricultural products found matching your search.',
                                      style: GoogleFonts.mukta(
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
                                            _selectedSubcategory = null;
                                            _searchFilter = '';
                                          });
                                        },
                                        child: const Text('Reset Filters'),
                                      ),
                                  ],
                                ),
                              )
                            else
                              _buildProductGrid(filtered, constraints, maxItems: filtered.length),
                          ]
                          // Default Home Screen: Show Recently Viewed, then Collections, then Categories
                          else ...[
                            ListenableBuilder(
                              listenable: RecentlyViewedController.instance,
                              builder: (context, _) {
                                if (isCatalogLoading || isCatalogError) {
                                  return const SizedBox.shrink();
                                }
                                final recentProducts = RecentlyViewedController.instance
                                    .resolveProducts(allProducts, limit: 12);
                                if (recentProducts.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.only(bottom: isMobile ? 18 : 28),
                                  child: RecentlyViewedSection(
                                    products: recentProducts,
                                    isMobile: isMobile,
                                    onClearHistory: () =>
                                        RecentlyViewedController.instance.clear(),
                                    onViewAll: () {
                                      setState(() {
                                        _selectedCategory = 'all';
                                        _selectedCollectionId = null;
                                        _searchFilter = '';
                                      });
                                    },
                                    onProductTap: (product) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailView(product: product),
                                        ),
                                      );
                                    },
                                    onAddToCart: (p, v) => _onAddToCart(p, v),
                                    onBuyNow: (p, v) => _onBuyNow(p, v),
                                  ),
                                );
                              },
                            ),
                            ListenableBuilder(
                              listenable: CollectionController.instance,
                              builder: (context, _) {
                                final collections =
                                    CollectionController.instance.collections;
                                if (isCatalogLoading ||
                                    isCatalogError ||
                                    collections.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                StoreCollection? bestSellerCol;
                                for (final c in collections) {
                                  if (_isBestSellerCollection(c)) {
                                    bestSellerCol = c;
                                    break;
                                  }
                                }

                                final bestSellerProducts = bestSellerCol == null
                                    ? const <ProductItem>[]
                                    : ProductItem.sortInStockFirst(
                                        allProducts
                                            .where((p) =>
                                                p.isInStock &&
                                                bestSellerCol!.matchesProduct(p))
                                            .toList()
                                          ..sort((a, b) {
                                            final ao = a.collectionSortOrders[
                                                    bestSellerCol!.id] ??
                                                a.displayOrder;
                                            final bo = b.collectionSortOrders[
                                                    bestSellerCol.id] ??
                                                b.displayOrder;
                                            return ao.compareTo(bo);
                                          }),
                                      );

                                final remainingCollections = collections
                                    .where((c) => c.id != bestSellerCol?.id)
                                    .toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (bestSellerCol != null &&
                                        bestSellerProducts.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: isMobile ? 22 : 34),
                                        child: FarmerFavouritesSection(
                                          allProducts: bestSellerProducts,
                                          categories: categories,
                                          isMobile: isMobile,
                                          onViewAll: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CollectionDetailView(
                                                  collection: bestSellerCol!,
                                                ),
                                              ),
                                            );
                                          },
                                          onProductTap: (product) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ProductDetailView(
                                                        product: product),
                                              ),
                                            );
                                          },
                                          onAddToCart: (p, v) =>
                                              _onAddToCart(p, v),
                                          onBuyNow: (p, v) => _onBuyNow(p, v),
                                        ),
                                      ),
                                    if (remainingCollections.isNotEmpty)
                                      ..._buildCollectionsSections(
                                        remainingCollections,
                                        allProducts,
                                        isMobile,
                                        constraints,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],

                          // Level 0 Major Category Sections rendered one by one
                          if (!isCatalogLoading &&
                              !isCatalogError &&
                              _selectedCategory == 'all' &&
                              _selectedCollectionId == null &&
                              _searchFilter.isEmpty)
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
    double childAspectRatio = 0.65;
    double crossAxisSpacing = 14;
    double mainAxisSpacing = 14;

    if (constraints.maxWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.58;
      crossAxisSpacing = 8;
      mainAxisSpacing = 8;
    } else if (constraints.maxWidth < 850) {
      crossAxisCount = 3;
      childAspectRatio = 0.62;
      crossAxisSpacing = 10;
      mainAxisSpacing = 10;
    } else if (constraints.maxWidth < 1180) {
      crossAxisCount = 4;
      childAspectRatio = 0.64;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else if (constraints.maxWidth < 1520) {
      crossAxisCount = 5;
      childAspectRatio = 0.68;
      crossAxisSpacing = 14;
      mainAxisSpacing = 14;
    } else {
      crossAxisCount = 6;
      childAspectRatio = 0.70;
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
      // Hide categories that have no products on the home screen
      if (categoryProducts.isEmpty) {
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
              _buildProductGrid(categoryProducts, constraints, maxItems: 6),
            ],
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildTwoToneSectionHeading({
    required String eyebrow,
    required String title,
    required bool isMobile,
    Widget? leadingIcon,
    required VoidCallback onViewAll,
  }) {
    const brandRed = Color(0xFFC81E1E);
    final words = title.trim().split(RegExp(r'\s+'));
    final firstPart =
        words.length > 1 ? '${words.sublist(0, words.length - 1).join(' ')} ' : '';
    final lastWord = words.isNotEmpty ? words.last : title;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 16, height: 2, color: brandRed),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      eyebrow.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.mukta(
                        color: brandRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon,
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          if (firstPart.isNotEmpty)
                            TextSpan(
                              text: firstPart,
                              style: GoogleFonts.mukta(
                                fontSize: isMobile ? 21 : 27,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                                height: 1.15,
                              ),
                            ),
                          TextSpan(
                            text: lastWord,
                            style: GoogleFonts.mukta(
                              fontSize: isMobile ? 21 : 27,
                              fontWeight: FontWeight.w800,
                              color: words.length > 1
                                  ? brandRed
                                  : const Color(0xFF111827),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 14,
              vertical: isMobile ? 6 : 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: brandRed.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.mukta(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: brandRed,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: brandRed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevel0CategoryHeader(
    CategoryItem category,
    int productCount,
    bool isMobile,
  ) {
    final hasIcon = CategoryIconBadge.hasAnyIcon(
      categoryImageUrl: category.categoryImageUrl,
      iconUrl: category.iconUrl,
      iconEmoji: category.icon,
    );
    return _buildTwoToneSectionHeading(
      eyebrow: category.groups.isNotEmpty
          ? '$productCount PRODUCTS • ${category.groups.length} SUBCATEGORIES'
          : '$productCount PRODUCTS',
      title: category.name,
      isMobile: isMobile,
      leadingIcon: hasIcon
          ? CategoryIconBadge(
              categoryImageUrl: category.categoryImageUrl,
              iconUrl: category.iconUrl,
              iconEmoji: category.icon,
              size: isMobile ? 24 : 28,
              emojiSize: isMobile ? 14 : 16,
              borderRadius: 6,
            )
          : null,
      onViewAll: () => _openCategoryDetail(category.id, null),
    );
  }

  Widget _buildBestSellersHeader(List<ProductItem> filtered, bool isMobile) {
    final bool isFiltered = _selectedCategory != 'all' || _selectedSubcategory != null || _searchFilter.isNotEmpty;
    final String title;
    if (_searchFilter.isNotEmpty) {
      title = 'Search Results';
    } else if (_selectedCategory != 'all') {
      title = _getCategoryTitle(_selectedCategory);
    } else {
      title = 'Best Sellers';
    }

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
                              title,
                              style: GoogleFonts.mukta(
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
                              style: GoogleFonts.mukta(
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
                          style: GoogleFonts.mukta(fontSize: 11, color: AppColors.primaryCrimson, fontWeight: FontWeight.w500),
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
                          style: GoogleFonts.mukta(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryCrimson),
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
                  title,
                  style: GoogleFonts.mukta(
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
                        style: GoogleFonts.mukta(
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
                    style: GoogleFonts.mukta(
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
                            style: GoogleFonts.mukta(
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
                style: GoogleFonts.mukta(
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

  bool _isBestSellerCollection(StoreCollection col) {
    final key = '${col.name} ${col.slug}'.toLowerCase();
    return key.contains('best seller') ||
        key.contains('bestseller') ||
        key.contains('farmer favourite') ||
        key.contains('farmer favorite');
  }

  List<Widget> _buildCollectionsSections(
    List<StoreCollection> collections,
    List<ProductItem> allProducts,
    bool isMobile,
    BoxConstraints constraints,
  ) {
    final availableProducts = allProducts.where((p) => p.isInStock).toList();
    final List<Widget> widgets = [];

    for (final col in collections) {
      final colProducts = availableProducts.where(col.matchesProduct).toList();
      final totalCount = colProducts.isNotEmpty ? colProducts.length : col.productCount;
      final visibleSubs = col.subCollections.take(6).toList();

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 18 : 28),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTwoToneSectionHeading(
                  eyebrow: col.subCollections.isNotEmpty
                      ? 'COLLECTION • ${col.subCollections.length} SUB-COLLECTIONS • $totalCount PRODUCTS'
                      : 'COLLECTION • $totalCount PRODUCTS',
                  title: col.name,
                  isMobile: isMobile,
                  leadingIcon: (col.image != null && col.image!.trim().isNotEmpty)
                      ? AppProductImage(
                          imageUrl: col.image!,
                          width: isMobile ? 24 : 28,
                          height: isMobile ? 24 : 28,
                          fit: BoxFit.cover,
                          borderRadius: 6,
                        )
                      : null,
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailView(collection: col),
                      ),
                    );
                  },
                ),
                if (visibleSubs.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 14),
                    child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  Builder(
                    builder: (context) {
                      final int maxCols = constraints.maxWidth >= 1100
                          ? 8
                          : (constraints.maxWidth >= 750
                              ? 6
                              : (constraints.maxWidth >= 450 ? 4 : 3));
                      final double circleSize = isMobile ? 68.0 : 88.0;

                      Widget buildSubCircleTile(StoreSubCollection sub) {
                        final subLiveCount = availableProducts
                            .where((p) => col.matchesSubCollection(p, sub))
                            .length;
                        final subDisplayCount =
                            subLiveCount > 0 ? subLiveCount : sub.productCount;
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubCollectionDetailView(
                                  collection: col,
                                  subCollection: sub,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: circleSize,
                                      height: circleSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFF0FDF4),
                                        border: Border.all(
                                          color: AppColors.primaryGreen
                                              .withValues(alpha: 0.25),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: (sub.image != null &&
                                                sub.image!.isNotEmpty)
                                            ? AppProductImage(
                                                imageUrl: sub.image!,
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(
                                                Icons.eco_rounded,
                                                color: AppColors.primaryGreen,
                                                size: 22,
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -2,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: subDisplayCount > 0
                                              ? const Color(0xFFF0FDF4)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: subDisplayCount > 0
                                                ? AppColors.primaryGreen
                                                    .withValues(alpha: 0.35)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Text(
                                          '$subDisplayCount',
                                          style: GoogleFonts.mukta(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: subDisplayCount > 0
                                                ? AppColors.primaryDarkGreen
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  sub.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.mukta(
                                    fontSize: isMobile ? 10.5 : 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (isMobile) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: visibleSubs
                                .map(
                                  (sub) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: SizedBox(
                                      width: 84,
                                      child: buildSubCircleTile(sub),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      }

                      if (visibleSubs.length <= maxCols) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: visibleSubs
                              .map(
                                (sub) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 4 : 6,
                                    ),
                                    child: buildSubCircleTile(sub),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleSubs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: maxCols,
                          mainAxisExtent: isMobile ? 88 : 134,
                          crossAxisSpacing: isMobile ? 8 : 12,
                          mainAxisSpacing: isMobile ? 10 : 14,
                        ),
                        itemBuilder: (context, index) =>
                            buildSubCircleTile(visibleSubs[index]),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildSelectedCollectionSection(
    List<StoreCollection> collections,
    List<ProductItem> allProducts,
    bool isMobile,
    BoxConstraints constraints,
  ) {
    final col = collections.where((c) => c.id == _selectedCollectionId).firstOrNull;
    if (col == null) {
      return [
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _selectedCollectionId = null;
            _selectedSubCollectionId = null;
          }),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Back to Home'),
        ),
      ];
    }

    final availableProducts = allProducts.where((p) => p.isInStock).toList();
    final activeSub = _selectedSubCollectionId == null
        ? null
        : col.subCollections.where((s) => s.id == _selectedSubCollectionId).firstOrNull;

    final filtered = availableProducts.where((p) {
      if (activeSub != null) return col.matchesSubCollection(p, activeSub);
      return col.matchesProduct(p);
    }).toList();

    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _selectedCollectionId = null;
                    _selectedSubCollectionId = null;
                  }),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('All Collections'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    col.name,
                    style: GoogleFonts.mukta(
                      fontSize: isMobile ? 17 : 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filtered.length} Products',
                    style: GoogleFonts.mukta(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
            if (col.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                col.description,
                style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            if (col.subCollections.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedSubCollectionId == null,
                    onSelected: (_) => setState(() => _selectedSubCollectionId = null),
                  ),
                  ...col.subCollections.map(
                    (sub) => ChoiceChip(
                      label: Text(sub.name),
                      selected: _selectedSubCollectionId == sub.id,
                      onSelected: (_) => setState(() => _selectedSubCollectionId = sub.id),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      SizedBox(height: isMobile ? 12 : 18),
      if (filtered.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              'No products assigned to this collection yet.',
              style: GoogleFonts.mukta(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        )
      else
        _buildProductGrid(filtered, constraints, maxItems: filtered.length),
    ];
  }

  Future<void> _refreshCatalog(BuildContext context) async {
    final catB = context.read<CategoryBloc?>();
    final prodB = context.read<ProductBloc?>();

    final futures = <Future<dynamic>>[
      CollectionController.instance.fetchCollections(forceRefresh: true),
    ];
    if (catB != null) {
      catB.add(const FetchCategories(isRefresh: true));
      futures.add(
        catB.stream
            .firstWhere((s) => s.status != CategoryStatus.loading)
            .timeout(const Duration(seconds: 8), onTimeout: () => catB.state),
      );
    } else {
      futures.add(CategoryController.instance.fetchCategories(forceRefresh: true));
    }

    if (prodB != null) {
      prodB.add(const FetchProducts(isRefresh: true));
      futures.add(
        prodB.stream
            .firstWhere((s) => s.status != ProductStatus.loading)
            .timeout(const Duration(seconds: 8), onTimeout: () => prodB.state),
      );
    } else {
      futures.add(ProductController.instance.fetchProducts(forceRefresh: true));
    }

    await Future.wait(futures);
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
