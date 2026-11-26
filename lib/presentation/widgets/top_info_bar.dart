import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  static const String _marqueeText =
      'Welcome to EBS Krishi Dukaan.   •   Free Delivery on Orders Above ₹500 across India.   •   100% Genuine Agro Products • Direct from Brands.   •   ';

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
                        const Expanded(
                          child: _ContinuousMarquee(
                            text: _marqueeText,
                            fontSize: 11.5,
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
                      // Left Continuous Single-Line Marquee
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: _ContinuousMarquee(
                            text: _marqueeText,
                            fontSize: fontSize,
                          ),
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

class _ContinuousMarquee extends StatefulWidget {
  final String text;
  final double fontSize;

  const _ContinuousMarquee({
    required this.text,
    required this.fontSize,
  });

  @override
  State<_ContinuousMarquee> createState() => _ContinuousMarqueeState();
}

class _ContinuousMarqueeState extends State<_ContinuousMarquee>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  static const double _pixelsPerSecond = 48.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!mounted || !_scrollController.hasClients) {
        _lastElapsed = elapsed;
        return;
      }
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;
      if (dt <= 0 || dt > 0.2) return;

      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;
      final halfExtent = maxExtent / 2;
      if (halfExtent <= 0) return;

      var next = _scrollController.offset + (_pixelsPerSecond * dt);
      if (next >= halfExtent) {
        next -= halfExtent;
      }
      _scrollController.jumpTo(next);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.mukta(
      color: Colors.white,
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w600,
    );

    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.text, style: style),
            Text(widget.text, style: style),
            Text(widget.text, style: style),
          ],
        ),
      ),
    );
  }
}
