import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/web_footer.dart';

class ProductDetailView extends StatefulWidget {
  final ProductItem product;

  const ProductDetailView({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _tabsScrollController = ScrollController();
  late ProductVariant _selectedVariant;
  int _selectedQuantity = 1;
  int _activeTabIndex = 0;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.defaultVariant;
  }

  @override
  void dispose() {
    _tabsScrollController.dispose();
    super.dispose();
  }

  void _onVariantSelected(ProductVariant variant) {
    setState(() {
      _selectedVariant = variant;
    });
  }

  void _onAddToCart() {
    CartController.instance.addItem(widget.product, _selectedVariant, _selectedQuantity);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $_selectedQuantity x ${widget.product.title} (${_selectedVariant.label}) to cart!',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primaryDarkGreen,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ),
    );
  }

  void _onBuyNow() {
    CartController.instance.addItem(widget.product, _selectedVariant, _selectedQuantity);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobileScreen = screenWidth < 700;

    final relatedProducts = ProductItem.sampleProducts
        .where((p) => p.id != widget.product.id && p.category == widget.product.category)
        .take(4)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      endDrawer: const QuickCartDrawer(),
      bottomNavigationBar: isMobileScreen ? _buildMobileStickyBottomBar() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top utilities bar
            const TopInfoBar(),

            // Main navigation header
            AnimatedBuilder(
              animation: CartController.instance,
              builder: (context, _) {
                return MainNavHeader(
                  cartItemCount: CartController.instance.totalCount,
                  onCartTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                );
              },
            ),

            // Breadcrumbs & Back link (Responsive)
            _buildBreadcrumbBar(context, isMobileScreen),

            // Main Product Details Section
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobileScreen ? 12 : 24,
                    vertical: isMobileScreen ? 8 : 16,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 960;
                      final isMobile = constraints.maxWidth < 650;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Image Viewport & Visuals
                            Expanded(
                              flex: 5,
                              child: _buildGallerySection(context, isMobile: false),
                            ),
                            const SizedBox(width: 32),
                            // Right: Product Specs, Pack Size Selector, Price, Buy Actions
                            Expanded(
                              flex: 6,
                              child: _buildPurchaseSection(context, isMobile: false),
                            ),
                          ],
                        );
                      }

                      // Mobile / Tablet stacked layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGallerySection(context, isMobile: isMobile),
                          const SizedBox(height: 16),
                          _buildPurchaseSection(context, isMobile: isMobile),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Tabs: Overview, Specifications & Dosage, Safety, Reviews
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobileScreen ? 12 : 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildTabsSection(isMobile: constraints.maxWidth < 650);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Related Products Section
            if (relatedProducts.isNotEmpty)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1680),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobileScreen ? 12 : 24),
                    child: _buildRelatedSection(relatedProducts),
                  ),
                ),
              ),

            const SizedBox(height: 48),

            // Integrated Footer with Trust Badges
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  /// Sticky Bottom Bar for Mobile Viewports
  Widget _buildMobileStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${_selectedVariant.displayRate.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  _selectedVariant.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _onBuyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCrimson,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbBar(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text('•', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Home',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  widget.product.category,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  widget.product.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context, {required bool isMobile}) {
    final discount = _selectedVariant.discountPercent;
    final imageHeight = isMobile ? 280.0 : 420.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Display Container with white background
        Container(
          width: double.infinity,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.agriculture_rounded,
                      size: 80,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              // Discount pill
              if (discount > 0)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.discountRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 10.5 : 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              // Authentic EBS Quality Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'EBS Certified',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Thumbnail selectors
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedImageIndex = i;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: isMobile ? 60 : 70,
                  height: isMobile ? 60 : 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageIndex == i ? AppColors.primaryGreen : AppColors.border,
                      width: _selectedImageIndex == i ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: i == 0
                      ? Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 24, color: AppColors.textMuted),
                        )
                      : Icon(
                          i == 1 ? Icons.science_rounded : Icons.eco_rounded,
                          color: _selectedImageIndex == i ? AppColors.primaryGreen : AppColors.textMuted,
                          size: 26,
                        ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 14),

        // Guarantee Strip under gallery (Responsive wrap)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMicroFeature(Icons.shield_outlined, '100% Genuine', isMobile),
              _buildMicroFeature(Icons.local_shipping_outlined, 'Fast Dispatch', isMobile),
              _buildMicroFeature(Icons.support_agent_outlined, 'Agronomist Help', isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicroFeature(IconData icon, String label, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isMobile ? 14 : 16, color: AppColors.primaryGreen),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 10.5 : 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(BuildContext context, {required bool isMobile}) {
    final discount = _selectedVariant.discountPercent;
    final savings = _selectedVariant.printedMrp - _selectedVariant.displayRate;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
          // Category Pill & Vendor Tag (Responsive Wrap)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.product.category.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Brand: ${widget.product.vendor}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Product Title
          Text(
            widget.product.title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 17 : 21,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          // Technical Name / Active Formula
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.primaryCrimson.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Active Composition: ${widget.product.technicalName}',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCrimson,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Rating & Reviews row (Responsive Wrap)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.ratingAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingAmber),
                    const SizedBox(width: 3),
                    Text(
                      widget.product.rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.product.reviewsCount} Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                ),
              ),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              Text(
                '100% Quality Verified',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // PROMINENT PACK SIZE / VARIANT SELECTOR
          Text(
            'Select Pack Size / Quantity Variant:',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Variant Cards Grid (Responsive Wrap)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.variants.map((v) {
              final isSelected = v.id == _selectedVariant.id;
              final varDiscount = v.discountPercent;

              return InkWell(
                onTap: () => _onVariantSelected(v),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 13,
                    vertical: isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGreen : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 15,
                            color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            v.label,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 11.5 : 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${v.displayRate.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 12.5 : 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          if (v.printedMrp > v.displayRate) ...[
                            const SizedBox(width: 5),
                            Text(
                              '₹${v.printedMrp.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (varDiscount > 0) ...[
                            const SizedBox(width: 5),
                            Text(
                              '$varDiscount% OFF',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.discountRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Price Calculation & Savings Highlight Box (Responsive Wrap)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      '₹${_selectedVariant.displayRate.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (_selectedVariant.printedMrp > _selectedVariant.displayRate) ...[
                      Text(
                        'MRP: ₹${_selectedVariant.printedMrp.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12.5 : 14,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Save ₹${savings.toInt()} ($discount% OFF)',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.discountRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Inclusive of all taxes • FREE Pan-India Delivery on orders above ₹500',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stock Status & Dispatch indicator
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'In Stock',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF065F46),
                ),
              ),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              Text(
                'Ready to dispatch from EBS Central Hub',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 11.5 : 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity Stepper + Purchase Action Buttons (Responsive Layout)
          if (isMobile) ...[
            // Mobile: Row 1 Stepper, Row 2 Dual Full-Width Action Buttons
            Row(
              children: [
                Text(
                  'Quantity:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                _buildQuantityControl(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onAddToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 17),
                      label: Text(
                        'Add to Cart',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onBuyNow,
                      icon: const Icon(Icons.bolt_rounded, size: 17),
                      label: Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCrimson,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Desktop: Single horizontal row
            Row(
              children: [
                _buildQuantityControl(),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onAddToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: Text(
                        'Add to Cart',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onBuyNow,
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCrimson,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // Agronomist consultation helpline
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, size: 24, color: AppColors.primaryGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Agronomy Advisory or Dosage Guidance?',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 11.5 : 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                      Text(
                        'Speak with an EBS certified agronomist toll-free: ${AppConstants.orderCallNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 10.5 : 11.5,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 16),
            color: _selectedQuantity > 1 ? AppColors.textPrimary : AppColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            onPressed: _selectedQuantity > 1
                ? () {
                    setState(() {
                      _selectedQuantity--;
                    });
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$_selectedQuantity',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 16),
            color: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _selectedQuantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection({required bool isMobile}) {
    final tabItems = [
      (
        label: 'Product Overview',
        shortLabel: 'Overview',
        icon: Icons.info_outline_rounded,
      ),
      (
        label: 'Technical Specs',
        shortLabel: 'Specs',
        icon: Icons.science_outlined,
      ),
      (
        label: 'Application Guide',
        shortLabel: 'Dosage & Guide',
        icon: Icons.water_drop_outlined,
      ),
      (
        label: 'Farmer Reviews (${widget.product.reviewsCount})',
        shortLabel: 'Reviews (${widget.product.reviewsCount})',
        icon: Icons.star_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Header Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 14,
              vertical: isMobile ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: isMobile ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SingleChildScrollView(
              controller: _tabsScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (int i = 0; i < tabItems.length; i++) ...[
                    if (i > 0) SizedBox(width: isMobile ? 6 : 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _activeTabIndex = i;
                        });
                        if (_tabsScrollController.hasClients) {
                          final targetOffset = (i * (isMobile ? 100.0 : 140.0)) - (isMobile ? 30.0 : 50.0);
                          _tabsScrollController.animateTo(
                            targetOffset.clamp(0.0, _tabsScrollController.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(isMobile ? 20 : 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 7 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == i
                              ? AppColors.primaryGreen
                              : (isMobile ? Colors.white : Colors.transparent),
                          borderRadius: BorderRadius.circular(isMobile ? 20 : 8),
                          border: Border.all(
                            color: _activeTabIndex == i
                                ? AppColors.primaryGreen
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: _activeTabIndex == i
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
                            Icon(
                              tabItems[i].icon,
                              size: isMobile ? 14 : 16,
                              color: _activeTabIndex == i
                                  ? Colors.white
                                  : (i == 3 ? AppColors.ratingAmber : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isMobile ? tabItems[i].shortLabel : tabItems[i].label,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 12 : 13.5,
                                fontWeight: _activeTabIndex == i ? FontWeight.w700 : FontWeight.w500,
                                color: _activeTabIndex == i ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Tab Body
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: _buildActiveTabContent(isMobile: isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent({required bool isMobile}) {
    switch (_activeTabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ${widget.product.title}',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14.5 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.product.title} is a premium agricultural formulation manufactured by ${widget.product.vendor} and distributed directly through EBS Essential BioCrop Science. Engineered for Indian climatic and soil conditions, it provides dependable crop protection and enhanced yield vitality.',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12.5 : 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Key Benefits:',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Rapid systemic action and extended residual efficacy in all growing seasons.', isMobile),
            _buildBulletPoint('Safe for beneficial insects when used according to standard label recommendations.', isMobile),
            _buildBulletPoint('100% genuine batch authenticated with EBS lab purity certification.', isMobile),
            _buildBulletPoint('Compatible with common tank-mix combinations without phytotoxicity risks.', isMobile),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Specifications & Composition',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14.5 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildSpecRow('Active Ingredient', widget.product.technicalName, isMobile),
            _buildSpecRow('Formulation Category', widget.product.category, isMobile),
            _buildSpecRow('Manufacturer', widget.product.vendor, isMobile),
            _buildSpecRow('Recommended Dosage', '1.5 - 2.0 ml / gm per liter of water (or 150-200 Ltr/acre)', isMobile),
            _buildSpecRow('Target Crops', 'Cotton, Paddy, Chili, Tomato, Sugarcane, Soybean, Pulses, Fruits', isMobile),
            _buildSpecRow('Pre-Harvest Interval (PHI)', '7 - 14 Days depending on crop stage', isMobile),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Apply & Safety Guidelines',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14.5 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Spray during cool morning or late afternoon hours to maximize leaf absorption.', isMobile),
            _buildBulletPoint('Use clean water free from mud or heavy organic sediment for tank preparation.', isMobile),
            _buildBulletPoint('Wear protective gloves and mask while handling chemical concentrates.', isMobile),
            _buildBulletPoint('Store in original container away from direct sunlight and children.', isMobile),
          ],
        );
      case 3:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  '${widget.product.rating} / 5.0',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < 5; i++)
                      const Icon(Icons.star_rounded, size: 18, color: AppColors.ratingAmber),
                  ],
                ),
                Text(
                  '(${widget.product.reviewsCount} verified farmer reviews)',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 11.5 : 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReviewItem(
              'Rajesh Patil (Farmer, Maharashtra)',
              5,
              'Used on my cotton field last month. Highly effective results within 48 hours. Genuine product and fast delivery from EBS.',
              isMobile,
            ),
            const Divider(color: AppColors.border),
            _buildReviewItem(
              'Suresh Reddy (Agronomist, Andhra Pradesh)',
              5,
              'Good formulation purity. The pack was well-sealed and the price is lower than our local market dealer.',
              isMobile,
            ),
          ],
        );
    }
  }

  Widget _buildBulletPoint(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String author, int rating, String comment, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                author,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < rating; i++)
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingAmber),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 11.5 : 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(List<ProductItem> relatedProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Farmers Also Bought',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;
            final isTablet = constraints.maxWidth < 1000;
            final count = isMobile ? 2 : (isTablet ? 3 : 4);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: isMobile ? 8 : 14,
                mainAxisSpacing: isMobile ? 8 : 14,
                childAspectRatio: isMobile ? 0.68 : 0.76,
              ),
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                final prod = relatedProducts[index];
                return ProductCard(
                  product: prod,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: prod),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
