import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';

class CategoryRibbon extends StatefulWidget {
  final String selectedCategoryId;
  final String? selectedSubcategory;
  final void Function(String categoryId, String? subcategory)? onCategorySelected;

  const CategoryRibbon({
    super.key,
    this.selectedCategoryId = 'all',
    this.selectedSubcategory,
    this.onCategorySelected,
  });

  @override
  State<CategoryRibbon> createState() => _CategoryRibbonState();
}

class _CategoryRibbonState extends State<CategoryRibbon> {
  final LayerLink _allCategoriesLink = LayerLink();
  final Map<String, LayerLink> _categoryLinks = {};

  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  String? _activeOpenTab;

  @override
  void initState() {
    super.initState();
    for (final cat in CategoryItem.sampleCategories) {
      _categoryLinks[cat.id] = LayerLink();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 220), () {
      _removeOverlay();
    });
  }

  void _cancelHide() {
    _hideTimer?.cancel();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && _activeOpenTab != null) {
      setState(() => _activeOpenTab = null);
    }
  }

  void _showMegaMenu(BuildContext context, List<CategoryItem> categories) {
    _cancelHide();
    if (_activeOpenTab == 'all' && _overlayEntry != null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _activeOpenTab = 'all');

    final entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // Non-blocking position follower
          Positioned.fill(
            child: CompositedTransformFollower(
              link: _allCategoriesLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 44),
              child: Align(
                alignment: Alignment.topLeft,
                child: MouseRegion(
                  onEnter: (_) => _cancelHide(),
                  onExit: (_) => _scheduleHide(),
                  child: _MegaMenuPopup(
                    categories: categories,
                    selectedCategoryId: widget.selectedCategoryId,
                    selectedSubcategory: widget.selectedSubcategory,
                    onSelect: (catId, subcat) {
                      _removeOverlay();
                      widget.onCategorySelected?.call(catId, subcat);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  void _showCategoryDropdown(BuildContext context, CategoryItem cat, LayerLink link) {
    _cancelHide();
    if (_activeOpenTab == cat.id && _overlayEntry != null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _activeOpenTab = cat.id);

    final entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: const Offset(0, 44),
              child: Align(
                alignment: Alignment.topLeft,
                child: MouseRegion(
                  onEnter: (_) => _cancelHide(),
                  onExit: (_) => _scheduleHide(),
                  child: _SingleCategoryPopup(
                    category: cat,
                    isSelected: widget.selectedCategoryId == cat.id,
                    selectedSubcategory: widget.selectedSubcategory,
                    onSelect: (catId, subcat) {
                      _removeOverlay();
                      widget.onCategorySelected?.call(catId, subcat);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryItem.sampleCategories;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      height: 48,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                const SizedBox(width: 8),

                // Master "ALL CATEGORIES" Tab with hover mega-menu on desktop
                CompositedTransformTarget(
                  link: _allCategoriesLink,
                  child: MouseRegion(
                    onEnter: (_) {
                      if (!isMobile) _showMegaMenu(context, categories);
                    },
                    onExit: (_) {
                      if (!isMobile) _scheduleHide();
                    },
                    child: InkWell(
                      onTap: () {
                        if (isMobile) {
                          _showMobileCategoriesSheet(context, categories);
                        } else {
                          if (_overlayEntry != null && _activeOpenTab == 'all') {
                            _removeOverlay();
                          } else {
                            _showMegaMenu(context, categories);
                          }
                        }
                      },
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: (_activeOpenTab == 'all' || widget.selectedCategoryId == 'all')
                              ? AppColors.primaryDarkGreen
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (_activeOpenTab == 'all' || widget.selectedCategoryId == 'all')
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.grid_view_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ALL CATEGORIES',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedRotation(
                              turns: _activeOpenTab == 'all' ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 180),
                              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.25),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                const SizedBox(width: 6),

                // Individual Category Tabs with hover dropdown on desktop
                ...categories.map(
                  (cat) => _buildCategoryTab(context, cat, isMobile),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, CategoryItem cat, bool isMobile) {
    final link = _categoryLinks[cat.id] ?? LayerLink();
    final isCategorySelected = widget.selectedCategoryId == cat.id;
    final isOpen = _activeOpenTab == cat.id;

    return CompositedTransformTarget(
      link: link,
      child: MouseRegion(
        onEnter: (_) {
          if (!isMobile) _showCategoryDropdown(context, cat, link);
        },
        onExit: (_) {
          if (!isMobile) _scheduleHide();
        },
        child: InkWell(
          onTap: () {
            if (isMobile) {
              _showMobileCategoryOptions(context, cat);
            } else {
              if (isOpen) {
                _removeOverlay();
              } else {
                _showCategoryDropdown(context, cat, link);
              }
            }
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: (isOpen || isCategorySelected) ? AppColors.primaryDarkGreen : Colors.transparent,
              border: isCategorySelected
                  ? const Border(bottom: BorderSide(color: Colors.white, width: 3))
                  : null,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 7),
                Text(
                  cat.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: isCategorySelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile Bottom Sheet for ALL CATEGORIES
  void _showMobileCategoriesSheet(BuildContext context, List<CategoryItem> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'All Product Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen),
              title: Text(
                'Show All Products',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: widget.selectedCategoryId == 'all'
                  ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                widget.onCategorySelected?.call('all', null);
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (c, idx) {
                  final cat = categories[idx];
                  final isCatSelected = widget.selectedCategoryId == cat.id;

                  return ExpansionTile(
                    leading: Text(cat.icon, style: const TextStyle(fontSize: 20)),
                    title: Text(
                      cat.name,
                      style: GoogleFonts.poppins(
                        fontWeight: isCatSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                        color: isCatSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                      ),
                    ),
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                        title: Text(
                          'All in ${cat.name}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                            fontSize: 13,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          widget.onCategorySelected?.call(cat.id, null);
                        },
                      ),
                      ...cat.subcategories.map(
                        (sub) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                          title: Text(sub, style: GoogleFonts.poppins(fontSize: 13)),
                          trailing: (isCatSelected && widget.selectedSubcategory == sub)
                              ? const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onCategorySelected?.call(cat.id, sub);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Bottom Sheet for a single Category
  void _showMobileCategoryOptions(BuildContext context, CategoryItem cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
              title: Text('All in ${cat.name}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
              onTap: () {
                Navigator.pop(ctx);
                widget.onCategorySelected?.call(cat.id, null);
              },
            ),
            ...cat.subcategories.map(
              (sub) => ListTile(
                leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 18, color: AppColors.textMuted),
                title: Text(sub, style: GoogleFonts.poppins(fontSize: 13)),
                trailing: (widget.selectedCategoryId == cat.id && widget.selectedSubcategory == sub)
                    ? const Icon(Icons.check, size: 18, color: AppColors.primaryCrimson)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onCategorySelected?.call(cat.id, sub);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop Hover Mega Menu:
/// Left pane shows Categories; Hovering on any Category updates Right pane with its Subcategories!
class _MegaMenuPopup extends StatefulWidget {
  final List<CategoryItem> categories;
  final String selectedCategoryId;
  final String? selectedSubcategory;
  final void Function(String categoryId, String? subcategory) onSelect;

  const _MegaMenuPopup({
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedSubcategory,
    required this.onSelect,
  });

  @override
  State<_MegaMenuPopup> createState() => _MegaMenuPopupState();
}

class _MegaMenuPopupState extends State<_MegaMenuPopup> {
  late CategoryItem _hoveredCategory;

  @override
  void initState() {
    super.initState();
    // Default hovered category to the currently selected one or the first category
    final match = widget.categories.firstWhere(
      (c) => c.id == widget.selectedCategoryId,
      orElse: () => widget.categories.first,
    );
    _hoveredCategory = match;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 680,
        height: 420,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column: Category List (Hovering changes active category)
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(right: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master "All Products" link
                  InkWell(
                    onTap: () => widget.onSelect('all', null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      color: widget.selectedCategoryId == 'all' ? AppColors.softRose : Colors.transparent,
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primaryCrimson),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'All Agricultural Products',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryCrimson,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryCrimson),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // Categories with onHover detection
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.categories.length,
                      itemBuilder: (ctx, idx) {
                        final cat = widget.categories[idx];
                        final isHovered = _hoveredCategory.id == cat.id;
                        final isSelected = widget.selectedCategoryId == cat.id;

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() => _hoveredCategory = cat);
                          },
                          child: InkWell(
                            onTap: () => widget.onSelect(cat.id, null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? Colors.white
                                    : (isSelected ? AppColors.lightGreen : Colors.transparent),
                                border: isHovered
                                    ? const Border(
                                        left: BorderSide(color: AppColors.primaryGreen, width: 4),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Text(cat.icon, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: (isHovered || isSelected)
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: (isHovered || isSelected)
                                            ? AppColors.primaryDarkGreen
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: isHovered ? AppColors.primaryGreen : Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Right Column: Dynamically displays the subcategories for hovered category
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subcategory Pane Header
                    Row(
                      children: [
                        Text(_hoveredCategory.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hoveredCategory.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${_hoveredCategory.subcategories.length} Specialized Subcategories',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // View All in this Category button
                        TextButton.icon(
                          onPressed: () => widget.onSelect(_hoveredCategory.id, null),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                          label: Text(
                            'View All',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            backgroundColor: AppColors.lightGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Grid / List of Subcategories
                    Expanded(
                      child: ListView.separated(
                        itemCount: _hoveredCategory.subcategories.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (ctx, idx) {
                          final sub = _hoveredCategory.subcategories[idx];
                          final isSubSelected = widget.selectedCategoryId == _hoveredCategory.id &&
                              widget.selectedSubcategory == sub;

                          return _SubcategoryHoverItem(
                            title: sub,
                            isSelected: isSubSelected,
                            onTap: () => widget.onSelect(_hoveredCategory.id, sub),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hoverable Subcategory List Item
class _SubcategoryHoverItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryHoverItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SubcategoryHoverItem> createState() => _SubcategoryHoverItemState();
}

class _SubcategoryHoverItemState extends State<_SubcategoryHoverItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.softRose
                : (_isHovered ? AppColors.lightGreen : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryCrimson
                  : (_isHovered ? AppColors.primaryGreen.withValues(alpha: 0.3) : Colors.transparent),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 16,
                color: widget.isSelected
                    ? AppColors.primaryCrimson
                    : (_isHovered ? AppColors.primaryGreen : AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: (widget.isSelected || _isHovered)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.isSelected
                        ? AppColors.primaryCrimson
                        : (_isHovered ? AppColors.primaryDarkGreen : AppColors.textPrimary),
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson)
              else if (_isHovered)
                const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop Hover Single Category Dropdown Popup
class _SingleCategoryPopup extends StatelessWidget {
  final CategoryItem category;
  final bool isSelected;
  final String? selectedSubcategory;
  final void Function(String categoryId, String? subcategory) onSelect;

  const _SingleCategoryPopup({
    required this.category,
    required this.isSelected,
    required this.selectedSubcategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "All in Category" top button
            InkWell(
              onTap: () => onSelect(category.id, null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: (isSelected && selectedSubcategory == null)
                    ? AppColors.softRose
                    : const Color(0xFFF9FAFB),
                child: Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All ${category.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: (isSelected && selectedSubcategory == null)
                              ? AppColors.primaryCrimson
                              : AppColors.primaryDarkGreen,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Subcategories
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Column(
                children: category.subcategories.map(
                  (sub) {
                    final isSubSelected = isSelected && selectedSubcategory == sub;
                    return _SubcategoryHoverItem(
                      title: sub,
                      isSelected: isSubSelected,
                      onTap: () => onSelect(category.id, sub),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
