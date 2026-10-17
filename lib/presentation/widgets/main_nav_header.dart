import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

import '../../data/models/cart_state.dart';
import '../../data/models/auth_state.dart';
import 'auth_modal.dart';

class MainNavHeader extends StatefulWidget {
  final int? cartItemCount;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onCartTap;

  const MainNavHeader({
    super.key,
    this.cartItemCount,
    this.onSearch,
    this.onCartTap,
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
                      children: [
                        _buildLogo(isCompact: constraints.maxWidth < 420),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.local_shipping_outlined, color: AppColors.textPrimary, size: 22),
                          tooltip: 'Track Order',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: CartController.instance,
                          builder: (context, _) {
                            final count = widget.cartItemCount ?? CartController.instance.totalCount;
                            return InkWell(
                              onTap: widget.onCartTap,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Badge(
                                  label: Text(
                                    count.toString(),
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: AppColors.primaryCrimson,
                                  child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 24),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: AuthController.instance,
                          builder: (context, _) {
                            final auth = AuthController.instance;
                            if (auth.isLoggedIn) {
                              return InkWell(
                                onTap: () => showAuthModal(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                                  ),
                                  child: const Icon(Icons.person_rounded, color: AppColors.primaryDarkGreen, size: 20),
                                ),
                              );
                            }
                            return IconButton(
                              icon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryGreen, size: 24),
                              tooltip: 'Login / My Account',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              onPressed: () => showAuthModal(context),
                            );
                          },
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
                          onTap: () {},
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
                          onPressed: () {},
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
                        onTap: () {},
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
                            return InkWell(
                              onTap: () => showAuthModal(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primaryGreen, width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              auth.currentUser?.name ?? 'My Account',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.primaryDarkGreen,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primaryDarkGreen),
                                          ],
                                        ),
                                        Text(
                                          auth.currentUser?.formattedPhone ?? '',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
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

  Widget _buildLogo({bool isCompact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.eco_rounded, color: Colors.white, size: isCompact ? 18 : 24),
        ),
        SizedBox(width: isCompact ? 6 : 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'EBS ',
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 17 : 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryCrimson,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'BioCrop',
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 17 : 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Text(
              'ESSENTIAL BIO CROP SCIENCE',
              style: GoogleFonts.poppins(
                fontSize: isCompact ? 7.2 : 8.8,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryCrimson,
                letterSpacing: 0.8,
              ),
            ),
          ],
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
}
