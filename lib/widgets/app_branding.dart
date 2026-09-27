import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/theme_state.dart';
import '../data/store_items.dart';
import 'islamic_pattern.dart';
import 'themed_background.dart';

const bool kLogoHasName = false;

const Color _overlayTop = Color(0x66041F18);
const Color _overlayBottom = Color(0xCC041F18);

/// الخلفية العامة:
/// 1) ألوان الثيم (مع animations VIP) كأساس.
/// 2) صورة الخلفية المختارة فوقها بشفافية خفيفة.
/// 3) overlay + child.
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
        final showBackgroundImage =
            bgId != 'default' && bgItem.imagePath != null;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) طبقة الثيم (مع animations VIP)
            const ThemedBackground(child: SizedBox.expand()),

            // 2) صورة الخلفية المختارة فوق الثيم
            if (showBackgroundImage)
              Opacity(
                opacity: 0.92,
                child: Image.asset(
                  bgItem.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              )
            else if (!themeState.palette.isVip &&
                bgItem.imagePath != null &&
                bgId == 'default')
              Image.asset(
                bgItem.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _FallbackBackground(),
              ),

            // 3) overlay لتوحيد الألوان
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: showBackgroundImage
                      ? [_overlayTop, _overlayBottom]
                      : [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                ),
              ),
            ),

            // 4) المحتوى
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
