import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/quran_prefs.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import '../widgets/app_branding.dart';
import '../widgets/ayah_card.dart';
import '../widgets/glass_card.dart';

/// Reads one surah, one verse per card (lines mode).
class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({
    super.key,
    required this.data,
    required this.surah,
  });

  final QuranData data;
  final QuranSurah surah;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(title: surah.nameAr),
              const _Controls(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: surah.ayahs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SurahHeader(data: data, surah: surah),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AyahCard(
                        surah: surah,
                        ayah: surah.ayahs[index - 1],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: appState.tr('back'),
            color: AppColors.softGold,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(
                fontSize: 26,
                color: AppColors.softGold,
                shadows: [
                  Shadow(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, quranPrefs]),
      builder: (context, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _ControlChip(
                icon: Icons.text_fields_rounded,
                label: quranPrefs.simpleFont
                    ? appState.tr('fontUthmani')
                    : appState.tr('fontSimple'),
                active: false,
                onTap: quranPrefs.toggleFont,
              ),
              const SizedBox(width: 10),
              _ControlChip(
                icon: Icons.translate_rounded,
                label: appState.tr('translationBtn'),
                active: quranPrefs.showTranslation,
                onTap: quranPrefs.toggleTranslation,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active ? AppColors.deepGreen : AppColors.gold;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: active
              ? const LinearGradient(
                  colors: [AppColors.softGold, AppColors.gold],
                )
              : null,
          color: active ? null : AppColors.deepGreen.withValues(alpha: 0.7),
          border: Border.all(color: AppColors.gold),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: active ? 0.55 : 0.3),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.data, required this.surah});

  final QuranData data;
  final QuranSurah surah;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, quranPrefs]),
      builder: (context, _) {
        final showBasmalah = surah.number != 1 && surah.number != 9;
        final type = appState.tr(surah.isMeccan ? 'meccan' : 'medinan');
        final verses = appState.isArabic
            ? '${surah.count} ${surah.count >= 3 && surah.count <= 10 ? 'آيات' : 'آية'}'
            : '${surah.count} ${appState.tr('versesWord')}';
        final basmalahStyle = quranPrefs.simpleFont
            ? GoogleFonts.notoNaskhArabic(
                fontSize: 26,
                height: 2.0,
                color: AppColors.gold,
              )
            : GoogleFonts.amiriQuran(
                fontSize: 30,
                height: 2.0,
                color: AppColors.gold,
              );
        return GlassCard(
          child: Column(
            children: [
              Text(
                surah.nameAr,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiriQuran(
                  fontSize: 34,
                  height: 1.6,
                  color: AppColors.softGold,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${surah.nameEn} • ${surah.meaning}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.cream.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$type • $verses',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gold.withValues(alpha: 0.9),
                ),
              ),
              if (showBasmalah) ...[
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 10),
                Text(
                  data.basmalah(simple: quranPrefs.simpleFont),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: basmalahStyle,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
