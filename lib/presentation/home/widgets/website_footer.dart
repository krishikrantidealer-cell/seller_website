import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 800;

    return Container(
      color: AppColors.forestDark,
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Grid Columns
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandColumn(),
                    const SizedBox(height: 28),
                    _buildCategoryColumn(),
                    const SizedBox(height: 28),
                    _buildSupportColumn(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildBrandColumn()),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildCategoryColumn()),
                    const SizedBox(width: 32),
                    Expanded(flex: 3, child: _buildSupportColumn()),
                  ],
                ),

              const SizedBox(height: 36),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 20),

              // Compliance & Copyright
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '© ${DateTime.now().year} EBS Essential Bio Crop Science Tradelink Pvt. Ltd. All rights reserved. Compliant with Insecticides Act 1968, Fertilizer (Control) Order 1985 & Legal Metrology Act.',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Made with 💚 for Indian Farmers',
                    style: TextStyle(color: Color(0xFF86EFAC), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              AppConstants.logoPath,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EBS BioCrop Science',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  'Essential Bio Crop Science',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.harvestAmberLight),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Pioneering direct manufacturer agricultural input e-commerce across India. Providing 100% genuine biological and chemical solutions, technical formulation transparency, and unbiased agronomy support.',
          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCategoryColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Categories',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        _FooterLink('Crop Protection (Insecticides & Fungicides)'),
        _FooterLink('Plant Nutrition & NPK Solubles'),
        _FooterLink('Biological & Organic Inputs'),
        _FooterLink('Plant Growth Regulators (PGR)'),
        _FooterLink('Battery Sprayers & Farm Machinery'),
        _FooterLink('Pheromone Pest Traps & IPM'),
      ],
    );
  }

  Widget _buildSupportColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farmer Helpline & Agronomy Support',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.harvestAmberLight),
            const SizedBox(width: 8),
            Text(
              'Toll Free: ${AppConstants.tollFreeNumber}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF4ADE80)),
            const SizedBox(width: 8),
            Text(
              'WhatsApp: ${AppConstants.whatsappSupport}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.email_outlined, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              AppConstants.supportEmail,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }
}
