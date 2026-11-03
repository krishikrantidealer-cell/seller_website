import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Resilient Product & Category Image Widget for Flutter Web & Mobile.
/// Uses `WebHtmlElementStrategy.prefer` so Google Cloud Storage signed URLs
/// (`https://storage.googleapis.com/...`) render without CanvasKit CORS errors,
/// and automatically falls back across [fallbackUrls] (`midUrl`, `lowUrl`, `originalUrl`).
class AppProductImage extends StatefulWidget {
  final String imageUrl;
  final List<String> fallbackUrls;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const AppProductImage({
    super.key,
    required this.imageUrl,
    this.fallbackUrls = const [],
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 0,
    this.fallbackIcon = Icons.inventory_2_outlined,
    this.fallbackIconSize = 42,
  });

  @override
  State<AppProductImage> createState() => _AppProductImageState();
}

class _AppProductImageState extends State<AppProductImage> {
  int _candidateIndex = 0;
  List<String> _candidates = const [];

  @override
  void initState() {
    super.initState();
    _recomputeCandidates();
  }

  @override
  void didUpdateWidget(covariant AppProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackUrls != widget.fallbackUrls) {
      _recomputeCandidates();
    }
  }

  void _recomputeCandidates() {
    final list = <String>[];
    final primary = widget.imageUrl.trim();
    if (primary.isNotEmpty &&
        (primary.startsWith('http://') || primary.startsWith('https://'))) {
      list.add(primary);
    }
    for (final fb in widget.fallbackUrls) {
      final trimmed = fb.trim();
      if (trimmed.isNotEmpty &&
          (trimmed.startsWith('http://') || trimmed.startsWith('https://')) &&
          !list.contains(trimmed)) {
        list.add(trimmed);
      }
    }
    _candidates = list;
    _candidateIndex = 0;
  }

  String? get _currentUrl {
    if (_candidates.isEmpty || _candidateIndex >= _candidates.length) {
      return null;
    }
    return _candidates[_candidateIndex];
  }

  void _onImageError() {
    if (_candidateIndex + 1 < _candidates.length && mounted) {
      setState(() {
        _candidateIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUrl = _currentUrl;
    if (activeUrl == null) {
      return _buildFallback();
    }

    Widget img = Image.network(
      activeUrl,
      key: ValueKey(activeUrl),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      filterQuality: FilterQuality.medium,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) {
        if (_candidateIndex + 1 < _candidates.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _onImageError());
        }
        return _buildFallback();
      },
    );

    if (widget.borderRadius > 0) {
      img = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: img,
      );
    }

    return img;
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.white,
      alignment: Alignment.center,
      child: Icon(
        widget.fallbackIcon,
        size: widget.fallbackIconSize,
        color: AppColors.textMuted,
      ),
    );
  }
}
