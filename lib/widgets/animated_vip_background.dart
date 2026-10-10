import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// بيانات نجمة واحدة (تُحسب مرة واحدة بدل كل إطار)
class _StarData {
  const _StarData({
    required this.fx,
    required this.fy,
    required this.phase,
    required this.speed,
    required this.radius,
  });

  final double fx;
  final double fy;
  final double phase;
  final double speed;
  final double radius;
}

/// نفس القيم العشوائية السابقة (Random(42)) → نفس الشكل بالضبط
final List<_StarData> _kStars = () {
  final rnd = math.Random(42);
  return List<_StarData>.generate(25, (_) {
    final fx = rnd.nextDouble();
    final fy = rnd.nextDouble();
    final phase = rnd.nextDouble() * math.pi * 2;
    final speed = 0.3 + rnd.nextDouble() * 0.7;
    final radius = 1.0 + rnd.nextDouble() * 1.8;
    return _StarData(
      fx: fx,
      fy: fy,
      phase: phase,
      speed: speed,
      radius: radius,
    );
  });
}();

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
        // ✅ الصورة في طبقة مستقلة: التكبير يتم على مستوى الـ GPU بدون إعادة رسمها
        AnimatedBuilder(
          animation: _zoom,
          child: RepaintBoundary(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          builder: (context, child) {
            final scale = 1.0 + 0.08 * _zoom.value;
            return Transform.scale(
              scale: scale,
              child: child,
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
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _stars,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _StarsPainter(_stars.value),
              ),
            ),
          ),
        ),

        // 4) shimmer
        IgnorePointer(
          child: RepaintBoundary(
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
    final paint = Paint();

    for (final star in _kStars) {
      final baseX = star.fx * size.width;
      final baseY = star.fy * size.height;

      final y = baseY -
          (progress * size.height * 0.3 * star.speed) % size.height;
      final wrappedY = (y + size.height) % size.height;
      final alpha =
          0.3 + 0.7 * (0.5 + 0.5 * math.sin(progress * 6 + star.phase));

      paint.color = AppColors.gold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX, wrappedY), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) =>
      old.progress != progress;
}
