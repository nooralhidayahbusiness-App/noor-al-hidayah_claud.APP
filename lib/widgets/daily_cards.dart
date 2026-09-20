import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/theme.dart';
import '../models/daily_content.dart';
import '../services/daily_content_service.dart';
import 'auth_widgets.dart';
import 'glass_card.dart';

/// Verse of the day, hadith of the day and dua of the day.
class DailyContentSection extends StatelessWidget {
  const DailyContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyContent>(
      future: DailyContentService.load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListenableBuilder(
            listenable: appState,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                appState.tr('dailyMissing'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }
        final content = snapshot.data;
        if (content == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }
        return ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final verse = content.verseToday;
            final hadith = content.hadithToday;
            final dua = content.duaToday;
            return Column(
              children: [
                _DailyCard(
                  title: appState.tr('verseOfDay'),
                  icon: Icons.menu_book_rounded,
                  text: verse.text,
                  textStyle: GoogleFonts.amiriQuran(
                    fontSize: 26,
                    height: 2.0,
                    color: AppColors.cream,
                  ),
                  source: _quranLabel(verse),
                ),
                const SizedBox(height: 16),
                _DailyCard(
                  title: appState.tr('hadithOfDay'),
                  icon: Icons.format_quote_rounded,
                  text: hadith.text,
                  textStyle: GoogleFonts.amiri(
                    fontSize: 20,
                    height: 1.9,
                    color: AppColors.cream,
                  ),
                  source: '${appState.tr('nawawiSource')} • ${hadith.number}',
                ),
                const SizedBox(height: 16),
                _DailyCard(
                  title: appState.tr('duaOfDay'),
                  icon: Icons.volunteer_activism_rounded,
                  text: dua.text,
                  textStyle: GoogleFonts.amiriQuran(
                    fontSize: 24,
                    height: 2.0,
                    color: AppColors.cream,
                  ),
                  source:
                      '${appState.tr('quranDuaSource')} • ${_quranLabel(dua)}',
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String _quranLabel(QuranEntry e) {
  final surah = appState.isArabic ? e.surahAr : e.surahEn;
  return '$surah • ${appState.tr('ayahWord')} ${e.ayah}';
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({
    required this.title,
    required this.icon,
    required this.text,
    required this.textStyle,
    required this.source,
  });

  final String title;
  final IconData icon;
  final String text;
  final TextStyle textStyle;
  final String source;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: brandStyle(
                    title,
                    fontSize: 22,
                    color: AppColors.softGold,
                  ),
                ),
              ),
              IconButton(
                tooltip: appState.tr('copy'),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: '$text\n\n$source'),
                  );
                  if (context.mounted) {
                    showAuthMessage(context, appState.tr('copied'));
                  }
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: AppColors.gold.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ExpandableText(text: text, style: textStyle),
          const SizedBox(height: 12),
          Text(
            source,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gold.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Long texts are shortened, with a "show more" button.
class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final long = widget.text.length > 260;
    final collapsed = long && !_expanded;
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: collapsed ? 7 : null,
            overflow: collapsed ? TextOverflow.fade : TextOverflow.clip,
            style: widget.style,
          ),
        ),
        if (long)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              appState.tr(_expanded ? 'showLess' : 'showMore'),
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
      ],
    );
  }
}
