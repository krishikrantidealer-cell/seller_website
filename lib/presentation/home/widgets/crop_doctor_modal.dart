import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/catalog/catalog_bloc.dart';
import '../../../logic/catalog/catalog_event.dart';

class CropProblem {
  final String pestName;
  final String hindiPestName;
  final String symptoms;
  final String recommendedTechnical;
  final String dosageGuide;
  final String targetSearchQuery;

  const CropProblem({
    required this.pestName,
    required this.hindiPestName,
    required this.symptoms,
    required this.recommendedTechnical,
    required this.dosageGuide,
    required this.targetSearchQuery,
  });
}

class CropOption {
  final String name;
  final String hindiName;
  final IconData icon;
  final List<CropProblem> problems;

  const CropOption({
    required this.name,
    required this.hindiName,
    required this.icon,
    required this.problems,
  });
}

class CropDoctorModal extends StatefulWidget {
  const CropDoctorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CatalogBloc>(),
        child: const CropDoctorModal(),
      ),
    );
  }

  @override
  State<CropDoctorModal> createState() => _CropDoctorModalState();
}

class _CropDoctorModalState extends State<CropDoctorModal> {
  static const List<CropOption> _crops = [
    CropOption(
      name: 'Cotton',
      hindiName: 'कपास',
      icon: Icons.spa_outlined,
      problems: [
        CropProblem(
          pestName: 'Pink Bollworm & American Bollworm',
          hindiPestName: 'गुलाबी सुंडी एवं अमेरिकन इल्ली',
          symptoms: 'Flower rosetting, bored squares, damaged bolls and premature drop.',
          recommendedTechnical: 'Chlorantraniliprole 18.5% SC / Emamectin Benzoate 5% SG',
          dosageGuide: '60 ml / Acre (6 ml प्रति 15L पंप)',
          targetSearchQuery: 'Chlorantraniliprole',
        ),
        CropProblem(
          pestName: 'Whitefly & Thrips',
          hindiPestName: 'सफेद मक्खी एवं थ्रिप्स',
          symptoms: 'Curling leaves, honeydew excretion, black sooty mould and leaf reddening.',
          recommendedTechnical: 'Yellow Sticky Traps + Bio-Neem Formulation',
          dosageGuide: '12-15 Sticky Traps / Acre for non-chemical IPM',
          targetSearchQuery: 'Sticky Traps',
        ),
      ],
    ),
    CropOption(
      name: 'Chilli',
      hindiName: 'मिर्च',
      icon: Icons.local_fire_department_outlined,
      problems: [
        CropProblem(
          pestName: 'Leaf Curl & Thrips (Muradiya)',
          hindiPestName: 'मुरड़िया रोग एवं थ्रिप्स',
          symptoms: 'Upward leaf curling, stunted plant height and flower drop.',
          recommendedTechnical: 'Emamectin Benzoate 5% SG + Yellow Sticky Traps',
          dosageGuide: '80 gm / Acre (8 gm प्रति 15L पंप)',
          targetSearchQuery: 'Emamectin Benzoate',
        ),
        CropProblem(
          pestName: 'Fruit Borer (Fal Chedak)',
          hindiPestName: 'फल छेदक इल्ली',
          symptoms: 'Circular holes on green and ripening chilli pods with rotting.',
          recommendedTechnical: 'Chlorantraniliprole 18.5% SC',
          dosageGuide: '60 ml / Acre',
          targetSearchQuery: 'Chlorantraniliprole',
        ),
      ],
    ),
    CropOption(
      name: 'Tomato',
      hindiName: 'टमाटर',
      icon: Icons.circle_outlined,
      problems: [
        CropProblem(
          pestName: 'Early & Late Blight (Jhoolsa)',
          hindiPestName: 'अगेती व पछेती झुलसा रोग',
          symptoms: 'Concentric dark rings on foliage, rapid stem and fruit rot.',
          recommendedTechnical: 'Trichoderma Viride Bio-Fungicide 1.5% WP',
          dosageGuide: '1 kg / Acre as soil application or foliar spray',
          targetSearchQuery: 'Trichoderma Viride',
        ),
        CropProblem(
          pestName: 'Fruit Borer & Pinworm',
          hindiPestName: 'फल छेदक सुंडी',
          symptoms: 'Tunneling holes on unripe fruit and larval presence.',
          recommendedTechnical: 'Chlorantraniliprole 18.5% SC',
          dosageGuide: '60 ml / Acre',
          targetSearchQuery: 'Chlorantraniliprole',
        ),
      ],
    ),
    CropOption(
      name: 'Paddy / Rice',
      hindiName: 'धान',
      icon: Icons.grain_outlined,
      problems: [
        CropProblem(
          pestName: 'Stem Borer & Leaf Folder',
          hindiPestName: 'तना छेदक व पत्ता लपेटक',
          symptoms: 'Dead heart in vegetative stage and white earheads at grain filling.',
          recommendedTechnical: 'Chlorantraniliprole 18.5% SC',
          dosageGuide: '60 ml / Acre in 150L water',
          targetSearchQuery: 'Chlorantraniliprole',
        ),
        CropProblem(
          pestName: 'Khaira Disease (Zinc Deficiency)',
          hindiPestName: 'खैरा रोग (जिंक की कमी)',
          symptoms: 'Rust-colored spots on lower leaves, retarded tillering and stunted growth.',
          recommendedTechnical: 'Chelated Zinc (Zn-EDTA 12%)',
          dosageGuide: '250 gm / Acre foliar spray',
          targetSearchQuery: 'Zinc',
        ),
      ],
    ),
    CropOption(
      name: 'Pulses & Soybean',
      hindiName: 'दलहन व सोयाबीन',
      icon: Icons.eco_outlined,
      problems: [
        CropProblem(
          pestName: 'Fusarium Wilt & Root Rot',
          hindiPestName: 'उकठा रोग व जड़ गलन',
          symptoms: 'Sudden yellowing, wilting and vascular browning of root system.',
          recommendedTechnical: 'Trichoderma Viride Bio-Fungicide',
          dosageGuide: '1-2 kg / Acre (with FYM or seed treatment)',
          targetSearchQuery: 'Trichoderma Viride',
        ),
        CropProblem(
          pestName: 'Girdle Beetle & Pod Borer',
          hindiPestName: 'गर्डल बीटल एवं फली छेदक',
          symptoms: 'Ring-shaped cut on stems leading to drying of top leaves.',
          recommendedTechnical: 'Emamectin Benzoate 5% SG',
          dosageGuide: '80-100 gm / Acre',
          targetSearchQuery: 'Emamectin Benzoate',
        ),
      ],
    ),
  ];

