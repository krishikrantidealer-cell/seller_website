import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../category/category_detail_view.dart';
import '../wishlist/wishlist_view.dart';
import '../orders/my_orders_view.dart';
import '../sell_with_us/sell_with_us_view.dart';
import '../be_a_partner/be_a_partner_view.dart';
import '../technical/technical_search_view.dart';
import 'floating_whatsapp_button.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  static const Color _borderHairline = Color(0xFF2D2A28);
  static const Color _mutedText = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.footerBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: isMobile ? 24 : 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrustBadgesSection(context),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 28),
                  child: const Divider(color: _borderHairline, height: 1),
                ),

                // Main Footer Columns (Desktop 4-col, Tablet 2x2, Mobile Brand + 2-col links + Support)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    if (w >= 960) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _brandColumn(context)),
                          const SizedBox(width: 40),
                          Expanded(flex: 2, child: _categoriesColumn(context)),
                          const SizedBox(width: 32),
                          Expanded(flex: 2, child: _quickLinksColumn(context)),
                          const SizedBox(width: 40),
                          Expanded(flex: 3, child: _supportColumn(context)),
                        ],
                      );
                    }
                    if (w >= 600) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _brandColumn(context)),
                              const SizedBox(width: 32),
                              Expanded(child: _supportColumn(context)),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Divider(color: _borderHairline, height: 1),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _categoriesColumn(context)),
                              const SizedBox(width: 32),
                              Expanded(child: _quickLinksColumn(context)),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _brandColumn(context),
                        const SizedBox(height: 24),
                        const Divider(color: _borderHairline, height: 1),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _categoriesColumn(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _quickLinksColumn(context)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: _borderHairline, height: 1),
                        const SizedBox(height: 20),
                        _supportColumn(context),
                      ],
                    );
                  },
                ),

                Padding(
                  padding: EdgeInsets.only(
                    top: isMobile ? 24 : 36,
                    bottom: isMobile ? 16 : 20,
                  ),
                  child: const Divider(color: _borderHairline, height: 1),
                ),

                _buildBottomLegalRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Minimal horizontal trust strip (no heavy card boxes)
  Widget _buildTrustBadgesSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final badges = [
          const _TrustBadgeItem(
            icon: Icons.verified_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: Colors.transparent,
            title: 'Guaranteed Authentic Value',
            subtitle: 'Direct from ${AppConstants.appName}',
          ),
          const _TrustBadgeItem(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: Colors.transparent,
            title: 'FREE Pan-India Shipping',
            subtitle: 'Reliable doorstep parcel dispatch',
          ),
          const _TrustBadgeItem(
            icon: Icons.science_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: Colors.transparent,
            title: 'CERTIFIED Lab Quality',
            subtitle: '100% genuine agri-inputs verified',
          ),
          const _TrustBadgeItem(
            icon: Icons.support_agent_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: Colors.transparent,
            title: 'EASY Returns & Advisory',
            subtitle: 'Agronomist consultation included',
          ),
        ];

        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (int i = 0; i < badges.length; i++) ...[
                if (i > 0)
                  const Divider(color: _borderHairline, height: 16),
                _buildBadgeItem(badges[i]),
              ],
            ],
          );
        }

        if (constraints.maxWidth < 1024) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBadgeItem(badges[0])),
                  const SizedBox(width: 20),
                  Expanded(child: _buildBadgeItem(badges[1])),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBadgeItem(badges[2])),
                  const SizedBox(width: 20),
                  Expanded(child: _buildBadgeItem(badges[3])),
                ],
              ),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < badges.length; i++) ...[
                if (i > 0)
                  const VerticalDivider(
                    color: _borderHairline,
                    width: 28,
                    thickness: 1,
                  ),
                Expanded(child: _buildBadgeItem(badges[i])),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeItem(_TrustBadgeItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(item.icon, color: item.iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: GoogleFonts.mukta(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.subtitle,
                style: GoogleFonts.mukta(
                  fontSize: 11.5,
                  color: _mutedText,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLegalRow(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 10,
        children: [
          Text(
            '© 2026 ${AppConstants.appName}. All rights reserved.',
            style: GoogleFonts.mukta(color: _mutedText, fontSize: 12),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 6,
            children: [
              _footerLink(
                'Privacy Policy',
                onTap: () => _showPolicyDialog(
                  context,
                  'Privacy Policy',
                  'At ${AppConstants.appName}, we prioritize customer confidentiality. We only collect essential contact, shipping, and order details necessary to fulfill agricultural product deliveries. Your personal information is never sold or shared with unauthorized third parties. All online payments are encrypted through PCI-DSS compliant secure gateways.',
                ),
              ),
              _footerLink(
                'Terms & Conditions',
                onTap: () => _showPolicyDialog(
                  context,
                  'Terms & Conditions',
                  'All agricultural inputs, seeds, bio-fertilizers, and crop protection products listed on ${AppConstants.appName} are 100% genuine and verified. Recommendations, dosages, and application methods provided on this site are for general guidance; farmers are advised to adhere to product packaging instructions according to local soil and crop conditions.',
                ),
              ),
              _footerLink(
                'Refund & Cancellation',
                onTap: () => _showPolicyDialog(
                  context,
                  'Refund & Cancellation Policy',
                  'We ensure complete peace of mind with our 7-day Easy Replacement & Refund guarantee for damaged, leaked, or incorrect shipments. Orders can be cancelled prior to warehouse dispatch through My Orders or by contacting our Farmer Support Helpline at ${AppConstants.helplineNumber}.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/images/ebs_logo.svg',
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 22),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'EBS ',
                          style: GoogleFonts.mukta(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryCrimson,
                          ),
                        ),
                        TextSpan(
                          text: 'Krishi Dukaan',
                          style: GoogleFonts.mukta(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Science-backed crop nutrition, certified organic inputs, and genuine agricultural supplies delivered across India.',
          style: GoogleFonts.mukta(
            color: _mutedText,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Connect With Us:',
          style: GoogleFonts.mukta(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildSocialMediaRow(context),
      ],
    );
  }

  Widget _categoriesColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Categories'),
        _footerLink(
          'Insecticides & Pesticides',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryDetailView(
                  initialCategoryId: 'crop-protection',
                  initialSubcategory: 'Insecticides',
                ),
              ),
            );
          },
        ),
        _footerLink(
          'Bio & Organic Fertilizers',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryDetailView(
                  initialCategoryId: 'fertilizers',
                  initialSubcategory: 'Bio Fertilizers',
                ),
              ),
            );
          },
        ),
        _footerLink(
          'Certified Hybrid Seeds',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryDetailView(
                  initialCategoryId: 'seeds',
                ),
              ),
            );
          },
        ),
        _footerLink(
          'Fungicides & Bactericides',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryDetailView(
                  initialCategoryId: 'crop-protection',
                  initialSubcategory: 'Fungicides',
                ),
              ),
            );
          },
        ),
        _footerLink(
          'Agricultural Sprayers',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryDetailView(
                  initialCategoryId: 'equipments',
                  initialSubcategory: 'Sprayers & Pumps',
                ),
              ),
            );
          },
        ),
        _footerLink(
          'Drip Irrigation Equipment',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryDetailView(
                  initialCategoryId: 'irrigation',
                  initialSubcategory: 'Drip Lateral & Emitters',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _quickLinksColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Quick Links'),
        _footerLink(
          'My Saved Wishlist',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistView()),
            );
          },
        ),
        _footerLink(
          'Track Your Order',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersView()),
            );
          },
        ),
        _footerLink(
          'About EBS Essential BioCrop Science',
          onTap: () => _showPolicyDialog(
            context,
            'About EBS Essential BioCrop Science',
            'EBS Essential BioCrop Science is dedicated to pioneering agricultural biotechnology, high-yield crop nutrition, certified organic inputs, and verified hybrid seeds for farmers across India. With scientific rigor and farmer-first values, we deliver lab-certified solutions directly to your farm.',
          ),
        ),
        _footerLink(
          'Be a Partner',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BeAPartnerView()),
            );
          },
        ),
        _footerLink(
          'Sell with Us (Seller Hub)',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellWithUsView()),
            );
          },
        ),
        _footerLink(
          'Agronomist Consultation',
          onTap: () async {
            final clean = AppConstants.helplineNumber.replaceAll(RegExp(r'[^0-9]'), '');
            final uri = Uri.parse('https://wa.me/$clean?text=Hello%20EBS%20Agronomist%2C%20I%20need%20expert%20consultation%20for%20my%20crops.');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
        ),
        _footerLink(
          'Research & Formulations',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicalSearchView()),
            );
          },
        ),
      ],
    );
  }

  Widget _supportColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _columnTitle('Farmer & Dealer Support'),
        // Click-to-call Phone Row
        InkWell(
          onTap: () async {
            final clean = AppConstants.helplineNumber.replaceAll(RegExp(r'[^0-9]'), '');
            final uri = Uri.parse('tel:$clean');
            try {
              await launchUrl(uri);
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.phone_outlined, color: AppColors.primaryGreen, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.helplineNumber,
                        style: GoogleFonts.mukta(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Mon – Sat, 9:00 AM – 7:00 PM',
                        style: GoogleFonts.mukta(color: _mutedText, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // WhatsApp Support Row (clean list style matching other contact rows)
        InkWell(
          onTap: () async {
            final clean = AppConstants.helplineNumber.replaceAll(RegExp(r'[^0-9]'), '');
            final uri = Uri.parse(
              'https://wa.me/$clean?text=Hello%20EBS%20Krishi%20Dukaan%2C%20I%20need%20support%20with%20my%20order%20or%20products.',
            );
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomPaint(
                  size: Size(16, 16),
                  painter: WhatsAppIconPainter(color: Color(0xFF25D366)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp Advisory',
                        style: GoogleFonts.mukta(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Quick crop & order support',
                        style: GoogleFonts.mukta(color: _mutedText, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Click-to-email Row
        InkWell(
          onTap: () async {
            final uri = Uri.parse(
              'mailto:${AppConstants.supportEmail}?subject=EBS%20Krishi%20Dukaan%20Inquiry',
            );
            try {
              await launchUrl(uri);
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded, color: _mutedText, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppConstants.supportEmail,
                    style: GoogleFonts.mukta(
                      color: const Color(0xFFD1D5DB),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaRow(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: const [
        SocialIconButton(platform: SocialPlatform.whatsapp),
        SocialIconButton(platform: SocialPlatform.facebook),
        SocialIconButton(platform: SocialPlatform.instagram),
        SocialIconButton(platform: SocialPlatform.youtube),
      ],
    );
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.mukta(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            content,
            style: GoogleFonts.mukta(
              color: const Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.mukta(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _columnTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: GoogleFonts.mukta(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _footerLink(String label, {VoidCallback? onTap}) {
    return _FooterLinkWidget(label: label, onTap: onTap);
  }
}

class _FooterLinkWidget extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _FooterLinkWidget({required this.label, this.onTap});

  @override
  State<_FooterLinkWidget> createState() => _FooterLinkWidgetState();
}

class _FooterLinkWidgetState extends State<_FooterLinkWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: GoogleFonts.mukta(
              color: _isHovered ? Colors.white : const Color(0xFF9CA3AF),
              fontSize: 13,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

enum SocialPlatform {
  whatsapp(
    name: 'WhatsApp',
    tooltip: 'Chat with BioCrop on WhatsApp',
    url: 'https://wa.me/919098544263?text=Hello%20EBS%20BioCrop%20Science%2C%20I%20have%20an%20inquiry%20about%20your%20products.',
    color: Color(0xFF25D366),
  ),
  facebook(
    name: 'Facebook',
    tooltip: 'Follow BioCrop on Facebook',
    url: AppConstants.facebookUrl,
    color: Color(0xFF1877F2),
  ),
  instagram(
    name: 'Instagram',
    tooltip: 'Follow BioCrop on Instagram',
    url: AppConstants.instagramUrl,
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFFFCAF45),
        Color(0xFFF77737),
        Color(0xFFF04B46),
        Color(0xFFDD2A7B),
        Color(0xFF833AB4),
      ],
    ),
  ),
  youtube(
    name: 'YouTube',
    tooltip: 'Subscribe to BioCrop on YouTube',
    url: AppConstants.youtubeUrl,
    color: Color(0xFFFF0000),
  );

  final String name;
  final String tooltip;
  final String url;
  final Color? color;
  final Gradient? gradient;

  const SocialPlatform({
    required this.name,
    required this.tooltip,
    required this.url,
    this.color,
    this.gradient,
  });
}

class SocialIconButton extends StatefulWidget {
  final SocialPlatform platform;
  final VoidCallback? onTap;

  const SocialIconButton({
    super.key,
    required this.platform,
    this.onTap,
  });

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    switch (widget.platform) {
      case SocialPlatform.whatsapp:
        iconWidget = const CustomPaint(
          size: Size(18, 18),
          painter: WhatsAppIconPainter(color: Colors.white),
        );
        break;
      case SocialPlatform.facebook:
        iconWidget = const CustomPaint(
          size: Size(18, 18),
          painter: FacebookLogoPainter(),
        );
        break;
      case SocialPlatform.instagram:
        iconWidget = const CustomPaint(
          size: Size(18, 18),
          painter: InstagramLogoPainter(),
        );
        break;
      case SocialPlatform.youtube:
        iconWidget = const CustomPaint(
          size: Size(18, 18),
          painter: YouTubeLogoPainter(),
        );
        break;
    }

    return Tooltip(
      message: widget.platform.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap ??
              () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Opening ${widget.platform.name}...',
                      style: GoogleFonts.mukta(fontSize: 12.5),
                    ),
                    backgroundColor: AppColors.primaryDarkGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 2),
                  ),
                );
                final uri = Uri.parse(widget.platform.url);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
          child: AnimatedScale(
            scale: _isHovered ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.platform.color,
                gradient: widget.platform.gradient,
                shape: BoxShape.circle,
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: (widget.platform.color ?? const Color(0xFFDD2A7B)).withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        const BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
          ),
        ),
      ),
    );
  }
}

class FacebookLogoPainter extends CustomPainter {
  final Color color;
  const FacebookLogoPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.save();
    canvas.scale(size.width / 24.0, size.height / 24.0);

    final path = Path();
    path.moveTo(14.0, 13.5);
    path.lineTo(16.5, 13.5);
    path.lineTo(17.5, 9.5);
    path.lineTo(14.0, 9.5);
    path.lineTo(14.0, 7.5);
    path.cubicTo(14.0, 6.45, 14.75, 6.0, 15.8, 6.0);
    path.lineTo(17.5, 6.0);
    path.lineTo(17.5, 2.3);
    path.cubicTo(16.8, 2.15, 15.5, 2.0, 13.8, 2.0);
    path.cubicTo(9.9, 2.0, 7.5, 4.35, 7.5, 8.6);
    path.lineTo(7.5, 9.5);
    path.lineTo(5.0, 9.5);
    path.lineTo(5.0, 13.5);
    path.lineTo(7.5, 13.5);
    path.lineTo(7.5, 22.0);
    path.lineTo(14.0, 22.0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InstagramLogoPainter extends CustomPainter {
  final Color color;
  const InstagramLogoPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24.0, size.height / 24.0);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final outerRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.2, 3.2, 17.6, 17.6),
      const Radius.circular(5.2),
    );
    canvas.drawRRect(outerRRect, strokePaint);
    canvas.drawCircle(const Offset(12.0, 12.0), 4.3, strokePaint);
    canvas.drawCircle(const Offset(16.8, 7.2), 1.25, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class YouTubeLogoPainter extends CustomPainter {
  final Color color;
  const YouTubeLogoPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24.0, size.height / 24.0);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(9.5, 7.2);
    path.lineTo(16.8, 12.0);
    path.lineTo(9.5, 16.8);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrustBadgeItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _TrustBadgeItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });
}
