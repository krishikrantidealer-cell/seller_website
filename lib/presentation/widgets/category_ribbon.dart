import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';

class CategoryRibbon extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String>? onCategorySelected;

  const CategoryRibbon({
    super.key,
    this.selectedCategoryId = 'all',
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = CategoryItem.sampleCategories;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20),
      height: 48,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryItem(
                  id: 'all',
                  label: 'All Categories',
                  icon: '📋',
                  isSelected: selectedCategoryId == 'all',
                ),
                ...categories.map(
                  (cat) => _categoryItem(
                    id: cat.id,
                    label: cat.name,
                    icon: cat.icon,
                    isSelected: selectedCategoryId == cat.id,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryItem({
    required String id,
    required String label,
    required String icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onCategorySelected?.call(id),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent,
          border: isSelected
              ? const Border(bottom: BorderSide(color: Colors.white, width: 3))
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
