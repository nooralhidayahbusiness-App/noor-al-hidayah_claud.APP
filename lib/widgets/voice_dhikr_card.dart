import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/navigation.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../screens/voice_dhikr_screen.dart';
import 'glass_card.dart';

/// بطاقة «بصوتك» في الصفحة الرئيسية: عدّاد الأذكار بالصوت.
class VoiceDhikrCard extends StatefulWidget {
  const VoiceDhikrCard({super.key});

  @override
  State<VoiceDhikrCard> createState() => _VoiceDhikrCardState();
}

class _VoiceDhikrCardState extends State<VoiceDhikrCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final ar = appState.isArabic;
        final title = ar ? 'بصوتك' : 'By Your Voice';
        final details = ar
            ? 'اختر الاستغفار أو التسبيح أو التحميد أو التكبير بأي عدد (33 • 99 • 100 • 1000 أو عدد تحدده)، ثم ردّد بصوتك — يفتح الميكروفون والعدّاد يحسب كل مرة تنطق فيها.'
            : 'Pick istighfar, tasbih, tahmid or takbir with any count (33 • 99 • 100 • 1000 or your own), then say it aloud — the microphone opens and the counter follows you.';

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            fadeRoute(const VoiceDhikrScreen()),
          ),
          child: GlassCard(
            child: Row(
              children: [
                // أيقونة الميكروفون النابضة
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final p = _pulse.value;
                    return Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.16),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.8),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold
                                .withValues(alpha: 0.18 + 0.30 * p),
                            blurRadius: 10 + 14 * p,
                            spreadRadius: 1 + 3 * p,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.mic_rounded,
                    color: AppColors.gold,
                    size: 32,
                  ),
                ),
                SizedBox(width: R.s(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: brandStyle(
                          title,
                          fontSize: R.f(context, 30),
                          color: AppColors.softGold,
                          shadows: [
                            Shadow(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: R.s(context, 4)),
                      Text(
                        details,
                        style: TextStyle(
                          fontSize: R.f(context, 12),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: AppColors.cream.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.s(context, 6)),
                Icon(
                  ar
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: AppColors.gold.withValues(alpha: 0.85),
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
