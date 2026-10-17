import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.footerBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: Padding(
            padding: EdgeInsets.only(
              top: isMobile ? 24 : 36,
              bottom: isMobile ? 20 : 28,
              left: isMobile ? 16 : 24,
              right: isMobile ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Integrated Trust Badges (Top tier of footer)
                _buildTrustBadgesSection(context),

                const SizedBox(height: 32),
                const Divider(color: Color(0xFF2E2A28), height: 1),
                const SizedBox(height: 36),

                // Main Footer Columns
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    if (!isWide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _brandColumn(),
                          const SizedBox(height: 32),
                          _categoriesColumn(),
                          const SizedBox(height: 32),
                          _quickLinksColumn(),
                          const SizedBox(height: 32),
                          _supportColumn(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _brandColumn()),
                        const SizedBox(width: 48),
                        Expanded(flex: 2, child: _categoriesColumn()),
                        const SizedBox(width: 48),
                        Expanded(flex: 2, child: _quickLinksColumn()),
                        const SizedBox(width: 48),
                        Expanded(flex: 3, child: _supportColumn()),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),
                const Divider(color: Color(0xFF2E2A28), height: 1),
                const SizedBox(height: 24),

                // Bottom Copyright & Legal Links with proper spacing
                _buildBottomLegalRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Integrated Trust Badges Tier inside the footer
  Widget _buildTrustBadgesSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactRow = constraints.maxWidth < 1000;

        final badges = [
          _TrustBadgeItem(
            icon: Icons.price_check_rounded,
            iconColor: AppColors.primaryCrimson,
            iconBgColor: AppColors.primaryCrimson.withValues(alpha: 0.18),
            title: 'Guaranteed Authentic Value',
            subtitle: 'Direct from EBS Essential BioCrop Science',
          ),
          _TrustBadgeItem(
            icon: Icons.local_shipping_rounded,
            iconColor: AppColors.primaryGreen,
            iconBgColor: AppColors.primaryGreen.withValues(alpha: 0.18),
            title: 'FREE Pan-India Shipping',
            subtitle: 'Reliable doorstep parcel dispatch',
          ),
          _TrustBadgeItem(
            icon: Icons.shield_rounded,
            iconColor: AppColors.primaryCrimson,
            iconBgColor: AppColors.primaryCrimson.withValues(alpha: 0.18),
            title: 'CERTIFIED Lab Quality',
            subtitle: '100% genuine agri-inputs verified',
          ),
          _TrustBadgeItem(
            icon: Icons.assignment_return_rounded,
            iconColor: AppColors.primaryGreen,
            iconBgColor: AppColors.primaryGreen.withValues(alpha: 0.18),
            title: 'EASY Returns & Advisory',
            subtitle: 'Agronomist consultation included',
          ),
        ];

        if (isCompactRow) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < badges.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _buildBadgeCard(badges[i], width: 280),
                ],
              ],
            ),
          );
        }

        return Row(
          children: [
            for (int i = 0; i < badges.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: _buildBadgeCard(badges[i])),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBadgeCard(_TrustBadgeItem item, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF24201E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF332D29)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLegalRow(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 12,
        children: [
          Text(
            '© 2026 EBS Essential BioCrop Science. All rights reserved.',
            style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _footerLink('Privacy Policy'),
              _footerLink('Terms & Conditions'),
              _footerLink('Refund & Cancellation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'EBS ',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCrimson,
                      ),
                    ),
                    TextSpan(
                      text: 'Essential BioCrop Science',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Pioneering agricultural biotechnology, advanced crop nutrition, certified organic inputs, and science-backed farming solutions delivered nationwide.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '100% Genuine Certified Products',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoriesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Categories'),
        _footerLink('Insecticides & Pesticides'),
        _footerLink('Bio & Organic Fertilizers'),
        _footerLink('Certified Hybrid Seeds'),
        _footerLink('Fungicides & Bactericides'),
        _footerLink('Agricultural Sprayers'),
        _footerLink('Drip Irrigation Equipment'),
      ],
    );
  }

  Widget _quickLinksColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Quick Links'),
        _footerLink('About EBS Essential BioCrop Science'),
        _footerLink('Track Your Order'),
        _footerLink('Seller & Distributor Hub'),
        _footerLink('Agronomist Consultation'),
        _footerLink('Research & Formulations'),
      ],
    );
  }

  Widget _supportColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Farmer & Dealer Support'),
        Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.helplineNumber,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Mon - Sat: 9:00 AM - 7:00 PM',
                  style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Email Support: support@ebsbiocrop.com',
          style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 13),
        ),
      ],
    );
  }

  Widget _columnTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _footerLink(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TrustBadgeItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _TrustBadgeItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });
}
