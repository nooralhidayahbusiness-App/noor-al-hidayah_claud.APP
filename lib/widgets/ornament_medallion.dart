import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'glow_sparks.dart';

Offset _polar(Offset c, double r, double angle) {
  return Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
}

/// Round medallion: a plain circle with one gold 12-point star outline that
/// rotates slowly around it, and the symbol image enlarged in the middle.
class OrnamentMedallion extends StatefulWidget {
  const OrnamentMedallion({
    super.key,
    required this.size,
    required this.child,
    this.glow = true,
  });

  final double size;
  final Widget child;
  final bool glow;

  static const double _innerRatio = 0.72;

  @override
  State<OrnamentMedallion> createState() => _OrnamentMedallionState();
}

class _OrnamentMedallionState extends State<OrnamentMedallion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 50),
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final inner = size * OrnamentMedallion._innerRatio;
    final medallion = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Static base: just the disc and one thin outer ring.
          Positioned.fill(child: CustomPaint(painter: const _MedallionBasePainter())),
          // Rotating ornament: a single gold star outline, nothing else.
          RotationTransition(
            turns: _rotation,
            child: SizedBox.expand(
              child: CustomPaint(painter: const _MedallionOrnamentPainter()),
            ),
          ),
          SizedBox(width: inner, height: inner, child: ClipOval(child: widget.child)),
        ],
      ),
    );
    if (!widget.glow) return medallion;
    return GlowSparks(spread: size * 0.3, sparks: 6, child: medallion);
  }
}

class _MedallionBasePainter extends CustomPainter {
  const _MedallionBasePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(colors: [AppColors.green, AppColors.deepGreen])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(c, r * 0.97, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = AppColors.gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The rotating part: only the outer 12-point star outline.
class _MedallionOrnamentPainter extends CustomPainter {
  const _MedallionOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    final casing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.deepGreen.withValues(alpha: 0.9);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.gold;

    final star = Path();
    for (var i = 0; i < 24; i++) {
      final radius = i.isEven ? r * 0.88 : r * 0.70;
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A symbol image from assets, with a gold icon if the file is missing.
class SymbolImage extends StatelessWidget {
  const SymbolImage(this.path, {super.key, required this.fallback, this.tint = false});

  final String path;
  final IconData fallback;
  final bool tint;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.contain,
      color: tint ? AppColors.gold : null,
      colorBlendMode: tint ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) => Icon(fallback, color: AppColors.gold, size: 30),
    );
  }
}
