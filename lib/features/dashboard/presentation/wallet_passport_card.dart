import 'dart:convert';
import 'dart:math' as math;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../passport/domain/passport_profile.dart';

/// Portrait-style Indian Passport card with 3D tilt & single-tap flip.
class WalletPassportCard extends StatefulWidget {
  const WalletPassportCard({
    super.key,
    required this.profile,
    this.onLongPress,
  });

  final PassportProfile profile;
  final VoidCallback? onLongPress;

  @override
  State<WalletPassportCard> createState() => _WalletPassportCardState();
}

class _WalletPassportCardState extends State<WalletPassportCard>
    with TickerProviderStateMixin {
  // -- flip --
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;
  bool _showBack = false;

  // -- tilt --
  double _tiltX = 0;
  double _tiltY = 0;
  bool _touching = false;
  bool _dragging = false;


  // -- tap glow pulse --
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = CurvedAnimation(
      parent: _flipCtrl,
      curve: Curves.easeInOutCubic,
    );


    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();

    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_dragging) return;
    HapticFeedback.mediumImpact();
    _pulseCtrl.forward(from: 0);
    if (_showBack) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    _showBack = !_showBack;
  }

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _touching = true;
      _dragging = false;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Size size = box.size;
    setState(() {
      _dragging = true;
      _tiltX = ((d.localPosition.dy / size.height) - 0.5).clamp(-0.5, 0.5);
      _tiltY = -((d.localPosition.dx / size.width) - 0.5).clamp(-0.5, 0.5);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    setState(() {
      _touching = false;
      _tiltX = 0;
      _tiltY = 0;
    });
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _dragging = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 570.0;

    return SizedBox(
      height: cardHeight,
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _handleTap();
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          widget.onLongPress?.call();
        },
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
              animation: _flipAnim,
              builder: (context, _) {
                final double angle = _flipAnim.value * math.pi;
                final bool isBack = angle > math.pi / 2;

                // Add a smooth scale-down effect at the middle of the flip (angle = pi/2)
                final double scale = 1.0 - 0.08 * math.sin(_flipAnim.value * math.pi);

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..scaleByDouble(scale, scale, 1.0, 1.0)
                    ..rotateY(angle),
                  child: AnimatedContainer(
                    duration: _touching
                        ? const Duration(milliseconds: 60)
                        : const Duration(milliseconds: 500),
                    curve: _touching ? Curves.linear : Curves.easeOutCubic,
                    transformAlignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateX(_tiltX * 0.14)
                      ..rotateY(_tiltY * 0.14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Back (rotated to face away)
                        Opacity(
                          opacity: isBack ? 1.0 : 0.0,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: RepaintBoundary(
                              child: _CardBack(
                                profile: widget.profile,
                                tiltY: _tiltY,
                              ),
                            ),
                          ),
                        ),
                        // Front
                        Opacity(
                          opacity: isBack ? 0.0 : 1.0,
                          child: RepaintBoundary(
                            child: _CardFront(
                              profile: widget.profile,
                              tiltY: _tiltY,
                              pulseCtrl: _pulseCtrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

// ─── FRONT SIDE ──────────────────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.profile,
    required this.tiltY,
    required this.pulseCtrl,
  });

  final PassportProfile profile;
  final double tiltY;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    final String name =
        profile.name.trim().isEmpty ? 'HOLDER NAME' : profile.name.toUpperCase();
    final String number = profile.passportNumber.trim().isEmpty
        ? 'A 1234567'
        : profile.passportNumber;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.28),
            blurRadius: 40,
            spreadRadius: -6,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // Subtle glow mimicking gloss
          BoxShadow(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: <Widget>[
            // — base gradient (deep navy, passport-like) —
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFF14244B),
                    Color(0xFF0A1226),
                  ],
                ),
              ),
            ),

            // — Ashoka Chakra watermark background —
            const Positioned.fill(child: CustomPaint(painter: _AshokaPainter())),

            // — subtle security pattern lines —
            const Positioned.fill(child: CustomPaint(painter: _SecurityLinePainter())),

            // — shimmer overlay —
            // — dynamic interactive shimmer —
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const <Color>[
                      Colors.transparent,
                      Color(0x18FFFFFF),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.5, 1.0],
                    transform: _SlideGradient(tiltY * 1200),
                  ),
                ),
              ),
            ),

            // — tricolor top strip —
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 6,
                child: Row(
                  children: <Widget>[
                    Expanded(child: Container(color: const Color(0xFFFF9933))),
                    Expanded(child: Container(color: Colors.white)),
                    Expanded(child: Container(color: const Color(0xFF138808))),
                  ],
                ),
              ),
            ),

            // — main content —
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 6), // tricolor strip
                // top header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: SvgPicture.asset(
                          'assets/identity/Emblem_of_India.svg',
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFD4A843),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            'REPUBLIC OF INDIA',
                            style: TextStyle(
                              color: Color(0xFFD4A843),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.4,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'PASSPORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const _EPassportSymbol(),
                    ],
                  ),
                ),

                const Spacer(),

                // — central emblem oval —
                _EmblemOval(),

                const Spacer(),

                // — bottom details —
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'NAME',
                              style: TextStyle(
                                color: const Color(0xFFD4A843).withValues(alpha: 0.95),
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'PASSPORT NO.',
                              style: TextStyle(
                                color: const Color(0xFFD4A843).withValues(alpha: 0.95),
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // — tap-to-flip indicator —
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white.withValues(alpha: 0.30),
                        size: 13,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Tap to Flip for more details',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.30),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BACK SIDE ───────────────────────────────────────────────────────────────

class _CardBack extends StatelessWidget {
  const _CardBack({required this.profile, required this.tiltY});

  final PassportProfile profile;
  final double tiltY;

  @override
  Widget build(BuildContext context) {
    final String fullName = profile.name.trim().isEmpty ? 'N/A' : profile.name.toUpperCase();
    final String dob = profile.dateOfBirth.isEmpty ? 'N/A' : profile.dateOfBirth;
    final String expiry = profile.expiryDate.isEmpty ? 'N/A' : profile.expiryDate;
    final String nationality = profile.nationality.isEmpty ? 'N/A' : profile.nationality;
    final String gender = profile.gender.isEmpty ? 'N/A' : profile.gender;
    final String placeOfBirth = profile.placeOfBirth.isEmpty ? 'N/A' : profile.placeOfBirth;
    final String issueDate = profile.issueDate.isEmpty ? 'N/A' : profile.issueDate;
    final String issuingAuthority = profile.issuingAuthority.isEmpty ? 'N/A' : profile.issuingAuthority;
        
    final String mrz = profile.mrzRaw.trim().isEmpty
        ? 'P<IND<<HOLDER<<NAME<<<<<<<<<<<<<<<<<<<<<\nA123456780IND9001011M3501011<<<<<<<<<<<04'
        : profile.mrzRaw;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.28),
            blurRadius: 40,
            spreadRadius: -6,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // Subtle glow
          BoxShadow(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: <Widget>[
            // — background —
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFF14244B),
                    Color(0xFF0A1226),
                  ],
                ),
              ),
            ),

            const Positioned.fill(child: CustomPaint(painter: _AshokaPainter())),
            const Positioned.fill(child: CustomPaint(painter: _SecurityLinePainter())),

            // shimmer
            // — dynamic interactive shimmer —
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const <Color>[
                      Colors.transparent,
                      Color(0x18FFFFFF),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.5, 1.0],
                    transform: _SlideGradient(tiltY * 1200),
                  ),
                ),
              ),
            ),

            // — tricolor bottom strip —
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 6,
                child: Row(
                  children: <Widget>[
                    Expanded(child: Container(color: const Color(0xFFFF9933))),
                    Expanded(child: Container(color: Colors.white)),
                    Expanded(child: Container(color: const Color(0xFF138808))),
                  ],
                ),
              ),
            ),

            // — content —
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // section header
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/identity/Emblem_of_India.svg',
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFD4A843),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'PERSONAL DETAILS',
                        style: TextStyle(
                          color: Color(0xFFD4A843),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // fields grid & photo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // NFC Photo Placeholder
                      Container(
                        width: 100,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: profile.imagePath.isNotEmpty
                              ? Image.memory(
                                  base64Decode(profile.imagePath),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 130,
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.nfc_rounded,
                                        color: Colors.white.withValues(alpha: 0.28),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'NFC\nPHOTO',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Fields
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _BackField(label: 'FULL NAME', value: fullName),
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(child: _BackField(label: 'GENDER', value: gender)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(child: _BackField(label: 'DOB', value: dob)),
                                Expanded(child: _BackField(label: 'PLACE OF BIRTH', value: placeOfBirth)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(child: _BackField(label: 'ISSUE DATE', value: issueDate)),
                                Expanded(child: _BackField(label: 'EXPIRY DATE', value: expiry)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _BackField(label: 'ISSUING AUTHORITY', value: issuingAuthority),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // — MRZ zone —
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'MACHINE READABLE ZONE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          mrz,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF8BAFC4).withValues(alpha: 0.9),
                            fontSize: 10.5,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // tap-to-flip hint
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.credit_card_rounded,
                          color: Colors.white.withValues(alpha: 0.32),
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap to flip back',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.32),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUB-WIDGETS ─────────────────────────────────────────────────────────────

class _EmblemOval extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      height: 178,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        gradient: RadialGradient(
          colors: <Color>[
            const Color(0xFF1F3058).withValues(alpha: 0.90),
            const Color(0xFF0E1B30).withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4A843).withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFD4A843).withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/identity/Emblem_of_India.svg',
          width: 88,
          height: 88,
          colorFilter: const ColorFilter.mode(
            Color(0xFFD4A843),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _EPassportSymbol extends StatelessWidget {
  const _EPassportSymbol();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 20),
      painter: _EPassportSymbolPainter(),
    );
  }
}

class _EPassportSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Outer rectangle
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);

    // Circle in the middle
    final double circleRadius = size.height * 0.22;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      circleRadius,
      paint,
    );

    // Left line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width / 2 - circleRadius, size.height / 2),
      paint,
    );

    // Right line
    canvas.drawLine(
      Offset(size.width / 2 + circleRadius, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackField extends StatelessWidget {
  const _BackField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ─── PAINTERS ────────────────────────────────────────────────────────────────

class _AshokaPainter extends CustomPainter {
  const _AshokaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.022)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final Offset center = Offset(size.width * 0.72, size.height * 0.42);
    for (double r = 24; r < 160; r += 16) {
      canvas.drawCircle(center, r, paint);
    }
    for (int i = 0; i < 24; i++) {
      final double angle = (i / 24) * 2 * math.pi;
      canvas.drawLine(
        center,
        Offset(
          center.dx + 150 * math.cos(angle),
          center.dy + 150 * math.sin(angle),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SecurityLinePainter extends CustomPainter {
  const _SecurityLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.012)
      ..strokeWidth = 0.6;

    // diagonal security micro-lines
    for (double x = -size.height; x < size.width * 2; x += 9) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.6, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);
  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}
