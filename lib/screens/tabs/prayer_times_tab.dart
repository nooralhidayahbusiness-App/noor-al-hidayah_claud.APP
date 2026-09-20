import 'package:flutter/material.dart';

import '../../core/app_flow.dart';
import '../../core/app_state.dart';
import '../../core/prayer_state.dart';
import '../../core/theme.dart';
import '../../core/time_format.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/prayer_widgets.dart';

class PrayerTimesTab extends StatelessWidget {
  const PrayerTimesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, prayerState, prayerState.now]),
      builder: (context, _) {
        final data = prayerState.data;
        final location = prayerState.location;
        if (data == null || location == null) {
          if (prayerState.status == PrayerStatus.error) {
            return PrayerErrorView(
              onRetry: prayerState.load,
              onChange: () => openLocationPicker(context),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        const icons = <String, IconData>{
          'fajr': Icons.nightlight_round,
          'sunrise': Icons.wb_sunny_outlined,
          'dhuhr': Icons.light_mode,
          'asr': Icons.brightness_medium,
          'maghrib': Icons.wb_twilight,
          'isha': Icons.dark_mode,
        };
        final rows = <MapEntry<String, String>>[
          MapEntry('fajr', data.fajr),
          MapEntry('sunrise', data.sunrise),
          MapEntry('dhuhr', data.dhuhr),
          MapEntry('asr', data.asr),
          MapEntry('maghrib', data.maghrib),
          MapEntry('isha', data.isha),
        ];
        final nextKey = prayerState.nextPrayer()?.key;

        return RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.green,
          onRefresh: prayerState.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              LocationHeader(
                label: location.label,
                date: appState.isArabic ? data.hijriAr : data.hijriEn,
              ),
              const SizedBox(height: 18),
              const NextPrayerCard(),
              const SizedBox(height: 18),
              GlassCard(
                ornament: false,
                child: Column(
                  children: [
                    for (final row in rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: PrayerRow(
                          icon: icons[row.key]!,
                          name: appState.tr(row.key),
                          time: formatTime12(row.value),
                          highlighted: row.key == nextKey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
