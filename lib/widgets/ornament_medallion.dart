import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/themed_colors.dart';
import '../core/theme_state.dart';
import 'glow_sparks.dart';

Offset _polar(Offset c, double r, double angle) {
  return Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
}

/// Round medallion — theme-aware.
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

    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final bg = ThemedColors.accentDark;
        final gold = ThemedColors.gold;

        final medallion = SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MedallionBasePainter(bg: bg, gold: gold),
                ),
              ),
              RotationTransition(
                turns: _rotation,
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: _MedallionOrnamentPainter(
                      bg: bg,
                      gold: gold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: inner,
                height: inner,
                child: ClipOval(child: widget.child),
              ),
            ],
          ),
        );
        if (!widget.glow) return medallion;
        return GlowSparks(
          spread: size * 0.3,
          sparks: 6,
          child: medallion,
        );
      },
    );
  }
}

class _MedallionBasePainter extends CustomPainter {
  _MedallionBasePainter({required this.bg, required this.gold});

  final Color bg;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [bg.withValues(alpha: 0.9), bg],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r * 0.97,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = gold,
    );
  }

  @override
  bool shouldRepaint(covariant _MedallionBasePainter old) =>
      old.bg != bg || old.gold != gold;
}

class _MedallionOrnamentPainter extends CustomPainter {
  _MedallionOrnamentPainter({required this.bg, required this.gold});

  final Color bg;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    final casing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeJoin = StrokeJoin.round
      ..color = bg.withValues(alpha: 0.9);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..color = gold;

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
  bool shouldRepaint(covariant _MedallionOrnamentPainter old) =>
      old.bg != bg || old.gold != gold;
}

/// A symbol image from assets, with a gold icon if the file is missing.
class SymbolImage extends StatelessWidget {
  const SymbolImage(
    this.path, {
    super.key,
    required this.fallback,
    this.tint = false,
  });

  final String path;
  final IconData fallback;
  final bool tint;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final gold = ThemedColors.gold;
        return Image.asset(
          path,
          fit: BoxFit.contain,
          color: tint ? gold : null,
          colorBlendMode: tint ? BlendMode.srcIn : null,
          errorBuilder: (context, error, stackTrace) =>
              Icon(fallback, color: gold, size: 30),
        );
      },
    );
  }
}
