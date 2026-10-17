import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MandiCommodity {
  final String crop;
  final String hindiCrop;
  final String mandi;
  final String state;
  final int minPrice;
  final int maxPrice;
  final int modalPrice;
  final int change;

  const MandiCommodity({
    required this.crop,
    required this.hindiCrop,
    required this.mandi,
    required this.state,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.change,
  });
}

class MandiBhavModal extends StatelessWidget {
  const MandiBhavModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const MandiBhavModal(),
    );
  }

  static const List<MandiCommodity> _rates = [
    MandiCommodity(
      crop: 'Cotton (Medium Staple)',
      hindiCrop: 'कपास (शंकर-6)',
      mandi: 'Rajkot APMC',
      state: 'Gujarat',
      minPrice: 6800,
      maxPrice: 7420,
      modalPrice: 7250,
      change: 120,
    ),
    MandiCommodity(
      crop: 'Soybean (Yellow)',
      hindiCrop: 'सोयाबीन (पीला)',
      mandi: 'Indore APMC',
      state: 'Madhya Pradesh',
      minPrice: 4400,
      maxPrice: 4850,
      modalPrice: 4680,
      change: 45,
    ),
    MandiCommodity(
      crop: 'Wheat (Mill Quality)',
      hindiCrop: 'गेहूँ (मिल क्वालिटी)',
      mandi: 'Khanna APMC',
      state: 'Punjab',
      minPrice: 2350,
      maxPrice: 2480,
      modalPrice: 2420,
      change: 15,
    ),
    MandiCommodity(
      crop: 'Mustard / Rapeseed',
      hindiCrop: 'सरसों (रायड़ा)',
      mandi: 'Jaipur APMC',
      state: 'Rajasthan',
      minPrice: 5100,
      maxPrice: 5500,
      modalPrice: 5350,
      change: 80,
    ),
    MandiCommodity(
      crop: 'Red Chilli (Teja)',
      hindiCrop: 'लाल मिर्च (तेजा)',
      mandi: 'Guntur APMC',
      state: 'Andhra Pradesh',
      minPrice: 14500,
      maxPrice: 18200,
      modalPrice: 16500,
      change: 350,
    ),
    MandiCommodity(
      crop: 'Chana / Desi Chickpea',
      hindiCrop: 'चना (देसी)',
      mandi: 'Akola APMC',
      state: 'Maharashtra',
      minPrice: 5500,
      maxPrice: 6100,
      modalPrice: 5850,
      change: 60,
    ),
    MandiCommodity(
      crop: 'Paddy (Basmati 1509)',
      hindiCrop: 'धान (बासमती 1509)',
      mandi: 'Karnal APMC',
      state: 'Haryana',
      minPrice: 3200,
      maxPrice: 3650,
      modalPrice: 3480,
      change: -40,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 16 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 780,
          maxHeight: size.height * 0.90,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 24,
                vertical: isCompact ? 12 : 16,
              ),
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
                    child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily APMC Mandi Bhav (दैनिक मंडी भाव)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 15 : 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'प्रमुख कृषि उपज मंडी समितियों (APMC) के ताजा व आधिकारिक दैनिक भाव',
                          style: TextStyle(
                            color: AppColors.harvestAmberLight,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

            // Live Update Badge
            Container(
              color: AppColors.paleGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live Updates: भाव प्रति क्विंटल (₹ / Quintal)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.forestDark),
                  ),
                  const Spacer(),
                  const Text(
                    'आज का बाजार (Today)',
                    style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _rates.length,
                separatorBuilder: (_, _) => const Divider(height: 16, color: AppColors.border),
                itemBuilder: (context, index) {
                  final item = _rates[index];
                  final isPositive = item.change >= 0;

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.crop} (${item.hindiCrop})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.mandi}, ${item.state}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${item.modalPrice}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestDark,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                                color: isPositive ? Colors.green : Colors.red,
                                size: 18,
                              ),
                              Text(
                                '${isPositive ? "+" : ""}₹${item.change}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPositive ? Colors.green : Colors.red,
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

            // Footer Assistance
            Container(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'कृषि विशेषज्ञ सलाह: 1800-203-1425',
                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.phone, size: 14),
                          label: const Text('Call Helpline (टोल फ्री)', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'मंडी व फसल से जुड़ी सलाह हेतु हमारे कृषि विशेषज्ञ से संपर्क करें: 1800-203-1425',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.phone, size: 14),
                          label: const Text('Call Helpline', style: TextStyle(fontSize: 12)),
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
