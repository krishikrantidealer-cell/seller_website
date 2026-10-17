import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/catalog/catalog_bloc.dart';
import '../../../logic/catalog/catalog_event.dart';
import '../../../logic/catalog/catalog_state.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/category_navigation_strip.dart';
import '../widgets/crop_doctor_modal.dart';
import '../widgets/farmer_drawer.dart';
import '../widgets/farmer_quick_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/main_header.dart';
import '../widgets/product_card.dart';
import '../widgets/top_utility_bar.dart';
import '../widgets/website_footer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogBloc>().add(const LoadCatalog());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCatalog() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        340.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 640;
    final isSmallMobile = screenWidth < 380;

    // Responsive columns calculation
    final int crossAxisCount = screenWidth >= 1200
        ? 4
        : screenWidth >= 900
            ? 3
            : 2;

    final double childAspectRatio = screenWidth >= 1200
        ? 0.62
        : screenWidth >= 900
            ? 0.62
            : screenWidth >= 640
                ? 0.60
                : isSmallMobile
                    ? 0.46
                    : 0.50;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const FarmerDrawer(),
      endDrawer: const CartDrawer(),
      bottomNavigationBar: const FarmerQuickBar(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Top Utility Bar
          const SliverToBoxAdapter(child: TopUtilityBar()),

          // Main Header with Search & Cart
          SliverToBoxAdapter(
            child: MainHeader(
              onOpenCart: () => _scaffoldKey.currentState?.openEndDrawer(),
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),

          // Categories Strip
          SliverToBoxAdapter(
            child: CategoryNavigationStrip(
              onCategorySelected: _scrollToCatalog,
            ),
          ),

          // Hero Promotional Banner
          SliverToBoxAdapter(
            child: HeroBanner(
              onExploreDeals: _scrollToCatalog,
              onCallAgronomist: () => CropDoctorModal.show(context),
            ),
          ),

          // Catalog Content Area (Directly below Hero Banner for Immediate Product Visibility)
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                  child: BlocBuilder<CatalogBloc, CatalogState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filter & Results Header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.searchQuery.isNotEmpty
                                          ? 'Search Results for "${state.searchQuery}"'
                                          : _getCategoryTitle(state),
                                      style: TextStyle(
                                        fontSize: isMobile ? 17 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Showing ${state.filteredProducts.length} certified agricultural products (प्रमाणित कृषि उत्पाद)',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (state.selectedCategoryId != 'all' || state.searchQuery.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    context.read<CatalogBloc>().add(const SearchTechnicalOrBrand(''));
                                    context.read<CatalogBloc>().add(const SelectCategory('all'));
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Product Grid or Empty State
                          if (state.status == CatalogStatus.loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(color: AppColors.primaryGreen),
                              ),
                            )
                          else if (state.filteredProducts.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No products match your criteria',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Try searching by active chemical ingredient (e.g. Chlorantraniliprole, Emamectin) or resetting your category filter.',
                                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<CatalogBloc>().add(const SearchTechnicalOrBrand(''));
                                      context.read<CatalogBloc>().add(const SelectCategory('all'));
                                    },
                                    child: const Text('View All Products'),
                                  ),
                                ],
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: isMobile ? 10 : 16,
                                mainAxisSpacing: isMobile ? 10 : 16,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: state.filteredProducts.length,
                              itemBuilder: (context, index) {
                                final ProductModel product = state.filteredProducts[index];
                                return ProductCard(product: product);
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Trust Badges Strip (Farmer-Friendly Bilingual — positioned below top products)
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 20,
                      runSpacing: 14,
                      children: [
                        _buildBadge(Icons.verified_outlined, '100% Genuine (असली)', 'Direct GST Bill & CIBRC Certified'),
                        _buildBadge(Icons.local_shipping_outlined, 'Free Delivery (मुफ्त डिलीवरी)', 'Across 50,000+ Rural PIN Codes'),
                        _buildBadge(Icons.science_outlined, 'Technical Search (सटीक रसायन)', 'Compare active chemical ingredients'),
                        _buildBadge(Icons.support_agent_outlined, 'Toll Free: 1800-203-1425', 'Free Agronomist Doctor Advisory'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          const SliverToBoxAdapter(child: WebsiteFooter()),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.paleGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  String _getCategoryTitle(CatalogState state) {
    if (state.selectedCategoryId == 'all') return 'Featured Agricultural Inputs';
    final found = state.categories.where((c) => c.id == state.selectedCategoryId);
    if (found.isNotEmpty) return found.first.name;
    return 'Catalog';
  }
}
