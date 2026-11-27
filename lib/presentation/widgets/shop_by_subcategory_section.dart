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

class ShopBySubcategorySection extends StatefulWidget {
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

  @override
  State<ShopBySubcategorySection> createState() =>
      _ShopBySubcategorySectionState();
}

class _ShopBySubcategorySectionState extends State<ShopBySubcategorySection>
    with TickerProviderStateMixin {
  static const Color _brandRed = Color(0xFFC81E1E);

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFF3FBF5), Color(0xFFDFF4E5)], // Mint Green
    [Color(0xFFFFFAF0), Color(0xFFF9EBD2)], // Warm Sand
    [Color(0xFFF4FBF5), Color(0xFFE3F5E8)], // Soft Sage
    [Color(0xFFFFF5F6), Color(0xFFFCE2E6)], // Soft Rose
    [Color(0xFFF2F8FF), Color(0xFFDCEBFC)], // Sky Blue
  ];

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  bool _isViewAllHovered = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<_SubcategoryEntry> _collectEntries() {
    final available = widget.allProducts.where((p) => p.isInStock).toList();
    final List<_SubcategoryEntry> entries = [];

    for (final cat in widget.categories) {
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
          if (gSlug.isNotEmpty && p.category.trim().toLowerCase() == gSlug) {
            return true;
          }
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

  Widget _staggeredReveal({required int index, required Widget child}) {
    final start = (index * 0.1).clamp(0.0, 0.55);
    final end = (start + 0.45).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
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
        _staggeredReveal(
          index: 0,
          child: Row(
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
                              fontSize: widget.isMobile ? 22 : 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                              height: 1.15,
                            ),
                          ),
                          TextSpan(
                            text: 'Category',
                            style: GoogleFonts.mukta(
                              fontSize: widget.isMobile ? 22 : 28,
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
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isViewAllHovered = true),
                onExit: (_) => setState(() => _isViewAllHovered = false),
                child: InkWell(
                  onTap: widget.onViewAllCategories,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isMobile ? 10 : 14,
                      vertical: widget.isMobile ? 6 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: _isViewAllHovered ? _brandRed : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isViewAllHovered
                            ? _brandRed
                            : _brandRed.withValues(alpha: 0.4),
                      ),
                      boxShadow: _isViewAllHovered
                          ? [
                              BoxShadow(
                                color: _brandRed.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All Categories',
                          style: GoogleFonts.mukta(
                            fontSize: widget.isMobile ? 12 : 13,
                            fontWeight: FontWeight.w700,
                            color: _isViewAllHovered ? Colors.white : _brandRed,
                          ),
                        ),
                        const SizedBox(width: 5),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          offset: _isViewAllHovered
                              ? const Offset(0.2, 0)
                              : Offset.zero,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: _isViewAllHovered ? Colors.white : _brandRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.isMobile ? 14 : 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            if (!isWide) {
              return Column(
                children: [
                  _staggeredReveal(
                    index: 1,
                    child: _buildFeaturedCard(featured, height: 340),
                  ),
                  if (visibleOthers.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ...visibleOthers.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _staggeredReveal(
                          index: entry.key + 2,
                          child: _buildSubCard(
                            entry.value,
                            gradient:
                                _cardGradients[entry.key % _cardGradients.length],
                            height: 150,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            }

            // Desktop Bento Grid: Left large Featured Card + Right 2x2 + 1 full-width bottom card
            final topFour = visibleOthers.take(4).toList();
            final bottomWide =
                visibleOthers.length > 4 ? visibleOthers[4] : null;
            final rightHeight = bottomWide != null ? 446.0 : 300.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _staggeredReveal(
                    index: 1,
                    child: _buildFeaturedCard(featured, height: rightHeight),
                  ),
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
                                child: _staggeredReveal(
                                  index: 2,
                                  child: _buildSubCard(
                                    topFour[0],
                                    gradient: _cardGradients[0],
                                    height: 142,
                                  ),
                                ),
                              ),
                              if (topFour.length > 1) ...[
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _staggeredReveal(
                                    index: 3,
                                    child: _buildSubCard(
                                      topFour[1],
                                      gradient: _cardGradients[1],
                                      height: 142,
                                    ),
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
                                child: _staggeredReveal(
                                  index: 4,
                                  child: _buildSubCard(
                                    topFour[2],
                                    gradient: _cardGradients[2],
                                    height: 142,
                                  ),
                                ),
                              ),
                              if (topFour.length > 3) ...[
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _staggeredReveal(
                                    index: 5,
                                    child: _buildSubCard(
                                      topFour[3],
                                      gradient: _cardGradients[3],
                                      height: 142,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (bottomWide != null) ...[
                          const SizedBox(height: 14),
                          _staggeredReveal(
                            index: 6,
                            child: _buildSubCard(
                              bottomWide,
                              gradient: _cardGradients[4],
                              height: 134,
                              maxImages: 3,
                            ),
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

    return _AnimatedBentoCard(
      height: height,
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      gradientColors: const [Color(0xFFFFFCF6), Color(0xFFF6E2B3)],
      defaultBorderColor: const Color(0xFFEDE2CC),
      hoverBorderColor: _brandRed.withValues(alpha: 0.35),
      onTap: () => widget.onSelectSubcategory(entry.parent.id, g.name),
      builder: (isHovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAE2D3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, _) {
                        final t = _pulseController.value;
                        return Container(
                          width: 8,
                          height: 8,
                          alignment: Alignment.center,
                          child: Container(
                            width: 6 + (t * 2),
                            height: 6 + (t * 2),
                            decoration: BoxDecoration(
                              color: _brandRed.withValues(
                                alpha: 0.65 + (t * 0.35),
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _brandRed.withValues(alpha: t * 0.4),
                                  blurRadius: 4 * t,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
              AnimatedScale(
                scale: isHovered ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Container(
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
              fontSize: widget.isMobile ? 22 : 26,
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
            onPressed: () =>
                widget.onSelectSubcategory(entry.parent.id, g.name),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandRed,
              foregroundColor: Colors.white,
              elevation: isHovered ? 3 : 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  offset: isHovered ? const Offset(0.22, 0) : Offset.zero,
                  child: Container(
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedScale(
              scale: isHovered ? 1.05 : 1.0,
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
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
          ),
        ],
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

    return _AnimatedBentoCard(
      height: height,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      gradientColors: gradient,
      defaultBorderColor: Colors.black.withValues(alpha: 0.05),
      hoverBorderColor: _brandRed.withValues(alpha: 0.25),
      onTap: () => widget.onSelectSubcategory(entry.parent.id, g.name),
      builder: (isHovered) => Row(
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
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      offset:
                          isHovered ? const Offset(0.25, 0) : Offset.zero,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isHovered ? _brandRed : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: isHovered ? Colors.white : _brandRed,
                        ),
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
            child: AnimatedScale(
              scale: isHovered ? 1.07 : 1.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
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
          ),
        ],
      ),
    );
  }
}

class _AnimatedBentoCard extends StatefulWidget {
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final Color defaultBorderColor;
  final Color hoverBorderColor;
  final VoidCallback onTap;
  final Widget Function(bool isHovered) builder;

  const _AnimatedBentoCard({
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.gradientColors,
    required this.defaultBorderColor,
    required this.hoverBorderColor,
    required this.onTap,
    required this.builder,
  });

  @override
  State<_AnimatedBentoCard> createState() => _AnimatedBentoCardState();
}

class _AnimatedBentoCardState extends State<_AnimatedBentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: widget.height,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _isHovered
                  ? widget.hoverBorderColor
                  : widget.defaultBorderColor,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.10 : 0.04),
                blurRadius: _isHovered ? 22 : 12,
                offset: Offset(0, _isHovered ? 10 : 4),
              ),
            ],
          ),
          child: widget.builder(_isHovered),
        ),
      ),
    );
  }
}
