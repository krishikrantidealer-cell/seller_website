import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class TrustFeaturesSection extends StatelessWidget {
  const TrustFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final isCompactRow = constraints.maxWidth < 1000;

        final cards = [
          _featureData(
            icon: Icons.price_check_rounded,
            iconColor: AppColors.primaryCrimson,
            iconBgColor: AppColors.softRose,
            title: 'Guaranteed Authentic Value',
            subtitle: 'Direct from EBS Essential BioCrop Science',
          ),
          _featureData(
            icon: Icons.local_shipping_rounded,
            iconColor: AppColors.primaryGreen,
            iconBgColor: AppColors.lightGreen,
            title: 'FREE Pan-India Shipping',
            subtitle: 'Reliable doorstep parcel dispatch',
          ),
          _featureData(
            icon: Icons.shield_rounded,
            iconColor: AppColors.primaryCrimson,
            iconBgColor: AppColors.softRose,
            title: 'CERTIFIED Lab Quality',
            subtitle: '100% genuine agri-inputs verified',
          ),
          _featureData(
            icon: Icons.assignment_return_rounded,
            iconColor: AppColors.primaryGreen,
            iconBgColor: AppColors.lightGreen,
            title: 'EASY Returns & Advisory',
            subtitle: 'Agronomist consultation included',
          ),
        ];

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 20,
            vertical: isMobile ? 12 : 20,
          ),
          margin: EdgeInsets.only(top: isMobile ? 16 : 28, bottom: 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: isCompactRow
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < cards.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            _buildCardWidget(cards[i], width: 250),
                          ],
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        for (int i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 14),
                          Expanded(child: _buildCardWidget(cards[i])),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  _FeatureItem _featureData({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return _FeatureItem(
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildCardWidget(_FeatureItem item, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 24),
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
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
}

class _FeatureItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });
}
