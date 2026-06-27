import 'dart:ui';

import 'package:flutter/material.dart';

/// Blur-to-sharp placement reveal — content lands from below onto the drawer.
class BlurPlaceReveal extends StatelessWidget {
  const BlurPlaceReveal({
    super.key,
    required this.animation,
    required this.intervalStart,
    required this.intervalEnd,
    required this.child,
    this.maxBlur = 16,
    this.placementOffset = 28,
    this.alignment = Alignment.center,
    this.curve = Curves.easeOutQuint,
  });

  final Animation<double> animation;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;
  final double maxBlur;
  final double placementOffset;
  final Alignment alignment;
  final Curve curve;

  static double _segmentRaw(
    double value,
    double start,
    double end,
  ) {
    if (end <= start) return value >= start ? 1.0 : 0.0;
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double raw = _segmentRaw(
          animation.value,
          intervalStart,
          intervalEnd,
        );
        final double motionT = curve.transform(raw);
        final double opacityT = Curves.easeOut
            .transform(((raw - 0.06) / 0.94).clamp(0.0, 1.0));
        final double blur = (1 - motionT) * maxBlur;

        return Opacity(
          opacity: opacityT,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.decal,
            ),
            child: Transform.translate(
              offset: Offset(0, (1 - motionT) * placementOffset),
              child: Transform.scale(
                scale: 0.94 + (0.06 * motionT),
                alignment: alignment,
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}