import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme_palette.dart';
import '../core/theme_state.dart';

/// الخلفية الشفافة للثيم — تعمل فوق صورة الخلفية.
class ThemedBackground extends StatelessWidget {
  const ThemedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final palette = themeState.palette;
        if (palette.isVip && palette.isAnimated) {
          return _AnimatedVipOverlay(palette: palette, child: child);
        }
        // ثيم عادي: طبقة شفافة بلون خفيف
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.accent.withValues(alpha: 0.35),
                    palette.accentDark.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}

class _AnimatedVipOverlay extends StatefulWidget {
  const _AnimatedVipOverlay({required this.palette, required this.child});

  final ThemePalette palette;
  final Widget child;

  @override
  State<_AnimatedVipOverlay> createState() => _AnimatedVipOverlayState();
}

class _AnimatedVipOverlayState extends State<_AnimatedVipOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  late final AnimationController _stars = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _shimmer.dispose();
    _stars.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) طبقة تلوين شفافة (يمكن للخلفية أن تظهر تحتها)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.palette.accent.withValues(alpha: 0.55),
                widget.palette.accentDark.withValues(alpha: 0.75),
              ],
            ),
          ),
        ),

        // 2) نجوم متحركة
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _stars,
            builder: (context, _) => CustomPaint(
              painter: _VipStarsPainter(
                progress: _stars.value,
                gold: widget.palette.gold,
              ),
            ),
          ),
        ),

        // 3) Shimmer ذهبي
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _shimmer,
            builder: (context, _) {
              final t = _shimmer.value;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 - 2 * (1 - t), -0.5),
                    end: Alignment(-1 + 2 * t + 1, 0.5),
                    colors: [
                      Colors.transparent,
                      widget.palette.gold.withValues(alpha: 0.05),
                      widget.palette.gold.withValues(alpha: 0.20),
                      widget.palette.gold.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),
        ),

        // 4) توهج نابض
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.7 + _glow.value * 0.4,
                    colors: [
                      widget.palette.gold
                          .withValues(alpha: 0.03 + 0.08 * _glow.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 5) المحتوى
        widget.child,
      ],
    );
  }
}

class _VipStarsPainter extends CustomPainter {
  _VipStarsPainter({required this.progress, required this.gold});

  final double progress;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(99);
    final paint = Paint();

    for (int i = 0; i < 45; i++) {
      final x = rnd.nextDouble() * size.width;
      final baseY = rnd.nextDouble() * size.height;
      final phase = rnd.nextDouble() * math.pi * 2;
      final speed = 0.25 + rnd.nextDouble() * 0.6;
      final radius = 1.5 + rnd.nextDouble() * 2.5;

      final y =
          baseY - (progress * size.height * 0.45 * speed) % size.height;
      final wrapped = (y + size.height) % size.height;
      final alpha =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(progress * 8 + phase));

      paint.color = gold.withValues(alpha: alpha * 0.25);
      canvas.drawCircle(Offset(x, wrapped), radius * 2.5, paint);

      paint.color = gold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, wrapped), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VipStarsPainter old) =>
      old.progress != progress || old.gold != gold;
}
