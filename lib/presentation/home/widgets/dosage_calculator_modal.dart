import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DosageCalculatorModal extends StatefulWidget {
  const DosageCalculatorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const DosageCalculatorModal(),
    );
  }

  @override
  State<DosageCalculatorModal> createState() => _DosageCalculatorModalState();
}

class _DosageCalculatorModalState extends State<DosageCalculatorModal> {
  double _acreage = 2.0;
  String _sprayMethod = 'battery'; // 'battery' (16L) or 'tractor' (200L/acre)
  String _productType = 'liquid'; // 'liquid' (ml) or 'powder' (gm)

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompact = screenWidth < 600;

    final double waterVolume = _sprayMethod == 'battery' ? _acreage * 150 : _acreage * 200;
    final int pumpCount = _sprayMethod == 'battery' ? (_acreage * 10).round() : 0;
    final double dosageAmount = _productType == 'liquid' ? _acreage * 60 : _acreage * 100;
    final String unit = _productType == 'liquid' ? 'ml' : 'gm';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24, vertical: isCompact ? 16 : 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: screenHeight * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 24, vertical: isCompact ? 12 : 16),
              decoration: const BoxDecoration(
                color: AppColors.forestDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.harvestAmber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EBS Smart Acreage & Spray Calculator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 15 : 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'खेत व दवा कैलकुलेटर — एकड़ अनुसार सही पानी और दवा की सटीक मात्रा',
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

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field Size
                    const Text(
                      '1. Enter Field Size (कुल जमीन एकड़ में):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _acreage,
                            min: 0.5,
                            max: 15.0,
                            divisions: 29,
                            activeColor: AppColors.primaryGreen,
                            label: '$_acreage Acres',
                            onChanged: (val) => setState(() => _acreage = val),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGreen),
                          ),
                          child: Text(
                            '$_acreage एकड़ (Acres)',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [1.0, 2.0, 3.0, 5.0, 10.0].map((acres) {
                        final isSel = _acreage == acres;
                        return ChoiceChip(
                          label: Text('$acres Acre'),
                          selected: isSel,
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => setState(() => _acreage = acres),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    // Spraying Equipment
                    const Text(
                      '2. Spraying Equipment (छिड़काव का साधन):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Flex(
                      direction: isCompact ? Axis.vertical : Axis.horizontal,
                      children: [
                        _buildEquipmentCard(
                          isCompact: isCompact,
                          title: '16L Battery Pump',
                          subtitle: '10-12 टंकियां प्रति एकड़ (150L)',
                          icon: Icons.battery_charging_full_rounded,
                          isSelected: _sprayMethod == 'battery',
                          onTap: () => setState(() => _sprayMethod = 'battery'),
                        ),
                        SizedBox(width: isCompact ? 0 : 12, height: isCompact ? 8 : 0),
                        _buildEquipmentCard(
                          isCompact: isCompact,
                          title: 'Tractor Boom Sprayer',
                          subtitle: '200 लीटर पानी प्रति एकड़ (Boom)',
                          icon: Icons.agriculture_rounded,
                          isSelected: _sprayMethod == 'tractor',
                          onTap: () => setState(() => _sprayMethod = 'tractor'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    // Formulation Type
                    const Text(
                      '3. Product Formulation Type (दवा का प्रकार):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Liquid Spray (तरल दवा - ml)'),
                          selected: _productType == 'liquid',
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: _productType == 'liquid' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setState(() => _productType = 'liquid'),
                        ),
                        ChoiceChip(
                          label: const Text('Powder / Granules (पाउडर/दानेदार - gm)'),
                          selected: _productType == 'powder',
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: _productType == 'powder' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setState(() => _productType = 'powder'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Computed Results Box
                    Container(
                      padding: EdgeInsets.all(isCompact ? 14 : 18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.leafAccent.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Scientific Calculation Summary (गणना परिणाम):',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.forestDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Flex(
                            direction: isCompact ? Axis.vertical : Axis.horizontal,
                            children: [
                              _buildResultTile('कुल पानी (Water)', '${waterVolume.toStringAsFixed(0)} Litres', isCompact),
                              if (_sprayMethod == 'battery')
                                _buildResultTile('कुल टंकियां (16L Tanks)', '$pumpCount Tanks', isCompact),
                              _buildResultTile('दवा की मात्रा (Medicine)', '${dosageAmount.toStringAsFixed(0)} $unit', isCompact),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '💡 कृषक सुझाव: दवा को पहले 2-3 लीटर पानी में अलग से घोलें (मास्टर घोल), फिर पूरी टंकी में मिलाकर स्प्रे करें।',
                            style: TextStyle(fontSize: 11.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
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

  Widget _buildEquipmentCard({
    required bool isCompact,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return isCompact ? SizedBox(width: double.infinity, child: content) : Expanded(child: content);
  }

  Widget _buildResultTile(String label, String value, bool isCompact) {
    final tile = Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 0 : 4,
        vertical: isCompact ? 4 : 0,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.forestDark)),
        ],
      ),
    );

    return isCompact ? SizedBox(width: double.infinity, child: tile) : Expanded(child: tile);
  }
}
