import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/tts_service.dart';

/// شريط كبير أعلى شاشة الأذكار/الأدعية: زر تشغيل لقراءة القسم كاملاً بصوت مسموع.
class ReadAloudBanner extends StatelessWidget {
  const ReadAloudBanner({
    super.key,
    required this.sessionKey,
    required this.title,
    required this.items,
    required this.lang,
  });

  /// مفتاح فريد للقسم (مثل adhkar:morning)
  final String sessionKey;

  /// اسم القسم (مثل: أذكار الصباح)
  final String title;

  /// النصوص التي ستُقرأ بالترتيب
  final List<String> items;

  /// لغة الصوت (مثل ar-SA أو en-US)
  final String lang;

  static const List<double> _rates = [0.35, 0.45, 0.6];
  static const List<String> _rateLabels = ['0.8x', '1x', '1.3x'];

  @override
  Widget build(BuildContext context) {
    final ar = appState.isArabic;

    return ListenableBuilder(
      listenable: ttsService,
      builder: (context, _) {
        final active = ttsService.activeKey == sessionKey;
        final playing = active && ttsService.status == TtsStatus.playing;
        final paused = active && ttsService.status == TtsStatus.paused;
        final hasError = ttsService.errorKey == sessionKey &&
            (ttsService.error ?? '').isNotEmpty;

        final progress = active ? '${ttsService.index + 1} / ${items.length}' : '';

        String subtitle;
        if (playing) {
          subtitle = ar ? 'جارٍ القراءة…  $progress' : 'Reading…  $progress';
        } else if (paused) {
          subtitle = ar ? 'متوقف مؤقتاً  $progress' : 'Paused  $progress';
        } else {
          subtitle = ar
              ? 'اضغط للاستماع إلى القسم كاملاً'
              : 'Tap to listen to the whole section';
        }

        var rateIndex = 1;
        for (int i = 0; i < _rates.length; i++) {
          if ((ttsService.rate - _rates[i]).abs() < 0.01) rateIndex = i;
        }

        return Container(
          padding: EdgeInsets.all(R.s(context, 12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.gold.withValues(alpha: 0.22),
                AppColors.deepGreen.withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: playing ? 0.95 : 0.55),
              width: playing ? 2 : 1.4,
            ),
            boxShadow: playing
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // زر التشغيل الكبير
                  GestureDetector(
                    onTap: () => ttsService.toggle(sessionKey, items, lang),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.deepGreen,
                        size: 36,
                      ),
                    ),
                  ),
                  SizedBox(width: R.s(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ar ? 'استمع: $title' : 'Listen: $title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: R.f(context, 15),
                            fontWeight: FontWeight.w800,
                            color: AppColors.softGold,
                          ),
                        ),
                        SizedBox(height: R.s(context, 2)),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: R.f(context, 12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    IconButton(
                      tooltip: ar ? 'إيقاف' : 'Stop',
                      onPressed: ttsService.stop,
                      icon: const Icon(Icons.stop_circle_rounded),
                      color: const Color(0xFFFF8A80),
                      iconSize: 34,
                    ),
                  GestureDetector(
                    onTap: () => ttsService
                        .setSpeed(_rates[(rateIndex + 1) % _rates.length]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Text(
                        _rateLabels[rateIndex],
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 6)),
              Row(
                children: [
                  Icon(
                    Icons.headphones_rounded,
                    size: 16,
                    color: AppColors.gold.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ar ? 'القراءة في الخلفية' : 'Keep reading in background',
                      style: TextStyle(
                        fontSize: R.f(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: ttsService.keepInBackground,
                      onChanged: ttsService.setKeepInBackground,
                      activeThumbColor: AppColors.gold,
                      activeTrackColor: AppColors.gold.withValues(alpha: 0.4),
                      inactiveThumbColor:
                          AppColors.cream.withValues(alpha: 0.7),
                      inactiveTrackColor: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              if (hasError)
                Padding(
                  padding: EdgeInsets.only(top: R.s(context, 4)),
                  child: Text(
                    ttsService.error!,
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      height: 1.5,
                      color: const Color(0xFFFFB4A9),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
