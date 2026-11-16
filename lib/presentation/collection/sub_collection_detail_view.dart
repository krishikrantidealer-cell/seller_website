import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/catalog_models.dart';
import '../../data/services/collection_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../product_detail/product_detail_view.dart';
import '../widgets/app_product_image.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/mobile_navigation_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/web_footer.dart';

/// Dedicated detail screen for a sub-collection (e.g. a specific crop inside
/// "Shop by Crop") displaying its products with search and sorting.
class SubCollectionDetailView extends StatefulWidget {
  final StoreCollection collection;
  final StoreSubCollection subCollection;

  const SubCollectionDetailView({
    super.key,
    required this.collection,
    required this.subCollection,
  });

  @override
  State<SubCollectionDetailView> createState() =>
      _SubCollectionDetailViewState();
}

class _SubCollectionDetailViewState extends State<SubCollectionDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchFilter = '';
  String _sortBy = 'featured';

  @override
  void initState() {
    super.initState();
    ProductController.instance.addListener(_onProductsUpdated);
    CollectionController.instance.addListener(_onProductsUpdated);
    if (ProductController.instance.products.isEmpty) {
      ProductController.instance.fetchProducts();
    }
    CollectionController.instance.fetchCollections(forceRefresh: true);
  }

  @override
  void dispose() {
    ProductController.instance.removeListener(_onProductsUpdated);
    CollectionController.instance.removeListener(_onProductsUpdated);
    super.dispose();
  }

  void _onProductsUpdated() {
    if (mounted) setState(() {});
  }

  StoreCollection? get _liveCollection {
    if (!CollectionController.instance.hasFetched) {
      return widget.collection;
    }
    return CollectionController.instance.collections
        .where((c) => c.id == widget.collection.id)
        .firstOrNull;
  }

  StoreSubCollection? get _liveSubCollection {
    final parent = _liveCollection;
    if (parent == null) return null;
    if (!CollectionController.instance.hasFetched) {
      return widget.subCollection;
    }
    return parent.subCollections
        .where((s) => s.id == widget.subCollection.id)
        .firstOrNull;
  }

  bool get _isUnavailable {
    if (!CollectionController.instance.hasFetched) return false;
    final parent = _liveCollection;
    final sub = _liveSubCollection;
    return parent == null || !parent.isActive || sub == null || !sub.isActive;
  }

  List<ProductItem> get _filteredProducts {
    final base = ProductController.instance.products
        .where((p) =>
            p.isAvailable &&
            widget.collection.matchesSubCollection(p, widget.subCollection))
        .toList();

    final query = _searchFilter.trim().toLowerCase();
    final searched = query.isEmpty
        ? base
        : base
            .where((p) =>
                p.title.toLowerCase().contains(query) ||
                p.vendor.toLowerCase().contains(query) ||
                p.technicalName.toLowerCase().contains(query))
            .toList();

    switch (_sortBy) {
      case 'price_low':
        searched.sort(
          (a, b) => a.defaultVariant.displayRate
              .compareTo(b.defaultVariant.displayRate),
        );
        break;
      case 'price_high':
        searched.sort(
          (a, b) => b.defaultVariant.displayRate
              .compareTo(a.defaultVariant.displayRate),
        );
        break;
      case 'rating':
        searched.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return searched;
  }

  void _onAddToCart(ProductItem product, ProductVariant variant) {
    CartController.instance.addItem(product, variant, 1);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${product.title} (${variant.label}) to cart',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
    final products = _filteredProducts;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: MobileNavigationDrawer(
        selectedCategoryId: 'all',
        onCategorySelected: (_, _) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onAllProductsSelected: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      endDrawer: const QuickCartDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight <= 1.0 || constraints.maxWidth <= 1.0) {
            return const SizedBox.shrink();
          }
          final isMobile = constraints.maxWidth < 650;

          return Column(
            children: [
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
                    const TopInfoBar(),
                    MainNavHeader(
                      onMenuTap: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      onCartTap: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                      onSearch: (query) =>
                          setState(() => _searchFilter = query),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 20,
                          vertical: isMobile ? 12 : 24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1680),
                            child: _isUnavailable
                                ? _buildUnavailableState(isMobile)
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildBreadcrumbBar(isMobile),
                                      SizedBox(height: isMobile ? 12 : 18),
                                      _buildSubCollectionHeader(
                                          products.length, isMobile),
                                      SizedBox(height: isMobile ? 14 : 20),
                                      _buildFilterAndSortRow(isMobile),
                                      SizedBox(height: isMobile ? 16 : 22),
                                      if (products.isEmpty)
                                        _buildEmptyState(isMobile)
                                      else
                                        _buildProductGrid(products, constraints),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const WebFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnavailableState(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 36 : 56,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.visibility_off_outlined,
              size: 32,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Collection Unavailable',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This collection is no longer active on the storefront.',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 13 : 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: Text(
              'Back to Store',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbBar(bool isMobile) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_outlined,
                    size: 15, color: AppColors.primaryDarkGreen),
                const SizedBox(width: 4),
                Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            size: 16, color: AppColors.textMuted),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              widget.collection.name,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            size: 16, color: AppColors.textMuted),
        Text(
          widget.subCollection.name,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubCollectionHeader(int count, bool isMobile) {
    final sub = widget.subCollection;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: isMobile ? 54 : 68,
              height: isMobile ? 54 : 68,
              color: Colors.white,
              child: (sub.image != null && sub.image!.isNotEmpty)
                  ? AppProductImage(imageUrl: sub.image!, fit: BoxFit.cover)
                  : const Icon(Icons.eco_rounded,
                      color: AppColors.primaryGreen, size: 30),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.collection.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub.name,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'Product' : 'Products'} available',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDarkGreen,
                side: BorderSide(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortRow(bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 320,
          child: TextField(
            onChanged: (val) => setState(() => _searchFilter = val),
            decoration: InputDecoration(
              hintText: 'Search products in ${widget.subCollection.name}...',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 19, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGreen),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              icon: const Icon(Icons.sort_rounded, size: 18),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              items: const [
                DropdownMenuItem(value: 'featured', child: Text('Sort: Featured')),
                DropdownMenuItem(
                    value: 'price_low', child: Text('Price: Low to High')),
                DropdownMenuItem(
                    value: 'price_high', child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _sortBy = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(
      List<ProductItem> products, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final crossAxisCount = width >= 1100
        ? 4
        : width >= 800
            ? 3
            : 2;
    final childAspectRatio = width < 500 ? 0.58 : 0.68;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: width < 650 ? 10 : 16,
        mainAxisSpacing: width < 650 ? 12 : 18,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
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
          onAddToCart: _onAddToCart,
          onBuyNow: _onBuyNow,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isMobile ? 36 : 52,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 32, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 14),
          Text(
            _searchFilter.trim().isNotEmpty
                ? 'No products match "$_searchFilter"'
                : 'No products in ${widget.subCollection.name} yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore other ${widget.collection.name.toLowerCase()} options or return to the collection.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.grid_view_rounded, size: 17),
            label: Text('Browse All ${widget.collection.name}'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
