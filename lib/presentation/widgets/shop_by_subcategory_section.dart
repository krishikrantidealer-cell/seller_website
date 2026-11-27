import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/catalog_models.dart';
import 'app_product_image.dart';
import 'category_icon_badge.dart';

class _SubcategoryEntry {
  final CategoryItem parent;
  final CategoryGroup group;
  final List<ProductItem> products;

  const _SubcategoryEntry({
    required this.parent,
    required this.group,
    required this.products,
  });
}

class ShopBySubcategorySection extends StatelessWidget {
  final List<CategoryItem> categories;
  final List<ProductItem> allProducts;
  final bool isMobile;
  final void Function(String categoryId, String? subcategory) onSelectSubcategory;
  final VoidCallback onViewAllCategories;

  const ShopBySubcategorySection({
    super.key,
    required this.categories,
    required this.allProducts,
    required this.isMobile,
    required this.onSelectSubcategory,
    required this.onViewAllCategories,
  });

  static const Color _brandRed = Color(0xFFC81E1E);

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFF3FBF5), Color(0xFFDFF4E5)], // Mint Green
    [Color(0xFFFFFAF0), Color(0xFFF9EBD2)], // Warm Sand
    [Color(0xFFF4FBF5), Color(0xFFE3F5E8)], // Soft Sage
    [Color(0xFFFFF5F6), Color(0xFFFCE2E6)], // Soft Rose
    [Color(0xFFF2F8FF), Color(0xFFDCEBFC)], // Sky Blue
  ];

  List<_SubcategoryEntry> _collectEntries() {
    final available = allProducts.where((p) => p.isInStock).toList();
    final List<_SubcategoryEntry> entries = [];

    for (final cat in categories) {
      for (final group in cat.groups) {
        final gId = group.id?.trim().toLowerCase() ?? '';
        final gName = group.name.trim().toLowerCase();
        final gSlug = group.slug?.trim().toLowerCase() ?? '';
        final matched = available.where((p) {
          if (gId.isNotEmpty) {
            if (p.categoryId?.trim().toLowerCase() == gId) return true;
            if (p.subCategoryIds.any((id) => id.trim().toLowerCase() == gId)) {
              return true;
            }
          }
          if (p.category.trim().toLowerCase() == gName) return true;
          if (gSlug.isNotEmpty && p.category.trim().toLowerCase() == gSlug) return true;
          return false;
        }).toList();

        entries.add(_SubcategoryEntry(
          parent: cat,
          group: group,
          products: matched,
        ));
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = _collectEntries();
    if (allEntries.isEmpty) return const SizedBox.shrink();

    // Pick featured subcategory (first with isFeatured == true, else first with products, else first)
    final featuredIndex = allEntries.indexWhere((e) => e.group.isFeatured);
    final chosenFeaturedIdx = featuredIndex >= 0
        ? featuredIndex
        : (allEntries.indexWhere((e) => e.products.isNotEmpty) >= 0
            ? allEntries.indexWhere((e) => e.products.isNotEmpty)
            : 0);

    final featured = allEntries[chosenFeaturedIdx];
    final others = <_SubcategoryEntry>[
      for (var i = 0; i < allEntries.length; i++)
        if (i != chosenFeaturedIdx) allEntries[i],
    ];
    final visibleOthers = others.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "— SHOP BY CATEGORIES" + "Shop Products by Category" + "View All Categories ->"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 16, height: 2, color: _brandRed),
                      const SizedBox(width: 8),
                      Text(
                        'SHOP BY CATEGORIES',
                        style: GoogleFonts.mukta(
                          color: _brandRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Shop Products by ',
                          style: GoogleFonts.mukta(
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'Category',
                          style: GoogleFonts.mukta(
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.w800,
                            color: _brandRed,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onViewAllCategories,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 14,
                  vertical: isMobile ? 6 : 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _brandRed.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Categories',
                      style: GoogleFonts.mukta(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w700,
                        color: _brandRed,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: _brandRed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 14 : 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            if (!isWide) {
              return Column(
                children: [
                  _buildFeaturedCard(featured, height: 340),
                  if (visibleOthers.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ...visibleOthers.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSubCard(
                          entry.value,
                          gradient: _cardGradients[entry.key % _cardGradients.length],
                          height: 150,
                        ),
                      );
                    }),
                  ],
                ],
              );
            }

            // Desktop Bento Grid: Left large Featured Card + Right 2x2 + 1 full-width bottom card
            final topFour = visibleOthers.take(4).toList();
            final bottomWide = visibleOthers.length > 4 ? visibleOthers[4] : null;
            final rightHeight = bottomWide != null ? 446.0 : 300.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildFeaturedCard(featured, height: rightHeight),
                ),
                if (visibleOthers.isNotEmpty) ...[
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        if (topFour.isNotEmpty)
                          Row(
                            children: [
                              Expanded(
                                child: _buildSubCard(
                                  topFour[0],
                                  gradient: _cardGradients[0],
                                  height: 142,
                                ),
                              ),
                              if (topFour.length > 1) ...[
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildSubCard(
                                    topFour[1],
                                    gradient: _cardGradients[1],
                                    height: 142,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        if (topFour.length > 2) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSubCard(
                                  topFour[2],
                                  gradient: _cardGradients[2],
                                  height: 142,
                                ),
                              ),
                              if (topFour.length > 3) ...[
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildSubCard(
                                    topFour[3],
                                    gradient: _cardGradients[3],
                                    height: 142,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (bottomWide != null) ...[
                          const SizedBox(height: 14),
                          _buildSubCard(
                            bottomWide,
                            gradient: _cardGradients[4],
                            height: 134,
                            maxImages: 3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(_SubcategoryEntry entry, {required double height}) {
    final g = entry.group;
    final imgs = entry.products
        .map((p) => p.imageUrl.trim())
        .where((u) => u.isNotEmpty)
        .take(3)
        .toList();

    return InkWell(
      onTap: () => onSelectSubcategory(entry.parent.id, g.name),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFCF6), Color(0xFFF6E2B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFEDE2CC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAE2D3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _brandRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'FEATURED CATEGORY',
                        style: GoogleFonts.mukta(
                          color: const Color(0xFF44403C),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: CategoryIconBadge.hasAnyIcon(
                    categoryImageUrl: g.categoryImageUrl,
                    iconUrl: g.iconUrl,
                    iconEmoji: g.icon,
                  )
                      ? CategoryIconBadge(
                          categoryImageUrl: g.categoryImageUrl,
                          iconUrl: g.iconUrl,
                          iconEmoji: g.icon,
                          size: 24,
                          emojiSize: 18,
                          borderRadius: 6,
                        )
                      : const Icon(
                          Icons.category_rounded,
                          color: _brandRed,
                          size: 20,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              g.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mukta(
                color: const Color(0xFF111827),
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.products.isNotEmpty
                    ? '${entry.parent.name} • ${entry.products.length} Products'
                    : entry.parent.name,
                style: GoogleFonts.mukta(
                  color: const Color(0xFF57534E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => onSelectSubcategory(entry.parent.id, g.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore ${g.name}',
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: _brandRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: imgs.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: imgs.map((url) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AppProductImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                              fallbackIcon: Icons.agriculture_rounded,
                              fallbackIconSize: 36,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: CategoryIconBadge.hasAnyIcon(
                        categoryImageUrl: g.categoryImageUrl,
                        iconUrl: g.iconUrl,
                        iconEmoji: g.icon,
                      )
                          ? CategoryIconBadge(
                              categoryImageUrl: g.categoryImageUrl,
                              iconUrl: g.iconUrl,
                              iconEmoji: g.icon,
                              size: 96,
                              emojiSize: 56,
                              borderRadius: 16,
                            )
                          : const Icon(
                              Icons.agriculture_rounded,
                              size: 72,
                              color: Color(0xFFB45309),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCard(
    _SubcategoryEntry entry, {
    required List<Color> gradient,
    required double height,
    int maxImages = 2,
  }) {
    final g = entry.group;
    final imgs = entry.products
        .map((p) => p.imageUrl.trim())
        .where((u) => u.isNotEmpty)
        .take(maxImages)
        .toList();

    return InkWell(
      onTap: () => onSelectSubcategory(entry.parent.id, g.name),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.mukta(
                          color: const Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.products.isNotEmpty
                              ? '${entry.parent.name} • ${entry.products.length}'
                              : entry.parent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mukta(
                            color: const Color(0xFF57534E),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Shop Now',
                        style: GoogleFonts.mukta(
                          color: _brandRed,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: _brandRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: imgs.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: imgs.map((url) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: AppProductImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                              fallbackIcon: Icons.agriculture_rounded,
                              fallbackIconSize: 28,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: CategoryIconBadge.hasAnyIcon(
                        categoryImageUrl: g.categoryImageUrl,
                        iconUrl: g.iconUrl,
                        iconEmoji: g.icon,
                      )
                          ? CategoryIconBadge(
                              categoryImageUrl: g.categoryImageUrl,
                              iconUrl: g.iconUrl,
                              iconEmoji: g.icon,
                              size: 56,
                              emojiSize: 36,
                              borderRadius: 12,
                            )
                          : const Icon(
                              Icons.agriculture_rounded,
                              size: 48,
                              color: Color(0xFF78716C),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
