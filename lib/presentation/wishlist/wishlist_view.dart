import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/wishlist_state.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/web_footer.dart';
import '../product_detail/product_detail_view.dart';

/// Screen displaying farmer's saved / liked wishlist products with quick add-to-cart.
class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _confirmClearWishlist() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppColors.primaryCrimson, size: 24),
            const SizedBox(width: 8),
            Text(
              'Clear Wishlist?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove all saved products from your wishlist?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              WishlistController.instance.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wishlist cleared', style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.primaryDarkGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCrimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Clear All', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _addToCart(ProductItem product, ProductVariant variant) {
    CartController.instance.addItem(product, variant, 1);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryDarkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${product.title} (${variant.label}) to cart!',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.amberAccent,
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      endDrawer: const QuickCartDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top information strip
            const TopInfoBar(),

            // Main navigation header
            MainNavHeader(
              onCartTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),

            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: AnimatedBuilder(
                    animation: WishlistController.instance,
                    builder: (context, _) {
                      final wishlist = WishlistController.instance;
                      final items = wishlist.items;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb row
                          _buildBreadcrumbs(context),
                          const SizedBox(height: 16),

                          // Header row: Title + Item Count + Actions
                          _buildHeaderRow(context, items.length),
                          const SizedBox(height: 20),

                          // Content: Empty State vs Products Grid
                          if (items.isEmpty)
                            _buildEmptyState(context)
                          else
                            _buildWishlistGrid(context, items),

                          const SizedBox(height: 48),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Storefront footer
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
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
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Home',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            'My Wishlist',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final titleWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.softRose,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.primaryCrimson,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    count == 1 ? '1 product saved' : '$count products saved',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );

        final clearButton = count > 0
            ? OutlinedButton.icon(
                onPressed: _confirmClearWishlist,
                icon: const Icon(Icons.delete_outline_rounded, size: 14),
                label: Text(
                  isMobile ? 'Clear' : 'Clear Wishlist',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryCrimson,
                  side: const BorderSide(color: AppColors.primaryCrimson, width: 1.1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            : const SizedBox.shrink();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: titleWidget),
            if (count > 0) clearButton,
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.softRose,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: AppColors.primaryCrimson,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Wishlist is Empty',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                'Explore top-performing seeds, crop protection, fertilizers, and farm equipment. Tap the heart ❤️ icon on any product to save it here for fast access and reordering.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: Text(
                'Explore Store',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context, List<ProductItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 4;
        if (width < 500) {
          crossAxisCount = 1;
        } else if (width < 800) {
          crossAxisCount = 2;
        } else if (width < 1180) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: crossAxisCount == 1 ? (width < 360 ? 175 : 160) : 380,
          ),
          itemBuilder: (context, index) {
            final product = items[index];
            if (crossAxisCount == 1) {
              return _WishlistHorizontalCard(
                product: product,
                onAddToCart: (p, v) => _addToCart(p, v),
              );
            }
            return _WishlistVerticalCard(
              product: product,
              onAddToCart: (p, v) => _addToCart(p, v),
            );
          },
        );
      },
    );
  }
}

/// Wishlist Vertical Card (Desktop & Tablet)
class _WishlistVerticalCard extends StatefulWidget {
  final ProductItem product;
  final Function(ProductItem, ProductVariant) onAddToCart;

  const _WishlistVerticalCard({
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<_WishlistVerticalCard> createState() => _WishlistVerticalCardState();
}

class _WishlistVerticalCardState extends State<_WishlistVerticalCard> {
  late ProductVariant _selectedVariant;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.defaultVariant;
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.variants.isNotEmpty
        ? widget.product.variants
        : [widget.product.defaultVariant];
    final discount = _selectedVariant.discountPercent;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Discount Badge + Remove Button
          Expanded(
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: widget.product),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.discountRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Remove from Wishlist Button (Filled Heart)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        WishlistController.instance.remove(widget.product.id);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed ${widget.product.title} from wishlist', style: GoogleFonts.poppins()),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 18,
                            color: AppColors.primaryCrimson,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Vendor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.product.vendor,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Title
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: widget.product),
                      ),
                    );
                  },
                  child: Text(
                    widget.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Technical name
                Text(
                  widget.product.technicalName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${_selectedVariant.displayRate.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_selectedVariant.printedMrp > _selectedVariant.displayRate)
                      Text(
                        '₹${_selectedVariant.printedMrp.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Variant Selector Dropdown if multiple
                if (variants.length > 1) ...[
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductVariant>(
                        value: _selectedVariant,
                        isDense: true,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary),
                        items: variants.map((v) {
                          return DropdownMenuItem<ProductVariant>(
                            value: v,
                            child: Text(
                              '${v.label} - ₹${v.displayRate.toInt()}',
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedVariant = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pack: ${_selectedVariant.label}',
                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Move / Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onAddToCart(widget.product, _selectedVariant),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                    label: Text(
                      'Add to Cart',
                      style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wishlist Horizontal Card (Compact Mobile)
class _WishlistHorizontalCard extends StatelessWidget {
  final ProductItem product;
  final Function(ProductItem, ProductVariant) onAddToCart;

  const _WishlistHorizontalCard({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final variant = product.defaultVariant;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isVeryNarrow = cardConstraints.maxWidth < 340;
        final imageWidth = isVeryNarrow ? 85.0 : 100.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.all(isVeryNarrow ? 8 : 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailView(product: product),
                    ),
                  );
                },
                child: Container(
                  width: imageWidth,
                  height: isVeryNarrow ? 130 : 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.agriculture_rounded,
                      size: 40,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isVeryNarrow ? 8 : 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                product.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDarkGreen,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Remove button
                            InkWell(
                              onTap: () {
                                WishlistController.instance.remove(product.id);
                              },
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 18,
                                color: AppColors.primaryCrimson,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: isVeryNarrow ? 11.5 : 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.technicalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (isVeryNarrow)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₹${variant.displayRate.toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  variant.label,
                                  style: GoogleFonts.poppins(fontSize: 9.5, color: AppColors.textMuted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: ElevatedButton.icon(
                              onPressed: () => onAddToCart(product, variant),
                              icon: const Icon(Icons.add_shopping_cart_rounded, size: 12),
                              label: Text(
                                'Add to Cart',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${variant.displayRate.toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                variant.label,
                                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => onAddToCart(product, variant),
                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 13),
                            label: Text(
                              'Add to Cart',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
