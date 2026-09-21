import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_state.dart';
import '../../core/arabic_text.dart';
import '../../core/fonts.dart';
import '../../core/navigation.dart';
import '../../core/quran_prefs.dart';
import '../../core/reading_state.dart';
import '../../core/theme.dart';
import '../../models/quran.dart';
import '../../services/quran_service.dart';
import '../../widgets/star_badge.dart';
import '../quran_reader_screen.dart';

/// The Quran tab: search box and the list of the 114 surahs.
class QuranBrowserTab extends StatefulWidget {
  const QuranBrowserTab({super.key});

  @override
  State<QuranBrowserTab> createState() => _QuranBrowserTabState();
}

class _QuranBrowserTabState extends State<QuranBrowserTab> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    quranPrefs.load();
    readingState.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(QuranSurah s, String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    return s.number.toString() == query ||
        normalizeArabic(s.nameAr).contains(normalizeArabic(query)) ||
        s.nameEn.toLowerCase().contains(lower) ||
        s.meaning.toLowerCase().contains(lower);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return FutureBuilder<QuranData>(
          future: QuranService.load(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    appState.tr('quranLoadError'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.6,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            final query = _query.trim();
            final list = [
              for (final s in data.surahs)
                if (_matches(s, query)) s,
            ];
            final title = appState.tr('quranTitle');
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: brandStyle(
                          title,
                          fontSize: 28,
                          color: AppColors.softGold,
                          shadows: [
                            Shadow(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _search,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 16,
                        ),
                        cursorColor: AppColors.gold,
                        decoration: InputDecoration(
                          hintText: appState.tr('searchSurah'),
                          hintStyle: TextStyle(
                            color: AppColors.cream.withValues(alpha: 0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.gold.withValues(alpha: 0.85),
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.25),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.gold,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (query.isEmpty) _ResumeSection(data: data),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            appState.tr('noResults'),
                            style: TextStyle(
                              color: AppColors.cream.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final surah = list[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _SurahTile(
                                surah: surah,
                                onTap: () => Navigator.of(context).push(
                                  fadeRoute(
                                    QuranReaderScreen(
                                      data: data,
                                      surah: surah,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah, required this.onTap});

  final QuranSurah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = appState.tr(surah.isMeccan ? 'meccan' : 'medinan');
    final verses = appState.isArabic
        ? '${surah.count} ${surah.count >= 3 && surah.count <= 10 ? 'آيات' : 'آية'}'
        : '${surah.count} ${appState.tr('versesWord')}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.deepGreen.withValues(alpha: 0.62),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              StarBadge(number: surah.number, size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameAr,
                      style: GoogleFonts.amiriQuran(
                        fontSize: 22,
                        height: 1.6,
                        color: AppColors.softGold,
                      ),
                    ),
                    Text(
                      '${surah.nameEn} • ${surah.meaning}',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.cream.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$type • $verses',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.gold.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                appState.isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.softGold.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// "Continue reading" and "My saved spot" cards at the top of the Quran tab.
class _ResumeSection extends StatelessWidget {
  const _ResumeSection({required this.data});

  final QuranData data;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, readingState]),
      builder: (context, _) {
        final mark = readingState.bookmark;
        final last = readingState.last;
        if (mark == null && last == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            children: [
              if (mark != null)
                _ResumeTile(
                  icon: Icons.bookmark_rounded,
                  title: appState.tr('savedSpot'),
                  position: mark,
                  data: data,
                ),
              if (mark != null && last != null) const SizedBox(height: 8),
              if (last != null)
                _ResumeTile(
                  icon: Icons.history_rounded,
                  title: appState.tr('continueReading'),
                  position: last,
                  data: data,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumeTile extends StatelessWidget {
  const _ResumeTile({
    required this.icon,
    required this.title,
    required this.position,
    required this.data,
  });

  final IconData icon;
  final String title;
  final ReadingPosition position;
  final QuranData data;

  @override
  Widget build(BuildContext context) {
    final surah = data.surah(position.surah);
    final surahName = appState.isArabic ? surah.nameAr : surah.nameEn;
    final place = position.pageMode
        ? '${appState.tr('pageLabel')} ${position.page} • $surahName'
        : '$surahName • ${appState.tr('ayahWord')} ${position.ayah}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          fadeRoute(
            QuranReaderScreen(
              data: data,
              surah: surah,
              initialAyah: position.ayah,
              startInPageMode: position.pageMode,
              initialPage: position.page,
            ),
          ),
        ),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.16),
                AppColors.deepGreen.withValues(alpha: 0.7),
              ],
            ),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.gold.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      place,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                appState.isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.softGold.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
