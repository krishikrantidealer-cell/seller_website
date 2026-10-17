import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/cart_state.dart';

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
      animation: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        final currentQty = cart.getQuantity(widget.product.id, _selectedVariant.id);
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
                    color: currentQty > 0 ? AppColors.primaryGreen : AppColors.border,
                    width: currentQty > 0 ? 1.5 : 1.0,
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
                        color: AppColors.warmBackground,
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(isCompact ? 8 : 12),
                                child: Image.network(
                                  widget.product.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.warmBackground,
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
                            // Added to cart indicator pill
                            if (currentQty > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 8, vertical: isCompact ? 2 : 4),
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
                                        isCompact ? '$currentQty' : '$currentQty in cart',
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
                      padding: EdgeInsets.all(isCompact ? 8 : 12),
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
                          SizedBox(height: isCompact ? 4 : 8),

                          // REA AgriBegri Pack Size / Variant Selector Pills
                          if (widget.product.variants.isNotEmpty) ...[
                            Text(
                              'Select Pack Size:',
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 8.5 : 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: widget.product.variants.map((v) {
                                  final isSelected = v.id == _selectedVariant.id;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedVariant = v;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isCompact ? 5 : 8,
                                          vertical: isCompact ? 2 : 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.lightGreen : Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryGreen : AppColors.border,
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          v.label,
                                          style: GoogleFonts.poppins(
                                            fontSize: isCompact ? 8.5 : 10,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          SizedBox(height: isCompact ? 6 : 10),

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

                          // REA AgriBegri Action: Quantity Stepper if In-Cart, Dual Buttons if Not
                          if (currentQty > 0)
                            _buildQuantityStepper(cart, isCompact: isCompact)
                          else
                            _buildDualActionButtons(cart, isCompact: isCompact),
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

  Widget _buildQuantityStepper(CartController cart, {bool isCompact = false}) {
    final itemKey = '${widget.product.id}_${_selectedVariant.id}';
    final qty = cart.getQuantity(widget.product.id, _selectedVariant.id);
    final buttonHeight = isCompact ? 32.0 : 38.0;
    final btnWidth = isCompact ? 32.0 : 38.0;

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
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: isCompact ? 12 : 14, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                'Qty: $qty',
                style: GoogleFonts.poppins(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
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

  Widget _buildDualActionButtons(CartController cart, {bool isCompact = false}) {
    final btnHeight = isCompact ? 32.0 : 38.0;

    if (isCompact) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: btnHeight,
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(widget.product, _selectedVariant);
                  widget.onAddToCart?.call(widget.product, _selectedVariant);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  'Add',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: btnHeight,
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(widget.product, _selectedVariant);
                  widget.onBuyNow?.call(widget.product, _selectedVariant);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  'Buy',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Add to Cart Button
        Expanded(
          flex: 5,
          child: SizedBox(
            height: btnHeight,
            child: ElevatedButton.icon(
              onPressed: () {
                cart.addItem(widget.product, _selectedVariant);
                widget.onAddToCart?.call(widget.product, _selectedVariant);
              },
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 15),
              label: Text(
                'Add to Cart',
                style: GoogleFonts.poppins(
                  fontSize: 11,
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
          ),
        ),
        const SizedBox(width: 6),
        // Buy Now Button
        Expanded(
          flex: 4,
          child: SizedBox(
            height: btnHeight,
            child: ElevatedButton.icon(
              onPressed: () {
                cart.addItem(widget.product, _selectedVariant);
                widget.onBuyNow?.call(widget.product, _selectedVariant);
              },
              icon: const Icon(Icons.bolt_rounded, size: 15),
              label: Text(
                'Buy Now',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCrimson,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
