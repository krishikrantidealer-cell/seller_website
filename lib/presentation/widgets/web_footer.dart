import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.footerBackground,
      padding: EdgeInsets.only(
        top: isMobile ? 32 : 48,
        bottom: 24,
        left: isMobile ? 12 : 24,
        right: isMobile ? 12 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top columns
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  if (!isWide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _brandColumn(),
                        const SizedBox(height: 32),
                        _categoriesColumn(),
                        const SizedBox(height: 32),
                        _supportColumn(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _brandColumn()),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _categoriesColumn()),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _quickLinksColumn()),
                      const SizedBox(width: 48),
                      Expanded(flex: 3, child: _supportColumn()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              const Divider(color: Color(0xFF374151), height: 1),
              const SizedBox(height: 24),
              // Bottom Copyright
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '© 2026 EBS BioCrop Science. All rights reserved.',
                    style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _footerLink('Privacy Policy'),
                      _footerLink('Terms & Conditions'),
                      _footerLink('Refund & Cancellation'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'EBS ',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCrimson,
                      ),
                    ),
                    TextSpan(
                      text: 'BioCrop Science',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Pioneering agricultural biotechnology, advanced crop nutrition, certified organic inputs, and science-backed farming solutions delivered nationwide.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '100% Genuine Certified Products',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoriesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Categories'),
        _footerLink('Insecticides & Pesticides'),
        _footerLink('Bio & Organic Fertilizers'),
        _footerLink('Certified Hybrid Seeds'),
        _footerLink('Fungicides & Bactericides'),
        _footerLink('Agricultural Sprayers'),
        _footerLink('Drip Irrigation Equipment'),
      ],
    );
  }

  Widget _quickLinksColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Quick Links'),
        _footerLink('About EBS BioCrop Science'),
        _footerLink('Track Your Order'),
        _footerLink('Seller & Distributor Hub'),
        _footerLink('Agronomist Consultation'),
        _footerLink('Research & Formulations'),
      ],
    );
  }

  Widget _supportColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Farmer & Dealer Support'),
        Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.helplineNumber,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Mon - Sat: 9:00 AM - 7:00 PM',
                  style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Email Support: support@ebsbiocrop.com',
          style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 13),
        ),
      ],
    );
  }

  Widget _columnTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _footerLink(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