  int _selectedCropIndex = 0;
  int _selectedProblemIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompact = screenWidth < 600;

    final activeCrop = _crops[_selectedCropIndex];
    final activeProblem = activeCrop.problems[_selectedProblemIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24, vertical: isCompact ? 16 : 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: screenHeight * 0.90,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 24, vertical: isCompact ? 12 : 18),
              decoration: const BoxDecoration(
                color: AppColors.forestDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology_alt_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EBS Agri Doctor & Crop Diagnostic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 15 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'फसल डॉक्टर — अपनी फसल चुनें, रोग पहचानें एवं सही वैज्ञानिक दवा पाएं',
                          style: TextStyle(
                            color: AppColors.harvestAmberLight,
                            fontSize: isCompact ? 10.5 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1: Select Crop
                    const Text(
                      '1. Select Your Crop / अपनी फसल चुनें:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_crops.length, (index) {
                        final crop = _crops[index];
                        final isSelected = index == _selectedCropIndex;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCropIndex = index;
                              _selectedProblemIndex = 0;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryGreen : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryGreen : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  crop.icon,
                                  size: 18,
                                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${crop.name} (${crop.hindiName})',
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    // Step 2: Select Pest / Disease
                    const Text(
                      '2. Identified Pest or Disease / दिखने वाले लक्षण या कीट:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(activeCrop.problems.length, (pIndex) {
                        final problem = activeCrop.problems[pIndex];
                        final isProblemSelected = pIndex == _selectedProblemIndex;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isProblemSelected ? AppColors.paleGreen : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isProblemSelected ? AppColors.primaryGreen : AppColors.border,
                              width: isProblemSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isProblemSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isProblemSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                            ),
                            onTap: () {
                              setState(() => _selectedProblemIndex = pIndex);
                            },
                            title: Text(
                              '${problem.pestName} (${problem.hindiPestName})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'लक्षण (Symptoms): ${problem.symptoms}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Step 3: Prescribed Formulation Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.leafAccent.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Recommended Scientific Formulation / अनुशंसित समाधान:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            activeProblem.recommendedTechnical,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.speed_rounded, size: 15, color: AppColors.harvestAmber),
                              const SizedBox(width: 6),
                              Text(
                                'Dosage (मात्रा): ${activeProblem.dosageGuide}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.harvestAmber),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: isCompact ? double.infinity : null,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<CatalogBloc>().add(SearchTechnicalOrBrand(activeProblem.targetSearchQuery));
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.shopping_basket_outlined, size: 18),
                              label: Text(
                                isCompact
                                    ? 'View Products (स्टोर में देखें)'
                                    : 'View "${activeProblem.targetSearchQuery}" in Catalog (स्टोर में देखें)',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
