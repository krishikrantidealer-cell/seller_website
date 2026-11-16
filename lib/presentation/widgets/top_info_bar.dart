import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/language_controller.dart';
import '../../core/theme/app_colors.dart';
import '../sell_with_us/sell_with_us_view.dart';
import '../be_a_partner/be_a_partner_view.dart';

class TopInfoBar extends StatelessWidget {
  const TopInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.instance;
    return AnimatedBuilder(
      animation: langCtrl,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          color: AppColors.primaryCrimson,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    // Mobile compact bar
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_in_talk_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '${langCtrl.tr('call_to_order')}: ${AppConstants.orderCallNumber}',
                                  style: GoogleFonts.mukta(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (constraints.maxWidth >= 500) ...[
                                const SizedBox(width: 8),
                                Container(width: 1, height: 10, color: Colors.white.withValues(alpha: 0.4)),
                                const SizedBox(width: 8),
                                Text(
                                  langCtrl.tr('free_delivery'),
                                  style: GoogleFonts.mukta(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildLanguageButton(context, langCtrl, fontSize: 10.5),
                      ],
                    );
                  }

                  final isLaptop = constraints.maxWidth < 1360;
                  final double itemGap = isLaptop ? 10.0 : 16.0;
                  final double fontSize = isLaptop ? 11.0 : 12.0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Contact info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_in_talk_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            '${langCtrl.tr('call_to_order')}: ${AppConstants.orderCallNumber}',
                            style: GoogleFonts.mukta(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: itemGap),
                          Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.4)),
                          SizedBox(width: itemGap),
                          Text(
                            '${langCtrl.tr('helpline')}: ${AppConstants.helplineNumber}',
                            style: GoogleFonts.mukta(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Right utilities
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
                          SizedBox(width: itemGap),
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
                          SizedBox(width: itemGap),
                          Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.4)),
                          SizedBox(width: itemGap),
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
                      color: isSelected ? AppColors.primaryCrimson : AppColors.textSecondary,
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
                      color: isSelected ? AppColors.primaryCrimson : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 16, color: AppColors.primaryCrimson),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: fontSize + 2, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              langCtrl.current.shortCode,
              style: GoogleFonts.mukta(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
