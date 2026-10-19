import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/web_footer.dart';
import '../category/category_detail_view.dart';

class TechnicalSearchView extends StatefulWidget {
  const TechnicalSearchView({super.key});

  @override
  State<TechnicalSearchView> createState() => _TechnicalSearchViewState();
}

class _TechnicalSearchViewState extends State<TechnicalSearchView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String? _selectedLetterFilter;
  final Set<String> _expandedLetters = {'A'}; // Only 'A' open by default

  final List<TechnicalItem> _allTechnicals = TechnicalItem.sampleTechnicalItems;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered technical items
  List<TechnicalItem> get _filteredTechnicals {
    return _allTechnicals.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.targetedPestsOrCrops.any((p) => p.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory = _selectedCategoryFilter == 'All' ||
          item.category.toLowerCase().contains(_selectedCategoryFilter.toLowerCase());

      final matchesLetter = _selectedLetterFilter == null ||
          item.firstLetter == _selectedLetterFilter;

      return matchesSearch && matchesCategory && matchesLetter;
    }).toList();
  }

  // Group by alphabetical letters
  Map<String, List<TechnicalItem>> get _groupedByLetter {
    final Map<String, List<TechnicalItem>> groups = {};
    for (final item in _filteredTechnicals) {
      final letter = item.firstLetter;
      groups.putIfAbsent(letter, () => []).add(item);
    }
    // Sort keys alphabetically
    final sortedKeys = groups.keys.toList()..sort();
    final Map<String, List<TechnicalItem>> sortedMap = {};
    for (final key in sortedKeys) {
      sortedMap[key] = groups[key]!;
    }
    return sortedMap;
  }

  // Check how many products in our store share this technical formulation
  int _getProductCountForTechnical(String techName) {
    return ProductItem.sampleProducts.where((p) {
      return p.technicalName.toLowerCase().contains(techName.toLowerCase()) ||
          techName.toLowerCase().contains(p.technicalName.toLowerCase());
    }).length;
  }

  void _onSelectTechnical(TechnicalItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailView(
          initialCategoryId: 'all',
          initialTechnicalName: item.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedByLetter;
    final totalCount = _filteredTechnicals.length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: const QuickCartDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Bar
            const TopInfoBar(),

            // Main Nav Header
            MainNavHeader(
              onCartTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              onSearch: (q) {
                setState(() {
                  _searchQuery = q;
                  _searchController.text = q;
                });
              },
            ),

            // Category Ribbon with Multi-tier hover navigation
            CategoryRibbon(
              selectedCategoryId: 'all',
              onCategorySelected: (catId, subcategory) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryDetailView(
                      initialCategoryId: catId,
                      initialSubcategory: subcategory,
                    ),
                  ),
                );
              },
            ),

            // Content Area
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: isMobile ? 16 : 28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb bar
                          _buildBreadcrumb(context),
                          const SizedBox(height: 16),

                          // Hero Banner / Title Card
                          _buildHeaderBanner(isMobile),
                          const SizedBox(height: 24),

                          // Search & Filter Box
                          _buildSearchAndFilters(isMobile),
                          const SizedBox(height: 20),

                          // Quick A-Z Letter Strip
                          _buildLetterQuickJump(),
                          const SizedBox(height: 24),

                          // Results Header
                          Row(
                            children: [
                              Text(
                                'Showing $totalCount Technical Formulations',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (_expandedLetters.length >= grouped.length) {
                                      _expandedLetters.clear();
                                    } else {
                                      _expandedLetters.addAll(grouped.keys);
                                    }
                                  });
                                },
                                icon: Icon(
                                  _expandedLetters.length >= grouped.length
                                      ? Icons.unfold_less_rounded
                                      : Icons.unfold_more_rounded,
                                  size: 18,
                                  color: AppColors.primaryGreen,
                                ),
                                label: Text(
                                  _expandedLetters.length >= grouped.length
                                      ? 'Collapse All'
                                      : 'Expand All',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Accordion Sections Grouped by Letter
                          if (grouped.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: grouped.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final letter = grouped.keys.elementAt(index);
                                final items = grouped[letter]!;
                                final isExpanded = _expandedLetters.contains(letter);

                                return _buildLetterAccordionCard(
                                  letter: letter,
                                  items: items,
                                  isExpanded: isExpanded,
                                  isMobile: isMobile,
                                );
                              },
                            ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Footer
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '/',
          style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Text(
          'Search by Technical Name',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDarkGreen,
            AppColors.primaryGreen,
            Color(0xFF388E3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.science_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'ACTIVE INGREDIENT & CHEMICAL DIRECTORY',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Search Products By Technical Name',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farmers and agronomists can search agricultural crop protection chemicals and fertilizers by their active scientific/technical compositions rather than commercial brand names. Compare brands and prices for the exact chemical formulation you need.',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 12 : 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isMobile) {
    final categories = ['All', 'Insecticide', 'Fungicide', 'Herbicide', 'Fertilizer', 'Seeds', 'Bio'];

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input box
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.warmBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  if (val.isNotEmpty) {
                    // Automatically open first matching letter
                    final matchingLetters = _groupedByLetter.keys;
                    if (matchingLetters.isNotEmpty) {
                      _expandedLetters.addAll(matchingLetters);
                    }
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search technical names (e.g. Chlorantraniliprole, Imidacloprid, Mancozeb)...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = _selectedCategoryFilter == cat;
              return InkWell(
                onTap: () {
                  setState(() => _selectedCategoryFilter = cat);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : AppColors.border,
                    ),
                  ),
                  child: Text(
                    cat == 'All' ? 'All Categories' : cat,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterQuickJump() {
    final letters = [
      'All',
      ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: letters.map((letter) {
            final isSelected = letter == 'All'
                ? _selectedLetterFilter == null
                : _selectedLetterFilter == letter;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (letter == 'All') {
                      _selectedLetterFilter = null;
                    } else {
                      _selectedLetterFilter = letter;
                      _expandedLetters.add(letter);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    letter,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLetterAccordionCard({
    required String letter,
    required List<TechnicalItem> items,
    required bool isExpanded,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // BioCrop Forest Green Section Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedLetters.remove(letter);
                } else {
                  _expandedLetters.add(letter);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 14 : 18,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDarkGreen, // Forest Dark Green
                    AppColors.primaryGreen,     // Rich Agro Green
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      letter,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Technical Formulations Starting With "$letter"',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'Item' : 'Items'}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Items List when open
          if (isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, idx) {
                final item = items[idx];
                final matchingProductsCount = _getProductCountForTechnical(item.name);

                return _buildTechnicalItemRow(
                  item: item,
                  matchingProductsCount: matchingProductsCount,
                  isMobile: isMobile,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTechnicalItemRow({
    required TechnicalItem item,
    required int matchingProductsCount,
    required bool isMobile,
  }) {
    Color badgeColor;
    if (item.category.contains('Insecticide')) {
      badgeColor = const Color(0xFFDC2626); // Crimson/Red
    } else if (item.category.contains('Fungicide')) {
      badgeColor = const Color(0xFFD97706); // Amber
    } else if (item.category.contains('Herbicide')) {
      badgeColor = const Color(0xFF0284C7); // Blue
    } else if (item.category.contains('Fertilizer')) {
      badgeColor = const Color(0xFF16A34A); // Green
    } else {
      badgeColor = const Color(0xFF7C3AED); // Purple
    }

    return InkWell(
      onTap: () => _onSelectTechnical(item),
      hoverColor: AppColors.warmBackground,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 12 : 16,
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item.category,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (matchingProductsCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '✓ $matchingProductsCount Products in Store',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _onSelectTechnical(item),
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: Text(
                          matchingProductsCount > 0 ? 'View Products' : 'Explore',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: matchingProductsCount > 0
                              ? AppColors.primaryGreen
                              : AppColors.primaryDarkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                item.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (matchingProductsCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '✓ $matchingProductsCount Products in Store',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _onSelectTechnical(item),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: Text(
                      matchingProductsCount > 0 ? 'View Products' : 'Explore Brands',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: matchingProductsCount > 0
                          ? AppColors.primaryGreen
                          : AppColors.primaryDarkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'No Technical Formulations Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No technical formulations matched "$_searchQuery". Try searching by another active ingredient like "Chlorpyrifos" or "Imidacloprid".'
                : 'No formulations found for the selected filter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
                _selectedCategoryFilter = 'All';
                _selectedLetterFilter = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
