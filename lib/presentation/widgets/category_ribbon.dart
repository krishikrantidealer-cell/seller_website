import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/services/category_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../../logic/category/category_bloc.dart';
import '../../logic/category/category_state.dart';
import '../be_a_partner/be_a_partner_view.dart';
import '../sell_with_us/sell_with_us_view.dart';
import 'category_icon_badge.dart';
import 'main_nav_header.dart';

class CategoryRibbon extends StatefulWidget {
  /// Global callback to cleanly dismiss any active category hover dropdown overlay (e.g. on page scroll).
  static void Function()? dismissActiveOverlay;

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
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  String? _activeOpenTab;

  @override
  void initState() {
    super.initState();
    CategoryRibbon.dismissActiveOverlay = _removeOverlay;
    for (final cat in CategoryController.instance.categories) {
      _categoryLinks[cat.id] = LayerLink();
    }
    _scrollController.addListener(_checkScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());
  }

  void _checkScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final canLeft = offset > 4;
    final canRight = max > 8 && offset < max - 4;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  @override
  void dispose() {
    if (CategoryRibbon.dismissActiveOverlay == _removeOverlay) {
      CategoryRibbon.dismissActiveOverlay = null;
    }
    _scrollController.removeListener(_checkScroll);
    _scrollController.dispose();
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 320), () {
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

    double topOffset = 152.0;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      topOffset = box.localToGlobal(Offset(0, box.size.height)).dy;
    }

