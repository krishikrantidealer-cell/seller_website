import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_product_image.dart';

/// Renders a category's visual icon from `categoryImageUrl`, `iconUrl` (SVG or raster),
/// or fallback emoji/text `iconEmoji`.
class CategoryIconBadge extends StatelessWidget {
  final String? categoryImageUrl;
  final String? iconUrl;
  final String? iconEmoji;
  final double size;
  final double emojiSize;
  final double borderRadius;

  const CategoryIconBadge({
    super.key,
    this.categoryImageUrl,
    this.iconUrl,
    this.iconEmoji,
    this.size = 18,
    this.emojiSize = 14,
    this.borderRadius = 4,
  });

  static bool hasAnyIcon({
    String? categoryImageUrl,
    String? iconUrl,
    String? iconEmoji,
  }) {
    return (categoryImageUrl != null && categoryImageUrl.trim().isNotEmpty) ||
        (iconUrl != null && iconUrl.trim().isNotEmpty) ||
        (iconEmoji != null && iconEmoji.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final img = categoryImageUrl?.trim() ?? '';
    if (img.isNotEmpty) {
      return AppProductImage(
        imageUrl: img,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
      );
    }

    final icon = iconUrl?.trim() ?? '';
    if (icon.isNotEmpty) {
      if (icon.toLowerCase().contains('.svg')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SvgPicture.network(
            icon,
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => SizedBox(width: size, height: size),
          ),
        );
      }
      return AppProductImage(
        imageUrl: icon,
        width: size,
        height: size,
        fit: BoxFit.contain,
        borderRadius: borderRadius,
      );
    }

    final emoji = iconEmoji?.trim() ?? '';
    if (emoji.isNotEmpty) {
      return Text(emoji, style: TextStyle(fontSize: emojiSize));
    }

    return const SizedBox.shrink();
  }
}
