import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/cart_state.dart';

/// Opens a responsive popup (modal bottom sheet on mobile, dialog on desktop)
/// displaying all available pack sizes / variants of a product with real-time
/// cart controls.
Future<void> showProductVariantsModal({
  required BuildContext context,
  required ProductItem product,
  ProductVariant? initialSelectedVariant,
  VoidCallback? onViewCart,
}) async {
  final isMobile = MediaQuery.sizeOf(context).width < 650;

  void handleViewCart(BuildContext modalCtx) {
    Navigator.pop(modalCtx);
    if (onViewCart != null) {
      onViewCart();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Scaffold.maybeOf(context)?.openEndDrawer();
      }
    });
  }

  if (isMobile) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductVariantsSheetContent(
        product: product,
        initialSelectedVariant: initialSelectedVariant,
        onViewCart: () => handleViewCart(ctx),
      ),
    );
  } else {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
          child: _ProductVariantsDialogContent(
            product: product,
            initialSelectedVariant: initialSelectedVariant,
            onViewCart: () => handleViewCart(ctx),
          ),
        ),
      ),
    );
  }
}

/// Mobile Bottom Sheet Content
class _ProductVariantsSheetContent extends StatelessWidget {
  final ProductItem product;
  final ProductVariant? initialSelectedVariant;
  final VoidCallback? onViewCart;

  const _ProductVariantsSheetContent({
    required this.product,
    this.initialSelectedVariant,
    this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle Pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Top Header with Product Info & Close Button
            _buildProductHeader(context, isMobile: true),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Scrollable Variants List
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: _VariantsList(product: product),
              ),
            ),

            // Bottom Cart Summary Bar
            _buildBottomBar(context, isMobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, {required bool isMobile}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.agriculture_rounded, size: 28, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'By ${product.vendor}',
                        style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  product.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.technicalName,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryCrimson,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Close Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, {required bool isMobile}) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        final variants = product.variants.isNotEmpty ? product.variants : [product.defaultVariant];
        int productItemsInCart = 0;
        double productSubtotal = 0;

        for (final v in variants) {
          final qty = cart.getQuantity(product.id, v.id);
          if (qty > 0) {
            productItemsInCart += qty;
            productSubtotal += (qty * v.displayRate);
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (productItemsInCart > 0) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            '$productItemsInCart in Cart (₹${productSubtotal.toInt()})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Total Cart Value: ₹${cart.subtotal.toInt()}',
                        style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ] else ...[
                      Text(
                        'Select a pack size above',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '100% Genuine EBS certified batch',
                        style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (cart.totalCount > 0)
                ElevatedButton.icon(
                  onPressed: onViewCart,
                  icon: const Icon(Icons.shopping_bag_rounded, size: 15),
                  label: Text(
                    'View Cart (${cart.totalCount})',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Desktop Dialog Content
class _ProductVariantsDialogContent extends StatelessWidget {
  final ProductItem product;
  final ProductVariant? initialSelectedVariant;
  final VoidCallback? onViewCart;

  const _ProductVariantsDialogContent({
    required this.product,
    this.initialSelectedVariant,
    this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                // Product Thumbnail
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.agriculture_rounded, size: 28, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDarkGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Brand: ${product.vendor}',
                              style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.technicalName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryCrimson,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Close Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textMuted),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Title strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Select Pack Size / Variant',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${product.variants.length} Options Available',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Scrollable List of All Variants
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _VariantsList(product: product),
            ),
          ),

          // Bottom Bar
          _buildDesktopBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildDesktopBottomBar(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        final variants = product.variants.isNotEmpty ? product.variants : [product.defaultVariant];
        int productItemsInCart = 0;
        double productSubtotal = 0;

        for (final v in variants) {
          final qty = cart.getQuantity(product.id, v.id);
          if (qty > 0) {
            productItemsInCart += qty;
            productSubtotal += (qty * v.displayRate);
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        productItemsInCart > 0
                            ? '$productItemsInCart pack(s) in cart (₹${productSubtotal.toInt()})'
                            : '100% Genuine formulation authenticated directly from manufacturer',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: productItemsInCart > 0 ? FontWeight.w700 : FontWeight.w500,
                          color: productItemsInCart > 0 ? AppColors.primaryDarkGreen : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  if (cart.totalCount > 0) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: onViewCart,
                      icon: const Icon(Icons.shopping_bag_rounded, size: 16),
                      label: Text(
                        'View Cart (${cart.totalCount})',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The List of All Variants with interactive Add/Stepper buttons
class _VariantsList extends StatelessWidget {
  final ProductItem product;

  const _VariantsList({required this.product});

  @override
  Widget build(BuildContext context) {
    final variants = product.variants.isNotEmpty ? product.variants : [product.defaultVariant];

    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;

        return Column(
          children: [
            for (int i = 0; i < variants.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _buildVariantRow(context, cart, variants[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildVariantRow(BuildContext context, CartController cart, ProductVariant variant) {
    final qty = cart.getQuantity(product.id, variant.id);
    final discount = variant.discountPercent;
    final savings = variant.printedMrp - variant.displayRate;
    final isInCart = qty > 0;
    final itemKey = '${product.id}_${variant.id}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isInCart ? AppColors.lightGreen.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInCart ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
          width: isInCart ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isInCart ? 0.04 : 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pack Size Label & Savings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      variant.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (discount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Pricing Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${variant.displayRate.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (variant.printedMrp > variant.displayRate) ...[
                      Text(
                        'MRP ₹${variant.printedMrp.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(Save ₹${savings.toInt()})',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      'In Stock • Ships in 24 hrs',
                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Interactive Action: Quantity Stepper if in cart, or "+ Add" button
          if (isInCart)
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primaryGreen, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => cart.decrement(itemKey),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                    child: Container(
                      width: 34,
                      height: 36,
                      alignment: Alignment.center,
                      child: Icon(
                        qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                        size: 16,
                        color: qty == 1 ? AppColors.primaryCrimson : AppColors.primaryDarkGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Text(
                      '$qty',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => cart.increment(itemKey),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                    child: Container(
                      width: 34,
                      height: 36,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: () {
                  cart.addItem(product, variant, 1);
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 15),
                label: Text(
                  'Add',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
