import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Frosted-glass panel with a thin gold border and a small gold ornament on top.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.ornament = true});

  final Widget child;
  final bool ornament;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.deepGreen.withValues(alpha: 0.72),
                  AppColors.deepGreen.withValues(alpha: 0.86),
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ornament) ...[
                  const _GoldOrnament(),
                  const SizedBox(height: 14),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldOrnament extends StatelessWidget {
  const _GoldOrnament();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.gold.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
