import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../logic/catalog/catalog_bloc.dart';
import '../../../logic/catalog/catalog_event.dart';
import '../../../logic/catalog/catalog_state.dart';
import 'crop_doctor_modal.dart';
import 'dosage_calculator_modal.dart';
import 'mandi_bhav_modal.dart';

class FarmerDrawer extends StatelessWidget {
  const FarmerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.forestDark,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppConstants.logoPath,
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.eco_rounded,
                      size: 36,
                      color: AppColors.harvestAmberLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EBS BioCrop Science',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Essential Bio Crop Science',
                          style: TextStyle(
                            color: AppColors.harvestAmberLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // Advisory Tools Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'FARMER ADVISORY TOOLS (किसान सेवाएं)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.psychology_alt_outlined, color: AppColors.primaryGreen),
                    title: const Text('Crop Doctor (फसल डॉक्टर)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Identify pest & disease symptoms', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      CropDoctorModal.show(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calculate_outlined, color: AppColors.harvestAmber),
                    title: const Text('Dosage Calculator (दवा कैलकुलेटर)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Calculate spray tank & water quantity', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      DosageCalculatorModal.show(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.trending_up_rounded, color: Color(0xFF0D9488)),
                    title: const Text('APMC Mandi Bhav (दैनिक मंडी भाव)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: const Text('Real-time commodity market rates', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      MandiBhavModal.show(context);
                    },
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  // Categories Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'PRODUCT CATEGORIES (उत्पाद श्रेणियां)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  BlocBuilder<CatalogBloc, CatalogState>(
                    builder: (context, state) {
                      return Column(
                        children: state.categories.map((CategoryModel cat) {
                          final isSelected = cat.id == state.selectedCategoryId;
                          return ListTile(
                            leading: Icon(cat.icon, color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary, size: 20),
                            title: Text(
                              '${cat.name} (${cat.hindiName})',
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                                color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.paleGreen : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${cat.count}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            onTap: () {
                              context.read<CatalogBloc>().add(SelectCategory(cat.id));
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  // Helpline Support Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.leafAccent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'किसान हेल्पलाइन (Toll Free)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.forestDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            AppConstants.tollFreeNumber,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.brandRed),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Free advisory by expert agronomists Mon-Sat 8AM - 8PM',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
