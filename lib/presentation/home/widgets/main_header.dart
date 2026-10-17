import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/cart/cart_bloc.dart';
import '../../../logic/cart/cart_state.dart';
import '../../../logic/catalog/catalog_bloc.dart';
import '../../../logic/catalog/catalog_event.dart';

class MainHeader extends StatefulWidget {
  final VoidCallback onOpenCart;

  const MainHeader({super.key, required this.onOpenCart});

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final showDeliveryTag = screenWidth >= 1180;
    final showCartText = screenWidth >= 640;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 12 : 24,
        vertical: 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Logo
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      context.read<CatalogBloc>().add(const SearchTechnicalOrBrand(''));
                      context.read<CatalogBloc>().add(const SelectCategory('all'));
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppConstants.logoPath,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.eco_rounded,
                            size: 38,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EBS BioCrop',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Essential Bio Crop Science',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandRed,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (isDesktop) ...[
                    const SizedBox(width: 24),
                    // Expanded Search Bar
                    Expanded(
                      child: _buildSearchBar(context, isDesktop),
                    ),
                    const SizedBox(width: 20),
                  ] else
                    const Spacer(),

                  // Actions: Free Delivery Tag + Cart + Account
                  if (showDeliveryTag) ...[
                    // Free delivery guarantee
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.leafAccent.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primaryGreen),
                          SizedBox(width: 6),
                          Text(
                            'Free Pan-India Delivery',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Cart Button with Counter
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      return InkWell(
                        onTap: widget.onOpenCart,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Badge(
                                isLabelVisible: cartState.totalCount > 0,
                                label: Text(
                                  '${cartState.totalCount}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                backgroundColor: AppColors.brandRed,
                                child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                              ),
                              if (showCartText) ...[
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'My Basket',
                                      style: TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                    Text(
                                      cartState.subtotal > 0
                                          ? '₹${cartState.subtotal.toStringAsFixed(0)}'
                                          : '₹0',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (!isDesktop) ...[
                const SizedBox(height: 10),
                _buildSearchBar(context, isDesktop),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<CatalogBloc>().add(SearchTechnicalOrBrand(query));
        },
        decoration: InputDecoration(
          hintText: isDesktop
              ? 'Search by Technical Formulation (e.g. Chlorantraniliprole, NPK) or Brand...'
              : 'Search active technical formulations or brands...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CatalogBloc>().add(const SearchTechnicalOrBrand(''));
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
