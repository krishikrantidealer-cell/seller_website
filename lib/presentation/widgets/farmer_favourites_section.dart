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
  State<FarmerFavouritesSection> createState() =>
      _FarmerFavouritesSectionState();
}

class _FarmerFavouritesSectionState extends State<FarmerFavouritesSection> {
  static const Color _brandRed = Color(0xFFC81E1E);
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  @override
  void didUpdateWidget(covariant FarmerFavouritesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allProducts.length != widget.allProducts.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollArrows() {
    if (!mounted || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final canLeft = pos.pixels > 4;
    final canRight =
        pos.maxScrollExtent > 4 && pos.pixels < pos.maxScrollExtent - 4;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.allProducts.where((p) => p.isInStock).toList();
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardHeight = widget.isMobile ? 320.0 : 375.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableW = constraints.maxWidth;
        final visibleCount = availableW >= 1280
            ? 6
            : (availableW >= 1000
                ? 5
                : (availableW >= 760
                    ? 4
                    : (availableW >= 520 ? 3 : 2)));
        final gap = widget.isMobile ? 10.0 : 14.0;
        final cardWidth =
            ((availableW - (gap * (visibleCount - 1))) / visibleCount)
                .clamp(155.0, 290.0);

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
                        Container(width: 16, height: 2, color: _brandRed),
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
            SizedBox(height: widget.isMobile ? 12 : 16),

            // Horizontal Carousel fitting 6 full cards on desktop with smooth < > scroll
            SizedBox(
              height: cardHeight,
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (notification) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _updateScrollArrows());
                  return false;
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: products.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: gap),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return SizedBox(
                          width: cardWidth,
                          child: ProductCard(
                            product: product,
                            onTap: () => widget.onProductTap(product),
                            onAddToCart: widget.onAddToCart,
                            onBuyNow: widget.onBuyNow,
                          ),
                        );
                      },
                    ),
                    if (!widget.isMobile && _canScrollLeft)
                      Positioned(
                        left: -14,
                        top: (cardHeight - 38) / 2,
                        child: _buildArrowButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => _scrollBy(-(cardWidth + gap) * 2),
                        ),
                      ),
                    if (!widget.isMobile && _canScrollRight)
                      Positioned(
                        right: -14,
                        top: (cardHeight - 38) / 2,
                        child: _buildArrowButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: () => _scrollBy((cardWidth + gap) * 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE7E5E4)),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF1C1917)),
        ),
      ),
    );
  }
}
