import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/wishlist_state.dart';
import 'app_product_image.dart';

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
  static const Color _brandRed = Color(0xFFC81E1E);
  static const Color _darkCharcoal = Color(0xFF1F2937);
  static const Color _imageTint = Color(0xFFF6EFE6);

  late ProductVariant _selectedVariant;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.defaultVariant;
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id ||
        !widget.product.variants.any((v) => v.id == _selectedVariant.id) ||
        oldWidget.product.defaultVariant.id != widget.product.defaultVariant.id) {
      _selectedVariant = widget.product.defaultVariant;
    } else if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.firstWhere(
        (v) => v.id == _selectedVariant.id,
        orElse: () => widget.product.defaultVariant,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([CartController.instance, WishlistController.instance]),
      builder: (context, _) {
        final cart = CartController.instance;
        final variants = widget.product.variants.isNotEmpty
            ? widget.product.variants
            : [widget.product.defaultVariant];
        final currentQty = cart.getQuantity(widget.product.id, _selectedVariant.id);
        final discount = _selectedVariant.discountPercent;
        final savings = (_selectedVariant.printedMrp - _selectedVariant.displayRate).round();
        final isOutOfStock = !widget.product.isAvailable ||
            !_selectedVariant.inStock ||
            (_selectedVariant.stock != null && _selectedVariant.stock! <= 0);
        final brandLabel = (widget.product.brandName.isNotEmpty
                ? widget.product.brandName
                : (widget.product.vendor.isNotEmpty
                    ? widget.product.vendor
                    : widget.product.category))
            .toUpperCase();

        return LayoutBuilder(
          builder: (context, cardConstraints) {
            final isCompact = cardConstraints.maxWidth < 210;

            return InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: currentQty > 0
                        ? AppColors.primaryGreen.withValues(alpha: 0.7)
                        : const Color(0xFFEAE6DF),
                    width: currentQty > 0 ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.045),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Tinted Image Box with Discount Pill & Wishlist Heart
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isCompact ? 6 : 8,
                          isCompact ? 6 : 8,
                          isCompact ? 6 : 8,
                          0,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _imageTint,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF0ECE4)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppProductImage(
                                imageUrl: widget.product.imageUrl,
                                fallbackUrls: widget.product.imageUrls,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                fallbackIcon: Icons.agriculture_rounded,
                                fallbackIconSize: 44,
                              ),
                              if (discount > 0)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompact ? 7 : 9,
                                      vertical: isCompact ? 2.5 : 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _brandRed,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$discount% OFF',
                                      style: GoogleFonts.mukta(
                                        color: Colors.white,
                                        fontSize: isCompact ? 9.5 : 10.5,
                                        fontWeight: FontWeight.w800,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: _buildWishlistButton(context, isCompact),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Details & Actions
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isCompact ? 9 : 12,
                        isCompact ? 7 : 10,
                        isCompact ? 9 : 12,
                        isCompact ? 9 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand / Manufacturer
                          Text(
                            brandLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mukta(
                              color: const Color(0xFF78716C),
                              fontSize: isCompact ? 9.5 : 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: isCompact ? 2 : 3),

                          // Product Title
                          Text(
                            widget.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mukta(
                              fontSize: isCompact ? 13 : 14.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1917),
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: isCompact ? 4 : 6),

                          // Price + MRP + Save Pill
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '₹${_selectedVariant.displayRate.toStringAsFixed(0)}',
                                  style: GoogleFonts.mukta(
                                    fontSize: isCompact ? 16 : 19,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF18181B),
                                    height: 1.1,
                                  ),
                                ),
                                if (_selectedVariant.printedMrp > _selectedVariant.displayRate) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '₹${_selectedVariant.printedMrp.toStringAsFixed(0)}',
                                    style: GoogleFonts.mukta(
                                      fontSize: isCompact ? 11 : 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF9CA3AF),
                                      decoration: TextDecoration.lineThrough,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                                if (savings > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompact ? 6 : 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Save ₹$savings',
                                      style: GoogleFonts.mukta(
                                        fontSize: isCompact ? 9.5 : 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF15803D),
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: isCompact ? 6 : 8),

                          // Pack Size Dropdown Selector Box
                          _buildPackSizeBox(variants, isCompact),
                          SizedBox(height: isCompact ? 6 : 9),

                          // Bottom Action Row: Add to Cart + Buy Now
                          if (isOutOfStock)
                            _buildOutOfStockButton(isCompact: isCompact)
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: currentQty > 0
                                      ? _buildQuantityStepper(cart, isCompact: isCompact)
                                      : _buildAddToCartButton(cart, isCompact: isCompact),
                                ),
                                SizedBox(width: isCompact ? 6 : 8),
                                Expanded(
                                  child: _buildBuyNowButton(cart, isCompact: isCompact),
                                ),
                              ],
                            ),
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

  Widget _buildWishlistButton(BuildContext context, bool isCompact) {
    final isLiked = WishlistController.instance.isLiked(widget.product.id);
    final size = isCompact ? 28.0 : 32.0;

    return Material(
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
                    color: added ? _brandRed : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      added
                          ? 'Added ${widget.product.title} to wishlist!'
                          : 'Removed from wishlist',
                      style: GoogleFonts.mukta(fontSize: 12.5),
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
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
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
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: isCompact ? 15 : 17,
              color: isLiked ? _brandRed : const Color(0xFF44403C),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackSizeBox(List<ProductVariant> variants, bool isCompact) {
    final hasMultiple = variants.length > 1;
    final box = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasMultiple ? const Color(0xFFD6CFC5) : const Color(0xFFEAE6DF),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasMultiple ? 'PACK SIZE • ${variants.length} OPTIONS' : 'PACK SIZE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.mukta(
                    fontSize: isCompact ? 8 : 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: hasMultiple ? _brandRed : const Color(0xFF78716C),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _selectedVariant.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.mukta(
                    fontSize: isCompact ? 11.5 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1917),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: isCompact ? 22 : 24,
            height: isCompact ? 22 : 24,
            decoration: BoxDecoration(
              color: hasMultiple ? const Color(0xFFFDF2F2) : const Color(0xFFF3F0EA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: isCompact ? 16 : 18,
              color: hasMultiple ? _brandRed : const Color(0xFF78716C),
            ),
          ),
        ],
      ),
    );

    if (!hasMultiple) return box;

    return PopupMenuButton<ProductVariant>(
      tooltip: 'Select Pack Size',
      initialValue: _selectedVariant,
      offset: const Offset(0, 48),
      color: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEAE6DF)),
      ),
      onSelected: (variant) {
        setState(() => _selectedVariant = variant);
      },
      itemBuilder: (context) => variants.map((v) {
        final isSelected = v.id == _selectedVariant.id;
        final vDiscount = v.discountPercent;
        return PopupMenuItem<ProductVariant>(
          value: v,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDF2F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? _brandRed.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: isSelected ? _brandRed : const Color(0xFFA8A29E),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.label,
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? _brandRed : const Color(0xFF1C1917),
                          ),
                        ),
                        if (vDiscount > 0)
                          Text(
                            '$vDiscount% OFF',
                            style: GoogleFonts.mukta(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${v.displayRate.toStringAsFixed(0)}',
                      style: GoogleFonts.mukta(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    if (v.printedMrp > v.displayRate)
                      Text(
                        '₹${v.printedMrp.toStringAsFixed(0)}',
                        style: GoogleFonts.mukta(
                          fontSize: 10.5,
                          color: const Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
      child: box,
    );
  }

  Widget _buildQuantityStepper(CartController cart, {bool isCompact = false}) {
    final itemKey = '${widget.product.id}_${_selectedVariant.id}';
    final qty = cart.getQuantity(widget.product.id, _selectedVariant.id);
    final buttonHeight = isCompact ? 32.0 : 36.0;
    final btnWidth = isCompact ? 24.0 : 28.0;

    return Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryGreen, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => cart.decrement(itemKey),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
            child: SizedBox(
              width: btnWidth,
              height: buttonHeight,
              child: Icon(
                qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                size: isCompact ? 14 : 16,
                color: qty == 1 ? _brandRed : AppColors.primaryDarkGreen,
              ),
            ),
          ),
          Text(
            '$qty',
            style: GoogleFonts.mukta(
              fontSize: isCompact ? 11.5 : 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          InkWell(
            onTap: () => cart.increment(itemKey),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
            child: SizedBox(
              width: btnWidth,
              height: buttonHeight,
              child: Icon(
                Icons.add_rounded,
                size: isCompact ? 14 : 16,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockButton({bool isCompact = false}) {
    final btnHeight = isCompact ? 32.0 : 36.0;

    return SizedBox(
      height: btnHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: _brandRed,
          backgroundColor: const Color(0xFFFEF2F2),
          side: const BorderSide(color: Color(0xFFFECACA)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Out of Stock',
          style: GoogleFonts.mukta(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(CartController cart, {bool isCompact = false}) {
    final btnHeight = isCompact ? 32.0 : 36.0;

    return SizedBox(
      height: btnHeight,
      child: ElevatedButton(
        onPressed: () {
          cart.addItem(widget.product, _selectedVariant);
          widget.onAddToCart?.call(widget.product, _selectedVariant);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Add to Cart',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.mukta(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton(CartController cart, {bool isCompact = false}) {
    final btnHeight = isCompact ? 32.0 : 36.0;

    return SizedBox(
      height: btnHeight,
      child: ElevatedButton(
        onPressed: () {
          if (cart.getQuantity(widget.product.id, _selectedVariant.id) == 0) {
            cart.addItem(widget.product, _selectedVariant);
          }
          widget.onBuyNow?.call(widget.product, _selectedVariant);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Buy Now',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.mukta(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
