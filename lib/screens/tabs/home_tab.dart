import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_flow.dart';
import '../../core/app_state.dart';
import '../../core/fonts.dart';
import '../../core/navigation.dart';
import '../../core/prayer_state.dart';
import '../../core/profile_state.dart';
import '../../core/theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/ai_teacher_card.dart';
import '../../widgets/avatar_picker.dart';
import '../../widgets/daily_cards.dart';
import '../../widgets/ornament_medallion.dart';
import '../../widgets/prayer_widgets.dart';
import '../prayer_times_page.dart';
import '../hadith_page.dart';

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
            const SizedBox(height: 18),
            AiTeacherCard(
              onTap: () =>
                  showAuthMessage(context, appState.tr('teacherSoon')),
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
              maxCrossAxisExtent: 130,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickTile(
                  label: appState.tr('tabPrayer'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const PrayerTimesPage())),
                  symbol: const SymbolImage(
                    'assets/images/clock.png',
                    fallback: Icons.schedule_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('tabQuran'),
                  onTap: () => onOpenTab(1),
                  symbol: const SymbolImage(
                    'assets/images/Quran.png',
                    fallback: Icons.menu_book_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('tabAdhkar'),
                  onTap: () => onOpenTab(2),
                  symbol: const SymbolImage(
                    'assets/images/pattern.png',
                    fallback: Icons.auto_stories_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('duas'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/dua-hands.png',
                    fallback: Icons.volunteer_activism_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('hadiths'),
                  onTap: () => Navigator.of(context).push(fadeRoute(const HadithPage())),
                  symbol: const SymbolImage(
                    'assets/images/muhammad.png',
                    fallback: Icons.format_quote_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('qibla'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/Kaaba.png',
                    fallback: Icons.explore_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('tasbeeh'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/tasbih.png',
                    fallback: Icons.touch_app_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('nearbyMosques'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/mosque.png',
                    fallback: Icons.mosque_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('khatmPlan'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/Read.png',
                    fallback: Icons.auto_stories_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('zakat'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/zakat.png',
                    fallback: Icons.favorite_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('haram'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/haram.png',
                    fallback: Icons.block_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('makruh'),
                  onTap: soon,
                  symbol: const SymbolImage(
                    'assets/images/stop.png',
                    fallback: Icons.warning_amber_rounded,
                    tint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const DailyContentSection(),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profileState,
      builder: (context, _) {
        final path = switch (profileState.avatar) {
          'man' => 'assets/images/arabian.png',
          'woman' => 'assets/images/hijab.png',
          _ => null,
        };
        const placeholder = Icon(
          Icons.person_rounded,
          color: AppColors.gold,
          size: 40,
        );
        return GestureDetector(
          onTap: () => showAvatarPicker(context),
          child: OrnamentMedallion(
            size: 104,
            child: path == null
                ? placeholder
                : Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => placeholder,
                  ),
          ),
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
        const _Avatar(),
        const SizedBox(height: 12),
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
    required this.label,
    required this.onTap,
    required this.symbol,
  });

  final String label;
  final VoidCallback onTap;
  final Widget symbol;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth - 8, 112.0);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OrnamentMedallion(
                  size: size,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: symbol,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
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
              ],
            ),
          ),
        );
      },
    );
  }
}
