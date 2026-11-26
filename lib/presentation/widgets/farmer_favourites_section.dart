import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/catalog_models.dart';
import 'app_product_image.dart';
import 'product_card.dart';

class FarmerFavouritesSection extends StatefulWidget {
  final List<ProductItem> allProducts;
  final List<CategoryItem> categories;
  final bool isMobile;
  final VoidCallback onViewAll;
  final Function(ProductItem) onProductTap;
  final Function(ProductItem, ProductVariant) onAddToCart;
  final Function(ProductItem, ProductVariant) onBuyNow;

  const FarmerFavouritesSection({
    super.key,
    required this.allProducts,
    required this.categories,
    required this.isMobile,
    required this.onViewAll,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  State<FarmerFavouritesSection> createState() => _FarmerFavouritesSectionState();
}

class _FarmerFavouritesSectionState extends State<FarmerFavouritesSection> {
  static const Color _brandRed = Color(0xFFC81E1E);

  String _selectedCatId = 'all';
  int _pageIndex = 0;
  ProductVariant? _featuredVariant;
  final ScrollController _pillScrollController = ScrollController();

  @override
  void dispose() {
    _pillScrollController.dispose();
    super.dispose();
  }

  List<ProductItem> _filteredProducts() {
    final inStock = widget.allProducts.where((p) => p.isInStock).toList();
    if (_selectedCatId == 'all') return inStock;
    final cat = widget.categories.cast<CategoryItem?>().firstWhere(
          (c) => c?.id == _selectedCatId,
          orElse: () => null,
        );
    final catName = cat?.name.toLowerCase() ?? '';
    return inStock.where((p) {
      if (p.category.toLowerCase() == catName) return true;
      if (p.categoryId == _selectedCatId) return true;
      if (cat?.backendId != null && p.categoryId == cat!.backendId) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts();
    if (products.isEmpty && _selectedCatId == 'all') {
      return const SizedBox.shrink();
    }

    final featured = products.isNotEmpty
        ? products.first
        : widget.allProducts.firstWhere(
            (p) => p.isInStock,
            orElse: () => widget.allProducts.first,
          );
    final featuredVariants = featured.variants.isNotEmpty
        ? featured.variants
        : [featured.defaultVariant];
    final activeFeaturedVariant = (_featuredVariant != null &&
            featuredVariants.any((v) => v.id == _featuredVariant!.id))
        ? _featuredVariant!
        : featured.defaultVariant;

    final gridProducts = products.length > 1 ? products.sublist(1) : products;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1020;
        final cardsPerPage = constraints.maxWidth >= 1220
            ? 3
            : (constraints.maxWidth >= 700 ? 2 : 2);
        final totalPages =
            gridProducts.isEmpty ? 1 : (gridProducts.length / cardsPerPage).ceil();
        final safePage = _pageIndex.clamp(0, totalPages - 1);
        final start = safePage * cardsPerPage;
        final end = (start + cardsPerPage).clamp(0, gridProducts.length);
        final pageProducts = gridProducts.sublist(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: "— BEST SELLERS" + "Farmer Favourites" + "View All ->"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 2,
                          color: _brandRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BEST SELLERS',
                          style: GoogleFonts.mukta(
                            color: _brandRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Farmer ',
                            style: GoogleFonts.mukta(
                              fontSize: widget.isMobile ? 22 : 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                              height: 1.15,
                            ),
                          ),
                          TextSpan(
                            text: 'Favourites',
                            style: GoogleFonts.mukta(
                              fontSize: widget.isMobile ? 22 : 28,
                              fontWeight: FontWeight.w800,
                              color: _brandRed,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: widget.onViewAll,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isMobile ? 10 : 14,
                      vertical: widget.isMobile ? 6 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _brandRed.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.mukta(
                            fontSize: widget.isMobile ? 12 : 13,
                            fontWeight: FontWeight.w700,
                            color: _brandRed,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: _brandRed,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.isMobile ? 14 : 20),

            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 375,
                    height: 418,
                    child: _buildFeaturedCard(
                      featured,
                      featuredVariants,
                      activeFeaturedVariant,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildRightSection(
                      pageProducts: pageProducts,
                      cardsPerPage: cardsPerPage,
                      safePage: safePage,
                      totalPages: totalPages,
                    ),
                  ),
                ],
              )
            else ...[
              _buildFeaturedCard(
                featured,
                featuredVariants,
                activeFeaturedVariant,
              ),
              const SizedBox(height: 16),
              _buildRightSection(
                pageProducts: pageProducts,
                cardsPerPage: cardsPerPage,
                safePage: safePage,
                totalPages: totalPages,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFeaturedCard(
    ProductItem product,
    List<ProductVariant> variants,
    ProductVariant variant,
  ) {
    final savings = (variant.printedMrp - variant.displayRate).round();
    final brand = (product.brandName.isNotEmpty
            ? product.brandName
            : (product.vendor.isNotEmpty ? product.vendor : 'EBS'))
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD92323), Color(0xFFA61E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _brandRed.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            top: 28,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Pill + Info + Product Image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '✦ Featured Pick',
                            style: GoogleFonts.mukta(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mukta(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mukta(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        if (product.technicalName.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            product.technicalName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mukta(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                '₹${variant.displayRate.toStringAsFixed(0)}',
                                style: GoogleFonts.mukta(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (variant.printedMrp > variant.displayRate) ...[
                                const SizedBox(width: 7),
                                Text(
                                  '₹${variant.printedMrp.toStringAsFixed(0)}',
                                  style: GoogleFonts.mukta(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              if (savings > 0) ...[
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Save ₹$savings',
                                    style: GoogleFonts.mukta(
                                      color: _brandRed,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _featureBullet('${product.category} category'),
                        if (product.technicalName.isNotEmpty)
                          _featureBullet(product.technicalName),
                        _featureBullet('Genuine quality product'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 235,
                      child: AppProductImage(
                        imageUrl: product.imageUrl,
                        fallbackUrls: product.imageUrls,
                        fit: BoxFit.contain,
                        fallbackIcon: Icons.agriculture_rounded,
                        fallbackIconSize: 52,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bottom Row: White Pack Size Selector + Explore Product Button
              Row(
                children: [
                  Expanded(
                    child: PopupMenuButton<ProductVariant>(
                      enabled: variants.length > 1,
                      initialValue: variant,
                      color: Colors.white,
                      onSelected: (v) => setState(() => _featuredVariant = v),
                      itemBuilder: (ctx) => variants.map((v) {
                        return PopupMenuItem<ProductVariant>(
                          value: v,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                v.label,
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '₹${v.displayRate.toStringAsFixed(0)}',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _brandRed,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'PACK SIZE',
                                    style: GoogleFonts.mukta(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF78716C),
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    variant.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.mukta(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1C1917),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (variants.length > 1)
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Color(0xFF57534E),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => widget.onProductTap(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _brandRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore Product',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_rounded, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mukta(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection({
    required List<ProductItem> pageProducts,
    required int cardsPerPage,
    required int safePage,
    required int totalPages,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Pills Bar
        SizedBox(
          height: 36,
          child: Row(
            children: [
              _smallScrollChevron(
                Icons.chevron_left_rounded,
                () {
                  if (_pillScrollController.hasClients) {
                    _pillScrollController.animateTo(
                      (_pillScrollController.offset - 180)
                          .clamp(0.0, _pillScrollController.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
              Expanded(
                child: ListView(
                  controller: _pillScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  children: [
                    _buildCategoryPill('all', 'All Products'),
                    ...widget.categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildCategoryPill(c.id, c.name),
                      ),
                    ),
                  ],
                ),
              ),
              _smallScrollChevron(
                Icons.chevron_right_rounded,
                () {
                  if (_pillScrollController.hasClients) {
                    _pillScrollController.animateTo(
                      (_pillScrollController.offset + 180)
                          .clamp(0.0, _pillScrollController.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3-Column Product Cards
        if (pageProducts.isEmpty)
          Container(
            height: 330,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAE6DF)),
            ),
            child: Text(
              'No products in this category yet.',
              style: GoogleFonts.mukta(
                color: const Color(0xFF78716C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          SizedBox(
            height: widget.isMobile ? 310 : 334,
            child: Row(
              children: List.generate(cardsPerPage, (i) {
                if (i >= pageProducts.length) {
                  return const Expanded(child: SizedBox.shrink());
                }
                final product = pageProducts[i];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < cardsPerPage - 1 ? 14 : 0,
                    ),
                    child: ProductCard(
                      product: product,
                      onTap: () => widget.onProductTap(product),
                      onAddToCart: widget.onAddToCart,
                      onBuyNow: widget.onBuyNow,
                    ),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 14),

        // Bottom Pagination Bar: pill + dot + "1 / N" on left, < > arrows on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ...List.generate(totalPages.clamp(1, 5), (idx) {
                  final isActive = idx == safePage;
                  return Container(
                    margin: const EdgeInsets.only(right: 5),
                    width: isActive ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? _brandRed : const Color(0xFFD6D3D1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${safePage + 1} / $totalPages',
                  style: GoogleFonts.mukta(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF78716C),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _circleNavButton(
                  Icons.chevron_left_rounded,
                  enabled: safePage > 0,
                  onTap: () => setState(() => _pageIndex = safePage - 1),
                ),
                const SizedBox(width: 8),
                _circleNavButton(
                  Icons.chevron_right_rounded,
                  enabled: safePage < totalPages - 1,
                  onTap: () => setState(() => _pageIndex = safePage + 1),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryPill(String id, String label) {
    final isSelected = _selectedCatId == id;
    return InkWell(
      onTap: () => setState(() {
        _selectedCatId = id;
        _pageIndex = 0;
      }),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.mukta(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1C1917),
          ),
        ),
      ),
    );
  }

  Widget _smallScrollChevron(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: const Color(0xFF57534E)),
      ),
    );
  }

  Widget _circleNavButton(
    IconData icon, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: enabled ? 2 : 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? const Color(0xFF1C1917) : const Color(0xFFD6D3D1),
          ),
        ),
      ),
    );
  }
}
