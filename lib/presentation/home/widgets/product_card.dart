import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_placeholder.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/cart/cart_bloc.dart';
import '../../../logic/cart/cart_event.dart';
import '../../../logic/catalog/catalog_bloc.dart';
import '../../../logic/catalog/catalog_event.dart';
import '../../../logic/catalog/catalog_state.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  Color _getToxicityColor(String toxicity) {
    switch (toxicity.toUpperCase()) {
      case 'GREEN':
        return const Color(0xFF16A34A);
      case 'BLUE':
        return const Color(0xFF2563EB);
      case 'YELLOW':
        return const Color(0xFFD97706);
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getToxicityLabel(String toxicity) {
    switch (toxicity.toUpperCase()) {
      case 'GREEN':
        return 'हरा त्रिभुज: जैविक व सुरक्षित (Green Bio)';
      case 'BLUE':
        return 'नीला त्रिभुज: मध्यम विषाक्त (Caution)';
      case 'YELLOW':
        return 'पीला त्रिभुज: विषाक्त (Toxicity Warning)';
      default:
        return 'CIBRC Registered';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, catalogState) {
        final currentVariant = catalogState.getSelectedVariant(product);
        final toxicityColor = _getToxicityColor(product.toxicity);

        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with 404 Fallback & Badges
              Stack(
                children: [
                  SafeNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Badges (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isOrganic)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco_rounded, size: 11, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  '100% जैविक (Bio)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (currentVariant.discountPercent > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${currentVariant.discountPercent}% छूट (OFF)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Rating badge (Bottom Right)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${product.reviewCount})',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Product Info Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand & Statutory CIBRC Triangle
                      Row(
                        children: [
                          Text(
                            product.brand.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.harvestAmber,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          Tooltip(
                            message: _getToxicityLabel(product.toxicity),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: toxicityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: toxicityColor, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.change_history_rounded, size: 11, color: toxicityColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    product.toxicity,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: toxicityColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Title (English)
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),

                      // Title (Hindi)
                      Text(
                        product.hindiTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Technical Formulation Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.leafAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Tech: ${product.technicalName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Dosage Guidance
                      Row(
                        children: [
                          const Icon(Icons.water_drop_outlined, size: 13, color: AppColors.harvestAmber),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'मात्रा: ${product.dosagePerPump}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Pack Size Variant Selector (Pills)
                      const Text(
                        'Pack Size (पैकिंग चुनें):',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: product.variants.map((PackVariant v) {
                            final isSel = v.id == currentVariant.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  context.read<CatalogBloc>().add(
                                        SelectProductVariant(
                                          productId: product.id,
                                          variant: v,
                                        ),
                                      );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.primaryGreen : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSel ? AppColors.primaryGreen : AppColors.border,
                                      width: isSel ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    v.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Price & Add to Cart Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '₹${currentVariant.sellingPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.forestDark,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (currentVariant.mrp > currentVariant.sellingPrice)
                                      Text(
                                        '₹${currentVariant.mrp.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                                if (currentVariant.savings > 0)
                                  Text(
                                    'बचत: ₹${currentVariant.savings.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Add to Cart Button
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    AddToCart(
                                      product: product,
                                      variant: currentVariant,
                                      quantity: 1,
                                    ),
                                  );

                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(milliseconds: 1400),
                                  backgroundColor: AppColors.forestDark,
                                  content: Text(
                                    '${product.title} (${currentVariant.label}) added to basket',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 15),
                            label: const Text(
                              'Add',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 11, color: Color(0xFF16A34A)),
                          SizedBox(width: 3),
                          Text(
                            'COD उपलब्ध | 100% असली GST बिल',
                            style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
