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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contact info
              Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Call to Order: ${AppConstants.orderCallNumber}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 16),
                  Text(
                    'Helpline: ${AppConstants.helplineNumber}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Right utilities
              Row(
                children: [
                  _navLink('Ask Agro Experts'),
                  const SizedBox(width: 16),
                  _navLink('Be a Partner'),
                  const SizedBox(width: 16),
                  _navLink('Sell with Us'),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.language, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'EN',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
