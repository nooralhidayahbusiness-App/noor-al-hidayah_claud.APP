import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Set to false to turn off the glow and the sparks everywhere.
const bool kGlowEffects = true;

enum GlowShape { circle, card }

class _Spark {
  const _Spark({
    required this.x,
    required this.phase,
    required this.cycles,
    required this.size,
    required this.sway,
    required this.swayTurns,
    required this.warm,
  });

  final double x;
  final double phase;
  final int cycles;
  final double size;
  final double sway;
  final double swayTurns;
  final bool warm;

  factory _Spark.random(math.Random r) {
    return _Spark(
      x: -0.05 + r.nextDouble() * 1.1,
      phase: r.nextDouble(),
      cycles: 1 + r.nextInt(2),
      size: 1.2 + r.nextDouble() * 2.2,
      sway: 2 + r.nextDouble() * 6,
      swayTurns: 1 + r.nextDouble() * 2,
      warm: r.nextBool(),
    );
  }
}

/// A soft golden light behind [child] with golden sparks rising from it.
/// The effect is painted outside the borders of [child] (no hard edge).
class GlowSparks extends StatefulWidget {
  const GlowSparks({
    super.key,
    required this.child,
    this.shape = GlowShape.circle,
    this.spread = 26,
    this.sparks = 8,
    this.intensity = 1.0,
  });

  final Widget child;
  final GlowShape shape;
  final double spread;
  final int sparks;
  final double intensity;

  @override
  State<GlowSparks> createState() => _GlowSparksState();
}

class _GlowSparksState extends State<GlowSparks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Spark> _sparks;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _sparks = List.generate(widget.sparks, (_) => _Spark.random(random));
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 6000 + random.nextInt(3000)),
    );
    if (kGlowEffects) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kGlowEffects) return widget.child;
    final s = widget.spread;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -s,
          right: -s,
          top: -s * 2.2,
          bottom: -s,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _GlowPainter(
                  animation: _controller,
                  sparks: _sparks,
                  shape: widget.shape,
                  spread: s,
                  intensity: widget.intensity,
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.animation,
    required this.sparks,
    required this.shape,
    required this.spread,
    required this.intensity,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Spark> sparks;
  final GlowShape shape;
  final double spread;
  final double intensity;

  Color _gold(double alpha) =>
      AppColors.gold.withValues(alpha: alpha.clamp(0.0, 1.0).toDouble());

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final inner = Rect.fromLTRB(
      spread,
      spread * 2.2,
      size.width - spread,
      size.height - spread,
    );
    if (inner.width <= 0 || inner.height <= 0) return;

    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
    final glow = (0.20 + 0.16 * pulse) * intensity;

    // Soft light behind the widget
    if (shape == GlowShape.circle) {
      final c = inner.center;
      final radius = inner.width / 2 + spread * (0.9 + 0.25 * pulse);
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [_gold(glow), _gold(glow * 0.35), Colors.transparent],
            stops: const [0.55, 0.8, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(26)),
        Paint()
          ..color = _gold(glow * 0.9)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, spread * 0.8),
      );
    }

    // Golden sparks rising
    final startY = shape == GlowShape.circle
        ? inner.bottom - inner.height * 0.30
        : inner.bottom - inner.height * 0.10;
    final rise = shape == GlowShape.circle
        ? inner.height * 0.30 + spread * 2.0
        : inner.height * 0.85 + spread * 2.0;

    for (final s in sparks) {
      final p = (t * s.cycles + s.phase) % 1.0;
      final y = startY - p * rise;
      final x = inner.left +
          s.x * inner.width +
          math.sin(p * 2 * math.pi * s.swayTurns + s.phase * 6.28) * s.sway;
      final alpha =
          (math.sin(p * math.pi) * 0.95 * intensity).clamp(0.0, 1.0).toDouble();
      if (alpha <= 0.02) continue;
      final color = s.warm ? AppColors.gold : AppColors.softGold;
      final radius = s.size * (0.6 + 0.6 * (1 - p));
      canvas.drawCircle(
        Offset(x, y),
        radius * 3.2,
        Paint()..color = color.withValues(alpha: alpha * 0.16),
      );
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.spread != spread ||
      oldDelegate.intensity != intensity;
}
