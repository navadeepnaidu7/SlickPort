import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'wallet_ticket_card.dart';

class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final filtered = mockTickets
        .where((t) => _filterIndex == 0
            ? t.status == TicketStatus.active
            : t.status == TicketStatus.expired)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter pills ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              _FilterPill(
                label: 'Active',
                selected: _filterIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _filterIndex = 0);
                },
              ),
              const SizedBox(width: 8),
              _FilterPill(
                label: 'Expired',
                selected: _filterIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _filterIndex = 1);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Cards ────────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(isActive: _filterIndex == 0)
              : PageView.builder(
                  padEnds: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    child: WalletTicketCard(ticket: filtered[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Filter pill ───────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F3A60) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF1F3A60)
                : Colors.black.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 44,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            isActive ? 'No active tickets' : 'No expired tickets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
