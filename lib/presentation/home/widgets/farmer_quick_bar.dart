import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'crop_doctor_modal.dart';
import 'dosage_calculator_modal.dart';
import 'mandi_bhav_modal.dart';

class FarmerQuickBar extends StatelessWidget {
  const FarmerQuickBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forestDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toll Free Helpline
                  _buildActionPill(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: Colors.white,
                    backgroundColor: AppColors.brandRed,
                    title: 'कॉल पर आर्डर (1800-203-1425)',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling EBS BioCrop Farmer Helpline: 1800-203-1425 (Toll Free)'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // WhatsApp Order
                  _buildActionPill(
                    icon: Icons.chat_bubble_rounded,
                    iconColor: Colors.white,
                    backgroundColor: const Color(0xFF22C55E),
                    title: 'व्हाट्सएप आर्डर (WhatsApp)',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening WhatsApp Support: ${AppConstants.whatsappSupport}'),
                          backgroundColor: AppColors.forestDark,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Crop Doctor
                  _buildActionPill(
                    icon: Icons.psychology_alt_outlined,
                    iconColor: AppColors.forestDark,
                    backgroundColor: AppColors.harvestAmberLight,
                    title: '🩺 फसल डॉक्टर (Crop Doctor)',
                    onTap: () => CropDoctorModal.show(context),
                  ),
                  const SizedBox(width: 8),

                  // Dosage Calculator
                  _buildActionPill(
                    icon: Icons.calculate_outlined,
                    iconColor: Colors.white,
                    backgroundColor: AppColors.primaryGreen,
                    title: '🧮 दवा कैलकुलेटर (Dosage Calc)',
                    onTap: () => DosageCalculatorModal.show(context),
                  ),
                  const SizedBox(width: 8),

                  // Mandi Bhav
                  _buildActionPill(
                    icon: Icons.trending_up_rounded,
                    iconColor: Colors.white,
                    backgroundColor: const Color(0xFF0D9488),
                    title: '📈 दैनिक मंडी भाव (Mandi Rates)',
                    onTap: () => MandiBhavModal.show(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
