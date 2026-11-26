import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/language_controller.dart';
import '../be_a_partner/be_a_partner_view.dart';
import '../sell_with_us/sell_with_us_view.dart';

class TopInfoBar extends StatefulWidget {
  const TopInfoBar({super.key});

  @override
  State<TopInfoBar> createState() => _TopInfoBarState();
}

class _TopInfoBarState extends State<TopInfoBar> {
  static const Color _brandRed = Color(0xFFC81E1E);

  static const List<String> _announcements = [
    'Welcome to EBS Krishi Dukaan.',
    'Free Delivery on Orders Above ₹500 across India.',
    '100% Genuine Agro Products • Direct from Brands.',
  ];

  int _announcementIndex = 0;
  Timer? _autoCycleTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCycle();
  }

  void _startAutoCycle() {
    _autoCycleTimer?.cancel();
    _autoCycleTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _announcementIndex = (_announcementIndex + 1) % _announcements.length;
      });
    });
  }

  @override
  void dispose() {
    _autoCycleTimer?.cancel();
    super.dispose();
  }

  void _prevAnnouncement() {
    setState(() {
      _announcementIndex =
          (_announcementIndex - 1 + _announcements.length) % _announcements.length;
    });
    _startAutoCycle();
  }

  void _nextAnnouncement() {
    setState(() {
      _announcementIndex = (_announcementIndex + 1) % _announcements.length;
    });
    _startAutoCycle();
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.instance;
    return AnimatedBuilder(
      animation: langCtrl,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          color: _brandRed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _circleArrow(Icons.chevron_left_rounded, _prevAnnouncement),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _announcements[_announcementIndex],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.mukta(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _circleArrow(Icons.chevron_right_rounded, _nextAnnouncement),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildLanguageButton(context, langCtrl, fontSize: 11),
                      ],
                    );
                  }

                  final isLaptop = constraints.maxWidth < 1360;
                  final double itemGap = isLaptop ? 10.0 : 14.0;
                  final double fontSize = isLaptop ? 11.5 : 12.5;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Announcement Ticker
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _circleArrow(Icons.chevron_left_rounded, _prevAnnouncement),
                            const SizedBox(width: 10),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 450),
                                  transitionBuilder: (child, anim) => FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.08, 0),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  ),
                                  child: Align(
                                    key: ValueKey(_announcementIndex),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _announcements[_announcementIndex],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.mukta(
                                        color: Colors.white,
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _circleArrow(Icons.chevron_right_rounded, _nextAnnouncement),
                          ],
                        ),
                      ),

                      // Right Utilities
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _navLink(
                            langCtrl.tr('be_a_partner'),
                            fontSize: fontSize,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BeAPartnerView()),
                              );
                            },
                          ),
                          _divider(itemGap),
                          _navLink(
                            'Bulk Enquiry',
                            fontSize: fontSize,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BeAPartnerView()),
                              );
                            },
                          ),
                          _divider(itemGap),
                          _navLink(
                            langCtrl.tr('sell_with_us'),
                            fontSize: fontSize,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SellWithUsView()),
                              );
                            },
                          ),
                          _divider(itemGap),
                          _buildLanguageButton(context, langCtrl, fontSize: fontSize),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _circleArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }

  Widget _divider(double gap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gap),
      child: Container(
        width: 1,
        height: 12,
        color: Colors.white.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    LanguageController langCtrl, {
    required double fontSize,
  }) {
    return PopupMenuButton<AppLanguage>(
      tooltip: langCtrl.tr('choose_language'),
      offset: const Offset(0, 28),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (lang) async {
        await langCtrl.setLanguage(lang);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Language set to ${lang.name} (${lang.nativeName})'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      itemBuilder: (context) {
        return LanguageController.supportedLanguages.map((lang) {
          final isSelected = lang.code == langCtrl.current.code;
          return PopupMenuItem<AppLanguage>(
            value: lang,
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    lang.shortCode,
                    style: GoogleFonts.mukta(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _brandRed : const Color(0xFF57534E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${lang.nativeName} (${lang.name})',
                    style: GoogleFonts.mukta(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? _brandRed : const Color(0xFF1C1917),
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 16, color: _brandRed),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: fontSize + 2, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              langCtrl.current.name,
              style: GoogleFonts.mukta(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: fontSize + 3, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String label, {double fontSize = 12.0, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: GoogleFonts.mukta(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
