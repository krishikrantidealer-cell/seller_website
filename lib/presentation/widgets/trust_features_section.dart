import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class TrustFeaturesSection extends StatelessWidget {
  const TrustFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth < 950;

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 20,
            vertical: isMobile ? 12 : 20,
          ),
          margin: EdgeInsets.symmetric(vertical: isMobile ? 8 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: Wrap(
                spacing: isMobile ? 10 : 20,
                runSpacing: isMobile ? 10 : 16,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _featureCard(
                    icon: Icons.price_check_rounded,
                    iconColor: AppColors.primaryCrimson,
                    iconBgColor: AppColors.softRose,
                    title: 'Guaranteed Authentic Value',
                    subtitle: 'Direct from EBS BioCrop Science',
                    width: isMobile
                        ? constraints.maxWidth
                        : isTablet
                            ? (constraints.maxWidth - 20) / 2
                            : (constraints.maxWidth - 60) / 4,
                  ),
                  _featureCard(
                    icon: Icons.local_shipping_rounded,
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: AppColors.lightGreen,
                    title: 'FREE Pan-India Shipping',
                    subtitle: 'Reliable doorstep parcel dispatch',
                    width: isMobile
                        ? constraints.maxWidth
                        : isTablet
                            ? (constraints.maxWidth - 20) / 2
                            : (constraints.maxWidth - 60) / 4,
                  ),
                  _featureCard(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.primaryCrimson,
                    iconBgColor: AppColors.softRose,
                    title: 'CERTIFIED Lab Quality',
                    subtitle: '100% genuine agri-inputs verified',
                    width: isMobile
                        ? constraints.maxWidth
                        : isTablet
                            ? (constraints.maxWidth - 20) / 2
                            : (constraints.maxWidth - 60) / 4,
                  ),
                  _featureCard(
                    icon: Icons.assignment_return_rounded,
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: AppColors.lightGreen,
                    title: 'EASY Returns & Advisory',
                    subtitle: 'Agronomist consultation included',
                    width: isMobile
                        ? constraints.maxWidth
                        : isTablet
                            ? (constraints.maxWidth - 20) / 2
                            : (constraints.maxWidth - 60) / 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _featureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
