import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

import '../../data/models/cart_state.dart';
import '../../data/models/auth_state.dart';
import 'auth_modal.dart';
import '../profile/farmer_profile_view.dart';
import '../orders/my_orders_view.dart';
import '../technical/technical_search_view.dart';

class MainNavHeader extends StatefulWidget {
  final int? cartItemCount;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onCartTap;
  final VoidCallback? onTechnicalSearchTap;

  final VoidCallback? onMenuTap;

  const MainNavHeader({
    super.key,
    this.cartItemCount,
    this.onSearch,
    this.onCartTap,
    this.onTechnicalSearchTap,
    this.onMenuTap,
  });

  @override
  State<MainNavHeader> createState() => _MainNavHeaderState();
}

class _MainNavHeaderState extends State<MainNavHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTechnicalSearch() {
    if (widget.onTechnicalSearchTap != null) {
      widget.onTechnicalSearchTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TechnicalSearchView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;

              if (isMobile) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: Brand logo + Quick Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onMenuTap != null) ...[
                                IconButton(
                                  icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 22),
                                  tooltip: 'Categories Menu',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: widget.onMenuTap,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: _buildLogo(
                                  isCompact: constraints.maxWidth < 600,
                                  isSmallMobile: constraints.maxWidth < 420,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (constraints.maxWidth >= 500) ...[
                              IconButton(
                                icon: const Icon(Icons.local_shipping_outlined, color: AppColors.textPrimary, size: 22),
                                tooltip: 'Track Order',
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 6),
                            ],
                            AnimatedBuilder(
                              animation: CartController.instance,
                              builder: (context, _) {
                                final count = widget.cartItemCount ?? CartController.instance.totalCount;
                                return InkWell(
                                  onTap: widget.onCartTap,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Badge(
                                      label: Text(
                                        count.toString(),
                                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: AppColors.primaryCrimson,
                                      child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 22),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            AnimatedBuilder(
                              animation: AuthController.instance,
                              builder: (context, _) {
                                final auth = AuthController.instance;
                                if (auth.isLoggedIn) {
                                  return _buildProfileDropdown(context, auth, isMobile: true);
                                }
                                return IconButton(
                                  icon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryGreen, size: 22),
                                  tooltip: 'Login / My Account',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: () => showAuthModal(context),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: widget.onSearch,
                              decoration: InputDecoration(
                                hintText: 'Search seeds, pesticides, fertilizers...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryCrimson,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.search, color: Colors.white, size: 16),
                                    onPressed: () {
                                      widget.onSearch?.call(_searchController.text);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _openTechnicalSearch,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryGreen),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.science_outlined, size: 16, color: AppColors.primaryDarkGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Technical',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDarkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              // Desktop Header
              return Row(
                children: [
                  // Brand Logo
                  _buildLogo(),
                  const SizedBox(width: 32),

                  // Search Bar + Search by Technical Name
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: widget.onSearch,
                              decoration: InputDecoration(
                                hintText: 'Search for seeds, pesticides, fertilizers...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryCrimson,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.search, color: Colors.white, size: 18),
                                    onPressed: () {
                                      widget.onSearch?.call(_searchController.text);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Search by Technical Name Button
                        ElevatedButton.icon(
                          onPressed: _openTechnicalSearch,
                          icon: const Icon(Icons.science_outlined, size: 18),
                          label: Text(
                            'Search by Technical',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Right Navigation Actions
                  Row(
                    children: [
                      // Track Order
                      _actionItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'Track Order',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyOrdersView()),
                          );
                        },
                      ),
                      const SizedBox(width: 24),

                      // Cart
                      AnimatedBuilder(
                        animation: CartController.instance,
                        builder: (context, _) {
                          final count = widget.cartItemCount ?? CartController.instance.totalCount;
                          return InkWell(
                            onTap: widget.onCartTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Badge(
                                    label: Text(
                                      count.toString(),
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: AppColors.primaryCrimson,
                                    child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cart',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 24),

                      // My Account / Phone + OTP Login
                      AnimatedBuilder(
                        animation: AuthController.instance,
                        builder: (context, _) {
                          final auth = AuthController.instance;
                          if (auth.isLoggedIn) {
                            return _buildProfileDropdown(context, auth, isMobile: false);
                          }

                          return OutlinedButton.icon(
                            onPressed: () => showAuthModal(context),
                            icon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primaryGreen),
                            label: Text(
                              'Login / My Account',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({bool isCompact = false, bool isSmallMobile = false}) {
    final double titleFontSize = isSmallMobile ? 12 : (isCompact ? 15 : 22);
    final double iconSize = isSmallMobile ? 14 : (isCompact ? 18 : 24);
    final double iconPadding = isSmallMobile ? 3 : (isCompact ? 6 : 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
          ),
          child: Icon(Icons.eco_rounded, color: Colors.white, size: iconSize),
        ),
        SizedBox(width: isSmallMobile ? 4 : (isCompact ? 6 : 10)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'EBS ',
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCrimson,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'BioCrop',
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (!isCompact && !isSmallMobile)
              Text(
                'ESSENTIAL BIO CROP SCIENCE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 8.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryCrimson,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context, AuthController auth, {required bool isMobile}) {
    final rawPhone = auth.currentUser?.phoneNumber ?? '';
    final shortPhone = rawPhone.length == 10
        ? '${rawPhone.substring(0, 5)} ${rawPhone.substring(5)}'
        : rawPhone;
    final phoneDisplay = isMobile ? shortPhone : (auth.currentUser?.formattedPhone ?? '');

    PopupMenuItem<String> buildMenuItem({
      required String value,
      required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String title,
      required String subtitle,
      bool isDestructive = false,
    }) {
      return PopupMenuItem<String>(
        value: value,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        height: 52,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.primaryCrimson : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: isDestructive
                  ? AppColors.primaryCrimson.withValues(alpha: 0.5)
                  : Colors.grey.shade400,
            ),
          ],
        ),
      );
    }

    final dropdownItems = <PopupMenuEntry<String>>[
      // Profile Card Header
      PopupMenuItem<String>(
        enabled: false,
        padding: EdgeInsets.zero,
        height: 68,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF0FDF4),
            border: Border(bottom: BorderSide(color: Color(0xFFDCFCE7), width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: (auth.currentUser?.name != null && auth.currentUser!.name!.trim().isNotEmpty)
                    ? Text(
                        auth.currentUser!.name!.trim()[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      )
                    : const Icon(Icons.person_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            (auth.currentUser?.name != null && auth.currentUser!.name!.trim().isNotEmpty)
                                ? auth.currentUser!.name!.trim()
                                : (auth.currentUser?.formattedPhone ?? phoneDisplay),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VERIFIED',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkGreen,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (auth.currentUser?.villageOrTown != null && auth.currentUser!.villageOrTown!.trim().isNotEmpty)
                          ? '${auth.currentUser!.villageOrTown!.trim()}, ${((auth.currentUser?.district != null && auth.currentUser!.district!.isNotEmpty) ? auth.currentUser!.district : auth.currentUser?.state) ?? ''}'
                          : (auth.currentUser?.location ?? 'Verified Farmer • EBS Direct'),
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Farmer Profile & Saved Addresses
      buildMenuItem(
        value: 'account',
        icon: Icons.person_outline_rounded,
        iconColor: const Color(0xFF16A34A),
        iconBg: const Color(0xFFF0FDF4),
        title: 'Farmer Profile',
        subtitle: 'Name, address & crop details',
      ),

      // Track Orders
      buildMenuItem(
        value: 'orders',
        icon: Icons.local_shipping_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEFF6FF),
        title: 'Track Orders',
        subtitle: 'Live parcel status & delivery',
      ),

      const PopupMenuDivider(height: 1),

      // Sign Out
      buildMenuItem(
        value: 'logout',
        icon: Icons.logout_rounded,
        iconColor: AppColors.primaryCrimson,
        iconBg: const Color(0xFFFEF2F2),
        title: 'Sign Out',
        subtitle: 'Switch or disconnect number',
        isDestructive: true,
      ),
    ];

    void handleSelect(String value) {
      if (value == 'account') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FarmerProfileView()),
        );
      } else if (value == 'orders') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersView()),
        );
      } else if (value == 'logout') {
        auth.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed out successfully'),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (isMobile) {
      return PopupMenuButton<String>(
        tooltip: 'Account Menu',
        offset: const Offset(0, 36),
        constraints: const BoxConstraints(minWidth: 260, maxWidth: 285),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        padding: EdgeInsets.zero,
        onSelected: handleSelect,
        itemBuilder: (context) => dropdownItems,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF2F7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  shortPhone,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Account Menu',
      offset: const Offset(0, 48),
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      onSelected: handleSelect,
      itemBuilder: (context) => dropdownItems,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2F7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Farmer Account',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
                Text(
                  phoneDisplay,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
