import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'crop_doctor_modal.dart';
import 'mandi_bhav_modal.dart';

class TopUtilityBar extends StatelessWidget {
  const TopUtilityBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 768;

    return Container(
      color: AppColors.forestDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toll Free & Support
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.support_agent_rounded, size: 16, color: AppColors.harvestAmberLight),
                    SizedBox(width: 6),
                    Text(
                      'Toll Free: ',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      AppConstants.tollFreeNumber,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 20),
                  // WhatsApp Orders
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF4ADE80)),
                      SizedBox(width: 6),
                      Text(
                        'WhatsApp: ${AppConstants.whatsappSupport}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
                const SizedBox(width: 20),
                // APMC Mandi Bhav Link
                TextButton.icon(
                  onPressed: () => MandiBhavModal.show(context),
                  icon: const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.harvestAmberLight),
                  label: const Text(
                    'Mandi Bhav (मंडी भाव)',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (isTablet) ...[
                  const SizedBox(width: 12),
                  // Crop Doctor
                  TextButton.icon(
                    onPressed: () => CropDoctorModal.show(context),
                    icon: const Icon(Icons.psychology_alt_outlined, size: 14, color: Color(0xFF86EFAC)),
                    label: const Text(
                      'Crop Doctor (फसल डॉक्टर)',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                // Language Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'English / हिन्दी',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
