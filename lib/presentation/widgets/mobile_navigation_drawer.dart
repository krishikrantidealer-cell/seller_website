import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/auth_state.dart';
import '../../data/models/wishlist_state.dart';
import 'auth_modal.dart';
import '../profile/farmer_profile_view.dart';
import '../orders/my_orders_view.dart';
import '../technical/technical_search_view.dart';
import '../wishlist/wishlist_view.dart';

class MobileNavigationDrawer extends StatelessWidget {
  final String selectedCategoryId;
  final String? selectedSubcategory;
  final Function(String categoryId, String? subcategory) onCategorySelected;
  final VoidCallback? onAllProductsSelected;

  const MobileNavigationDrawer({
    super.key,
    this.selectedCategoryId = 'all',
    this.selectedSubcategory,
    required this.onCategorySelected,
    this.onAllProductsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Compact Brand Header
            _buildDrawerHeader(context),

            // Scrollable Navigation Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  // Quick Actions Bar (Orders, Wishlist, Technical, Profile)
                  _buildQuickActionBar(context),

                  const SizedBox(height: 4),

                  // Section Header: Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CATEGORIES',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '11 Categories',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // All Products Item
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Material(
                      color: selectedCategoryId == 'all' ? AppColors.lightGreen : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: selectedCategoryId == 'all'
                              ? AppColors.primaryGreen.withValues(alpha: 0.4)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        minLeadingWidth: 26,
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: selectedCategoryId == 'all' ? AppColors.primaryGreen : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 16,
                            color: selectedCategoryId == 'all' ? Colors.white : AppColors.primaryGreen,
                          ),
                        ),
                        title: Text(
                          'All Products',
                          style: GoogleFonts.poppins(
                            fontWeight: selectedCategoryId == 'all' ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 12.5,
                            color: selectedCategoryId == 'all' ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                          ),
                        ),
                        trailing: selectedCategoryId == 'all'
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 16)
                            : const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                        onTap: () {
                          Navigator.pop(context);
                          if (onAllProductsSelected != null) {
                            onAllProductsSelected!();
                          } else {
                            onCategorySelected('all', null);
                          }
                        },
                      ),
                    ),
                  ),

                  // Major Categories Accordions
                  ...CategoryItem.sampleCategories.map((cat) {
                    final isCatSelected = selectedCategoryId == cat.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isCatSelected ? AppColors.primaryGreen.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                            width: isCatSelected ? 1.2 : 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            key: PageStorageKey('drawer_cat_${cat.id}'),
                            initiallyExpanded: isCatSelected,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isCatSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCatSelected ? AppColors.primaryGreen.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(cat.icon, style: const TextStyle(fontSize: 14)),
                            ),
                            title: Text(
                              cat.name,
                              style: GoogleFonts.poppins(
                                fontWeight: isCatSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 12.5,
                                color: isCatSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                              ),
                            ),
                            children: [
                              Material(
                                color: const Color(0xFFF8FAFC),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: [
                                      // Quick All in Category button
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          onCategorySelected(cat.id, null);
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isCatSelected && selectedSubcategory == null
                                                ? AppColors.primaryGreen
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isCatSelected && selectedSubcategory == null
                                                  ? AppColors.primaryGreen
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'All in ${cat.name}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11.5,
                                                  color: isCatSelected && selectedSubcategory == null
                                                      ? Colors.white
                                                      : AppColors.primaryDarkGreen,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 13,
                                                color: isCatSelected && selectedSubcategory == null
                                                    ? Colors.white
                                                    : AppColors.primaryGreen,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // Groups and subcategories
                                      if (cat.groups.isNotEmpty)
                                        ...cat.groups.map(
                                          (group) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Material(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Theme(
                                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                                child: ExpansionTile(
                                                  dense: true,
                                                  visualDensity: VisualDensity.compact,
                                                  tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                  leading: group.icon != null
                                                      ? Text(group.icon!, style: const TextStyle(fontSize: 13))
                                                      : null,
                                                  title: Text(
                                                    group.name,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: selectedSubcategory == group.name
                                                          ? AppColors.primaryDarkGreen
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  children: [
                                                    Material(
                                                      color: Colors.white,
                                                      child: Column(
                                                        children: group.subcategories.map(
                                                          (sub) {
                                                            final isSubSelected = isCatSelected && selectedSubcategory == sub;
                                                            return ListTile(
                                                              dense: true,
                                                              visualDensity: VisualDensity.compact,
                                                              contentPadding: const EdgeInsets.only(left: 24, right: 10),
                                                              title: Text(
                                                                sub,
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 11,
                                                                  fontWeight: isSubSelected ? FontWeight.w700 : FontWeight.w500,
                                                                  color: isSubSelected ? AppColors.primaryDarkGreen : AppColors.textSecondary,
                                                                ),
                                                              ),
                                                              trailing: isSubSelected
                                                                  ? const Icon(Icons.check, size: 13, color: AppColors.primaryGreen)
                                                                  : const Icon(Icons.chevron_right_rounded, size: 13, color: Color(0xFFCBD5E1)),
                                                              onTap: () {
                                                                Navigator.pop(context);
                                                                onCategorySelected(cat.id, sub);
                                                              },
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        ...cat.subcategories.map(
                                          (sub) {
                                            final isSubSelected = isCatSelected && selectedSubcategory == sub;
                                            return ListTile(
                                              dense: true,
                                              visualDensity: VisualDensity.compact,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                              title: Text(
                                                sub,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.5,
                                                  fontWeight: isSubSelected ? FontWeight.w700 : FontWeight.w500,
                                                  color: isSubSelected ? AppColors.primaryDarkGreen : AppColors.textSecondary,
                                                ),
                                              ),
                                              trailing: isSubSelected
                                                  ? const Icon(Icons.check, size: 13, color: AppColors.primaryGreen)
                                                  : const Icon(Icons.chevron_right_rounded, size: 13, color: Color(0xFFCBD5E1)),
                                              onTap: () {
                                                Navigator.pop(context);
                                                onCategorySelected(cat.id, sub);
                                              },
                                            );
                                          },
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
                  }),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: topPadding > 0 ? topPadding + 6 : 14,
        bottom: 10,
        left: 14,
        right: 14,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3E17), Color(0xFF1E5B29)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/images/company_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EBS BioCrop',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Direct Farmer Store • Authentic Inputs',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFBBF7D0),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                ),
                tooltip: 'Close Menu',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // User Welcome & Status Badge
          AnimatedBuilder(
            animation: AuthController.instance,
            builder: (context, _) {
              final auth = AuthController.instance;
              if (auth.isLoggedIn) {
                final name = auth.currentUser?.name ?? auth.currentUser?.formattedPhone ?? 'Farmer';
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerProfileView()));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, size: 14, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste, $name',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Verified Farmer • Tap for profile & orders',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFBBF7D0),
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.white70),
                      ],
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showAuthModal(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.login_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login / Register with Mobile',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Get Kisan discounts & live order tracking',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFBBF7D0),
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'SIGN IN',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.local_shipping_outlined,
              label: 'Orders',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersView()));
              },
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: WishlistController.instance,
              builder: (context, _) {
                final count = WishlistController.instance.totalCount;
                return _buildQuickActionItem(
                  icon: Icons.favorite_border_rounded,
                  label: 'Wishlist',
                  badgeCount: count,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistView()));
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.science_outlined,
              label: 'Technical',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicalSearchView()));
              },
            ),
          ),
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerProfileView()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badgeCount != null && badgeCount > 0,
              label: Text(
                '$badgeCount',
                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primaryCrimson,
              child: Icon(icon, size: 19, color: AppColors.primaryDarkGreen),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
