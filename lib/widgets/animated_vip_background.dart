import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// خلفية VIP متحركة: zoom بطيء + نجوم + shimmer + طبقة الثيم فوقها.
class AnimatedVipBackground extends StatefulWidget {
  const AnimatedVipBackground({
    super.key,
    required this.imagePath,
    this.overlay,
    this.child,
  });

  final String imagePath;

  /// طبقة إضافية تُرسم فوق الصورة (مثل ThemedBackground للـ VIP).
  final Widget? overlay;
  final Widget? child;

  @override
  State<AnimatedVipBackground> createState() =>
      _AnimatedVipBackgroundState();
}

class _AnimatedVipBackgroundState extends State<AnimatedVipBackground>
    with TickerProviderStateMixin {
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat(reverse: true);

  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  late final AnimationController _stars = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _zoom.dispose();
    _shimmer.dispose();
    _stars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) الصورة مع zoom بطيء
        AnimatedBuilder(
          animation: _zoom,
          builder: (context, _) {
            final scale = 1.0 + 0.08 * _zoom.value;
            return Transform.scale(
              scale: scale,
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
              ),
            );
          },
        ),

        // 2) طبقة تعتيم
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x55041F18), Color(0xBB041F18)],
            ),
          ),
        ),

        // 3) نجوم متحركة
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _stars,
            builder: (context, _) => CustomPaint(
              painter: _StarsPainter(_stars.value),
            ),
          ),
        ),

        // 4) shimmer
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
                      AppColors.gold.withValues(alpha: 0.08),
                      AppColors.gold.withValues(alpha: 0.18),
                      AppColors.gold.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),
        ),

        // 5) طبقة الثيم فوق كل شي
        if (widget.overlay != null) widget.overlay!,

        // 6) المحتوى
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final paint = Paint()..color = AppColors.gold;

    for (int i = 0; i < 25; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final baseY = rnd.nextDouble() * size.height;
      final phase = rnd.nextDouble() * math.pi * 2;
      final speed = 0.3 + rnd.nextDouble() * 0.7;
      final radius = 1.0 + rnd.nextDouble() * 1.8;

      final y = baseY - (progress * size.height * 0.3 * speed) % size.height;
      final wrappedY = (y + size.height) % size.height;
      final alpha =
          0.3 + 0.7 * (0.5 + 0.5 * math.sin(progress * 6 + phase));

      paint.color = AppColors.gold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX, wrappedY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) =>
      old.progress != progress;
}
