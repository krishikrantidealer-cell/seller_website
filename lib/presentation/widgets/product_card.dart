import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/wishlist_state.dart';
import 'product_variants_modal.dart';

class ProductCard extends StatefulWidget {
  final ProductItem product;
  final VoidCallback? onTap;
  final Function(ProductItem, ProductVariant)? onAddToCart;
  final Function(ProductItem, ProductVariant)? onBuyNow;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onBuyNow,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late ProductVariant _selectedVariant;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.defaultVariant;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([CartController.instance, WishlistController.instance]),
      builder: (context, _) {
        final cart = CartController.instance;
        final variants = widget.product.variants.isNotEmpty ? widget.product.variants : [widget.product.defaultVariant];
        final currentQty = cart.getQuantity(widget.product.id, _selectedVariant.id);
        final totalProductQty = variants.fold<int>(0, (sum, v) => sum + cart.getQuantity(widget.product.id, v.id));
        final discount = _selectedVariant.discountPercent;

        return LayoutBuilder(
          builder: (context, cardConstraints) {
            final isCompact = cardConstraints.maxWidth < 220;

            return InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: totalProductQty > 0 ? AppColors.primaryGreen : AppColors.border,
                    width: totalProductQty > 0 ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Image Container with Discount Badge & In-Cart Badge
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 10,
                                  vertical: isCompact ? 4 : 8,
                                ),
                                child: Image.network(
                                  widget.product.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.white,
                                    child: const Icon(
                                      Icons.agriculture_rounded,
                                      size: 48,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Discount Badge
                            if (discount > 0)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 8, vertical: isCompact ? 2 : 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.discountRed,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$discount% OFF',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: isCompact ? 9.5 : 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            // Wishlist Heart Icon Button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    final added = WishlistController.instance.toggleWishlist(widget.product);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.primaryDarkGreen,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                        content: Row(
                                          children: [
                                            Icon(
                                              added ? Icons.favorite_rounded : Icons.heart_broken_rounded,
                                              color: added ? AppColors.primaryCrimson : Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                added
                                                    ? 'Added ${widget.product.title} to wishlist!'
                                                    : 'Removed from wishlist',
                                                style: GoogleFonts.poppins(fontSize: 12.5),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: isCompact ? 28 : 32,
                                    height: isCompact ? 28 : 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: WishlistController.instance.isLiked(widget.product.id)
                                            ? AppColors.primaryCrimson.withValues(alpha: 0.3)
                                            : AppColors.border,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        WishlistController.instance.isLiked(widget.product.id)
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        size: isCompact ? 15 : 18,
                                        color: WishlistController.instance.isLiked(widget.product.id)
                                            ? AppColors.primaryCrimson
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Added to cart indicator pill
                            if (totalProductQty > 0)
                              Positioned(
                                top: 8,
                                right: isCompact ? 34 : 44,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 5 : 7, vertical: isCompact ? 2 : 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_bag_rounded, size: isCompact ? 10 : 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        isCompact ? '$totalProductQty' : '$totalProductQty in cart',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: isCompact ? 9 : 10,
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
                    ),

                    // Content details
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 8 : 12,
                        vertical: isCompact ? 6 : 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Tag & Vendor
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.product.category.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: isCompact ? 8.5 : 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  widget.product.vendor,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: isCompact ? 8.5 : 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 3 : 6),

                          // Product Title
                          Text(
                            widget.product.title,
                            style: GoogleFonts.poppins(
                              fontSize: isCompact ? 11.5 : 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isCompact ? 2 : 4),

                          // Technical Name
                          Text(
                            widget.product.technicalName,
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryCrimson,
                              fontSize: isCompact ? 9.5 : 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isCompact ? 4 : 6),

                          // Rating & Reviews
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.ratingAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: isCompact ? 12 : 14, color: AppColors.ratingAmber),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.product.rating.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: isCompact ? 9.5 : 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.product.reviewsCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: isCompact ? 9.5 : 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 4 : 6),

                          // Pack Size selector chip / label (tap opens variants popup)
                          InkWell(
                            onTap: () => _openVariantsModal(context),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedVariant.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: isCompact ? 10 : 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDarkGreen,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.product.variants.length > 1) ...[
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 2 : 4),

                          // Pricing
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${_selectedVariant.displayRate.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: isCompact ? 15 : 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (_selectedVariant.printedMrp > _selectedVariant.displayRate)
                                Text(
                                  '₹${_selectedVariant.printedMrp.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isCompact ? 10 : 12,
                                    color: AppColors.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 6 : 10),

                          // Action Buttons (Add to Cart / Stepper)
                          if (currentQty > 0)
                            _buildQuantityStepper(cart, isCompact: isCompact)
                          else
                            _buildAddToCartButton(cart, isCompact: isCompact),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openVariantsModal(BuildContext context) {
    showProductVariantsModal(
      context: context,
      product: widget.product,
      initialSelectedVariant: _selectedVariant,
      onViewCart: () {
        if (widget.onBuyNow != null) {
          widget.onBuyNow?.call(widget.product, _selectedVariant);
        } else {
          Scaffold.maybeOf(context)?.openEndDrawer();
        }
      },
    );
  }

  Widget _buildQuantityStepper(CartController cart, {bool isCompact = false}) {
    final itemKey = '${widget.product.id}_${_selectedVariant.id}';
    final qty = cart.getQuantity(widget.product.id, _selectedVariant.id);
    final buttonHeight = isCompact ? 32.0 : 38.0;
    final btnWidth = isCompact ? 30.0 : 36.0;

    return Container(
      height: buttonHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => cart.decrement(itemKey),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
            child: Container(
              width: btnWidth,
              height: buttonHeight,
              alignment: Alignment.center,
              child: Icon(
                qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                size: isCompact ? 16 : 18,
                color: qty == 1 ? AppColors.primaryCrimson : AppColors.primaryDarkGreen,
              ),
            ),
          ),
          Flexible(
            child: InkWell(
              onTap: () => _openVariantsModal(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: isCompact ? 12 : 14, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Qty: $qty',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: isCompact ? 11 : 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ),
                  if (widget.product.variants.length > 1) ...[
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.primaryDarkGreen),
                  ],
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => cart.increment(itemKey),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
            child: Container(
              width: btnWidth,
              height: buttonHeight,
              alignment: Alignment.center,
              child: Icon(
                Icons.add_rounded,
                size: isCompact ? 16 : 18,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(CartController cart, {bool isCompact = false}) {
    final btnHeight = isCompact ? 32.0 : 38.0;

    return SizedBox(
      height: btnHeight,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openVariantsModal(context),
        icon: Icon(Icons.add_shopping_cart_rounded, size: isCompact ? 14 : 16),
        label: Text(
          'Add to Cart',
          style: GoogleFonts.poppins(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
