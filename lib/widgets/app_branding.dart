import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/theme_state.dart';
import '../data/store_items.dart';
import 'animated_vip_background.dart';
import 'islamic_pattern.dart';

const bool kLogoHasName = false;

const Color _overlayTop = Color(0x66041F18);
const Color _overlayBottom = Color(0xCC041F18);

/// الخلفية العامة — تعرض الصورة المناسبة بناءً على themeState.backgroundId.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final id = themeState.backgroundId;
        final item = findItem('background', id) ??
            findItem('background', 'default')!;

        // VIP متحركة
        if (item.isVip && item.isAnimated && item.imagePath != null) {
          return AnimatedVipBackground(
            imagePath: item.imagePath!,
            child: child,
          );
        }

        // عادية
        return Stack(
          fit: StackFit.expand,
          children: [
            if (item.imagePath != null)
              Image.asset(
                item.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _FallbackBackground(),
              )
            else
              const _FallbackBackground(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_overlayTop, _overlayBottom],
                ),
              ),
            ),
            ?child,
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

/// App logo with a soft golden glow.
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
