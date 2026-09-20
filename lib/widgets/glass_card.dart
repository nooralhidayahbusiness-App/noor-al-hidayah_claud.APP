import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'glow_sparks.dart';

/// Frosted-glass card used everywhere: gold border, gold corner ornaments,
/// a small gold ornament on top, and a glowing light with rising sparks.
/// Every new card built with this widget gets all of these automatically.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.ornament = true,
    this.glow = true,
  });

  final Widget child;
  final bool ornament;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.deepGreen.withValues(alpha: 0.72),
                  AppColors.deepGreen.withValues(alpha: 0.86),
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            child: CustomPaint(
              painter: const _CornerOrnamentsPainter(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ornament) ...[
                      const _GoldOrnament(),
                      const SizedBox(height: 14),
                    ],
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (!glow) return card;
    return GlowSparks(
      shape: GlowShape.card,
      spread: 26,
      sparks: 10,
      intensity: 0.9,
      child: card,
    );
  }
}

Offset _polar(Offset c, double r, double angle) {
  return Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
}

/// Quarter rosettes in the four corners of a card.
class _CornerOrnamentsPainter extends CustomPainter {
  const _CornerOrnamentsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final c in corners) {
      _rosette(canvas, c, 38);
    }
  }

  void _rosette(Canvas canvas, Offset c, double r) {
    final casing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.deepGreen.withValues(alpha: 0.85);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.gold.withValues(alpha: 0.75);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: 0.6);

    canvas.drawCircle(c, r * 0.98, ring);

    final star = Path();
    for (var i = 0; i < 24; i++) {
      final radius = i.isEven ? r * 0.9 : r * 0.7;
      final p = _polar(c, radius, math.pi / 12 * i - math.pi / 2);
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, casing);
    canvas.drawPath(star, line);

    final points = [
      for (var k = 0; k < 12; k++)
        _polar(c, r * 0.72, math.pi / 6 * k - math.pi / 2),
    ];
    for (var k = 0; k < 12; k++) {
      final a = points[k];
      final b = points[(k + 5) % 12];
      canvas.drawLine(a, b, casing);
      canvas.drawLine(a, b, line);
    }

    canvas.drawCircle(c, r * 0.36, ring);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoldOrnament extends StatelessWidget {
  const _GoldOrnament();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.gold.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
