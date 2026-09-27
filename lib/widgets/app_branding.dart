import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/theme_state.dart';
import 'islamic_pattern.dart';

/// Set to true if your logo.png already contains the app name.
const bool kLogoHasName = false;

/// Background darkening.
const Color _overlayTop = Color(0x66041F18);
const Color _overlayBottom = Color(0xCC041F18);

/// Full-screen dynamic background.
/// يقرأ themeState.backgroundId ويطبّق Hue Shift على الصورة الأصلية.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.child});

  final Widget? child;

  /// Hue rotation degrees لكل خلفية.
  static const Map<String, double> hueShifts = {
    'default': 0,
    'night': 120,
    'sunset': -90,
    'mosque': -40,
    'kaaba': 180,
    'ramadan': 160,
    'floral': -30,
  };

  /// معامل السطوع (1.0 = طبيعي، أقل = أغمق).
  static const Map<String, double> brightness = {
    'default': 1.0,
    'night': 0.85,
    'kaaba': 0.55,
    'mosque': 0.75,
    'ramadan': 0.85,
  };

  static ColorFilter _filter(double hueDeg, double bright) {
    final rad = hueDeg * math.pi / 180.0;
    final c = math.cos(rad);
    final s = math.sin(rad);

    final rr = 0.213 + c * 0.787 - s * 0.213;
    final rg = 0.715 - c * 0.715 - s * 0.715;
    final rb = 0.072 - c * 0.072 + s * 0.928;
    final gr = 0.213 - c * 0.213 + s * 0.143;
    final gg = 0.715 + c * 0.285 + s * 0.140;
    final gb = 0.072 - c * 0.072 - s * 0.283;
    final br = 0.213 - c * 0.213 - s * 0.787;
    final bg = 0.715 - c * 0.715 + s * 0.715;
    final bb = 0.072 + c * 0.928 + s * 0.072;

    return ColorFilter.matrix(<double>[
      rr * bright, rg * bright, rb * bright, 0, 0,
      gr * bright, gg * bright, gb * bright, 0, 0,
      br * bright, bg * bright, bb * bright, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final id = themeState.backgroundId;
        final hue = hueShifts[id] ?? 0;
        final bright = brightness[id] ?? 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: _filter(hue, bright),
              child: Image.asset(
                'assets/images/backgrounds/backgroundv2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _FallbackBackground(),
              ),
            ),
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
