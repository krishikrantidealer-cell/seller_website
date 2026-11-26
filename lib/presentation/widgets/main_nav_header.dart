import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

import '../../data/models/cart_state.dart';
import '../../data/models/auth_state.dart';
import '../../data/models/wishlist_state.dart';
import 'auth_modal.dart';
import '../profile/farmer_profile_view.dart';
import '../orders/my_orders_view.dart';
import '../technical/technical_search_view.dart';
import '../wishlist/wishlist_view.dart';

class MainNavHeader extends StatefulWidget {
  static final ValueNotifier<String> globalSearchNotifier = ValueNotifier<String>('');

  final int? cartItemCount;
  final ValueChanged<String>? onSearch;
  final String? searchQuery;
  final VoidCallback? onCartTap;
  final VoidCallback? onTechnicalSearchTap;

  final VoidCallback? onMenuTap;

  const MainNavHeader({
    super.key,
    this.cartItemCount,
    this.onSearch,
    this.searchQuery,
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
  void initState() {
    super.initState();
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
    }
  }

  @override
  void didUpdateWidget(covariant MainNavHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != null &&
        widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      if (widget.searchQuery!.isEmpty) {
        _searchController.clear();
      } else {
        _searchController.text = widget.searchQuery!;
      }
    }
  }

  void _handleSearchChanged(String value) {
    setState(() {});
    widget.onSearch?.call(value);
  }

