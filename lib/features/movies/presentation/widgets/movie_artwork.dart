import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class MovieArtwork extends StatelessWidget {
  const MovieArtwork({
    super.key,
    required this.imageUrl,
    required this.height,
    this.width,
    this.borderRadius = 18,
    this.iconSize = 48,
  });

  final String? imageUrl;
  final double height;
  final double? width;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    if (imageUrl == null) {
      return _FallbackArtwork(
        width: width,
        height: height,
        borderRadius: radius,
        iconSize: iconSize,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _FallbackArtwork(
            width: width,
            height: height,
            borderRadius: radius,
            iconSize: iconSize,
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return _FallbackArtwork(
              width: width,
              height: height,
              borderRadius: radius,
              iconSize: iconSize,
              showLoader: true,
            );
          },
        ),
      ),
    );
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.iconSize,
    this.showLoader = false,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final double iconSize;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryRed, Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: showLoader
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.play_circle_fill_rounded,
                size: iconSize,
                color: Colors.white.withValues(alpha: 0.92),
              ),
      ),
    );
  }
}
