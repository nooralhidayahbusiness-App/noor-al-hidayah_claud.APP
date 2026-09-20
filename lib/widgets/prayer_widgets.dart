import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/prayer_state.dart';
import '../core/theme.dart';
import '../core/time_format.dart';
import 'auth_widgets.dart';
import 'glass_card.dart';
import 'number_text.dart';

/// Next prayer: clock symbol, prayer name with its time, and the countdown.
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, prayerState, prayerState.now]),
      builder: (context, _) {
        final next = prayerState.nextPrayer();
        if (next == null) return const SizedBox.shrink();
        final remaining = next.at.difference(prayerState.now.value);
        final name = appState.tr(next.key);
        return GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appState.tr('nextPrayer'),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Image.asset(
                          'assets/images/clock.png',
                          width: 112,
                          height: 112,
                          color: AppColors.gold,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.access_time_rounded,
                            size: 90,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: brandStyle(
                              name,
                              fontSize: 46,
                              color: AppColors.softGold,
                              shadows: [
                                Shadow(
                                  color: AppColors.gold.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          TimeText(
                            formatTime12(next.timeText),
                            fontSize: 24,
                            color: AppColors.cream,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountdownText(
                              formatCountdown(remaining),
                              fontSize: 40,
                              color: AppColors.gold,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.tr('remaining'),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.cream.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Location name and date shown above the prayer times.
class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key, required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.gold,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softGold,
                ),
              ),
            ),
          ],
        ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.cream.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}

class PrayerRow extends StatelessWidget {
  const PrayerRow({
    super.key,
    required this.icon,
    required this.name,
    required this.time,
    required this.highlighted,
  });

  final IconData icon;
  final String name;
  final String time;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: highlighted
            ? AppColors.gold.withValues(alpha: 0.14)
            : Colors.transparent,
        border: Border.all(
          color: highlighted
              ? AppColors.gold.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: highlighted
                ? AppColors.gold
                : AppColors.softGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
          ),
          TimeText(
            time,
            fontSize: 19,
            color: highlighted ? AppColors.gold : AppColors.cream,
          ),
        ],
      ),
    );
  }
}

class PrayerErrorView extends StatelessWidget {
  const PrayerErrorView({
    super.key,
    required this.onRetry,
    required this.onChange,
  });

  final VoidCallback onRetry;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          ornament: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Text(
                appState.tr('ptError'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 18),
              GoldButton(label: appState.tr('retry'), onPressed: onRetry),
              TextButton(
                onPressed: onChange,
                child: Text(
                  appState.tr('changeLocation'),
                  style: const TextStyle(color: AppColors.softGold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
