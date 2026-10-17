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
  late ProductVariant _selectedVariant;
  int _selectedQuantity = 1;
  int _activeTabIndex = 0;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.defaultVariant;
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
    final relatedProducts = ProductItem.sampleProducts
        .where((p) => p.id != widget.product.id && p.category == widget.product.category)
        .take(4)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      endDrawer: const QuickCartDrawer(),
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

            // Breadcrumbs & Back link
            _buildBreadcrumbBar(context),

            // Main Product Details Section
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 960;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Image Viewport & Visuals
                            Expanded(
                              flex: 5,
                              child: _buildGallerySection(context),
                            ),
                            const SizedBox(width: 36),
                            // Right: Product Specs, Pack Size Selector, Price, Buy Actions
                            Expanded(
                              flex: 6,
                              child: _buildPurchaseSection(context),
                            ),
                          ],
                        );
                      }

                      // Mobile / Tablet stacked layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGallerySection(context),
                          const SizedBox(height: 24),
                          _buildPurchaseSection(context),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Tabs: Overview, Specifications & Dosage, Safety, Reviews
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabsSection(),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Related Products Section
            if (relatedProducts.isNotEmpty)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1680),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildBreadcrumbBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Home',
                  style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                widget.product.category,
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.product.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    final discount = _selectedVariant.discountPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Display Container with white background
        Container(
          width: double.infinity,
          height: 440,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.agriculture_rounded,
                      size: 96,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              // Discount pill
              if (discount > 0)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.discountRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              // Authentic EBS Quality Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'EBS Certified',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
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

        const SizedBox(height: 16),

        // Thumbnail selectors
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedImageIndex = i;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageIndex == i ? AppColors.primaryGreen : AppColors.border,
                      width: _selectedImageIndex == i ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: i == 0
                      ? Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 28, color: AppColors.textMuted),
                        )
                      : Icon(
                          i == 1 ? Icons.science_rounded : Icons.eco_rounded,
                          color: _selectedImageIndex == i ? AppColors.primaryGreen : AppColors.textMuted,
                          size: 32,
                        ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        // Guarantee Strip under gallery
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMicroFeature(Icons.shield_outlined, '100% Genuine'),
              _buildMicroFeature(Icons.local_shipping_outlined, 'Fast Dispatch'),
              _buildMicroFeature(Icons.support_agent_outlined, 'Agronomist Help'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicroFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(BuildContext context) {
    final discount = _selectedVariant.discountPercent;
    final savings = _selectedVariant.printedMrp - _selectedVariant.displayRate;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Pill & Vendor Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.product.category.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Brand: ${widget.product.vendor}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Product Title
          Text(
            widget.product.title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          // Technical Name / Active Formula
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCrimson.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Active Composition: ${widget.product.technicalName}',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCrimson,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Rating & Reviews row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ratingAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.ratingAmber),
                    const SizedBox(width: 4),
                    Text(
                      widget.product.rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.product.reviewsCount} Customer Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              Text(
                '100% Quality Verified',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // PROMINENT PACK SIZE / VARIANT SELECTOR
          Text(
            'Select Pack Size / Quantity Variant:',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Variant Cards Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.product.variants.map((v) {
              final isSelected = v.id == _selectedVariant.id;
              final varDiscount = v.discountPercent;

              return InkWell(
                onTap: () => _onVariantSelected(v),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              blurRadius: 8,
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
                            size: 16,
                            color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            v.label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${v.displayRate.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          if (v.printedMrp > v.displayRate) ...[
                            const SizedBox(width: 6),
                            Text(
                              '₹${v.printedMrp.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (varDiscount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '$varDiscount% OFF',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
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

          const SizedBox(height: 20),

          // Price Calculation & Savings Highlight Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${_selectedVariant.displayRate.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_selectedVariant.printedMrp > _selectedVariant.displayRate) ...[
                      Text(
                        'MRP: ₹${_selectedVariant.printedMrp.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You Save ₹${savings.toInt()} ($discount% OFF)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.discountRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Inclusive of all taxes • FREE Pan-India Delivery on orders above ₹500',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Stock Status & Dispatch indicator
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'In Stock',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF065F46),
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              Text(
                'Ready to dispatch from EBS Central Hub',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quantity Stepper + Purchase Action Buttons
          Row(
            children: [
              // Quantity Stepper
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      color: _selectedQuantity > 1 ? AppColors.textPrimary : AppColors.textMuted,
                      onPressed: _selectedQuantity > 1
                          ? () {
                              setState(() {
                                _selectedQuantity--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$_selectedQuantity',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      color: AppColors.textPrimary,
                      onPressed: () {
                        setState(() {
                          _selectedQuantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add to Cart Button
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _onAddToCart,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text(
                      'Add to Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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

              // Buy Now Button
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _onBuyNow,
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: Text(
                      'Buy Now',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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

          const SizedBox(height: 22),

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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                      Text(
                        'Speak with an EBS certified agronomist toll-free: ${AppConstants.orderCallNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
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

  Widget _buildTabsSection() {
    final tabs = [
      'Product Overview',
      'Technical Specs & Dosage',
      'Application Guide',
      'Farmer Reviews (${widget.product.reviewsCount})',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Header Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _activeTabIndex = i;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTabIndex == i ? AppColors.primaryGreen : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          tabs[i],
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: _activeTabIndex == i ? FontWeight.w700 : FontWeight.w500,
                            color: _activeTabIndex == i ? AppColors.primaryGreen : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tab Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildActiveTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ${widget.product.title}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.product.title} is a premium agricultural formulation manufactured by ${widget.product.vendor} and distributed directly through EBS Essential BioCrop Science. Engineered for Indian climatic and soil conditions, it provides dependable crop protection and enhanced yield vitality.',
              style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Key Benefits:',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Rapid systemic action and extended residual efficacy in all growing seasons.'),
            _buildBulletPoint('Safe for beneficial insects when used according to standard label recommendations.'),
            _buildBulletPoint('100% genuine batch authenticated with EBS lab purity certification.'),
            _buildBulletPoint('Compatible with common tank-mix combinations without phytotoxicity risks.'),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Specifications & Composition',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            _buildSpecRow('Active Ingredient', widget.product.technicalName),
            _buildSpecRow('Formulation Category', widget.product.category),
            _buildSpecRow('Manufacturer', widget.product.vendor),
            _buildSpecRow('Recommended Dosage', '1.5 - 2.0 ml / gm per liter of water (or 150-200 Ltr/acre)'),
            _buildSpecRow('Target Crops', 'Cotton, Paddy, Chili, Tomato, Sugarcane, Soybean, Pulses, Fruits'),
            _buildSpecRow('Pre-Harvest Interval (PHI)', '7 - 14 Days depending on crop stage'),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Apply & Safety Guidelines',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint('Spray during cool morning or late afternoon hours to maximize leaf absorption.'),
            _buildBulletPoint('Use clean water free from mud or heavy organic sediment for tank preparation.'),
            _buildBulletPoint('Wear protective gloves and mask while handling chemical concentrates.'),
            _buildBulletPoint('Store in the original tightly sealed container away from direct sunlight and children.'),
          ],
        );
      case 3:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${widget.product.rating} / 5.0',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      const Icon(Icons.star_rounded, size: 20, color: AppColors.ratingAmber),
                  ],
                ),
                const SizedBox(width: 10),
                Text(
                  'Based on ${widget.product.reviewsCount} verified farmer purchases',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildReviewItem(
              'Rajesh Patil (Farmer, Maharashtra)',
              5,
              'Used on my cotton field last month. Highly effective results within 48 hours. Genuine product and fast delivery from EBS.',
            ),
            const Divider(color: AppColors.border),
            _buildReviewItem(
              'Suresh Reddy (Agronomist, Andhra Pradesh)',
              5,
              'Good formulation purity. The pack was well-sealed and the price is lower than our local market dealer.',
            ),
          ],
        );
    }
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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

  Widget _buildReviewItem(String author, int rating, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Row(
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
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
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
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.76,
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
