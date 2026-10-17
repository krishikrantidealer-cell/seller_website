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
  static const int _initialPage = 3000;
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  final List<BannerData> _banners = [
    const BannerData(
      title: 'EBS Essential BioCrop Nutrition & Protection',
      subtitle: 'Up to 40% OFF on Certified Bio-Fertilizers & Crop Care Essentials',
      tag: 'EBS SPECIAL OFFER',
      buttonText: 'Shop BioCrop Essentials',
      gradient: [Color(0xFF2F7D32), Color(0xFF1B5E20)],
      icon: Icons.agriculture_rounded,
    ),
    const BannerData(
      title: 'Guaranteed Authentic Agricultural Inputs',
      subtitle: 'Direct from EBS Essential BioCrop Science Labs with Nationwide Delivery',
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
    _pageController = PageController(initialPage: _initialPage);
    _currentIndex = _initialPage % _banners.length;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
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
        final isTablet = constraints.maxWidth < 950;
        final bannerHeight = isMobile
            ? 210.0
            : isTablet
                ? 270.0
                : 340.0;

        return SizedBox(
          width: double.infinity,
          height: bannerHeight,
          child: Stack(
            children: [
              // Full-width edge-to-edge PageView with continuous infinite looping
              PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) {
                  final realIndex = (idx % _banners.length + _banners.length) % _banners.length;
                  if (_currentIndex != realIndex) {
                    setState(() => _currentIndex = realIndex);
                  }
                },
                itemBuilder: (context, index) {
                  final realIndex = (index % _banners.length + _banners.length) % _banners.length;
                  final banner = _banners[realIndex];
                  return _buildBannerCard(banner, isMobile: isMobile, isTablet: isTablet);
                },
              ),

              // Left Chevron (Desktop / Tablet)
              if (!isMobile)
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.88),
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),

              // Right Chevron (Desktop / Tablet)
              if (!isMobile)
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.88),
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom Overlay Dots Pagination
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners.length,
                    (index) {
                      final isSelected = _currentIndex == index;
                      return GestureDetector(
                        onTap: () {
                          if (_pageController.hasClients) {
                            final currentVirtual = _pageController.page?.round() ?? _initialPage;
                            final currentReal = (currentVirtual % _banners.length + _banners.length) % _banners.length;
                            final diff = index - currentReal;
                            _pageController.animateToPage(
                              currentVirtual + diff,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 26 : 8,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerCard(BannerData banner, {bool isMobile = false, bool isTablet = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Subtle background decorative circles for visual depth
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Main Centered Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : (isTablet ? 36 : 64),
                  vertical: isMobile ? 18 : 28,
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
                              vertical: isMobile ? 3 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
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
                              fontSize: isMobile ? 17 : (isTablet ? 22 : 30),
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isMobile ? 4 : 8),
                          Text(
                            banner.subtitle,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: isMobile ? 11 : (isTablet ? 13 : 15),
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
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 26,
                                vertical: isMobile ? 9 : 14,
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
                      SizedBox(width: isTablet ? 24 : 48),
                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          banner.icon,
                          size: isTablet ? 64 : 96,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
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
