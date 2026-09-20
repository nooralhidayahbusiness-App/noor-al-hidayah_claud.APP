import 'package:flutter/material.dart';

import '../../core/app_flow.dart';
import '../../core/app_state.dart';
import '../../core/fonts.dart';
import '../../core/prayer_state.dart';
import '../../core/theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/prayer_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, prayerState]),
      builder: (context, _) {
        final data = prayerState.data;
        final date = data == null
            ? ''
            : (appState.isArabic ? data.hijriAr : data.hijriEn);
        final label = prayerState.location?.label ?? '';

        void soon() => showAuthMessage(context, appState.tr('comingSoon'));

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _Greeting(date: date, label: label),
            const SizedBox(height: 18),
            if (data != null)
              const NextPrayerCard()
            else if (prayerState.status == PrayerStatus.error)
              PrayerErrorView(
                onRetry: prayerState.load,
                onChange: () => openLocationPicker(context),
              )
            else
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              appState.tr('quickAccess'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.extent(
              maxCrossAxisExtent: 120,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickTile(
                  icon: Icons.schedule_rounded,
                  label: appState.tr('tabPrayer'),
                  onTap: () => onOpenTab(1),
                ),
                _QuickTile(
                  icon: Icons.menu_book_rounded,
                  label: appState.tr('tabQuran'),
                  onTap: () => onOpenTab(2),
                ),
                _QuickTile(
                  icon: Icons.auto_stories_rounded,
                  label: appState.tr('tabAdhkar'),
                  onTap: () => onOpenTab(3),
                ),
                _QuickTile(
                  icon: Icons.explore_rounded,
                  label: appState.tr('qibla'),
                  onTap: soon,
                ),
                _QuickTile(
                  icon: Icons.touch_app_rounded,
                  label: appState.tr('tasbeeh'),
                  onTap: soon,
                ),
                _QuickTile(
                  icon: Icons.volunteer_activism_rounded,
                  label: appState.tr('duas'),
                  onTap: soon,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.date, required this.label});

  final String date;
  final String label;

  @override
  Widget build(BuildContext context) {
    final greeting = appState.tr('greeting');
    return Column(
      children: [
        Text(
          greeting,
          textAlign: TextAlign.center,
          style: brandStyle(
            greeting,
            fontSize: 36,
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
        if (date.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.deepGreen.withValues(alpha: 0.6),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(icon, color: AppColors.gold, size: 26),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
