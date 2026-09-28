import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/responsive.dart';
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
    final iconSize = R.s(context, 82);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        ornament: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: const SymbolImage(
                'assets/images/ai-teacher.png',
                fallback: Icons.school_rounded,
                tint: true,
              ),
            ),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            title,
                            maxLines: 1,
                            softWrap: false,
                            style: brandStyle(
                              title,
                              fontSize: R.f(context, 20),
                              color: AppColors.softGold,
                              shadows: [
                                Shadow(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.5),
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
                      ),
                      SizedBox(width: R.s(context, 6)),
                      const _AiBadge(),
                    ],
                  ),
                  SizedBox(height: R.s(context, 4)),
                  Text(
                    appState.tr('teacherDesc'),
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      height: 1.5,
                      color: AppColors.cream.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: R.s(context, 8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 10),
                      vertical: R.s(context, 5),
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
                          style: TextStyle(
                            fontSize: R.f(context, 11),
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        SizedBox(width: R.s(context, 4)),
                        Icon(
                          rtl
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          size: R.s(context, 13),
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
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 7),
        vertical: R.s(context, 3),
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: R.s(context, 11), color: AppColors.deepGreen),
          SizedBox(width: R.s(context, 3)),
          Text(
            'AI',
            style: TextStyle(
              fontSize: R.f(context, 10),
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
