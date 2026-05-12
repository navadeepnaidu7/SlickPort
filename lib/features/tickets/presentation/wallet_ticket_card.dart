import 'package:flutter/material.dart';

// ── Mock data model ───────────────────────────────────────────────────────────

enum TicketStatus { active, expired }

class MockTicket {
  const MockTicket({
    required this.id,
    required this.operator,
    required this.trainName,
    required this.fromCode,
    required this.fromName,
    required this.toCode,
    required this.toName,
    required this.departTime,
    required this.arriveTime,
    required this.date,
    required this.duration,
    required this.ticketClass,
    required this.coach,
    required this.seat,
    required this.berth,
    required this.passengerName,
    required this.pnr,
    required this.bookingId,
    required this.status,
    this.progressFraction = 0.45,
  });

  final String id;
  final String operator;
  final String trainName;
  final String fromCode;
  final String fromName;
  final String toCode;
  final String toName;
  final String departTime;
  final String arriveTime;
  final String date;
  final String duration;
  final String ticketClass;
  final String coach;
  final String seat;
  final String berth;
  final String passengerName;
  final String pnr;
  final String bookingId;
  final TicketStatus status;
  final double progressFraction;
}

final List<MockTicket> mockTickets = [
  const MockTicket(
    id: 'mock_t1',
    operator: 'IRCTC',
    trainName: '12427 RAJDHANI EXPRESS',
    fromCode: 'NZM',
    fromName: 'H. Nizamuddin',
    toCode: 'NDLS',
    toName: 'New Delhi',
    departTime: '08:40',
    arriveTime: '13:10',
    date: '23 Mar, 2024',
    duration: '4h 30m',
    ticketClass: 'AC 2 Tier',
    coach: 'B2',
    seat: '23',
    berth: 'LB',
    passengerName: 'Navadeep Naidu',
    pnr: '2432587612',
    bookingId: 'E12345678',
    status: TicketStatus.active,
    progressFraction: 0.48,
  ),
  const MockTicket(
    id: 'mock_t2',
    operator: 'IRCTC',
    trainName: '12951 MUMBAI RAJDHANI',
    fromCode: 'NDLS',
    fromName: 'New Delhi',
    toCode: 'BCT',
    toName: 'Mumbai Central',
    departTime: '16:55',
    arriveTime: '08:15',
    date: '10 Jan, 2024',
    duration: '15h 20m',
    ticketClass: 'AC 3 Tier',
    coach: 'A1',
    seat: '45',
    berth: 'UB',
    passengerName: 'Navadeep Naidu',
    pnr: '8821456730',
    bookingId: 'E98765432',
    status: TicketStatus.expired,
    progressFraction: 1.0,
  ),
];

// ── Ticket card widget ────────────────────────────────────────────────────────

class WalletTicketCard extends StatelessWidget {
  const WalletTicketCard({super.key, required this.ticket});
  final MockTicket ticket;

  @override
  Widget build(BuildContext context) {
    final bool isActive = ticket.status == TicketStatus.active;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main body ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Operator row
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A3E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.train_rounded,
                            color: Color(0xFF4C7CFF), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(ticket.operator,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('PNR',
                              style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8)),
                          Text(ticket.pnr,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.qr_code_2_rounded,
                          color: Colors.white.withValues(alpha: 0.5), size: 26),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Train name + status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A3E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(ticket.trainName,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF34C759)
                              : const Color(0xFF8E8E93),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isActive ? 'ON TIME' : 'COMPLETED',
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF34C759)
                              : const Color(0xFF8E8E93),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Route row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket.fromName,
                              style: const TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 11)),
                          Text(ticket.fromCode,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5)),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  painter: _DashedLinePainter(),
                                  child: const SizedBox(height: 1),
                                ),
                              ),
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A3E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.train_rounded,
                                    color: Colors.white70, size: 18),
                              ),
                              Expanded(
                                child: CustomPaint(
                                  painter: _DashedLinePainter(),
                                  child: const SizedBox(height: 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(ticket.toName,
                              style: const TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 11)),
                          Text(ticket.toCode,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Times row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket.departTime,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          Text(ticket.date,
                              style: const TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 11)),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    color: Color(0xFF8E8E93), size: 12),
                                const SizedBox(width: 3),
                                Text(ticket.duration,
                                    style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${ticket.ticketClass}  •  ${ticket.coach}  •  ${ticket.seat}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(ticket.arriveTime,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          Text(ticket.date,
                              style: const TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Live status bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFF8E8E93),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'LIVE STATUS' : 'JOURNEY STATUS',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(ticket.fromCode,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _ProgressTrack(
                                    progress: ticket.progressFraction,
                                    isActive: isActive),
                              ),
                            ),
                            Text(ticket.toCode,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isActive
                              ? 'Running on time'
                              : 'Journey completed',
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF34C759)
                                : const Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Passenger row
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          color: Color(0xFF8E8E93), size: 22),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PASSENGER',
                              style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8)),
                          Text(ticket.passengerName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('COACH & SEAT',
                              style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8)),
                          Row(
                            children: [
                              Text(
                                '${ticket.coach}  •  ${ticket.seat}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A3E),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.white24, width: 0.5),
                                ),
                                child: Text(ticket.berth,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Perforated divider ─────────────────────────────────────
            _PerforatedDivider(),

            // ── QR + booking ID section ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        color: Colors.black, size: 56),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFF8E8E93),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'CONFIRMED' : 'COMPLETED',
                              style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFF8E8E93),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isActive
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.history_rounded,
                              color: isActive
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFF8E8E93),
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(ticket.bookingId,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                        const Text('Booking ID',
                            style: TextStyle(
                                color: Color(0xFF8E8E93), fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF8E8E93), size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters & helpers ────────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    const dashW = 4.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress, required this.isActive});
  final double progress;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final filled = w * progress.clamp(0.0, 1.0);
      return SizedBox(
        height: 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Track
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Filled
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: filled,
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF34C759)
                      : const Color(0xFF8E8E93),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Train icon at progress point
            Positioned(
              left: (filled - 14).clamp(0, w - 28),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF34C759)
                        : const Color(0xFF8E8E93),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.train_rounded,
                    size: 14,
                    color: isActive
                        ? const Color(0xFF34C759)
                        : const Color(0xFF8E8E93)),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PerforatedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          // Left notch
          Container(
            width: 12, height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
          // Dashed line
          Expanded(
            child: CustomPaint(
              painter: _HorizontalDashPainter(),
              child: const SizedBox(height: 1),
            ),
          ),
          // Right notch
          Container(
            width: 12, height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1.5;
    const dashW = 6.0;
    const gap = 5.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashW, y), paint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
