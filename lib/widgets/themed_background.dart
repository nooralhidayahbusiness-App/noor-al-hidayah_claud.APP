import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme_palette.dart';
import '../core/theme_state.dart';

/// الخلفية العامة للتطبيق — تتغير مع الثيم المختار.
/// تدعم الأنيميشن تلقائياً للثيمات VIP.
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
          return _AnimatedVipTheme(palette: palette, child: child);
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.accent, palette.accentDark],
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class _AnimatedVipTheme extends StatefulWidget {
  const _AnimatedVipTheme({required this.palette, required this.child});

  final ThemePalette palette;
  final Widget child;

  @override
  State<_AnimatedVipTheme> createState() => _AnimatedVipThemeState();
}

class _AnimatedVipThemeState extends State<_AnimatedVipTheme>
    with TickerProviderStateMixin {
  late final AnimationController _shift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  late final AnimationController _stars = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 25),
  )..repeat();

  @override
  void dispose() {
    _shift.dispose();
    _shimmer.dispose();
    _stars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Animated gradient
        AnimatedBuilder(
          animation: _shift,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + _shift.value * 0.3, -1),
                  end: Alignment(1, 1 - _shift.value * 0.3),
                  colors: [
                    widget.palette.accent,
                    widget.palette.accentLight,
                    widget.palette.accentDark,
                  ],
                  stops: [0.0, 0.4 + _shift.value * 0.2, 1.0],
                ),
              ),
            );
          },
        ),
        // Stars
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _stars,
            builder: (context, _) => CustomPaint(
              painter: _VipStarsPainter(_stars.value),
            ),
          ),
        ),
        // Shimmer overlay
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _shimmer,
            builder: (context, _) {
              final t = _shimmer.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 - 2 * (1 - t), -0.5),
                    end: Alignment(-1 + 2 * t + 1, 0.5),
                    colors: [
                      Colors.transparent,
                      widget.palette.gold.withValues(alpha: 0.06),
                      widget.palette.gold.withValues(alpha: 0.15),
                      widget.palette.gold.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _VipStarsPainter extends CustomPainter {
  _VipStarsPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(99);
    final paint = Paint()..color = const Color(0xFFD4AF37);
    for (int i = 0; i < 30; i++) {
      final x = rnd.nextDouble() * size.width;
      final baseY = rnd.nextDouble() * size.height;
      final phase = rnd.nextDouble() * math.pi * 2;
      final speed = 0.3 + rnd.nextDouble() * 0.6;
      final radius = 0.8 + rnd.nextDouble() * 1.6;

      final y =
          baseY - (progress * size.height * 0.25 * speed) % size.height;
      final wrapped = (y + size.height) % size.height;
      final alpha =
          0.3 + 0.6 * (0.5 + 0.5 * math.sin(progress * 6 + phase));
      paint.color = const Color(0xFFD4AF37).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, wrapped), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VipStarsPainter old) =>
      old.progress != progress;
}
