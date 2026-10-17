import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';

class CategoryRibbon extends StatelessWidget {
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
                // "ALL CATEGORIES" Master Dropdown Button
                _buildAllCategoriesDropdown(context, categories, isMobile),

                const SizedBox(width: 6),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.25),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                const SizedBox(width: 6),

                // Individual Category Dropdowns
                ...categories.map(
                  (cat) => _buildCategoryDropdown(context, cat),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Master "ALL CATEGORIES" dropdown with mega-menu list or bottom sheet on mobile
  Widget _buildAllCategoriesDropdown(
    BuildContext context,
    List<CategoryItem> categories,
    bool isMobile,
  ) {
    final isSelected = selectedCategoryId == 'all';

    if (isMobile) {
      return InkWell(
        onTap: () => _showMobileCategoriesSheet(context, categories),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDarkGreen : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.grid_view_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'ALL CATEGORIES',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 8,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Explore all agricultural categories',
        offset: const Offset(0, 44),
        onSelected: (val) {
          if (val == '__all__') {
            onCategorySelected?.call('all', null);
          } else {
            final parts = val.split('::');
            if (parts.length == 2) {
              onCategorySelected?.call(parts[0], parts[1]);
            } else {
              onCategorySelected?.call(val, null);
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: '__all__',
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: 10),
                Text(
                  'All Categories & Products',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (selectedCategoryId == 'all')
                  const Icon(Icons.check, size: 16, color: AppColors.primaryGreen),
              ],
            ),
          ),
          const PopupMenuDivider(),
          ...categories.map(
            (cat) => PopupMenuItem<String>(
              value: cat.id,
              child: Row(
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (cat.subcategories.isNotEmpty)
                          Text(
                            cat.subcategories.take(2).join(', '),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDarkGreen : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
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
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Individual Category Dropdown Button with sleek popup menu
  Widget _buildCategoryDropdown(BuildContext context, CategoryItem cat) {
    final isCategorySelected = selectedCategoryId == cat.id;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 8,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: '${cat.name} subcategories',
        offset: const Offset(0, 44),
        onSelected: (subcat) {
          if (subcat == '__all__') {
            onCategorySelected?.call(cat.id, null);
          } else {
            onCategorySelected?.call(cat.id, subcat);
          }
        },
        itemBuilder: (context) => [
          // Header: View All in this Category
          PopupMenuItem<String>(
            value: '__all__',
            child: Row(
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All ${cat.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
                if (isCategorySelected && selectedSubcategory == null)
                  const Icon(Icons.check, size: 16, color: AppColors.primaryGreen),
              ],
            ),
          ),
          const PopupMenuDivider(),
          // Subcategories
          ...cat.subcategories.map(
            (sub) {
              final isSubSelected = isCategorySelected && selectedSubcategory == sub;
              return PopupMenuItem<String>(
                value: sub,
                child: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      size: 15,
                      color: isSubSelected ? AppColors.primaryCrimson : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sub,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: isSubSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSubSelected ? AppColors.primaryCrimson : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSubSelected)
                      const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson),
                  ],
                ),
              );
            },
          ),
        ],
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isCategorySelected ? AppColors.primaryDarkGreen : Colors.transparent,
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
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile Bottom Sheet displaying full category hierarchy with subcategories
  void _showMobileCategoriesSheet(BuildContext context, List<CategoryItem> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
            // "Show All Products" chip
            ListTile(
              leading: const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen),
              title: Text(
                'Show All Products',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: selectedCategoryId == 'all'
                  ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                onCategorySelected?.call('all', null);
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (c, idx) {
                  final cat = categories[idx];
                  final isCatSelected = selectedCategoryId == cat.id;

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
                          onCategorySelected?.call(cat.id, null);
                        },
                      ),
                      ...cat.subcategories.map(
                        (sub) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                          title: Text(
                            sub,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          trailing: (isCatSelected && selectedSubcategory == sub)
                              ? const Icon(Icons.check, size: 16, color: AppColors.primaryCrimson)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            onCategorySelected?.call(cat.id, sub);
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
}
