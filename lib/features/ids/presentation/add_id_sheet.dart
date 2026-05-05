import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/id_document.dart';

class AddIdSheet extends StatelessWidget {
  const AddIdSheet({super.key, required this.onSelectType});

  final void Function(IdDocumentType) onSelectType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, -10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add ID Card',
                      style: TextStyle(
                          color: Color(0xFF1C1C1E),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Choose the type of ID to add",
                      style:
                          TextStyle(color: Color(0xFF8E8E93), fontSize: 15)),
                ),
                const SizedBox(height: 24),
                _IdOption(
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFF1C3252),
                  title: 'PAN Card',
                  subtitle: 'Permanent Account Number — Income Tax India',
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectType(IdDocumentType.pan);
                  },
                ),
                const SizedBox(height: 12),
                _IdOption(
                  icon: Icons.fingerprint_rounded,
                  iconColor: const Color(0xFF003F87),
                  title: 'Aadhaar Card',
                  subtitle: 'UIDAI 12-digit biometric identity',
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectType(IdDocumentType.aadhaar);
                  },
                ),
                const SizedBox(height: 12),
                _IdOption(
                  icon: Icons.drive_eta_rounded,
                  iconColor: const Color(0xFF8E8E93),
                  title: 'Driving Licence',
                  subtitle: 'State-issued driving licence',
                  onTap: () {},
                  comingSoon: true,
                ),
                const SizedBox(height: 12),
                _IdOption(
                  icon: Icons.how_to_vote_rounded,
                  iconColor: const Color(0xFF8E8E93),
                  title: 'Voter ID',
                  subtitle: 'Election Commission of India',
                  onTap: () {},
                  comingSoon: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdOption extends StatefulWidget {
  const _IdOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool comingSoon;

  @override
  State<_IdOption> createState() => _IdOptionState();
}

class _IdOptionState extends State<_IdOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        if (widget.comingSoon) return;
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.97 : 1.0,
        child: Opacity(
          opacity: widget.comingSoon ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(widget.icon, color: widget.iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.title,
                              style: const TextStyle(
                                  color: Color(0xFF1C1C1E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          if (widget.comingSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE5E5EA),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Text('Soon',
                                  style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(widget.subtitle,
                          style: const TextStyle(
                              color: Color(0xFF8E8E93), fontSize: 13)),
                    ],
                  ),
                ),
                if (!widget.comingSoon)
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFC7C7CC), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
