import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/services/collection_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../widgets/app_product_image.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/mobile_navigation_drawer.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/web_footer.dart';
import 'sub_collection_detail_view.dart';

/// Dedicated detail screen for a Collection (e.g. "Shop by Crop") displaying
/// all of its sub-collections.
class CollectionDetailView extends StatefulWidget {
  final StoreCollection collection;

  const CollectionDetailView({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailView> createState() => _CollectionDetailViewState();
}

class _CollectionDetailViewState extends State<CollectionDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    ProductController.instance.addListener(_onUpdated);
    CollectionController.instance.addListener(_onUpdated);
    if (ProductController.instance.products.isEmpty) {
      ProductController.instance.fetchProducts();
    }
    CollectionController.instance.fetchCollections(forceRefresh: true);
  }

  @override
  void dispose() {
    ProductController.instance.removeListener(_onUpdated);
    CollectionController.instance.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) setState(() {});
  }

  StoreCollection? get _liveCollection {
    if (!CollectionController.instance.hasFetched) {
      return widget.collection;
    }
    return CollectionController.instance.collections
        .where((c) => c.id == widget.collection.id)
        .firstOrNull;
  }

  bool get _isCollectionUnavailable {
    if (!CollectionController.instance.hasFetched) return false;
    final live = _liveCollection;
    return live == null || !live.isActive;
  }

  StoreCollection get _collection => _liveCollection ?? widget.collection;

  @override
  Widget build(BuildContext context) {
    final col = _collection;
    final availableProducts = ProductController.instance.products
        .where((p) => p.isAvailable)
        .toList();
    final query = _searchQuery.trim().toLowerCase();
    final filteredSubs = query.isEmpty
        ? col.subCollections
        : col.subCollections
            .where((s) =>
                s.name.toLowerCase().contains(query) ||
                s.slug.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: MobileNavigationDrawer(
        selectedCategoryId: 'all',
        onCategorySelected: (_, _) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onAllProductsSelected: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      endDrawer: const QuickCartDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight <= 1.0 || constraints.maxWidth <= 1.0) {
            return const SizedBox.shrink();
          }
          final isMobile = constraints.maxWidth < 650;

          return Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopInfoBar(),
                    MainNavHeader(
                      onMenuTap: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      onCartTap: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                      onSearch: (val) => setState(() => _searchQuery = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 20,
                          vertical: isMobile ? 12 : 24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1680),
                            child: _isCollectionUnavailable
                                ? _buildCollectionUnavailableState(isMobile)
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildBreadcrumbBar(col, isMobile),
                                      SizedBox(height: isMobile ? 12 : 18),
                                      _buildCollectionBanner(col, isMobile),
                                      SizedBox(height: isMobile ? 16 : 22),
                                      if (col.subCollections.isNotEmpty) ...[
                                        _buildSubCollectionsToolbar(
                                            col, filteredSubs.length, isMobile),
                                        SizedBox(height: isMobile ? 12 : 16),
                                        if (filteredSubs.isEmpty)
                                          _buildNoMatchingSubCollections()
                                        else
                                          _buildSubCollectionsGrid(
                                            col,
                                            filteredSubs,
                                            availableProducts,
                                            constraints,
                                            isMobile,
                                          ),
                                      ],
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const WebFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollectionUnavailableState(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 36 : 56,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.visibility_off_outlined,
              size: 32,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Collection Unavailable',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This collection is no longer active on the storefront.',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 13 : 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: Text(
              'Back to Store',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbBar(StoreCollection col, bool isMobile) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_outlined,
                    size: 15, color: AppColors.primaryDarkGreen),
                const SizedBox(width: 4),
                Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            size: 16, color: AppColors.textMuted),
        Text(
          col.name,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionBanner(StoreCollection col, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: isMobile ? 54 : 68,
              height: isMobile ? 54 : 68,
              color: Colors.white,
              child: (col.image != null && col.image!.isNotEmpty)
                  ? AppProductImage(imageUrl: col.image!, fit: BoxFit.cover)
                  : const Icon(Icons.category_rounded,
                      color: AppColors.primaryGreen, size: 30),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  col.name,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (col.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    col.description,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '${col.subCollections.length} Sub-Collections',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDarkGreen,
                side: BorderSide(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubCollectionsToolbar(
      StoreCollection col, int visibleCount, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: isMobile ? 18 : 22,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'All ${col.name} ($visibleCount)',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 16 : 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(
          width: isMobile ? double.infinity : 300,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Filter ${col.name.toLowerCase()}...',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 19, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGreen),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildSubCollectionsGrid(
    StoreCollection col,
    List<StoreSubCollection> subs,
    List<ProductItem> availableProducts,
    BoxConstraints constraints,
    bool isMobile,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subs.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isMobile ? 140 : 165,
        mainAxisExtent: isMobile ? 114 : 126,
        crossAxisSpacing: isMobile ? 10 : 12,
        mainAxisSpacing: isMobile ? 10 : 12,
      ),
      itemBuilder: (context, index) {
        final sub = subs[index];
        final subLiveCount = availableProducts
            .where((p) => col.matchesSubCollection(p, sub))
            .length;
        final subDisplayCount =
            subLiveCount > 0 ? subLiveCount : sub.productCount;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubCollectionDetailView(
                  collection: col,
                  subCollection: sub,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: isMobile ? 42 : 48,
                            height: isMobile ? 42 : 48,
                            color: const Color(0xFFF0FDF4),
                            child: (sub.image != null && sub.image!.isNotEmpty)
                                ? AppProductImage(
                                    imageUrl: sub.image!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.eco_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 22,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sub.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 12 : 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: subDisplayCount > 0
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: subDisplayCount > 0
                            ? AppColors.primaryGreen.withValues(alpha: 0.3)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      '$subDisplayCount',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: subDisplayCount > 0
                            ? AppColors.primaryDarkGreen
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoMatchingSubCollections() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          'No sub-collections match "$_searchQuery"',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
