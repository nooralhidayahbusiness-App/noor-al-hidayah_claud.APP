import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

Path _starPath(Offset c, double r, {double inner = 0.72}) {
  final path = Path();
  for (int i = 0; i < 16; i++) {
    final angle = (math.pi / 8) * i - math.pi / 2;
    final radius = i.isEven ? r : r * inner;
    final x = c.dx + radius * math.cos(angle);
    final y = c.dy + radius * math.sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

/// Soft repeating Islamic star pattern (used as a fallback background).
class IslamicPattern extends StatelessWidget {
  const IslamicPattern({super.key, this.opacity = 0.09, this.cell = 84});

  final double opacity;
  final double cell;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PatternPainter(opacity: opacity, cell: cell),
        size: Size.infinite,
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.opacity, required this.cell});

  final double opacity;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final half = cell / 2;
    for (double y = 0; y <= size.height + cell; y += cell) {
      for (double x = 0; x <= size.width + cell; x += cell) {
        canvas.drawPath(_starPath(Offset(x, y), cell * 0.42), paint);
        canvas.drawPath(
          _starPath(Offset(x + half, y + half), cell * 0.2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.cell != cell;
}

/// Fallback logo (crescent + star) drawn in code.
class NoorLogo extends StatelessWidget {
  const NoorLogo({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.30),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    canvas.drawPath(
      _starPath(c, r * 0.96, inner: 0.84),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.gold.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      c,
      r * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.gold.withValues(alpha: 0.85),
    );

    final goldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.softGold, AppColors.gold],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final moon = Path()
      ..addOval(Rect.fromCircle(center: c.translate(-r * 0.06, 0), radius: r * 0.42));
    final cut = Path()
      ..addOval(Rect.fromCircle(center: c.translate(r * 0.13, -r * 0.03), radius: r * 0.36));
    canvas.drawPath(Path.combine(PathOperation.difference, moon, cut), goldPaint);

    canvas.drawPath(_starPath(c.translate(r * 0.23, 0), r * 0.13), goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
