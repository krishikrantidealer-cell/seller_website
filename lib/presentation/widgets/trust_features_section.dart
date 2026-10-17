import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class TrustFeaturesSection extends StatelessWidget {
  const TrustFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              return Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _featureCard(
                    icon: Icons.price_check_rounded,
                    iconColor: AppColors.primaryCrimson,
                    iconBgColor: AppColors.softRose,
                    title: 'Guaranteed Authentic Value',
                    subtitle: 'Direct from EBS BioCrop Science',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                  _featureCard(
                    icon: Icons.local_shipping_rounded,
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: AppColors.lightGreen,
                    title: 'FREE Pan-India Shipping',
                    subtitle: 'Reliable doorstep parcel dispatch',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                  _featureCard(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.primaryCrimson,
                    iconBgColor: AppColors.softRose,
                    title: 'CERTIFIED Lab Quality',
                    subtitle: '100% genuine agri-inputs verified',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                  _featureCard(
                    icon: Icons.assignment_return_rounded,
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: AppColors.lightGreen,
                    title: 'EASY Returns & Advisory',
                    subtitle: 'Agronomist consultation included',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
