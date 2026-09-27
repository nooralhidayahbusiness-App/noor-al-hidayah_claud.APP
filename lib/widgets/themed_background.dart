import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme_palette.dart';
import '../core/theme_state.dart';

/// الخلفية العامة للتطبيق — تتغير مع الثيم المختار.
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
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

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
    _shift.dispose();
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
        // 1) Animated gradient — يتنقل بين الألوان
        AnimatedBuilder(
          animation: _shift,
          builder: (context, _) {
            final t = _shift.value;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + t * 0.6, -1),
                  end: Alignment(1 - t * 0.4, 1),
                  colors: [
                    widget.palette.accentDark,
                    widget.palette.accentLight,
                    widget.palette.accent,
                    widget.palette.accentLight,
                  ],
                  stops: [
                    0.0,
                    0.3 + t * 0.15,
                    0.5 + t * 0.1,
                    1.0 - t * 0.15,
                  ],
                ),
              ),
            );
          },
        ),

        // 2) النجوم المتحركة (أكبر وأوضح)
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

        // 3) Shimmer ذهبي قوي
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
                      widget.palette.gold.withValues(alpha: 0.08),
                      widget.palette.gold.withValues(alpha: 0.30),
                      widget.palette.gold.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),
        ),

        // 4) توهج نابض في المنتصف
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
                          .withValues(alpha: 0.04 + 0.10 * _glow.value),
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

      // هالة
      paint.color = gold.withValues(alpha: alpha * 0.25);
      canvas.drawCircle(Offset(x, wrapped), radius * 2.5, paint);

      // النجمة
      paint.color = gold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, wrapped), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VipStarsPainter old) =>
      old.progress != progress || old.gold != gold;
}
