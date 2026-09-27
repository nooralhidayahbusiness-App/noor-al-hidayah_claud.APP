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

/// الخلفية العامة:
/// - أولوية 1: خلفية VIP (backgroundvip1/2/3) → AnimatedVipBackground.
/// - أولوية 2: ثيم VIP (vip_emperor/cosmic/crimson) → ThemedBackground متحرك.
/// - أولوية 3: خلفية عادية (صورة ثابتة + overlay).
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
        final palette = themeState.palette;

        final isVipBg = bgItem.isVip &&
            bgItem.isAnimated &&
            bgItem.imagePath != null;
        final isVipTheme = palette.isVip && palette.isAnimated;

        // أولوية 1: خلفية VIP متحركة
        if (isVipBg) {
          return AnimatedVipBackground(
            imagePath: bgItem.imagePath!,
            child: child,
          );
        }

        // أولوية 2: ثيم VIP متحرك (مع إخفاء صورة الخلفية كي يظهر الأنيميشن)
        if (isVipTheme) {
          return ThemedBackground(
            child: child ?? const SizedBox.expand(),
          );
        }

        // أولوية 3: عادي
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
