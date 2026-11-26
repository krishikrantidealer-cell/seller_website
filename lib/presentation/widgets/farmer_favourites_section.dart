import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/catalog_models.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardsPerPage = constraints.maxWidth >= 1400
            ? 6
            : (constraints.maxWidth >= 1150
                ? 5
                : (constraints.maxWidth >= 880
                    ? 4
                    : (constraints.maxWidth >= 620 ? 3 : 2)));
        final totalPages =
            products.isEmpty ? 1 : (products.length / cardsPerPage).ceil();
        final safePage = _pageIndex.clamp(0, totalPages - 1);
        final start = safePage * cardsPerPage;
        final end = (start + cardsPerPage).clamp(0, products.length);
        final pageProducts = products.sublist(start, end);

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
            SizedBox(height: widget.isMobile ? 14 : 18),

            _buildRightSection(
              pageProducts: pageProducts,
              cardsPerPage: cardsPerPage,
              safePage: safePage,
              totalPages: totalPages,
            ),
          ],
        );
      },
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
          child: ListView(
            controller: _pillScrollController,
            scrollDirection: Axis.horizontal,
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
            height: widget.isMobile ? 320 : 375,
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