  void _handleSearchSubmitted(String value) {
    if (widget.onSearch != null) {
      widget.onSearch!(value);
      return;
    }
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      MainNavHeader.globalSearchNotifier.value = trimmed;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    MainNavHeader.globalSearchNotifier.value = '';
    widget.onSearch?.call('');
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 1100;

              if (isMobile) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: Brand logo + Quick Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
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
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildLogo(
                                    isCompact: constraints.maxWidth < 600,
                                    isSmallMobile: constraints.maxWidth < 420,
                                  ),
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
                            // Mobile Wishlist Button
                            AnimatedBuilder(
                              animation: WishlistController.instance,
                              builder: (context, _) {
                                final count = WishlistController.instance.totalCount;
                                return Tooltip(
                                  message: count > 0 ? 'Wishlist ($count)' : 'Wishlist',
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const WishlistView()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: count > 0
                                          ? Badge(
                                              label: Text(
                                                count.toString(),
                                                style: GoogleFonts.mukta(fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                              backgroundColor: AppColors.primaryCrimson,
                                              child: const Icon(Icons.favorite_rounded, color: AppColors.primaryCrimson, size: 22),
                                            )
                                          : const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary, size: 22),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            AnimatedBuilder(
                              animation: CartController.instance,
                              builder: (context, _) {
                                final count = widget.cartItemCount ?? CartController.instance.totalCount;
                                return InkWell(
                                  onTap: widget.onCartTap,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: count > 0
                                        ? Badge(
                                            label: Text(
                                              count.toString(),
                                              style: GoogleFonts.mukta(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: AppColors.primaryCrimson,
                                            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 22),
                                          )
                                        : const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 22),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            AnimatedBuilder(
                              animation: AuthController.instance,
                              builder: (context, _) {
                                final auth = AuthController.instance;
                                if (auth.isLoggedIn) {
                                  return _buildProfileDropdown(
                                    context,
                                    auth,
                                    isMobile: true,
                                    isCompact: constraints.maxWidth < 360,
                                  );
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
                              onChanged: _handleSearchChanged,
                              onSubmitted: _handleSearchSubmitted,
                              textAlignVertical: TextAlignVertical.center,
                              style: GoogleFonts.mukta(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search seeds, pesticides, fertilizers...',
                                hintStyle: GoogleFonts.mukta(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                                prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 40),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                suffixIconConstraints: BoxConstraints(
                                  minWidth: _searchController.text.isNotEmpty ? 68 : 36,
                                  minHeight: 40,
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchController.text.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
                                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 16),
                                        tooltip: 'Clear search',
                                        onPressed: _clearSearch,
                                      ),
                                    Container(
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
                                  ],
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
                                  style: GoogleFonts.mukta(
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
                  const SizedBox(width: 24),

                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAE6DF)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF78716C),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _handleSearchChanged,
                              onSubmitted: _handleSearchSubmitted,
                              textAlignVertical: TextAlignVertical.center,
                              style: GoogleFonts.mukta(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText:
                                    'Search products, crops, brands or crop problems...',
                                hintStyle: GoogleFonts.mukta(
                                  color: const Color(0xFF78716C),
                                  fontSize: 13.5,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: const Size(28, 36),
                                padding: EdgeInsets.zero,
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              tooltip: 'Clear search',
                              onPressed: _clearSearch,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _handleSearchSubmitted(_searchController.text),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC81E1E),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 22),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: Text(
                                  'Search',
                                  style: GoogleFonts.mukta(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),

                  // Right Navigation Actions: Account, Wishlist, Cart
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Account
                      AnimatedBuilder(
                        animation: AuthController.instance,
                        builder: (context, _) {
                          final auth = AuthController.instance;
                          if (auth.isLoggedIn) {
                            return _buildProfileDropdown(
                              context,
                              auth,
                              isMobile: false,
                            );
                          }
                          return InkWell(
                            onTap: () => showAuthModal(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF1C1917),
                                    size: 22,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Account',
                                    style: GoogleFonts.mukta(
                                      color: const Color(0xFF1C1917),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),

                      // Wishlist
                      AnimatedBuilder(
                        animation: WishlistController.instance,
                        builder: (context, _) {
                          final count = WishlistController.instance.totalCount;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const WishlistView()),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  count > 0
                                      ? Badge(
                                          label: Text(
                                            count.toString(),
                                            style: GoogleFonts.mukta(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor:
                                              const Color(0xFFC81E1E),
                                          child: const Icon(
                                            Icons.favorite_rounded,
                                            color: Color(0xFFC81E1E),
                                            size: 22,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.favorite_border_rounded,
                                          color: Color(0xFF1C1917),
                                          size: 22,
                                        ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Wishlist',
                                    style: GoogleFonts.mukta(
                                      color: count > 0
                                          ? const Color(0xFFC81E1E)
                                          : const Color(0xFF1C1917),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),

                      // Cart
                      AnimatedBuilder(
                        animation: CartController.instance,
                        builder: (context, _) {
                          final count = widget.cartItemCount ??
                              CartController.instance.totalCount;
                          return InkWell(
                            onTap: widget.onCartTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Badge(
                                    label: Text(
                                      count.toString(),
                                      style: GoogleFonts.mukta(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFC81E1E),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Color(0xFF1C1917),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cart',
                                    style: GoogleFonts.mukta(
                                      color: const Color(0xFF1C1917),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                      height: 1.1,
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({bool isCompact = false, bool isSmallMobile = false}) {
    final double logoHeight = isSmallMobile ? 48 : (isCompact ? 58 : 70);
    final double maxLogoWidth = isSmallMobile ? 185 : (isCompact ? 225 : 265);

    return Tooltip(
      message: 'Ebs Krishi Dukaan',
      child: InkWell(
        onTap: () {
          _clearSearch();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: isSmallMobile ? 0 : 4),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxLogoWidth),
            child: SvgPicture.asset(
              'assets/images/ebs_logo.svg',
              height: logoHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                height: logoHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'EBS Krishi Dukaan',
                      style: GoogleFonts.mukta(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context, AuthController auth, {required bool isMobile, bool isCompact = false}) {
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
                    style: GoogleFonts.mukta(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.primaryCrimson : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.mukta(
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
                        style: GoogleFonts.mukta(
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
                            style: GoogleFonts.mukta(
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
                            style: GoogleFonts.mukta(
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
                      style: GoogleFonts.mukta(
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

      // My Wishlist
      buildMenuItem(
        value: 'wishlist',
        icon: Icons.favorite_outline_rounded,
        iconColor: AppColors.primaryCrimson,
        iconBg: const Color(0xFFFEF2F2),
        title: 'My Wishlist',
        subtitle: '${WishlistController.instance.totalCount} saved farm products',
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
      } else if (value == 'wishlist') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WishlistView()),
        );
      } else if (value == 'logout') {
        showSignOutConfirmationDialog(context).then((confirmed) {
          if (confirmed == true && context.mounted) {
            auth.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Signed out successfully',
                      style: GoogleFonts.mukta(color: Colors.white, fontSize: 12.5),
                    ),
                  ],
                ),
                backgroundColor: AppColors.textPrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
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
              if (!isCompact) ...[
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    shortPhone,
                    style: GoogleFonts.mukta(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
                      style: GoogleFonts.mukta(
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
                  style: GoogleFonts.mukta(
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