    final entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            top: topOffset,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {},
                  child: MouseRegion(
                    hitTestBehavior: HitTestBehavior.opaque,
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
          ),
        ],
      ),
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  // ignore: unused_element
  void _showCategoryDropdown(BuildContext context, CategoryItem cat, LayerLink link) {
    _cancelHide();
    if (_activeOpenTab == cat.id && _overlayEntry != null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _activeOpenTab = cat.id);

    // Calculate stable horizontal offset clamped to screen edges so the entire dropdown
    // (540px for categories with groups, 320px for simple lists) stays fully visible on screen.
    double dx = 0.0;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final tabGlobal = renderBox.localToGlobal(Offset.zero);
      final screenWidth = MediaQuery.sizeOf(context).width;
      final totalWidth = cat.groups.isNotEmpty ? 540.0 : 320.0;

      final rightEdge = tabGlobal.dx + totalWidth;
      if (rightEdge > screenWidth - 16.0) {
        dx = (screenWidth - 16.0) - rightEdge;
      }
      if (tabGlobal.dx + dx < 16.0) {
        dx = 16.0 - tabGlobal.dx;
      }
    }

    final entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: Offset(dx, 46),
              child: Align(
                alignment: Alignment.topLeft,
                child: MouseRegion(
                  hitTestBehavior: HitTestBehavior.opaque,
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
    final categoryBloc = context.read<CategoryBloc?>();
    if (categoryBloc != null) {
      return BlocBuilder<CategoryBloc, CategoryState>(
        bloc: categoryBloc,
        builder: (context, state) {
          return _buildRibbonContent(context, state.effectiveCategories);
        },
      );
    }

    return ListenableBuilder(
      listenable: CategoryController.instance,
      builder: (context, _) {
        return _buildRibbonContent(context, CategoryController.instance.categories);
      },
    );
  }

  Widget _buildRibbonContent(BuildContext context, List<CategoryItem> categories) {
    for (final cat in categories) {
      _categoryLinks.putIfAbsent(cat.id, () => LayerLink());
    }

    return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            final isMobile = constraints.maxWidth < 768 || screenWidth < 768;

            if (isMobile) {
              return _buildMobileMenuBar(context, categories);
            }

            // Check scroll bounds on layout build so arrow buttons react immediately
            WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());

            final isHomeActive = widget.selectedCategoryId == 'all';
            final brands = ProductController.instance.products
                .map((p) => p.brandName.trim())
                .where((b) => b.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            return Container(
              width: double.infinity,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF3F0EA), width: 1),
                  bottom: BorderSide(color: Color(0xFFEAE6DF), width: 1),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1680),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Navigation Links
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Home Pill
                                InkWell(
                                  onTap: () {
                                    _removeOverlay();
                                    MainNavHeader.globalSearchNotifier.value = '';
                                    Navigator.of(context).popUntil((r) => r.isFirst);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isHomeActive ? const Color(0xFFFDF2F2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Home',
                                      style: GoogleFonts.mukta(
                                        color: isHomeActive
                                            ? const Color(0xFFC81E1E)
                                            : const Color(0xFF1C1917),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Shop Products (with Mega Menu on hover/tap)
                                CompositedTransformTarget(
                                  link: _allCategoriesLink,
                                  child: MouseRegion(
                                    hitTestBehavior: HitTestBehavior.opaque,
                                    onEnter: (_) {
                                      if (!isMobile) _showMegaMenu(context, categories);
                                    },
                                    onExit: (_) {
                                      if (!isMobile) _scheduleHide();
                                    },
                                    child: InkWell(
                                      onTap: () {
                                        if (_overlayEntry != null && _activeOpenTab == 'all') {
                                          _removeOverlay();
                                        } else {
                                          _showMegaMenu(context, categories);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _activeOpenTab == 'all'
                                              ? const Color(0xFFFDF2F2)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Shop Products',
                                              style: GoogleFonts.mukta(
                                                color: _activeOpenTab == 'all'
                                                    ? const Color(0xFFC81E1E)
                                                    : const Color(0xFF1C1917),
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            AnimatedRotation(
                                              turns: _activeOpenTab == 'all' ? 0.5 : 0.0,
                                              duration: const Duration(milliseconds: 180),
                                              child: Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: _activeOpenTab == 'all'
                                                    ? const Color(0xFFC81E1E)
                                                    : const Color(0xFF57534E),
                                                size: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Brands Dropdown
                                PopupMenuButton<String>(
                                  tooltip: 'Filter by Brand',
                                  offset: const Offset(0, 38),
                                  color: Colors.white,
                                  onSelected: (brand) {
                                    MainNavHeader.globalSearchNotifier.value = brand;
                                    Navigator.of(context).popUntil((r) => r.isFirst);
                                  },
                                  itemBuilder: (ctx) => brands.take(20).map((b) {
                                    return PopupMenuItem<String>(
                                      value: b,
                                      child: Text(
                                        b,
                                        style: GoogleFonts.mukta(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C1917),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Brands',
                                          style: GoogleFonts.mukta(
                                            color: const Color(0xFF1C1917),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF57534E),
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Bulk Deals
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const BeAPartnerView()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Text(
                                      'Bulk Deals',
                                      style: GoogleFonts.mukta(
                                        color: const Color(0xFF1C1917),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Offers
                                PopupMenuButton<String>(
                                  tooltip: 'Browse Offers',
                                  offset: const Offset(0, 38),
                                  color: Colors.white,
                                  onSelected: (catId) {
                                    widget.onCategorySelected?.call(catId, null);
                                  },
                                  itemBuilder: (ctx) => categories.take(8).map((c) {
                                    return PopupMenuItem<String>(
                                      value: c.id,
                                      child: Text(
                                        'Best Deals in ${c.name}',
                                        style: GoogleFonts.mukta(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C1917),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Offers',
                                          style: GoogleFonts.mukta(
                                            color: const Color(0xFF1C1917),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF57534E),
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // About Us
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SellWithUsView()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Text(
                                      'About Us',
                                      style: GoogleFonts.mukta(
                                        color: const Color(0xFF1C1917),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Expert Support Helpline
                        if (screenWidth >= 900)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.phone_in_talk_outlined,
                                size: 16,
                                color: Color(0xFF15803D),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Expert support',
                                style: GoogleFonts.mukta(
                                  color: const Color(0xFF15803D),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppConstants.helplineNumber,
                                style: GoogleFonts.mukta(
                                  color: const Color(0xFF57534E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }

  /// Dedicated Mobile Category Menu Bar (clean non-scrolling full menu bar)
  Widget _buildMobileMenuBar(BuildContext context, List<CategoryItem> categories) {
    final isAllSelected = widget.selectedCategoryId == 'all';
    final activeCat = categories.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == widget.selectedCategoryId,
      orElse: () => categories.cast<CategoryItem?>().firstWhere(
        (c) => c?.name.toLowerCase() == widget.selectedCategoryId.toLowerCase() ||
               c?.groups.any((g) => g.name.toLowerCase() == widget.selectedCategoryId.toLowerCase() || widget.selectedCategoryId.toLowerCase().contains(g.name.toLowerCase())) == true,
        orElse: () => null,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 60) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          height: 44,
          color: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openMobileMenu(context, categories),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isAllSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.primaryDarkGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isAllSelected ? 0.35 : 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (activeCat != null && !isAllSelected) ...[
                                if (CategoryIconBadge.hasAnyIcon(
                                  categoryImageUrl: activeCat.categoryImageUrl,
                                  iconUrl: activeCat.iconUrl,
                                  iconEmoji: activeCat.icon,
                                )) ...[
                                  CategoryIconBadge(
                                    categoryImageUrl: activeCat.categoryImageUrl,
                                    iconUrl: activeCat.iconUrl,
                                    iconEmoji: activeCat.icon,
                                    size: 16,
                                    emojiSize: 14,
                                    borderRadius: 4,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    widget.selectedSubcategory != null
                                        ? '${activeCat.name} › ${widget.selectedSubcategory}'
                                        : activeCat.name,
                                    style: GoogleFonts.mukta(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else ...[
                                Flexible(
                                  child: Text(
                                    'All Categories',
                                    style: GoogleFonts.mukta(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isAllSelected) ...[
                          InkWell(
                            onTap: () {
                              widget.onCategorySelected?.call('all', null);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Clear',
                                    style: GoogleFonts.mukta(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Browse',
                                style: GoogleFonts.mukta(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMobileMenu(BuildContext context, List<CategoryItem> categories) {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.hasDrawer) {
      scaffoldState.openDrawer();
    } else {
      _showMobileCategoriesSheet(context, categories);
    }
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
                    style: GoogleFonts.mukta(
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
                style: GoogleFonts.mukta(fontWeight: FontWeight.w600, fontSize: 14),
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
                    leading: CategoryIconBadge.hasAnyIcon(
                      categoryImageUrl: cat.categoryImageUrl,
                      iconUrl: cat.iconUrl,
                      iconEmoji: cat.icon,
                    )
                        ? CategoryIconBadge(
                            categoryImageUrl: cat.categoryImageUrl,
                            iconUrl: cat.iconUrl,
                            iconEmoji: cat.icon,
                            size: 22,
                            emojiSize: 20,
                            borderRadius: 4,
                          )
                        : null,
                    title: Text(
                      cat.name,
                      style: GoogleFonts.mukta(
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
                          style: GoogleFonts.mukta(
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
                      if (cat.groups.isNotEmpty)
                        ...cat.groups.map(
                          (group) => ExpansionTile(
                            dense: true,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 24),
                            leading: CategoryIconBadge.hasAnyIcon(
                              categoryImageUrl: group.categoryImageUrl,
                              iconUrl: group.iconUrl,
                              iconEmoji: group.icon,
                            )
                                ? CategoryIconBadge(
                                    categoryImageUrl: group.categoryImageUrl,
                                    iconUrl: group.iconUrl,
                                    iconEmoji: group.icon,
                                    size: 18,
                                    emojiSize: 16,
                                    borderRadius: 4,
                                  )
                                : null,
                            title: Text(
                              group.name,
                              style: GoogleFonts.mukta(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.only(left: 48, right: 16),
                                leading: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryGreen),
                                title: Text(
                                  'All ${group.name}',
                                  style: GoogleFonts.mukta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  widget.onCategorySelected?.call(cat.id, group.name);
                                },
                              ),
                              ...group.subcategories.map(
                                (sub) => ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.only(left: 48, right: 16),
                                  title: Text(sub, style: GoogleFonts.mukta(fontSize: 12.5)),
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
                          ),
                        )
                      else
                        ...cat.subcategories.map(
                          (sub) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                            title: Text(sub, style: GoogleFonts.mukta(fontSize: 13)),
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
  // ignore: unused_element
  void _showMobileCategoryOptions(BuildContext context, CategoryItem cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Container(
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
                    if (CategoryIconBadge.hasAnyIcon(
                      categoryImageUrl: cat.categoryImageUrl,
                      iconUrl: cat.iconUrl,
                      iconEmoji: cat.icon,
                    )) ...[
                      CategoryIconBadge(
                        categoryImageUrl: cat.categoryImageUrl,
                        iconUrl: cat.iconUrl,
                        iconEmoji: cat.icon,
                        size: 22,
                        emojiSize: 20,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        cat.name,
                        style: GoogleFonts.mukta(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
                title: Text('All in ${cat.name}', style: GoogleFonts.mukta(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onCategorySelected?.call(cat.id, null);
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    if (cat.groups.isNotEmpty)
                      ...cat.groups.map(
                        (group) => ExpansionTile(
                          leading: CategoryIconBadge.hasAnyIcon(
                            categoryImageUrl: group.categoryImageUrl,
                            iconUrl: group.iconUrl,
                            iconEmoji: group.icon,
                          )
                              ? CategoryIconBadge(
                                  categoryImageUrl: group.categoryImageUrl,
                                  iconUrl: group.iconUrl,
                                  iconEmoji: group.icon,
                                  size: 20,
                                  emojiSize: 18,
                                  borderRadius: 4,
                                )
                              : null,
                          title: Text(
                            group.name,
                            style: GoogleFonts.mukta(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${group.subcategories.length} subcategories',
                            style: GoogleFonts.mukta(fontSize: 11, color: AppColors.textMuted),
                          ),
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                              leading: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryGreen),
                              title: Text(
                                'View All ${group.name}',
                                style: GoogleFonts.mukta(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                widget.onCategorySelected?.call(cat.id, group.name);
                              },
                            ),
                            ...group.subcategories.map(
                              (sub) => ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                                leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: AppColors.textMuted),
                                title: Text(sub, style: GoogleFonts.mukta(fontSize: 12.5)),
                                trailing: (widget.selectedCategoryId == cat.id && widget.selectedSubcategory == sub)
                                    ? const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson)
                                    : null,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  widget.onCategorySelected?.call(cat.id, sub);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...cat.subcategories.map(
                        (sub) => ListTile(
                          leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 18, color: AppColors.textMuted),
                          title: Text(sub, style: GoogleFonts.mukta(fontSize: 13)),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop Hover Mega Menu:
/// Left pane: Major Categories (Seeds, Insecticides, etc.)
/// Middle pane: Categories under hovered Major Category
/// Right pane: Subcategories of hovered Category opening in the side
class _MegaMenuPopup extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxH = (MediaQuery.sizeOf(context).height - 170).clamp(240.0, 480.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFF3F0EA), width: 1),
            bottom: BorderSide(color: Color(0xFFEAE6DF), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final colCount = constraints.maxWidth >= 1200
                      ? 5
                      : (constraints.maxWidth >= 900 ? 4 : 3);
                  final spacing = 28.0;
                  final colWidth =
                      (constraints.maxWidth - (spacing * (colCount - 1))) / colCount;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 28,
                    children: categories.map((cat) {
                      final items = <String>[];
                      if (cat.groups.isNotEmpty) {
                        for (final g in cat.groups) {
                          items.add(g.name);
                        }
                      } else {
                        items.addAll(cat.subcategories);
                      }
                      final visibleItems = items.take(5).toList();

                      return SizedBox(
                        width: colWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => onSelect(cat.id, null),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (CategoryIconBadge.hasAnyIcon(
                                      categoryImageUrl: cat.categoryImageUrl,
                                      iconUrl: cat.iconUrl,
                                      iconEmoji: cat.icon,
                                    )) ...[
                                      CategoryIconBadge(
                                        categoryImageUrl: cat.categoryImageUrl,
                                        iconUrl: cat.iconUrl,
                                        iconEmoji: cat.icon,
                                        size: 18,
                                        emojiSize: 14,
                                        borderRadius: 4,
                                      ),
                                      const SizedBox(width: 7),
                                    ],
                                    Flexible(
                                      child: Text(
                                        cat.name.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.mukta(
                                          color: const Color(0xFF78716C),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...visibleItems.map((item) {
                              final isSelected = selectedCategoryId == cat.id &&
                                  selectedSubcategory == item;
                              return _MegaMenuLink(
                                label: item,
                                isSelected: isSelected,
                                onTap: () => onSelect(cat.id, item),
                              );
                            }),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => onSelect(cat.id, null),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View all',
                                      style: GoogleFonts.mukta(
                                        color: const Color(0xFFC81E1E),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: Color(0xFFC81E1E),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MegaMenuLink extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MegaMenuLink({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MegaMenuLink> createState() => _MegaMenuLinkState();
}

class _MegaMenuLinkState extends State<_MegaMenuLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mukta(
              fontSize: 14,
              fontWeight: (widget.isSelected || _hovered)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: (widget.isSelected || _hovered)
                  ? const Color(0xFFC81E1E)
                  : const Color(0xFF1C1917),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _UnusedMegaMenuPlaceholder extends StatefulWidget {
  final List<CategoryItem> categories;
  final String selectedCategoryId;
  final String? selectedSubcategory;
  final void Function(String categoryId, String? subcategory) onSelect;

  const _UnusedMegaMenuPlaceholder({
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedSubcategory,
    required this.onSelect,
  });

  @override
  State<_UnusedMegaMenuPlaceholder> createState() => _MegaMenuPopupState();
}

class _MegaMenuPopupState extends State<_UnusedMegaMenuPlaceholder> {
  late CategoryItem _hoveredCategory;
  CategoryGroup? _hoveredGroup;
  final ScrollController _majorScrollController = ScrollController();
  final ScrollController _categoriesScrollController = ScrollController();
  final ScrollController _subcategoriesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.categories.isEmpty) {
      _hoveredCategory = const CategoryItem(id: 'all', name: 'All Products', icon: '');
      _hoveredGroup = null;
      return;
    }
    final match = widget.categories.firstWhere(
      (c) => c.id == widget.selectedCategoryId,
      orElse: () => widget.categories.first,
    );
    _hoveredCategory = match;
    _hoveredGroup = match.groups.isNotEmpty ? match.groups.first : null;
  }

  @override
  void dispose() {
    _majorScrollController.dispose();
    _categoriesScrollController.dispose();
    _subcategoriesScrollController.dispose();
    super.dispose();
  }

  void _onHoverCategory(CategoryItem cat) {
    if (_hoveredCategory.id == cat.id) return;
    setState(() {
      _hoveredCategory = cat;
      _hoveredGroup = cat.groups.isNotEmpty ? cat.groups.first : null;
    });
    if (_categoriesScrollController.hasClients) {
      _categoriesScrollController.jumpTo(0);
    }
    if (_subcategoriesScrollController.hasClients) {
      _subcategoriesScrollController.jumpTo(0);
    }
  }

  void _onHoverGroup(CategoryGroup group) {
    if (_hoveredGroup?.name == group.name) return;
    setState(() {
      _hoveredGroup = group;
    });
    if (_subcategoriesScrollController.hasClients) {
      _subcategoriesScrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _hoveredCategory.groups;
    final activeGroup = _hoveredGroup ?? (groups.isNotEmpty ? groups.first : null);

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 720,
          height: 430,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column: Major Categories
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
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
                      color: widget.selectedCategoryId == 'all' ? AppColors.softRose : Colors.white,
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primaryCrimson),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'All Products',
                              style: GoogleFonts.mukta(
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

                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                    child: Text(
                      'MAJOR CATEGORIES',
                      style: GoogleFonts.mukta(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // Major Categories List
                  Expanded(
                    child: RawScrollbar(
                      controller: _majorScrollController,
                      thumbVisibility: true,
                      thickness: 4.5,
                      radius: const Radius.circular(8),
                      thumbColor: AppColors.primaryGreen.withValues(alpha: 0.35),
                      child: ListView.builder(
                        controller: _majorScrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: widget.categories.length,
                        itemBuilder: (ctx, idx) {
                          final cat = widget.categories[idx];
                          final isHovered = _hoveredCategory.id == cat.id;
                          final isSelected = widget.selectedCategoryId == cat.id;

                          return MouseRegion(
                            onEnter: (_) => _onHoverCategory(cat),
                            child: InkWell(
                              onTap: () => widget.onSelect(cat.id, null),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? Colors.white
                                      : (isSelected ? AppColors.lightGreen : Colors.transparent),
                                  border: isHovered
                                      ? const Border(
                                          left: BorderSide(color: AppColors.primaryGreen, width: 3.5),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    if (CategoryIconBadge.hasAnyIcon(
                                      categoryImageUrl: cat.categoryImageUrl,
                                      iconUrl: cat.iconUrl,
                                      iconEmoji: cat.icon,
                                    )) ...[
                                      CategoryIconBadge(
                                        categoryImageUrl: cat.categoryImageUrl,
                                        iconUrl: cat.iconUrl,
                                        iconEmoji: cat.icon,
                                        size: 18,
                                        emojiSize: 15,
                                        borderRadius: 4,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        cat.name,
                                        style: GoogleFonts.mukta(
                                          fontSize: 12.5,
                                          fontWeight: (isHovered || isSelected)
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: (isHovered || isSelected)
                                              ? AppColors.primaryDarkGreen
                                              : AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                  ),
                ],
              ),
            ),

            // Middle Column: Categories under hovered Major Category
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(right: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // View all in hovered major category
                  InkWell(
                    onTap: () => widget.onSelect(_hoveredCategory.id, null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'All ${_hoveredCategory.name}',
                              style: GoogleFonts.mukta(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDarkGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryGreen),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                    child: Text(
                      'CATEGORIES',
                      style: GoogleFonts.mukta(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // Categories list
                  Expanded(
                    child: RawScrollbar(
                      controller: _categoriesScrollController,
                      thumbVisibility: true,
                      thickness: 4.5,
                      radius: const Radius.circular(8),
                      thumbColor: AppColors.primaryGreen.withValues(alpha: 0.35),
                      child: ListView.builder(
                        controller: _categoriesScrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: groups.length,
                        itemBuilder: (ctx, idx) {
                          final group = groups[idx];
                          final isHovered = activeGroup?.name == group.name;

                          return MouseRegion(
                            onEnter: (_) => _onHoverGroup(group),
                            child: InkWell(
                              onTap: () => widget.onSelect(_hoveredCategory.id, group.name),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isHovered ? Colors.white : Colors.transparent,
                                  border: isHovered
                                      ? const Border(
                                          left: BorderSide(color: AppColors.primaryGreen, width: 3.5),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    if (CategoryIconBadge.hasAnyIcon(
                                      categoryImageUrl: group.categoryImageUrl,
                                      iconUrl: group.iconUrl,
                                      iconEmoji: group.icon,
                                    )) ...[
                                      CategoryIconBadge(
                                        categoryImageUrl: group.categoryImageUrl,
                                        iconUrl: group.iconUrl,
                                        iconEmoji: group.icon,
                                        size: 16,
                                        emojiSize: 14,
                                        borderRadius: 4,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        group.name,
                                        style: GoogleFonts.mukta(
                                          fontSize: 12,
                                          fontWeight: isHovered ? FontWeight.w700 : FontWeight.w500,
                                          color: isHovered ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 15,
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
                  ),
                ],
              ),
            ),

            // Right Column: Subcategories opening in the side
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeGroup != null) ...[
                      Row(
                        children: [
                          if (activeGroup.icon != null) ...[
                            Text(activeGroup.icon!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeGroup.name,
                                  style: GoogleFonts.mukta(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${activeGroup.subcategories.length} Subcategories',
                                  style: GoogleFonts.mukta(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => widget.onSelect(_hoveredCategory.id, activeGroup.name),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              backgroundColor: const Color(0xFFF0FDF4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              'View All',
                              style: GoogleFonts.mukta(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Subcategories List
                      Expanded(
                        child: RawScrollbar(
                          controller: _subcategoriesScrollController,
                          thumbVisibility: true,
                          thickness: 4.5,
                          radius: const Radius.circular(8),
                          thumbColor: AppColors.primaryGreen.withValues(alpha: 0.35),
                          child: ListView.separated(
                            controller: _subcategoriesScrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: activeGroup.subcategories.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 4),
                            itemBuilder: (ctx, idx) {
                              final sub = activeGroup.subcategories[idx];
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
                      ),
                    ] else
                      Center(
                        child: Text(
                          'No subcategories available',
                          style: GoogleFonts.mukta(color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.softRose
                : (_isHovered ? const Color(0xFFF0FDF4) : Colors.transparent),
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
                size: 15,
                color: widget.isSelected
                    ? AppColors.primaryCrimson
                    : (_isHovered ? AppColors.primaryGreen : AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.mukta(
                    fontSize: 12.5,
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
                const Icon(Icons.check, size: 15, color: AppColors.primaryCrimson)
              else if (_isHovered)
                const Icon(Icons.chevron_right, size: 15, color: AppColors.primaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop Hover Single Major Category Dropdown Popup:
/// Left pane (220px): Categories under this Major Category
/// Right pane (320px): Subcategories of the hovered Category or placeholder
class _SingleCategoryPopup extends StatefulWidget {
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
  State<_SingleCategoryPopup> createState() => _SingleCategoryPopupState();
}

class _SingleCategoryPopupState extends State<_SingleCategoryPopup> {
  CategoryGroup? _hoveredGroup;
  final ScrollController _categoriesScrollController = ScrollController();
  final ScrollController _subcategoriesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _hoveredGroup = null;
  }

  @override
  void dispose() {
    _categoriesScrollController.dispose();
    _subcategoriesScrollController.dispose();
    super.dispose();
  }

  void _onHoverGroup(CategoryGroup group) {
    if (_hoveredGroup?.name == group.name) return;
    setState(() {
      _hoveredGroup = group;
    });
    if (_subcategoriesScrollController.hasClients) {
      _subcategoriesScrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.category.groups;
    final activeGroup = _hoveredGroup;

    // Stable, predictable dimensions:
    // If groups exist: always 540.0 wide (220px categories + 320px subcategories)
    // If no groups: 320.0 wide
    final double popupWidth = groups.isNotEmpty ? 540.0 : 320.0;
    final double popupHeight = groups.isNotEmpty
        ? 430.0
        : ((widget.category.subcategories.length * 38.0 + 55.0).clamp(160.0, 430.0));

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: popupWidth,
          height: popupHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: groups.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => widget.onSelect(widget.category.id, null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: (widget.isSelected && widget.selectedSubcategory == null)
                            ? AppColors.softRose
                            : const Color(0xFFF9FAFB),
                        child: Row(
                          children: [
                            if (widget.category.icon.isNotEmpty) ...[
                              Text(widget.category.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                'All ${widget.category.name}',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: (widget.isSelected && widget.selectedSubcategory == null)
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
                    Expanded(
                      child: RawScrollbar(
                        controller: _subcategoriesScrollController,
                        thumbVisibility: true,
                        thickness: 4.5,
                        radius: const Radius.circular(8),
                        thumbColor: AppColors.primaryGreen.withValues(alpha: 0.35),
                        child: ListView(
                          controller: _subcategoriesScrollController,
                          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          children: widget.category.subcategories.map((sub) {
                            final isSubSelected = widget.isSelected && widget.selectedSubcategory == sub;
                            return _SubcategoryHoverItem(
                              title: sub,
                              isSelected: isSubSelected,
                              onTap: () => widget.onSelect(widget.category.id, sub),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Column: Categories under this Major Category (fixed width: 220px)
                    Container(
                      width: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
                      ),
                      child: _buildCategoriesColumn(groups, activeGroup),
                    ),

                    // Right Column: Subcategories opening in the side panel (320px)
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: _buildSubcategoriesColumn(activeGroup),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCategoriesColumn(
    List<CategoryGroup> groups,
    CategoryGroup? activeGroup,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "All in [Category]" top header item
        MouseRegion(
          onEnter: (_) {
            setState(() => _hoveredGroup = null);
          },
          child: InkWell(
            onTap: () => widget.onSelect(widget.category.id, null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: (widget.isSelected && widget.selectedSubcategory == null)
                  ? AppColors.softRose
                  : Colors.white,
              child: Row(
                children: [
                  if (widget.category.icon.isNotEmpty) ...[
                    Text(widget.category.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      'All ${widget.category.name}',
                      style: GoogleFonts.mukta(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: (widget.isSelected && widget.selectedSubcategory == null)
                            ? AppColors.primaryCrimson
                            : AppColors.primaryDarkGreen,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),

        // Section label
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Text(
            'CATEGORIES',
            style: GoogleFonts.mukta(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),

        // Categories List
        Expanded(
          child: RawScrollbar(
            controller: _categoriesScrollController,
            thumbVisibility: true,
            thickness: 4.5,
            radius: const Radius.circular(8),
            thumbColor: AppColors.primaryGreen.withValues(alpha: 0.35),
            child: ListView.builder(
              controller: _categoriesScrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              padding: EdgeInsets.zero,
              itemCount: groups.length,
              itemBuilder: (ctx, idx) {
                final group = groups[idx];
                final isHovered = activeGroup?.name == group.name;

                return MouseRegion(
                  onEnter: (_) => _onHoverGroup(group),
                  child: InkWell(
                    onTap: () => widget.onSelect(widget.category.id, group.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isHovered ? Colors.white : Colors.transparent,
                        border: isHovered
                            ? const Border(
                                left: BorderSide(color: AppColors.primaryGreen, width: 3.5),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (CategoryIconBadge.hasAnyIcon(
                            categoryImageUrl: group.categoryImageUrl,
                            iconUrl: group.iconUrl,
                            iconEmoji: group.icon,
                          )) ...[
                            CategoryIconBadge(
                              categoryImageUrl: group.categoryImageUrl,
                              iconUrl: group.iconUrl,
                              iconEmoji: group.icon,
                              size: 16,
                              emojiSize: 14,
                              borderRadius: 4,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              group.name,
                              style: GoogleFonts.mukta(
                                fontSize: 12.5,
                                fontWeight: isHovered ? FontWeight.w700 : FontWeight.w500,
                                color: isHovered
                                    ? AppColors.primaryDarkGreen
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (group.subcategories.isNotEmpty)
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
        ),
      ],
    );
  }

  Widget _buildSubcategoriesColumn(CategoryGroup? activeGroup) {
    if (activeGroup == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.grid_view_rounded, size: 28, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore ${widget.category.name}',
                style: GoogleFonts.mukta(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Hover over any category to view subcategories',
                style: GoogleFonts.mukta(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => widget.onSelect(widget.category.id, null),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: Text(
                  'View All Products',
                  style: GoogleFonts.mukta(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (activeGroup.subcategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.category_outlined, size: 36, color: AppColors.textMuted),
              const SizedBox(height: 8),
              Text(
                'Explore all ${activeGroup.name} products',
                style: GoogleFonts.mukta(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => widget.onSelect(widget.category.id, activeGroup.name),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('View Category Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Side Subcategory Header
        Row(
          children: [
            if (activeGroup.icon != null) ...[
              Text(activeGroup.icon!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeGroup.name,
                    style: GoogleFonts.mukta(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${activeGroup.subcategories.length} Subcategories',
                    style: GoogleFonts.mukta(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => widget.onSelect(widget.category.id, activeGroup.name),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                backgroundColor: const Color(0xFFF0FDF4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                'View All',
                style: GoogleFonts.mukta(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 8),

        // Subcategories list
        Expanded(
          child: RawScrollbar(
            controller: _subcategoriesScrollController,
            thumbVisibility: true,
            thickness: 4.5,
            radius: const Radius.circular(8),
            thumbColor: AppColors.primaryGreen.withValues(alpha: 0.35),
            child: ListView.separated(
              controller: _subcategoriesScrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              padding: EdgeInsets.zero,
              itemCount: activeGroup.subcategories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (ctx, idx) {
                final sub = activeGroup.subcategories[idx];
                final isSubSelected = widget.isSelected && widget.selectedSubcategory == sub;

                return _SubcategoryHoverItem(
                  title: sub,
                  isSelected: isSubSelected,
                  onTap: () => widget.onSelect(widget.category.id, sub),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
