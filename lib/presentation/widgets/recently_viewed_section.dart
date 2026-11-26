import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/catalog_models.dart';
import 'product_card.dart';

class RecentlyViewedSection extends StatefulWidget {
  final List<ProductItem> products;
  final bool isMobile;
  final VoidCallback onClearHistory;
  final VoidCallback onViewAll;
  final Function(ProductItem) onProductTap;
  final Function(ProductItem, ProductVariant) onAddToCart;
  final Function(ProductItem, ProductVariant) onBuyNow;

  const RecentlyViewedSection({
    super.key,
    required this.products,
    required this.isMobile,
    required this.onClearHistory,
    required this.onViewAll,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  State<RecentlyViewedSection> createState() => _RecentlyViewedSectionState();
}

class _RecentlyViewedSectionState extends State<RecentlyViewedSection> {
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
  void didUpdateWidget(covariant RecentlyViewedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products.length != widget.products.length) {
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
    final canRight = pos.maxScrollExtent > 4 && pos.pixels < pos.maxScrollExtent - 4;
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
    final cardWidth = widget.isMobile ? 185.0 : 230.0;
    final cardHeight = widget.isMobile ? 315.0 : 365.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: "Recently Viewed" + "Clear History" + "View All ->"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Recently ',
                      style: GoogleFonts.mukta(
                        fontSize: widget.isMobile ? 20 : 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        height: 1.15,
                      ),
                    ),
                    TextSpan(
                      text: 'Viewed',
                      style: GoogleFonts.mukta(
                        fontSize: widget.isMobile ? 20 : 26,
                        fontWeight: FontWeight.w800,
                        color: _brandRed,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: widget.onClearHistory,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isMobile ? 9 : 13,
                      vertical: widget.isMobile ? 5 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD6D3D1)),
                    ),
                    child: Text(
                      'Clear History',
                      style: GoogleFonts.mukta(
                        fontSize: widget.isMobile ? 11.5 : 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1917),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: widget.isMobile ? 10 : 14),
                InkWell(
                  onTap: widget.onViewAll,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.mukta(
                            fontSize: widget.isMobile ? 12.5 : 13.5,
                            fontWeight: FontWeight.w700,
                            color: _brandRed,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: _brandRed,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: widget.isMobile ? 12 : 16),

        // Horizontal Carousel with Left & Right Arrow Controls (only shown when scrollable)
        SizedBox(
          height: cardHeight,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
              return false;
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  itemCount: widget.products.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: widget.isMobile ? 10 : 16),
                  itemBuilder: (context, index) {
                    final product = widget.products[index];
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
                      onTap: () => _scrollBy(-(cardWidth + 16) * 2),
                    ),
                  ),
                if (!widget.isMobile && _canScrollRight)
                  Positioned(
                    right: -14,
                    top: (cardHeight - 38) / 2,
                    child: _buildArrowButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _scrollBy((cardWidth + 16) * 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
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
