import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class MainNavHeader extends StatefulWidget {
  final int cartItemCount;
  final ValueChanged<String>? onSearch;

  const MainNavHeader({
    super.key,
    this.cartItemCount = 2,
    this.onSearch,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
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
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Badge(
                            label: Text(
                              widget.cartItemCount.toString(),
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppColors.discountRed,
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
                  ),
                  const SizedBox(width: 24),

                  // My Account
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline, size: 18, color: AppColors.primaryGreen),
                    label: Text(
                      'My Account',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'EBS ',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryCrimson,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'BioCrop',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Text(
              'SCIENCE & INNOVATION',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryCrimson,
                letterSpacing: 1.4,
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
