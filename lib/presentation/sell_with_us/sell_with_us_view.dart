import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/web_footer.dart';
import '../be_a_partner/be_a_partner_view.dart';

class SellWithUsView extends StatefulWidget {
  const SellWithUsView({super.key});

  @override
  State<SellWithUsView> createState() => _SellWithUsViewState();
}

class _SellWithUsViewState extends State<SellWithUsView> {
  final _scrollController = ScrollController();
  final Set<int> _expandedFaqIndices = {0};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean?text=Hello%20EBS,%20I%20want%20to%20register%20as%20a%20seller');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Seller%20Partnership%20Inquiry%20-%20EBS');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Sticky Top Info Bar & Navigation Header
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TopInfoBar(),
                MainNavHeader(),
              ],
            ),
          ),

          // Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Breadcrumb
                  _buildBreadcrumb(context, isMobile),

                  // Hero Banner
                  _buildHeroBanner(context, isMobile),

                  // Key Benefits (Why Sell with Us)
                  _buildWhySellSection(isMobile),

                  // How to Sell (4-Step Process)
                  _buildHowItWorksSection(isMobile),

                  // Guarantee Banner
                  _buildGuaranteeBanner(isMobile),

                  // Partner CTA Section
                  _buildPartnerCtaSection(context, isMobile),

                  // 24x7 Seller Support Card
                  _buildSupportSection(isMobile),

                  // FAQs Section
                  _buildFaqSection(isMobile),

                  const SizedBox(height: 48),

                  // Web Footer
                  const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 15, color: AppColors.primaryGreen),
                      const SizedBox(width: 5),
                      Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Home',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Sell with Us',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3E17), Color(0xFF1E5B29), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 36,
        vertical: isMobile ? 36 : 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF86EFAC), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'EBS DIRECT SELLER & PARTNER NETWORK',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 10.5 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Grow Your Agri Business Across India',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 26 : 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Text(
                  'Reach lakhs of active farmers, dealers, and FPOs across India. List your pesticides, fertilizers, bio-stimulants, and seeds with zero upfront listing costs.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 13 : 16.5,
                    color: const Color(0xFFE2E8F0),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // CTA Buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BeAPartnerView()),
                      );
                    },
                    icon: const Icon(Icons.handshake_rounded, size: 20),
                    label: Text(
                      'Be a Partner',
                      style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF166534),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(AppConstants.helplineNumber),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 19, color: Colors.white),
                    label: Text(
                      'Seller Support: ${AppConstants.helplineNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Quick Metrics
              Wrap(
                alignment: WrapAlignment.center,
                spacing: isMobile ? 12 : 28,
                runSpacing: 12,
                children: [
                  _buildMetricBadge(Icons.groups_rounded, 'Lakhs of Growers', 'Pan-India Farmer Base'),
                  _buildMetricBadge(Icons.local_shipping_outlined, 'Fast Logistics', 'Doorstep Hub Pickup'),
                  _buildMetricBadge(Icons.money_off_rounded, '₹0 Upfront Cost', 'Pay Only When You Sell'),
                  _buildMetricBadge(Icons.account_balance_wallet_outlined, 'Direct Bank Payouts', '10-12 Working Days'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBadge(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF86EFAC), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhySellSection(bool isMobile) {
    final benefits = [
      (
        icon: Icons.public_rounded,
        title: 'Lakhs of Farmer Customers',
        desc: 'Direct access to progressive farmers, commercial growers, FPOs, and village agri-dealers across 28+ states.',
        color: const Color(0xFF16A34A),
      ),
      (
        icon: Icons.payments_outlined,
        title: 'No Fixed Costs. Pay When You Sell',
        desc: 'Zero listing charges, zero recurring monthly subscription. You only pay nominal transaction fees on confirmed orders.',
        color: const Color(0xFF0284C7),
      ),
      (
        icon: Icons.local_shipping_outlined,
        title: 'Easy and Fast Shipping',
        desc: 'EBS logistics network arranges seamless doorstep pickup from your warehouse and ensures safe pan-India delivery.',
        color: const Color(0xFFD97706),
      ),
      (
        icon: Icons.account_balance_outlined,
        title: 'Secure & Timely Payments',
        desc: 'Payments are directly deposited into your verified bank account within 10-12 business days following successful delivery.',
        color: const Color(0xFF7C3AED),
      ),
      (
        icon: Icons.campaign_outlined,
        title: 'Brand Marketing & Advisory Support',
        desc: 'Complimentary digital promotion, crop advisory campaigns, and technical product recommendation to our grower community.',
        color: const Color(0xFFDC2626),
      ),
      (
        icon: Icons.support_agent_rounded,
        title: 'Dedicated 24x7 Seller Support',
        desc: 'Personalized onboarding, catalog management assistance, and quick resolution via phone (+91 9098544263) and WhatsApp.',
        color: const Color(0xFF059669),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Text(
                'WHY SELL ON EBS BIOCROP?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Built to Supercharge Your Agri-Business',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 22 : 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 650
                      ? 1
                      : (constraints.maxWidth < 1050 ? 2 : 3);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      mainAxisExtent: isMobile ? 180 : 190,
                    ),
                    itemCount: benefits.length,
                    itemBuilder: (context, index) {
                      final item = benefits[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon, color: item.color, size: 24),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                item.desc,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isMobile) {
    final steps = [
      (
        step: '1',
        title: 'Set-up your Seller Account',
        desc: 'Provide your business details, contact information, bank account details, and GST/PAN information.',
        icon: Icons.person_add_alt_1_rounded,
      ),
      (
        step: '2',
        title: 'List Your Products',
        desc: 'Provide description, pack sizes, MRP, and formulation specs. Farmers use this information to buy with confidence.',
        icon: Icons.playlist_add_check_rounded,
      ),
      (
        step: '3',
        title: 'Ship Orders',
        desc: 'Once a buyer orders your product, pack it safely. You can use EBS delivery services for hassle-free doorstep pickup.',
        icon: Icons.local_shipping_rounded,
      ),
      (
        step: '4',
        title: 'Get Paid on Time',
        desc: 'Your payment is directly deposited into your bank account within 10-12 working days with full accounting transparency.',
        icon: Icons.currency_rupee_rounded,
      ),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Text(
                'SIMPLE 4-STEP PROCESS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How to Sell on Essential BioCrop Science',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 22 : 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  if (isNarrow) {
                    return Column(
                      children: steps.map((s) => _buildStepCard(s, isMobile: true)).toList(),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: steps.map((s) => Expanded(child: _buildStepCard(s, isMobile: false))).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(({String desc, IconData icon, String step, String title}) s, {required bool isMobile}) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 8 : 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF166534),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  s.step,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(s.icon, color: AppColors.primaryGreen, size: 28),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            s.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.desc,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F3E17),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'WHAT WE GUARANTEE FOR EVERY SELLER',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF86EFAC),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Be Smart, Relax and Sell with Essential BioCrop Science',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildGuaranteeChip('High Increase in Your Sales'),
                  _buildGuaranteeChip('Better Profit Margins'),
                  _buildGuaranteeChip('Pay Only When You Sell'),
                  _buildGuaranteeChip('Hassle-Free Timely Payments'),
                  _buildGuaranteeChip('Aggressive Marketing of Your Products'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuaranteeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF86EFAC), size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCtaSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 36, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF15803D), Color(0xFF166534)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF166534).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  'Ready to Partner with Us?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 22 : 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    "Join India's fast-growing agricultural network. Fill up our partner form and our top management and commerce department will contact you directly.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 13 : 15.5,
                      color: const Color(0xFFDCFCE7),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BeAPartnerView()),
                        );
                      },
                      icon: const Icon(Icons.description_rounded, size: 19),
                      label: Text(
                        'Be a Partner',
                        style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF166534),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(AppConstants.helplineNumber),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 19, color: Colors.white),
                      label: Text(
                        'Call: ${AppConstants.helplineNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportSection(bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36, vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              children: [
                Text(
                  '24x7 DEDICATED SELLER SUPPORT',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Have Questions About Partnering With Us?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our Seller Helpdesk is ready to assist you with registration, logistics, and account verification.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(AppConstants.helplineNumber),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: Text(
                        AppConstants.helplineNumber,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(AppConstants.helplineNumber),
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: Text(
                        'WhatsApp: ${AppConstants.helplineNumber}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _sendEmail('sales@ebsbiocrop.com'),
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: Text(
                        'sales@ebsbiocrop.com',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF166534)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF166534)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      (
        q: 'How much does it cost to register and sell on Essential BioCrop Science?',
        a: 'Registration and product catalog listing on EBS are 100% FREE. There are no upfront fees, setup costs, or monthly subscriptions. You only pay a small standard service fee when your products are successfully sold.',
      ),
      (
        q: 'Who manages shipping and customer order fulfillment?',
        a: 'EBS logistics partners handle doorstep pickup directly from your registered manufacturing plant, warehouse, or store. Once picked up, our pan-India logistics network safely delivers the parcel to the farmer or agro-dealer.',
      ),
      (
        q: 'When and how do I receive payments for my sales?',
        a: 'Payments are directly transferred into your verified bank account via NEFT/RTGS within 10 to 12 working days after the order has been delivered to the customer, along with complete invoice reconciliation reports.',
      ),
      (
        q: 'What documents are required to begin selling as a vendor?',
        a: 'To start selling, you need: (1) A valid Business PAN Card, (2) GST Registration Certificate (if applicable for your product categories), (3) Active Bank Account details / Cancelled Cheque for payout processing, and (4) Product manufacturing or dealer license.',
      ),
      (
        q: 'Can I sell across all Indian states or only locally?',
        a: 'You can sell across all 28 states and Union Territories in India. Our courier network covers over 20,000 pin codes nationwide.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything You Need to Know About Selling',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              for (int i = 0; i < faqs.length; i++) ...[
                _buildFaqItem(i, faqs[i].q, faqs[i].a),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer) {
    final isExpanded = _expandedFaqIndices.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.primaryGreen.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? 0.03 : 0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedFaqIndices.remove(index);
                } else {
                  _expandedFaqIndices.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isExpanded ? const Color(0xFF166534) : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? AppColors.primaryGreen : AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
