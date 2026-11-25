import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/websocket_service.dart';
import '../../core/theme/app_colors.dart';
import 'app_product_image.dart';

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
  StreamSubscription<Map<String, dynamic>>? _bannerWsSub;

  static const List<List<Color>> _fallbackGradients = [
    [Color(0xFF2F7D32), Color(0xFF1B5E20)],
    [Color(0xFFA61E22), Color(0xFF801417)],
    [Color(0xFF2F7D32), Color(0xFFA61E22)],
  ];

  static const List<BannerData> _defaultBanners = [
    BannerData(
      title: 'EBS Essential BioCrop Nutrition & Protection',
      subtitle: 'Up to 40% OFF on Certified Bio-Fertilizers & Crop Care Essentials',
      tag: 'EBS SPECIAL OFFER',
      buttonText: 'Shop BioCrop Essentials',
      gradient: [Color(0xFF2F7D32), Color(0xFF1B5E20)],
      icon: Icons.agriculture_rounded,
    ),
    BannerData(
      title: 'Guaranteed Authentic Agricultural Inputs',
      subtitle: 'Direct from EBS Essential BioCrop Science Labs with Nationwide Delivery',
      tag: 'FAST & SECURE DISPATCH',
      buttonText: 'Explore Crop Nutrition',
      gradient: [Color(0xFFA61E22), Color(0xFF801417)],
      icon: Icons.verified_user_rounded,
    ),
    BannerData(
      title: 'Free Agronomy & Crop Advisory',
      subtitle: 'Personalized soil health, pest management, and dosage advice from science experts',
      tag: 'EXPERT CONSULTATION',
      buttonText: 'Consult Science Experts',
      gradient: [Color(0xFF2F7D32), Color(0xFFA61E22)],
      icon: Icons.support_agent_rounded,
    ),
  ];

  List<BannerData> _banners = _defaultBanners;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _currentIndex = _initialPage % _banners.length;

    _fetchBanners();
    _bannerWsSub = WebSocketService().bannerUpdates.listen((_) {
      _fetchBanners();
    });

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _banners.length > 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _fetchBanners() async {
    try {
      final resp = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.banners}'),
      );
      if (resp.statusCode != 200) return;
      final decoded = jsonDecode(resp.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      if (data is! List) return;

      final live = <BannerData>[];
      for (var i = 0; i < data.length; i++) {
        final raw = data[i];
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        live.add(BannerData(
          title: (map['title'] ?? '').toString(),
          subtitle: (map['subtitle'] ?? '').toString(),
          tag: (map['tag'] ?? '').toString(),
          buttonText: (map['buttonText'] ?? '').toString(),
          ctaLink: (map['ctaLink'] ?? '').toString(),
          imageUrl: (map['imageUrl'] ?? '').toString(),
          gradient: _fallbackGradients[i % _fallbackGradients.length],
          icon: Icons.agriculture_rounded,
        ));
      }

      if (!mounted) return;
      final nextList = live.isNotEmpty ? live : _defaultBanners;
      setState(() {
        _banners = nextList;
        final page = _pageController.hasClients
            ? (_pageController.page?.round() ?? _initialPage)
            : _initialPage;
        _currentIndex = (page % nextList.length + nextList.length) % nextList.length;
      });
    } catch (_) {
      // Keep current/default banners if network is temporarily unavailable.
    }
  }

  void _handleBannerTap(BannerData banner) {
    final link = banner.ctaLink.trim();
    if (link.isEmpty) return;
    if (link.startsWith('/')) {
      context.go(link);
    } else if (link.startsWith('http://') || link.startsWith('https://')) {
      launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _bannerWsSub?.cancel();
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
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildBannerCard(BannerData banner, {bool isMobile = false, bool isTablet = false}) {
    final hasImage = banner.imageUrl.trim().isNotEmpty;
    final hasTextContent = banner.tag.trim().isNotEmpty ||
        banner.title.trim().isNotEmpty ||
        banner.subtitle.trim().isNotEmpty ||
        banner.buttonText.trim().isNotEmpty;

    return GestureDetector(
      onTap: banner.ctaLink.trim().isNotEmpty ? () => _handleBannerTap(banner) : null,
      child: Container(
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
            if (hasImage)
              Positioned.fill(
                child: AppProductImage(
                  imageUrl: banner.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: banner.icon,
                ),
              ),
            if (hasImage && hasTextContent)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            if (!hasImage) ...[
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
            ],

            // Main Centered Content
            if (hasTextContent)
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
                              if (banner.tag.trim().isNotEmpty) ...[
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
                                    style: GoogleFonts.mukta(
                                      color: Colors.white,
                                      fontSize: isMobile ? 9 : 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isMobile ? 6 : 12),
                              ],
                              if (banner.title.trim().isNotEmpty)
                                Text(
                                  banner.title,
                                  style: GoogleFonts.mukta(
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
                              if (banner.subtitle.trim().isNotEmpty) ...[
                                SizedBox(height: isMobile ? 4 : 8),
                                Text(
                                  banner.subtitle,
                                  style: GoogleFonts.mukta(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: isMobile ? 11 : (isTablet ? 13 : 15),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (banner.buttonText.trim().isNotEmpty) ...[
                                SizedBox(height: isMobile ? 10 : 20),
                                ElevatedButton(
                                  onPressed: () => _handleBannerTap(banner),
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
                                    style: GoogleFonts.mukta(
                                      fontWeight: FontWeight.w700,
                                      fontSize: isMobile ? 11 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isMobile && !hasImage) ...[
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
      ),
    );
  }
}

class BannerData {
  final String title;
  final String subtitle;
  final String tag;
  final String buttonText;
  final String ctaLink;
  final String imageUrl;
  final List<Color> gradient;
  final IconData icon;

  const BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.buttonText,
    this.ctaLink = '',
    this.imageUrl = '',
    required this.gradient,
    required this.icon,
  });
}
