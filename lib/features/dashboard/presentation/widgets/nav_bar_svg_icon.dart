import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Crossfades between filled and unfilled SVG nav icons using [progress].
class NavBarSvgIcon extends StatelessWidget {
  const NavBarSvgIcon({
    super.key,
    required this.filledAsset,
    required this.unfilledAsset,
    required this.activeColor,
    required this.inactiveColor,
    required this.width,
    required this.height,
    required this.progress,
    this.offsetX = 0,
  });

  final String filledAsset;
  final String unfilledAsset;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final double progress;
  final double offsetX;

  @override
  Widget build(BuildContext context) {
    final double filledOpacity = progress.clamp(0.0, 1.0);
    final double renderScale = MediaQuery.devicePixelRatioOf(context).clamp(2.5, 4.0);

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (filledOpacity < 1)
            Opacity(
              opacity: 1 - filledOpacity,
              child: _CrispNavSvg(
                asset: unfilledAsset,
                color: inactiveColor,
                width: width,
                height: height,
                renderScale: renderScale,
              ),
            ),
          if (filledOpacity > 0)
            Opacity(
              opacity: filledOpacity,
              child: _CrispNavSvg(
                asset: filledAsset,
                color: activeColor,
                width: width,
                height: height,
                renderScale: renderScale,
              ),
            ),
        ],
      ),
      ),
    );
  }
}

/// Renders an SVG at [renderScale]× resolution, then fits it down for sharp edges.
class _CrispNavSvg extends StatelessWidget {
  const _CrispNavSvg({
    required this.asset,
    required this.color,
    required this.width,
    required this.height,
    required this.renderScale,
  });

  final String asset;
  final Color color;
  final double width;
  final double height;
  final double renderScale;

  @override
  Widget build(BuildContext context) {
    final double renderW = width * renderScale;
    final double renderH = height * renderScale;

    return RepaintBoundary(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SvgPicture.asset(
          asset,
          width: renderW,
          height: renderH,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          clipBehavior: Clip.none,
          allowDrawingOutsideViewBox: true,
        ),
      ),
    );
  }
}