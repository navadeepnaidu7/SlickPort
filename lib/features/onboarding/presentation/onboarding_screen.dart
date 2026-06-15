import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dashboard/presentation/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  double _page = 0;

  static const List<_OnboardingStep> _steps = <_OnboardingStep>[
    _OnboardingStep(
      eyebrow: 'SlickPort',
      title: 'Your passport, staged like a private pass.',
      body:
          'Capture identity details into a refined local workspace built for clarity and speed.',
      icon: Icons.auto_awesome_rounded,
      primary: Color(0xFF0B1B34),
      accent: Color(0xFFC9A760),
      secondary: Color(0xFF2F9B9B),
    ),
    _OnboardingStep(
      eyebrow: 'MRZ capture',
      title: 'Aim once. Let the scan line find the signal.',
      body:
          'The camera flow is shaped around the machine readable zone, ready for OCR integration.',
      icon: Icons.document_scanner_rounded,
      primary: Color(0xFF111F36),
      accent: Color(0xFFD3B77A),
      secondary: Color(0xFF5FA7A0),
    ),
    _OnboardingStep(
      eyebrow: 'Chip ready',
      title: 'A calm NFC moment for verified identity.',
      body:
          'MRZ-derived access keys prepare the secure chip read while sensitive data stays offline.',
      icon: Icons.nfc_rounded,
      primary: Color(0xFF0E1A2D),
      accent: Color(0xFF3DC7B3),
      secondary: Color(0xFFD7B25A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageChange);
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageChange)
      ..dispose();
    super.dispose();
  }

  void _handlePageChange() {
    setState(() {
      _page = _pageController.page ?? 0;
    });
  }

  Future<void> _continue() async {
    final int current = _page.round();
    if (current < _steps.length - 1) {
      _pageController.animateToPage(
        current + 1,
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => const DashboardScreen(),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuint,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int activeIndex = _page.round().clamp(0, _steps.length - 1).toInt();
    final _OnboardingStep activeStep = _steps[activeIndex];

    return Scaffold(
      backgroundColor: activeStep.primary,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.28,
            colors: <Color>[
              activeStep.accent.withValues(alpha: 0.46),
              activeStep.primary,
              const Color(0xFF05070C),
            ],
            stops: const <double>[0, 0.46, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _TopBar(progress: (_page + 1) / _steps.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _steps.length,
                  itemBuilder: (BuildContext context, int index) {
                    final double delta = (_page - index)
                        .clamp(-1.0, 1.0)
                        .toDouble();
                    return _OnboardingPage(
                      step: _steps[index],
                      delta: delta,
                      pageIndex: index,
                    );
                  },
                ),
              ),
              _BottomControls(
                activeIndex: activeIndex,
                stepCount: _steps.length,
                isLast: activeIndex == _steps.length - 1,
                onContinue: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Icon(Icons.credit_card_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.step,
    required this.delta,
    required this.pageIndex,
  });

  final _OnboardingStep step;
  final double delta;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final double textOffset = 34 * delta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double visualHeight = math.min(
            constraints.maxHeight * 0.48,
            360,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: visualHeight,
                child: _PassportStage(
                  step: step,
                  delta: delta,
                  pageIndex: pageIndex,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Transform.translate(
                  offset: Offset(textOffset, 0),
                  child: Opacity(
                    opacity: (1 - delta.abs() * 0.35)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Eyebrow(step: step),
                        const SizedBox(height: 12),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width - 44,
                              child: Text(
                                step.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  height: 1.02,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          step.body,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 16,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PassportStage extends StatelessWidget {
  const _PassportStage({
    required this.step,
    required this.delta,
    required this.pageIndex,
  });

  final _OnboardingStep step;
  final double delta;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    if (pageIndex == 0) {
      return _WalletOnboardingAnim(delta: delta);
    } else if (pageIndex == 1) {
      return _ScannerOnboardingAnim(delta: delta);
    } else {
      return _NfcOnboardingAnim(delta: delta);
    }
  }
}

// ── Step 0: Wallet Insertion Animation ────────────────────────────────────────

class _WalletOnboardingAnim extends StatefulWidget {
  const _WalletOnboardingAnim({required this.delta});
  final double delta;

  @override
  State<_WalletOnboardingAnim> createState() => _WalletOnboardingAnimState();
}

class _WalletOnboardingAnimState extends State<_WalletOnboardingAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _slideAnim = Tween<double>(begin: -140.0, end: -15.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double lift = 14 * widget.delta.abs();
    final double rotation = -0.10 + (widget.delta * -0.06);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardH = constraints.maxHeight * 0.76;
        final cardW = cardH * 1.586;
        
        return Center(
          child: SizedBox(
            width: cardW,
            height: cardH + 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Wallet Back Layer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: cardH * 0.72,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                
                // 2. Inserting Passport Card
                AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (context, child) {
                    return Positioned(
                      top: _slideAnim.value + lift,
                      left: 12,
                      right: 12,
                      height: cardH * 0.88,
                      child: Transform.rotate(
                        angle: rotation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2C59), Color(0xFF1B3A6B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.public_rounded, color: Color(0xFFD3B77A), size: 20),
                            Container(
                              width: 16,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD3B77A).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'PASSPORT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(width: 40, height: 3.5, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                            const Spacer(),
                            Container(width: 26, height: 3.5, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 3. Wallet Front Pocket Sleeve
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: cardH * 0.64,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, color: Colors.white.withValues(alpha: 0.5), size: 13),
                              const SizedBox(width: 6),
                              Text(
                                'SECURE WALLET STAGING',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Step 1: Viewfinder Scanning Animation ──────────────────────────────────────

class _ScannerOnboardingAnim extends StatefulWidget {
  const _ScannerOnboardingAnim({required this.delta});
  final double delta;

  @override
  State<_ScannerOnboardingAnim> createState() => _ScannerOnboardingAnimState();
}

class _ScannerOnboardingAnimState extends State<_ScannerOnboardingAnim>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _scanController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _laserAnim;

  int _revealedFields = 0;
  bool _scanComplete = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<double>(begin: 160.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _laserAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.05, end: 0.95), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 0.05), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 0.05, end: 0.95), weight: 25),
    ]).animate(CurvedAnimation(parent: _scanController, curve: Curves.easeInOutSine));

    _slideController.forward().then((_) {
      if (mounted) _scanController.forward();
    });

    _scanController.addListener(() {
      final val = _scanController.value;
      if (mounted) {
        setState(() {
          if (val > 0.20 && _revealedFields < 1) {
            _revealedFields = 1;
          }
          if (val > 0.50 && _revealedFields < 2) {
            _revealedFields = 2;
          }
          if (val > 0.80 && _revealedFields < 3) {
            _revealedFields = 3;
          }
          if (_scanController.isCompleted) {
            _scanComplete = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardH = constraints.maxHeight * 0.72;
        final cardW = cardH * 1.586;
        
        return Center(
          child: SizedBox(
            width: cardW,
            height: cardH,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Passport Biodata Card
                AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              child: const Icon(Icons.person_outline_rounded, color: Colors.white70, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _revealFieldWidget('SURNAME', 'KUMAR', _revealedFields >= 1),
                                  const SizedBox(height: 2),
                                  _revealFieldWidget('PASSPORT NO', 'Z1234567', _revealedFields >= 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _revealFieldWidget('NATIONALITY', 'INDIAN', _revealedFields >= 3),
                                ],
                              ),
                            ),
                            if (_scanComplete)
                              AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.elasticOut,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Color(0xFF07111F), size: 14),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Mock MRZ code
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'P<INDKUMAR<<RAHUL<<<<<<<<<<<<<<<<<<<<<<<<<<<',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 6.0, fontFamily: 'RobotoMono', letterSpacing: 0.5),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Z1234567<8IND9208154M2612316<<<<<<<<<<<<<<02',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 6.0, fontFamily: 'RobotoMono', letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 2. Glowing scan laser
                if (_slideController.isCompleted && !_scanComplete)
                  AnimatedBuilder(
                    animation: _laserAnim,
                    builder: (context, child) {
                      final topOffset = _laserAnim.value * (cardH - 14) + 7;
                      return Positioned(
                        top: topOffset,
                        left: 8,
                        right: 8,
                        child: child!,
                      );
                    },
                    child: Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // 3. Viewfinder Brackets
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ViewfinderPainter(
                        color: _scanComplete ? Colors.greenAccent : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _revealFieldWidget(String label, String value, bool revealed) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 240),
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      crossFadeState: revealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 6.0, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    const double len = 14.0;
    const double pad = 4.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2),
      const Radius.circular(20),
    );

    // Draw 4 corners
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.top + len)
        ..lineTo(r.left, r.top)
        ..lineTo(r.left + len, r.top),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(r.right - len, r.top)
        ..lineTo(r.right, r.top)
        ..lineTo(r.right, r.top + len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.bottom - len)
        ..lineTo(r.left, r.bottom)
        ..lineTo(r.left + len, r.bottom),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(r.right - len, r.bottom)
        ..lineTo(r.right, r.bottom)
        ..lineTo(r.right, r.bottom - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter old) => old.color != color;
}

// ── Step 2: NFC Biometric Verification Animation ──────────────────────────────

class _NfcOnboardingAnim extends StatefulWidget {
  const _NfcOnboardingAnim({required this.delta});
  final double delta;

  @override
  State<_NfcOnboardingAnim> createState() => _NfcOnboardingAnimState();
}

class _NfcOnboardingAnimState extends State<_NfcOnboardingAnim>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _progressController;
  late final Animation<double> _progressAnim;

  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );
    
    _progressController.forward();

    _progressController.addListener(() {
      if (_progressController.isCompleted) {
        if (mounted) {
          setState(() {
            _isVerified = true;
          });
          _pulseController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardH = constraints.maxHeight * 0.9;
        final cardW = cardH * 0.78;
        
        return Center(
          child: SizedBox(
            width: cardW + 60,
            height: cardH,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Passport Biometric Card
                Positioned(
                  bottom: 0,
                  width: cardW,
                  height: cardH * 0.74,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.fingerprint_rounded, color: Colors.white30, size: 22),
                            // Golden Biometric Chip
                            Container(
                              width: 20,
                              height: 15,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD3B77A),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black45, width: 0.5),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 70,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 100,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 2. NFC Waves
                if (!_isVerified)
                  Positioned(
                    top: cardH * 0.22,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(100, 70),
                          painter: _NfcWavePainter(
                            progress: _pulseController.value,
                          ),
                        );
                      },
                    ),
                  ),
                
                // 3. The Smartphone
                Positioned(
                  top: 0,
                  width: cardW * 0.85,
                  height: cardH * 0.42,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 100,
                        height: 76,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dynamic Island
                            Container(
                              width: 32,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Apple progress ring
                            AnimatedBuilder(
                              animation: _progressAnim,
                              builder: (context, child) {
                                return SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: _progressAnim.value,
                                        strokeWidth: 3.0,
                                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _isVerified ? Colors.greenAccent : const Color(0xFF3DC7B3),
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 280),
                                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                        child: _isVerified
                                            ? const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 28)
                                            : Text(
                                                '${(_progressAnim.value * 100).toInt()}%',
                                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Text(
                              _isVerified ? 'VERIFIED' : 'HOLD NEAR CARD',
                              style: TextStyle(
                                color: _isVerified ? Colors.greenAccent : Colors.white70,
                                fontSize: 8.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NfcWavePainter extends CustomPainter {
  _NfcWavePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 1.0 - progress)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cx = size.width / 2;
    final double radius = 8.0 + progress * 30.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, 0), radius: radius),
      math.pi * 0.25,
      math.pi * 0.5,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, 0), radius: radius - 10.0),
      math.pi * 0.25,
      math.pi * 0.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NfcWavePainter old) => old.progress != progress;
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: step.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: step.accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        step.eyebrow,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.activeIndex,
    required this.stepCount,
    required this.isLast,
    required this.onContinue,
  });

  final int activeIndex;
  final int stepCount;
  final bool isLast;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Row(
        children: <Widget>[
          Row(
            children: List<Widget>.generate(stepCount, (int index) {
              final bool active = index == activeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                width: active ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: active ? 0.95 : 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const Spacer(),
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF07111F),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: Text(
                isLast ? 'Enter SlickPort' : 'Continue',
                key: ValueKey<bool>(isLast),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.primary,
    required this.accent,
    required this.secondary,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final Color primary;
  final Color accent;
  final Color secondary;
}
