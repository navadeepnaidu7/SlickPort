import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/entry_reveal.dart';
import '../../passport/application/passport_draft_controller.dart';
import '../../passport/domain/passport_profile.dart';
import '../../passport/presentation/passport_entry_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Offset _cardDrag = Offset.zero;
  int _selectedSignal = 0;

  void _openPassportEntry() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 680),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, _, _) => const PassportEntryScreen(),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          final Animation<double> curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showActionSheet(_DashboardAction action) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ActionSheet(
          action: action,
          onPrimaryTap: action.kind == _ActionKind.scan
              ? () {
                  Navigator.of(context).pop();
                  _openPassportEntry();
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PassportProfile profile = ref.watch(passportDraftProvider);
    final List<_Signal> signals = <_Signal>[
      _Signal(
        label: 'MRZ',
        value: profile.mrzRaw.trim().isEmpty ? 'Waiting' : 'Captured',
        icon: Icons.document_scanner_rounded,
        color: const Color(0xFF4C7CFF),
      ),
      _Signal(
        label: 'Chip',
        value: 'Ready',
        icon: Icons.nfc_rounded,
        color: const Color(0xFF12BFAF),
      ),
      _Signal(
        label: 'Vault',
        value: 'Local',
        icon: Icons.lock_rounded,
        color: const Color(0xFFFFB703),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: <Widget>[
          const _InteriorBackdrop(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
              children: <Widget>[
                EntryReveal(
                  child: _DashboardHeader(onProfileTap: _openPassportEntry),
                ),
                const SizedBox(height: 22),
                EntryReveal(
                  delay: const Duration(milliseconds: 80),
                  child: GestureDetector(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        _cardDrag += details.delta;
                        _cardDrag = Offset(
                          _cardDrag.dx.clamp(-42, 42).toDouble(),
                          _cardDrag.dy.clamp(-34, 34).toDouble(),
                        );
                      });
                    },
                    onPanEnd: (_) {
                      setState(() => _cardDrag = Offset.zero);
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_cardDrag.dy / -420)
                        ..rotateY(_cardDrag.dx / 360),
                      transformAlignment: Alignment.center,
                      child: _IdentityPass(profile: profile, drag: _cardDrag),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                EntryReveal(
                  delay: const Duration(milliseconds: 150),
                  child: _SignalRail(
                    signals: signals,
                    selectedIndex: _selectedSignal,
                    onSelected: (int index) {
                      setState(() => _selectedSignal = index);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
                const SizedBox(height: 18),
                EntryReveal(
                  delay: const Duration(milliseconds: 220),
                  child: _InsightPanel(signal: signals[_selectedSignal]),
                ),
                const SizedBox(height: 18),
                EntryReveal(
                  delay: const Duration(milliseconds: 280),
                  child: _TimelinePanel(onOpenEntry: _openPassportEntry),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _CommandDock(
              onScanTap: () => _showActionSheet(_DashboardAction.scan),
              onNfcTap: () => _showActionSheet(_DashboardAction.nfc),
              onEditTap: _openPassportEntry,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteriorBackdrop extends StatelessWidget {
  const _InteriorBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF8FAFC),
            Color(0xFFEAF0F7),
            Color(0xFFF7F2EA),
          ],
        ),
      ),
      child: SizedBox.expand(
        child: CustomPaint(painter: _BackdropMeshPainter()),
      ),
    );
  }
}

class _BackdropMeshPainter extends CustomPainter {
  const _BackdropMeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = const Color(0x1A07111F)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), line);
    }

    final Paint glow = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x224C7CFF), Color(0x0019D3C5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.08,
          size.width * 0.78,
          220,
        ),
        const Radius.circular(44),
      ),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'SlickPort',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Identity workspace',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _PressableScale(
          onTap: onProfileTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.64),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF07111F)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityPass extends StatelessWidget {
  const _IdentityPass({required this.profile, required this.drag});

  final PassportProfile profile;
  final Offset drag;

  @override
  Widget build(BuildContext context) {
    final String name = profile.name.trim().isEmpty
        ? 'Passport holder'
        : profile.name;
    final String number = profile.passportNumber.trim().isEmpty
        ? 'Not added'
        : profile.passportNumber;

    return Container(
      height: 372,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF07111F).withValues(alpha: 0.22),
            blurRadius: 42,
            offset: const Offset(0, 26),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _PassBackground()),
            Positioned(
              top: 24 + drag.dy * 0.08,
              right: 24 + drag.dx * 0.08,
              child: const Icon(
                Icons.public_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              top: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const _GlassBadge(text: 'PRIVATE PASS'),
                  _GlassBadge(
                    text: profile.nationality.isEmpty
                        ? '---'
                        : profile.nationality,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PassNumberStrip(number: number),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _PassMeta(
                          label: 'DOB',
                          value: profile.dateOfBirth.isEmpty
                              ? '--'
                              : profile.dateOfBirth,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PassMeta(
                          label: 'Expiry',
                          value: profile.expiryDate.isEmpty
                              ? '--'
                              : profile.expiryDate,
                        ),
                      ),
                    ],
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

class _PassBackground extends StatelessWidget {
  const _PassBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PassPainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF06111F),
              Color(0xFF2454FF),
              Color(0xFF111827),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.14);

    for (int i = 0; i < 9; i++) {
      final Path path = Path();
      final double y = 74 + i * 18;
      path.moveTo(-20, y);
      path.cubicTo(
        size.width * 0.28,
        y - 42,
        size.width * 0.62,
        y + 42,
        size.width + 20,
        y - 10,
      );
      canvas.drawPath(path, wave);
    }

    final Paint chip = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(28, 126, 66, 52),
        const Radius.circular(14),
      ),
      chip,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white.withValues(alpha: 0.12),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _PassNumberStrip extends StatelessWidget {
  const _PassNumberStrip({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.confirmation_number_rounded,
            color: Colors.white70,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassMeta extends StatelessWidget {
  const _PassMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SignalRail extends StatelessWidget {
  const _SignalRail({
    required this.signals,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_Signal> signals;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: signals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          return _SignalPill(
            signal: signals[index],
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _SignalPill extends StatelessWidget {
  const _SignalPill({
    required this.signal,
    required this.selected,
    required this.onTap,
  });

  final _Signal signal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        width: selected ? 172 : 128,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF07111F)
              : Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: signal.color.withValues(alpha: selected ? 0.28 : 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                signal.icon,
                color: selected ? Colors.white : signal.color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    signal.label,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF07111F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    signal.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? Colors.white70
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.signal});

  final _Signal signal;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: <Widget>[
              Icon(signal.icon, color: signal.color, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${signal.label} signal',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _insightFor(signal.label),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.35,
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

  String _insightFor(String label) {
    return switch (label) {
      'MRZ' => 'Camera capture opens into a focused passport detail studio.',
      'Chip' => 'NFC verification is staged as a quiet guided session.',
      _ => 'Sensitive identity details stay in the local device flow.',
    };
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.onOpenEntry});

  final VoidCallback onOpenEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Next moves',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _PressableScale(
                onTap: onOpenEntry,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _TimelineStep(title: 'Capture details', active: true),
          const _TimelineStep(title: 'Extract MRZ', active: false),
          const _TimelineStep(title: 'Verify chip', active: false),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.title, required this.active});

  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF19D3C5) : Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandDock extends StatelessWidget {
  const _CommandDock({
    required this.onScanTap,
    required this.onNfcTap,
    required this.onEditTap,
  });

  final VoidCallback onScanTap;
  final VoidCallback onNfcTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _DockAction(
                      icon: Icons.document_scanner_rounded,
                      label: 'Scan MRZ',
                      onTap: onScanTap,
                    ),
                  ),
                  Expanded(
                    child: _DockAction(
                      icon: Icons.nfc_rounded,
                      label: 'Read chip',
                      onTap: onNfcTap,
                    ),
                  ),
                  _PressableScale(
                    onTap: onEditTap,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07111F),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockAction extends StatelessWidget {
  const _DockAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF07111F)),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({required this.action, this.onPrimaryTap});

  final _DashboardAction action;
  final VoidCallback? onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF07111F).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(action.icon, color: action.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        action.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  action.body,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: onPrimaryTap ?? () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF07111F),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: Text(action.buttonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.96 : 1,
        child: widget.child,
      ),
    );
  }
}

class _Signal {
  const _Signal({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

enum _ActionKind { scan, nfc }

class _DashboardAction {
  const _DashboardAction({
    required this.kind,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.icon,
    required this.color,
  });

  static const _DashboardAction scan = _DashboardAction(
    kind: _ActionKind.scan,
    title: 'Scan the passport face',
    body:
        'Open the capture studio, tune passport details, and prepare the MRZ data for OCR.',
    buttonLabel: 'Open capture studio',
    icon: Icons.document_scanner_rounded,
    color: Color(0xFF4C7CFF),
  );

  static const _DashboardAction nfc = _DashboardAction(
    kind: _ActionKind.nfc,
    title: 'Chip read is staged',
    body:
        'The NFC session will use MRZ-derived access keys and guide the device placement here.',
    buttonLabel: 'Got it',
    icon: Icons.nfc_rounded,
    color: Color(0xFF19D3C5),
  );

  final _ActionKind kind;
  final String title;
  final String body;
  final String buttonLabel;
  final IconData icon;
  final Color color;
}
