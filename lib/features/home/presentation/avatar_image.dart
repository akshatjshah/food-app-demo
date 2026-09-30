import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'avatar_provider.dart';

/// Displays a customer avatar.
///
/// New PNG avatars render via [Image.asset] so the full body (head to shoes)
/// stays visible with no crop/stretch/distortion and the original PNG
/// background is preserved. Legacy SVG ids keep rendering via
/// [SvgPicture.asset] so existing users never break.
///
/// IMPORTANT: callers must size the surrounding box with
/// [avatarAspectRatioFor] (see [AvatarPortrait]) and use [BoxFit.cover] only
/// inside a ratio-matched box — where cover == contain and nothing crops.
/// Never place this inside a circle/square that would cut the source.
class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.avatarId,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String avatarId;
  final BoxFit fit;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(avatarId);
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment is Alignment ? alignment as Alignment : Alignment.center,
      );
    }
    return Image.asset(
      asset,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Theme.of(context).cardColor,
        alignment: Alignment.center,
        child: Icon(
          Icons.person_rounded,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Single shared compact portrait presentation used by Profile and
/// Edit Profile so both show the EXACT same asset with the EXACT same
/// aspect-ratio-aware, never-cropped rendering.
///
/// The box width is fixed; the height is derived automatically from the
/// source image's own aspect ratio via [avatarAspectRatioFor]:
/// `height = width / ratio`. No hardcoded height, no circle, no square.
class AvatarPortrait extends StatelessWidget {
  const AvatarPortrait({
    super.key,
    required this.avatarId,
    this.width = 50,
    this.borderRadius = 14,
    this.borderWidth = 2,
    this.semanticLabel,
  });

  final String avatarId;
  final double width;
  final double borderRadius;
  final double borderWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ratio = avatarAspectRatioFor(avatarId);
    return Semantics(
      label: semanticLabel ?? 'User avatar',
      image: true,
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: ratio,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1),
              // Ratio-matched box: cover fills edge-to-edge with no crop
              // and no white gaps; the PNG's own background reaches all
              // four edges exactly as authored.
              child: AvatarImage(avatarId: avatarId, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small circular Home header avatar showing the HEAD of the selected avatar.
///
/// ONE consistent treatment for every avatar: the same saved asset is
/// rendered at the uniform [kHomeFaceZoom] scale (aspect preserved, never
/// stretched) and positioned so the uniform window center
/// ([kHomeFaceCenterX], [kHomeFaceCenterY]) lands at the circle center via
/// [OverflowBox.alignment]. The circle therefore contains the face/head with
/// a small background margin — never the full body, never an aggressive
/// face-zoom, and identically for all 8 avatars (and future additions).
class HomeAvatarFace extends StatelessWidget {
  const HomeAvatarFace({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.borderWidth = 2,
  });

  final String avatarId;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    // Actual source ratio keeps the zoom uniform without distortion.
    final ratio = avatarAspectRatioFor(avatarId);
    // Rendered source size (uniform zoom, aspect preserved).
    final childWidth = size * kHomeFaceZoom;
    final childHeight = childWidth / ratio;
    // OverflowBox alignment that centers the uniform window in the circle:
    // child offset = (size - child) * (a + 1) / 2 must equal
    // (size / 2 - centerFraction * child) on each axis.
    double align(double f, double child) =>
        ((size - 2 * f * child) / (size - child) - 1).clamp(-1.0, 1.0);
    return Semantics(
      label: 'User avatar',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: borderWidth,
          ),
        ),
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: OverflowBox(
              maxWidth: childWidth,
              maxHeight: childHeight,
              alignment: Alignment(
                align(kHomeFaceCenterX, childWidth),
                align(kHomeFaceCenterY, childHeight),
              ),
              child: SizedBox(
                width: childWidth,
                height: childHeight,
                child: AvatarImage(avatarId: avatarId, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
