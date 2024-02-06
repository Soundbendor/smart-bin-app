import 'package:flutter/material.dart';

/// A widget that displays an image from a URL or asset.
class DynamicImage extends StatelessWidget {
  /// The URL or asset name of the image to display
  final String imageUrl;

  // Image properties copied from the Image class
  final double scale;
  final double? width;
  final double? height;
  final Color? color;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  final Widget Function(BuildContext context, Object error, StackTrace? trace)?
      errorBuilder;

  const DynamicImage(
    this.imageUrl, {
    super.key,
    this.scale = 1.0,
    this.width,
    this.height,
    this.color,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = false,
    this.errorBuilder,
  });

  Widget onError(BuildContext context, Object error, StackTrace? stackTrace) {
    return Icon(
      Icons.error,
      size: width ?? height,
      color: color,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith("http")) {
      return Image.network(
        imageUrl,
        key: key,
        errorBuilder: errorBuilder ?? onError,
        scale: scale,
        width: width,
        height: height,
        color: color,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        opacity: opacity,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        isAntiAlias: isAntiAlias,
      );
    } else {
      return Image.asset(
        imageUrl,
        key: key,
        errorBuilder: errorBuilder ?? onError,
        scale: scale,
        width: width,
        height: height,
        color: color,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        opacity: opacity,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        isAntiAlias: isAntiAlias,
      );
    }
  }
}
