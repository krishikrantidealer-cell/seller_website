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
    final double waterVolume = _sprayMethod == 'battery' ? _acreage * 150 : _acreage * 200;
    final int pumpCount = _sprayMethod == 'battery' ? (_acreage * 10).round() : 0;
    final double dosageAmount = _productType == 'liquid' ? _acreage * 60 : _acreage * 100;
    final String unit = _productType == 'liquid' ? 'ml' : 'gm';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EBS Smart Acreage & Spray Calculator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'खेत व दवा कैलकुलेटर — एकड़ अनुसार सही पानी और दवा की सटीक मात्रा',
                          style: TextStyle(
                            color: AppColors.harvestAmberLight,
                            fontSize: 12,
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
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _sprayMethod = 'battery'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _sprayMethod == 'battery' ? AppColors.paleGreen : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _sprayMethod == 'battery' ? AppColors.primaryGreen : AppColors.border,
                                  width: _sprayMethod == 'battery' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.battery_charging_full_rounded,
                                    color: _sprayMethod == 'battery' ? AppColors.primaryGreen : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('16L Battery Pump', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text('10-12 टंकियां प्रति एकड़', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _sprayMethod = 'tractor'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _sprayMethod == 'tractor' ? AppColors.paleGreen : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _sprayMethod == 'tractor' ? AppColors.primaryGreen : AppColors.border,
                                  width: _sprayMethod == 'tractor' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.agriculture_rounded,
                                    color: _sprayMethod == 'tractor' ? AppColors.primaryGreen : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Tractor Boom Sprayer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text('200 लीटर पानी प्रति एकड़', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Liquid Spray (तरल दवा - ml)'),
                          selected: _productType == 'liquid',
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: _productType == 'liquid' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _productType = 'liquid'),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Powder / Granules (पाउडर/दानेदार - gm)'),
                          selected: _productType == 'powder',
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: _productType == 'powder' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _productType = 'powder'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Computed Results Box
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
                          const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Scientific Calculation Summary (गणना परिणाम):',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.forestDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildResultTile('कुल पानी (Water)', '${waterVolume.toStringAsFixed(0)} Litres'),
                              if (_sprayMethod == 'battery')
                                _buildResultTile('कुल टंकियां (16L Tanks)', '$pumpCount Tanks'),
                              _buildResultTile('दवा की मात्रा (Medicine)', '${dosageAmount.toStringAsFixed(0)} $unit'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '💡 कृषक सुझाव: दवा को पहले 2-3 लीटर पानी में अलग से घोलें (मास्टर घोल), फिर पूरी टंकी में मिलाकर स्प्रे करें।',
                            style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
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

  Widget _buildResultTile(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
      ),
    );
  }
}
