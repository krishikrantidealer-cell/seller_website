import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_placeholder.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../logic/cart/cart_bloc.dart';
import '../../../logic/cart/cart_event.dart';
import '../../../logic/cart/cart_state.dart';
import 'farmer_checkout_modal.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = min(screenWidth, 420.0);

    return Drawer(
      backgroundColor: Colors.white,
      width: drawerWidth,
      child: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.forestDark,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your Agri Basket (${state.totalCount} Items)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Free Delivery Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  color: AppColors.paleGreen,
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'मुफ़्त होम डिलीवरी (FREE Pan-India Doorstep Delivery)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Items list or Empty State
                Expanded(
                  child: state.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove_shopping_cart_outlined, size: 68, color: Colors.grey.shade300),
                                const SizedBox(height: 14),
                                const Text(
                                  'आपकी टोकरी खाली है (Basket is Empty)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'कीटनाशक, कवकनाशी एवं जैविक खाद के उच्च गुणवत्ता वाले उत्पाद जोड़ें।',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                                  label: const Text('खरीदारी शुरू करें (Browse Products)'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.items.length,
                          separatorBuilder: (context, index) => const Divider(height: 20, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final CartItemModel item = state.items[index];
                            final itemSavings = (item.variant.mrp - item.variant.sellingPrice) * item.quantity;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SafeNetworkImage(
                                    imageUrl: item.product.imageUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Pack: ${item.variant.label}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          if (itemSavings > 0)
                                            Text(
                                              'बचत ₹${itemSavings.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '₹${item.variant.sellingPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (item.variant.mrp > item.variant.sellingPrice)
                                            Text(
                                              '₹${item.variant.mrp.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: AppColors.textMuted,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Quantity modifier
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          item.quantity > 1 ? Icons.remove : Icons.delete_outline_rounded,
                                          size: 14,
                                          color: item.quantity > 1 ? AppColors.textPrimary : Colors.red,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        onPressed: () {
                                          context.read<CartBloc>().add(
                                                UpdateQuantity(
                                                  productId: item.product.id,
                                                  variantId: item.variant.id,
                                                  quantity: item.quantity - 1,
                                                ),
                                              );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 14, color: AppColors.textPrimary),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        onPressed: () {
                                          context.read<CartBloc>().add(
                                                UpdateQuantity(
                                                  productId: item.product.id,
                                                  variantId: item.variant.id,
                                                  quantity: item.quantity + 1,
                                                ),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                // Footer with Checkout Breakdown
                if (!state.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Savings row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'कुल किसान बचत (Total Savings)',
                                style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '- ₹${state.totalSavings.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Delivery row
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Doorstep Delivery',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'FREE (मुफ़्त)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Grand Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                Text('कुल देय राशि (Incl. GST)', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                              ],
                            ),
                            Text(
                              '₹${state.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Proceed to Checkout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop(); // close drawer
                              FarmerCheckoutModal.show(context, state);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandRed,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                            label: const Text(
                              'Proceed to Farmer Checkout (ऑर्डर करें)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // WhatsApp Direct Order alternative
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              FarmerCheckoutModal.show(context, state);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF15803D),
                              side: const BorderSide(color: Color(0xFF22C55E)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                            label: const Text(
                              'Order via WhatsApp (व्हाट्सएप ऑर्डर)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
