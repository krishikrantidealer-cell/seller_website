import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback? onExploreDeals;
  final VoidCallback? onCallAgronomist;

  const HeroBanner({
    super.key,
    this.onExploreDeals,
    this.onCallAgronomist,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 992;
    final isMobile = screenWidth < 640;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isCompact ? 22 : 32),
              vertical: isMobile ? 16 : 22,
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
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.harvestAmber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Kisan Vishwas • 100% Genuine Agri-Inputs (असली उत्पाद)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Direct Manufacturer Sourcing for Crop Science & Nutrition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 18 : (isCompact ? 22 : 26),
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search by Technical Formulation (Active Ingredients) with Free Doorstep Delivery across 50,000+ PIN codes.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: isMobile ? 12 : 13.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: onExploreDeals,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandRed,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 22,
                                vertical: isMobile ? 11 : 13,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                            label: const Text(
                              'Explore Products (उत्पाद देखें) ↓',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: onCallAgronomist,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70, width: 1.2),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 18,
                                vertical: isMobile ? 11 : 13,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.call_outlined, size: 16),
                            label: const Text(
                              'Helpline: 1800-203-1425',
                              style: TextStyle(fontSize: 12.5),
                            ),
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppColors.harvestAmberLight, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'EBS BioCrop Science Trust Promise',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 16),
                          _buildPromiseItem(Icons.verified_outlined, '100% Genuine with Official GST Bill'),
                          _buildPromiseItem(Icons.local_shipping_outlined, 'Zero Shipping Fees: Free Doorstep Delivery'),
                          _buildPromiseItem(Icons.payments_outlined, 'Cash on Delivery (COD) Available'),
                          _buildPromiseItem(Icons.spa_outlined, 'Eco-Friendly Bio & Organic Certified Formulations'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF86EFAC), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
