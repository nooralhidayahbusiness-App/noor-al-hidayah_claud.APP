import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/prayer_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/time_format.dart';
import 'auth_widgets.dart';
import 'glass_card.dart';
import 'number_text.dart';

/// Next prayer: adhan symbol, prayer name with its time, and the countdown.
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
        final iconSize = R.s(context, 92);

        return GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appState.tr('nextPrayer'),
                style: TextStyle(
                  fontSize: R.f(context, 12),
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: R.s(context, 10)),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Image.asset(
                          'assets/icons/adhan.png',
                          width: iconSize,
                          height: iconSize,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                            Icons.access_time_rounded,
                            size: iconSize,
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
                              fontSize: R.f(context, 38),
                              color: AppColors.softGold,
                              shadows: [
                                Shadow(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.5),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 2)),
                          TimeText(
                            formatTime12(next.timeText),
                            fontSize: R.f(context, 20),
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
                              fontSize: R.f(context, 32),
                              color: AppColors.gold,
                            ),
                            SizedBox(height: R.s(context, 3)),
                            Text(
                              appState.tr('remaining'),
                              style: TextStyle(
                                fontSize: R.f(context, 11),
                                color:
                                    AppColors.cream.withValues(alpha: 0.6),
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
            Icon(
              Icons.location_on_rounded,
              color: AppColors.gold,
              size: R.s(context, 18),
            ),
            SizedBox(width: R.s(context, 5)),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.softGold,
                ),
              ),
            ),
          ],
        ),
        if (date.isNotEmpty) ...[
          SizedBox(height: R.s(context, 5)),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.f(context, 12),
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
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 12),
        vertical: R.s(context, 12),
      ),
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
            size: R.s(context, 20),
            color: highlighted
                ? AppColors.gold
                : AppColors.softGold.withValues(alpha: 0.8),
          ),
          SizedBox(width: R.s(context, 12)),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: R.f(context, 14.5),
                fontWeight:
                    highlighted ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
          ),
          TimeText(
            time,
            fontSize: R.f(context, 16),
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
        padding: EdgeInsets.all(R.s(context, 22)),
        child: GlassCard(
          ornament: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: R.s(context, 36),
                color: AppColors.gold,
              ),
              SizedBox(height: R.s(context, 12)),
              Text(
                appState.tr('ptError'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  height: 1.6,
                  color: AppColors.cream,
                ),
              ),
              SizedBox(height: R.s(context, 14)),
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
