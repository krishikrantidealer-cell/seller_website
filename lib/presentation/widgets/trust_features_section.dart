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
                    title: 'Guaranteed Lowest Prices',
                    subtitle: 'Direct from authorized manufacturers',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                  _featureCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'FREE India Wide Shipping',
                    subtitle: 'Reliable doorstep parcel dispatch',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                  _featureCard(
                    icon: Icons.shield_rounded,
                    title: 'SAFE SHOPPING Guarantee',
                    subtitle: '100% genuine agri-inputs verified',
                    width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 72) / 4,
                  ),
                  _featureCard(
                    icon: Icons.assignment_return_rounded,
                    title: 'EASY Returns & Support',
                    subtitle: 'Hassle-free replacement policy',
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
    required String title,
    required String subtitle,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
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
