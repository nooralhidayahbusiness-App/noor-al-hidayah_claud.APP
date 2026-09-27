import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/theme_state.dart';
import '../data/store_items.dart';
import 'animated_vip_background.dart';
import 'islamic_pattern.dart';
import 'themed_background.dart';

const bool kLogoHasName = false;

const Color _overlayTop = Color(0x66041F18);
const Color _overlayBottom = Color(0xCC041F18);

/// الخلفية العامة — الصورة + طبقة الثيم فوقها.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final bgId = themeState.backgroundId;
        final bgItem = findItem('background', bgId) ??
            findItem('background', 'default')!;
        final isVipBg =
            bgItem.isVip && bgItem.isAnimated && bgItem.imagePath != null;

        // خلفية VIP متحركة (صورة + zoom + نجوم)
        if (isVipBg) {
          return AnimatedVipBackground(
            imagePath: bgItem.imagePath!,
            overlay: const ThemedBackground(child: SizedBox.expand()),
            child: child,
          );
        }

        // عادي: صورة + طبقة الثيم الشفافة فوقها
        return Stack(
          fit: StackFit.expand,
          children: [
            if (bgItem.imagePath != null)
              Image.asset(
                bgItem.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _FallbackBackground(),
              )
            else
              const _FallbackBackground(),

            // overlay أساسي للصور العادية
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_overlayTop, _overlayBottom],
                ),
              ),
            ),

            // طبقة الثيم (نجوم + shimmer للـ VIP)
            const ThemedBackground(child: SizedBox.expand()),

            if (child != null) child!,
          ],
        );
      },
    );
  }
}

class _FallbackBackground extends StatelessWidget {
  const _FallbackBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.green, AppColors.deepGreen],
        ),
      ),
      child: SizedBox.expand(child: IslamicPattern()),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.4,
      height: size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  NoorLogo(size: size),
            ),
          ),
        ],
      ),
    );
  }
}
