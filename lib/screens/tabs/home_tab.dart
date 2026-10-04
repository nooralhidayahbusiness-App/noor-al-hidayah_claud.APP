import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/fonts.dart';
import '../../core/navigation.dart';
import '../../core/prayer_state.dart';
import '../../core/profile_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../widgets/ai_teacher_card.dart';
import '../../widgets/daily_cards.dart';
import '../../widgets/ornament_medallion.dart';
import '../../widgets/prayer_widgets.dart';
import '../ai_teacher_screen.dart';
import '../change_photo_screen.dart';
import '../duas_screen.dart';
import '../hadith_page.dart';
import '../haram_screen.dart';
import '../khatm_plan_screen.dart';
import '../mosques_screen.dart';
import '../prayer_times_page.dart';
import '../qibla_screen.dart';
import '../tasbeeh_screen.dart';
import '../zakat_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, prayerState, profileState]),
      builder: (context, _) {
        final data = prayerState.data;
        final date = data == null
            ? ''
            : (appState.isArabic ? data.hijriAr : data.hijriEn);
        final label = prayerState.location?.label ?? '';

        return ListView(
          padding: EdgeInsets.fromLTRB(
            R.s(context, 16),
            R.s(context, 4),
            R.s(context, 16),
            R.s(context, 20),
          ),
          children: [
            _Greeting(date: date, label: label),
            SizedBox(height: R.s(context, 12)),
            if (data != null)
              const NextPrayerCard()
            else if (prayerState.status == PrayerStatus.error)
              PrayerErrorView(
                onRetry: prayerState.load,
                onChange: () => openLocationPicker(context),
              )
            else
              Padding(
                padding: EdgeInsets.all(R.s(context, 24)),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
            SizedBox(height: R.s(context, 12)),
            AiTeacherCard(
              onTap: () => Navigator.of(context).push(
                fadeRoute(const AiTeacherScreen()),
              ),
            ),
            SizedBox(height: R.s(context, 20)),
            Text(
              appState.tr('quickAccess'),
              style: TextStyle(
                fontSize: R.f(context, 15),
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            SizedBox(height: R.s(context, 8)),
            GridView.extent(
              maxCrossAxisExtent: R.s(context, 105),
              mainAxisSpacing: R.s(context, 8),
              crossAxisSpacing: R.s(context, 8),
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
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const DuasScreen())),
                  symbol: const SymbolImage(
                    'assets/images/dua-hands.png',
                    fallback: Icons.volunteer_activism_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('hadiths'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const HadithPage())),
                  symbol: const SymbolImage(
                    'assets/images/muhammad.png',
                    fallback: Icons.format_quote_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('qibla'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const QiblaScreen())),
                  symbol: const SymbolImage(
                    'assets/images/Kaaba.png',
                    fallback: Icons.explore_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('tasbeeh'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const TasbeehScreen())),
                  symbol: const SymbolImage(
                    'assets/images/tasbih.png',
                    fallback: Icons.touch_app_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('nearbyMosques'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const MosquesScreen())),
                  symbol: const SymbolImage(
                    'assets/images/mosque.png',
                    fallback: Icons.mosque_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('khatmPlan'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const KhatmPlanScreen())),
                  symbol: const SymbolImage(
                    'assets/images/Read.png',
                    fallback: Icons.auto_stories_rounded,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('zakat'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const ZakatScreen())),
                  symbol: const SymbolImage(
                    'assets/images/zakat.png',
                    fallback: Icons.favorite_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('haram'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const HaramScreen())),
                  symbol: const SymbolImage(
                    'assets/images/haram.png',
                    fallback: Icons.block_rounded,
                    tint: true,
                  ),
                ),
                _QuickTile(
                  label: appState.tr('makruh'),
                  onTap: () => Navigator.of(context)
                      .push(fadeRoute(const MakruhScreen())),
                  symbol: const SymbolImage(
                    'assets/images/stop.png',
                    fallback: Icons.warning_amber_rounded,
                    tint: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: R.s(context, 18)),
            const DailyContentSection(),
          ],
        );
      },
    );
  }
}

// ============================================================
// _Avatar — يعرض صورة البروفايل الحقيقية (من profileState)
// ============================================================
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profileState,
      builder: (context, _) {
        final photoBytes = profileState.photoBytes;
        final gender = profileState.avatar ?? 'man';
        final fallbackPath = gender == 'woman'
            ? 'assets/images/hijab.png'
            : 'assets/images/arabian.png';

        final placeholder = Icon(
          Icons.person_rounded,
          color: AppColors.gold,
          size: R.s(context, 26),
        );

        Widget child;
        if (photoBytes != null && photoBytes.isNotEmpty) {
          child = Image.memory(
            photoBytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => placeholder,
          );
        } else {
          child = Image.asset(
            fallbackPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );
        }

        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChangePhotoScreen(),
              ),
            );
          },
          child: OrnamentMedallion(
            size: R.s(context, 78),
            child: child,
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
        SizedBox(height: R.s(context, 8)),
        Text(
          greeting,
          textAlign: TextAlign.center,
          style: brandStyle(
            greeting,
            fontSize: R.f(context, 26),
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
          SizedBox(height: R.s(context, 4)),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.f(context, 11.5),
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (label.isNotEmpty) ...[
          SizedBox(height: R.s(context, 4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.gold,
                size: R.s(context, 13),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 12),
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
        final maxSize = R.s(context, 84);
        final size = math.min(constraints.maxWidth - 6, maxSize);
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
                    padding: const EdgeInsets.all(3),
                    child: symbol,
                  ),
                ),
                SizedBox(height: R.s(context, 4)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.f(context, 10.5),
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
