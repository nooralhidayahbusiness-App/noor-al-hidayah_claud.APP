import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/theme.dart';
import 'glass_card.dart';
import 'ornament_medallion.dart';

/// Main entry of the AI Quran teacher, shown on the home screen.
class AiTeacherCard extends StatelessWidget {
  const AiTeacherCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = appState.tr('teacherTitle');
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        ornament: false,
        child: Row(
          children: [
            const SizedBox(
              width: 120,
              height: 120,
              child: SymbolImage(
                'assets/images/ai-teacher.png',
                fallback: Icons.school_rounded,
                tint: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: brandStyle(
                            title,
                            fontSize: 30,
                            color: AppColors.softGold,
                            shadows: [
                              Shadow(
                                color: AppColors.gold.withValues(alpha: 0.5),
                                blurRadius: 16,
                              ),
                              const Shadow(
                                color: Color(0xCC000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const _AiBadge(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appState.tr('teacherDesc'),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.cream.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.gold.withValues(alpha: 0.14),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appState.tr('teacherCta'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          rtl
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.softGold, AppColors.gold],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.deepGreen),
          SizedBox(width: 4),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}
