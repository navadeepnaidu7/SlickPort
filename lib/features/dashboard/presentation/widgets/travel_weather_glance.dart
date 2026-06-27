import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _PhaseStyle {
  const _PhaseStyle({
    required this.topColor,
    required this.bottomColor,
    required this.horizonColor,
    required this.celestialColor,
    required this.borderColor,
    required this.temperature,
    required this.condition,
    required this.copy,
    required this.showStars,
    required this.showClouds,
    required this.celestialY,
  });

  final Color topColor;
  final Color bottomColor;
  final Color horizonColor;
  final Color celestialColor;
  final Color borderColor;
  final String temperature;
  final String condition;
  final String copy;
  final bool showStars;
  final bool showClouds;
  final double celestialY;
}

class TravelWeatherGlance extends StatefulWidget {
  const TravelWeatherGlance({super.key});

  @override
  State<TravelWeatherGlance> createState() => _TravelWeatherGlanceState();
}

class _TravelWeatherGlanceState extends State<TravelWeatherGlance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _driftCtrl;

  @override
  void initState() {
    super.initState();
    _driftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _driftCtrl.dispose();
    super.dispose();
  }

  _PhaseStyle _phaseForHour(int hour) {
    if (hour >= 6 && hour < 11) {
      return const _PhaseStyle(
        topColor: Color(0xFFFFB88C),
        bottomColor: Color(0xFF8EC5FF),
        horizonColor: Color(0xFFFFE2B8),
        celestialColor: Color(0xFFFFE08A),
        borderColor: Color(0xFFFFC98E),
        temperature: '21°',
        condition: 'Soft morning light',
        copy: 'Gentle light for an early airport run.',
        showStars: false,
        showClouds: true,
        celestialY: 0.62,
      );
    }
    if (hour >= 11 && hour < 17) {
      return const _PhaseStyle(
        topColor: Color(0xFF4DA3FF),
        bottomColor: Color(0xFFBFE4FF),
        horizonColor: Color(0xFFEAF6FF),
        celestialColor: Color(0xFFFFF4B3),
        borderColor: Color(0xFF7EC0FF),
        temperature: '24°',
        condition: 'Clear · Sunny',
        copy: 'Bright skies — great for a day trip.',
        showStars: false,
        showClouds: true,
        celestialY: 0.48,
      );
    }
    if (hour >= 17 && hour < 21) {
      return const _PhaseStyle(
        topColor: Color(0xFFFF8A4C),
        bottomColor: Color(0xFF4B2D7A),
        horizonColor: Color(0xFFFFC27A),
        celestialColor: Color(0xFFFFB347),
        borderColor: Color(0xFFFF9A62),
        temperature: '19°',
        condition: 'Golden hour',
        copy: 'Warm evening glow before your next leg.',
        showStars: false,
        showClouds: true,
        celestialY: 0.72,
      );
    }
    return const _PhaseStyle(
      topColor: Color(0xFF0B1530),
      bottomColor: Color(0xFF1A2748),
      horizonColor: Color(0xFF24345C),
      celestialColor: Color(0xFFE8EEFF),
      borderColor: Color(0xFF6E86B8),
      temperature: '18°',
      condition: 'Clear · Night',
      copy: 'Calm night air — time to review your plans.',
      showStars: true,
      showClouds: false,
      celestialY: 0.38,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _PhaseStyle phase = _phaseForHour(DateTime.now().hour);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: phase.borderColor.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: phase.celestialColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: ColoredBox(
          color: const Color(0xFF081A36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 38,
                child: AnimatedBuilder(
                  animation: _driftCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _TravelSkyPainter(
                        phase: phase,
                        drift: _driftCtrl.value,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          phase.temperature,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              phase.condition,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF9BB0D0),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phase.copy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF7F96B8),
                        fontSize: 11,
                        height: 1.25,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelSkyPainter extends CustomPainter {
  const _TravelSkyPainter({
    required this.phase,
    required this.drift,
  });

  final _PhaseStyle phase;
  final double drift;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [phase.topColor, phase.bottomColor],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final Paint horizonGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          phase.horizonColor.withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55));
    canvas.drawRect(rect, horizonGlow);

    if (phase.showStars) {
      final Paint star = Paint()..color = Colors.white;
      for (int i = 0; i < 18; i++) {
        final double x = (i * 37 + 11) % size.width;
        final double y = (i * 19 + 7) % (size.height * 0.8);
        final double r = i.isEven ? 1.1 : 0.7;
        star.color = Colors.white.withValues(alpha: 0.25 + (i % 3) * 0.15);
        canvas.drawCircle(Offset(x, y), r, star);
      }
    }

    if (phase.showClouds) {
      final Paint cloud = Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final double driftX = math.sin(drift * math.pi * 2) * 8;
      _drawCloud(canvas, cloud, Offset(size.width * 0.22 + driftX, size.height * 0.58), 18);
      _drawCloud(canvas, cloud, Offset(size.width * 0.62 - driftX, size.height * 0.66), 14);
    }

    final Offset celestial = Offset(
      size.width * (0.72 + math.sin(drift * math.pi * 2) * 0.02),
      size.height * phase.celestialY,
    );
    final Paint glow = Paint()
      ..color = phase.celestialColor.withValues(alpha: 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(celestial, 16, glow);
    final Paint body = Paint()..color = phase.celestialColor;
    canvas.drawCircle(celestial, phase.showStars ? 7 : 9, body);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center + Offset(radius * 0.9, 2), radius * 0.75, paint);
    canvas.drawCircle(center - Offset(radius * 0.8, 1), radius * 0.65, paint);
  }

  @override
  bool shouldRepaint(covariant _TravelSkyPainter old) =>
      old.drift != drift || old.phase.temperature != phase.temperature;
}