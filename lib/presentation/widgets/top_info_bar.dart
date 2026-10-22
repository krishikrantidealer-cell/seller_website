import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class TopInfoBar extends StatelessWidget {
  const TopInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryCrimson,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // Mobile compact bar
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Call to Order: ${AppConstants.orderCallNumber}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (constraints.maxWidth >= 500) ...[
                      const SizedBox(width: 8),
                      Container(width: 1, height: 10, color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Text(
                        'Free Pan-India Delivery',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                );
              }

              final isLaptop = constraints.maxWidth < 1360;
              final double itemGap = isLaptop ? 10.0 : 16.0;
              final double fontSize = isLaptop ? 11.0 : 12.0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contact info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'Call to Order: ${AppConstants.orderCallNumber}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: itemGap),
                      Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.4)),
                      SizedBox(width: itemGap),
                      Text(
                        'Helpline: ${AppConstants.helplineNumber}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Right utilities
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navLink('Ask EBS Experts', fontSize: fontSize),
                      SizedBox(width: itemGap),
                      _navLink('Be a Partner', fontSize: fontSize),
                      SizedBox(width: itemGap),
                      _navLink('Sell with Us', fontSize: fontSize),
                      SizedBox(width: itemGap),
                      Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.4)),
                      SizedBox(width: itemGap),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'EN',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _navLink(String label, {double fontSize = 12.0}) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
