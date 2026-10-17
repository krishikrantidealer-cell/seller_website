import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/cart/cart_bloc.dart';
import '../../../logic/cart/cart_state.dart';
import '../../../logic/catalog/catalog_bloc.dart';
import '../../../logic/catalog/catalog_event.dart';
import 'crop_doctor_modal.dart';
import 'dosage_calculator_modal.dart';

class MainHeader extends StatefulWidget {
  final VoidCallback onOpenCart;
  final VoidCallback? onOpenDrawer;

  const MainHeader({
    super.key,
    required this.onOpenCart,
    this.onOpenDrawer,
  });

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
    final isMobile = screenWidth < 640;
    final showDeliveryTag = screenWidth >= 1180;
    final showCartText = screenWidth >= 640;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 8 : 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Mobile Drawer Hamburger Button
                  if (!isDesktop && widget.onOpenDrawer != null) ...[
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppColors.forestDark, size: 26),
                      onPressed: widget.onOpenDrawer,
                      tooltip: 'Open Menu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Logo
                  Expanded(
                    flex: isDesktop ? 0 : 1,
                    child: InkWell(
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
                            height: isMobile ? 38 : 48,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.eco_rounded,
                              size: isMobile ? 32 : 38,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'EBS BioCrop Science',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.5 : 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Essential Bio Crop Science',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isMobile ? 8.5 : 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandRed,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isDesktop) ...[
                    const SizedBox(width: 24),
                    // Expanded Search Bar
                    Expanded(
                      child: _buildSearchBar(context, isDesktop),
                    ),
                    const SizedBox(width: 20),
                  ] else ...[
                    const SizedBox(width: 8),
                  ],

                  // Actions: Free Delivery Tag + Crop Doctor + Calc + Cart
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
                    const SizedBox(width: 10),
                    // Crop Doctor Quick Button
                    TextButton.icon(
                      onPressed: () => CropDoctorModal.show(context),
                      icon: const Icon(Icons.psychology_alt_outlined, size: 16, color: AppColors.primaryGreen),
                      label: const Text('फसल डॉक्टर', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.paleGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Dosage Calc Quick Button
                    TextButton.icon(
                      onPressed: () => DosageCalculatorModal.show(context),
                      icon: const Icon(Icons.calculate_outlined, size: 16, color: AppColors.harvestAmber),
                      label: const Text('दवा कैलकुलेटर', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.forestDark)),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    const SizedBox(width: 12),
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
              const SizedBox(height: 8),
              _buildTechnicalShortcuts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalShortcuts(BuildContext context) {
    final List<String> technicals = [
      'Chlorantraniliprole',
      'Bio-NPK',
      'Emamectin Benzoate',
      'Trichoderma Viride',
      'Gibberellic Acid',
      '12V Battery Sprayer',
      'Sticky Traps',
      'Zinc EDTA',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text(
            'प्रमुख रसायन (Search Active Technical): ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          ...technicals.map((tech) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  label: Text(tech),
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  backgroundColor: AppColors.paleGreen,
                  side: BorderSide(color: AppColors.leafAccent.withValues(alpha: 0.3)),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () {
                    _searchController.text = tech;
                    context.read<CatalogBloc>().add(SearchTechnicalOrBrand(tech));
                  },
                ),
              )),
        ],
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
