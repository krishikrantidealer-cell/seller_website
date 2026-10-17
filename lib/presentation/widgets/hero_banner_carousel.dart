import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({super.key});

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<BannerData> _banners = [
    const BannerData(
      title: 'EBS BioCrop Nutrition & Protection',
      subtitle: 'Up to 40% OFF on Certified Bio-Fertilizers & Crop Care Essentials',
      tag: 'EBS SPECIAL OFFER',
      buttonText: 'Shop BioCrop Essentials',
      gradient: [Color(0xFF2F7D32), Color(0xFF1B5E20)],
      icon: Icons.agriculture_rounded,
    ),
    const BannerData(
      title: 'Guaranteed Authentic Agricultural Inputs',
      subtitle: 'Direct from EBS BioCrop Science Labs with Nationwide Delivery',
      tag: 'FAST & SECURE DISPATCH',
      buttonText: 'Explore Crop Nutrition',
      gradient: [Color(0xFFA61E22), Color(0xFF801417)],
      icon: Icons.verified_user_rounded,
    ),
    const BannerData(
      title: 'Free Agronomy & Crop Advisory',
      subtitle: 'Personalized soil health, pest management, and dosage advice from science experts',
      tag: 'EXPERT CONSULTATION',
      buttonText: 'Consult Science Experts',
      gradient: [Color(0xFF2F7D32), Color(0xFFA61E22)],
      icon: Icons.support_agent_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final next = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final bannerHeight = isMobile ? 200.0 : 280.0;

        return Container(
          width: double.infinity,
          color: AppColors.warmBackground,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 10 : 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  SizedBox(
                    height: bannerHeight,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (idx) => setState(() => _currentIndex = idx),
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            final banner = _banners[index];
                            return _buildBannerCard(banner, isMobile: isMobile);
                          },
                        ),
                        // Prev/Next Navigation Buttons (Desktop/Tablet)
                        if (!isMobile) ...[
                          Positioned(
                            left: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? (isMobile ? 18 : 24) : 8,
                        height: isMobile ? 6 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? AppColors.primaryGreen : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerCard(BannerData banner, {bool isMobile = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        gradient: LinearGradient(
          colors: banner.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: banner.gradient.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 48,
        vertical: isMobile ? 16 : 36,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    banner.tag,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isMobile ? 9 : 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 12),
                Text(
                  banner.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 17 : 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 4 : 10),
                Text(
                  banner.subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isMobile ? 11 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 10 : 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: banner.gradient.first,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 24,
                      vertical: isMobile ? 8 : 14,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    banner.buttonText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 11 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(banner.icon, size: 96, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

class BannerData {
  final String title;
  final String subtitle;
  final String tag;
  final String buttonText;
  final List<Color> gradient;
  final IconData icon;

  const BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.buttonText,
    required this.gradient,
    required this.icon,
  });
}
