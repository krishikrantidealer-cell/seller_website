import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 992;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.forestDark,
            AppColors.primaryGreen,
            Color(0xFF2E7D32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 36,
              vertical: isCompact ? 24 : 32,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.harvestAmber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Kisan Vishwas • 100% Genuine Direct Inputs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Direct Manufacturer Sourcing for Crop Science & Nutrition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 20 : 28,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Search by Technical Formulation (Active Chemical & Bio-Ingredients) and compare brands with guaranteed doorstep delivery across 50,000+ PIN codes.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isCompact ? 13 : 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                            ),
                            icon: const Icon(Icons.flash_on_rounded, size: 18),
                            label: const Text('Explore Best Deals'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70, width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            ),
                            icon: const Icon(Icons.call_outlined, size: 18),
                            label: const Text('Call Agronomist 1800-203-1425'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppColors.harvestAmberLight, size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'EBS BioCrop Science Trust Promise',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 20),
                          _buildPromiseItem(Icons.verified_outlined, 'No Counterfeits: 100% Genuine with GST Bill'),
                          _buildPromiseItem(Icons.local_shipping_outlined, 'Zero Shipping Fees: Free Pan-India Delivery'),
                          _buildPromiseItem(Icons.currency_rupee_rounded, 'Advance COD Protection & Lowest Price Guarantee'),
                          _buildPromiseItem(Icons.spa_outlined, 'Residue-Free Organic & Bio-Fungicide Solutions'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromiseItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF86EFAC), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
