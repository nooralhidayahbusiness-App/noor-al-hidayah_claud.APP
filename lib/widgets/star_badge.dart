import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

/// Gold eight-point star with a number inside (surah and ayah numbers).
class StarBadge extends StatelessWidget {
  const StarBadge({super.key, required this.number, this.size = 40});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: const _StarBadgePainter(),
        child: Center(
          child: Text(
            '$number',
            style: GoogleFonts.cinzel(
              fontSize: size * (number >= 100 ? 0.27 : 0.34),
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarBadgePainter extends CustomPainter {
  const _StarBadgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final radius = i.isEven ? r : r * 0.8;
      final angle = math.pi / 8 * i - math.pi / 2;
      final p = Offset(
        c.dx + radius * math.cos(angle),
        c.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.deepGreen.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.gold,
    );
    canvas.drawCircle(
      c,
      r * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.gold.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
