import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/divine_names.dart';
import '../core/quran_prefs.dart';
import '../core/reciter_prefs.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import '../services/quran_audio_service.dart';
import '../services/share_service.dart';
import '../services/tafsir_service.dart';
import 'auth_widgets.dart';
import 'glow_sparks.dart';
import 'star_badge.dart';

/// One verse in its own card (lines mode). It has its own corner ornament and
/// a softly pulsing light behind it, without sparks.
class AyahCard extends StatelessWidget {
  const AyahCard({super.key, required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;

  Future<void> _copy(
    BuildContext context,
    String arabic,
    bool withTranslation,
    bool withTafsir,
  ) async {
    final buffer = StringBuffer()
      ..writeln(arabic)
      ..writeln();
    if (withTranslation) {
      buffer
        ..writeln(ayah.translation)
        ..writeln();
    }
    if (withTafsir) {
      final text = TafsirService.cachedData?.textFor(
            arabic: appState.isArabic,
            surah: surah.number,
            ayah: ayah.number,
          ) ??
          '';
      if (text.isNotEmpty) {
        buffer
          ..writeln(text)
          ..writeln();
      }
    }
    buffer.write('${surah.nameAr} • ${ayah.number}');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      showAuthMessage(context, appState.tr('copied'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: quranAudio.nowPlaying,
      builder: (context, spot, _) {
        final active = spot != null &&
            spot.surah == surah.number &&
            spot.ayah == ayah.number;
        return ListenableBuilder(
          listenable: Listenable.merge([appState, quranPrefs]),
          builder: (context, _) {
            final simple = quranPrefs.simpleFont;
            final arabic = simple ? ayah.simple : ayah.uthmani;
            final arabicStyle = simple
                ? GoogleFonts.notoNaskhArabic(
                    fontSize: 24,
                    height: 2.1,
                    color: AppColors.cream,
                  )
                : GoogleFonts.amiriQuran(
                    fontSize: 26,
                    height: 2.1,
                    color: AppColors.cream,
                  );
            final showTranslation =
                quranPrefs.showTranslation && ayah.translation.isNotEmpty;
            final showTafsir = quranPrefs.showTafsir;

            return GlowSparks(
              shape: GlowShape.card,
              spread: 18,
              sparks: 0,
              intensity: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.deepGreen.withValues(alpha: 0.82),
                      AppColors.deepGreen.withValues(alpha: 0.92),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: active ? 0.95 : 0.4),
                    width: active ? 1.6 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: CustomPaint(
                    painter: const _AyahCornerPainter(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              StarBadge(number: ayah.number, size: 38),
                              const Spacer(),
                              IconButton(
                                tooltip: appState.tr('playAyah'),
                                onPressed: () => quranAudio.playFrom(
                                  surah,
                                  ayah,
                                  reciterPrefs.reciter,
                                ),
                                icon: Icon(
                                  active
                                      ? Icons.graphic_eq_rounded
                                      : Icons.play_circle_outline_rounded,
                                  size: 21,
                                  color: AppColors.gold.withValues(alpha: 0.8),
                                ),
                              ),
                              IconButton(
                                tooltip: appState.tr('saveImage'),
                                onPressed: () => shareAyahImage(
                                  context,
                                  surah: surah,
                                  ayah: ayah,
                                ),
                                icon: Icon(
                                  Icons.image_outlined,
                                  size: 21,
                                  color: AppColors.gold.withValues(alpha: 0.8),
                                ),
                              ),
                              IconButton(
                                tooltip: appState.tr('copy'),
                                onPressed: () => _copy(
                                  context,
                                  arabic,
                                  showTranslation,
                                  showTafsir,
                                ),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  size: 20,
                                  color: AppColors.gold.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(children: quranSpans(arabic, arabicStyle)),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: arabicStyle,
                          ),
                          if (showTranslation) ...[
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              color: AppColors.gold.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ayah.translation,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15.5,
                                height: 1.65,
                                color: AppColors.cream.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                          if (showTafsir) ...[
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              color: AppColors.gold.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 12),
                            _TafsirSection(surah: surah, ayah: ayah),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// The tafsir of one verse (Arabic or English, following the app language).
class _TafsirSection extends StatelessWidget {
  const _TafsirSection({required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;

  @override
  Widget build(BuildContext context) {
    final cached = TafsirService.cachedData;
    if (cached != null) return _body(cached);
    return FutureBuilder<TafsirData>(
      future: TafsirService.load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            appState.tr('tafsirError'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.gold,
              ),
            ),
          );
        }
        return _body(data);
      },
    );
  }

  Widget _body(TafsirData data) {
    final arabic = appState.isArabic;
    final text = data.textFor(
      arabic: arabic,
      surah: surah.number,
      ayah: ayah.number,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: AppColors.gold,
            ),
            const SizedBox(width: 6),
            Text(
              appState.tr('tafsirTitle'),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (text.isEmpty)
          Text(
            appState.tr('tafsirShared'),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.cream.withValues(alpha: 0.6),
            ),
          )
        else
          _TafsirText(text: text, arabic: arabic),
        const SizedBox(height: 6),
        Text(
          data.sourceName(arabic),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gold.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// Long tafsir texts are shortened, with a "show more" button.
class _TafsirText extends StatefulWidget {
  const _TafsirText({required this.text, required this.arabic});

  final String text;
  final bool arabic;

  @override
  State<_TafsirText> createState() => _TafsirTextState();
}

class _TafsirTextState extends State<_TafsirText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final long = widget.text.length > 320;
    final collapsed = long && !_expanded;
    final style = widget.arabic
        ? GoogleFonts.notoNaskhArabic(
            fontSize: 17,
            height: 1.9,
            color: AppColors.cream.withValues(alpha: 0.92),
          )
        : TextStyle(
            fontSize: 15,
            height: 1.65,
            color: AppColors.cream.withValues(alpha: 0.88),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.text,
              textDirection:
                  widget.arabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: widget.arabic ? TextAlign.right : TextAlign.left,
              maxLines: collapsed ? 6 : null,
              overflow: collapsed ? TextOverflow.fade : TextOverflow.clip,
              style: style,
            ),
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

/// Corner ornament for verse cards: an eight-point star (two squares) with
/// concentric arcs. Different on purpose from the other cards of the app.
class _AyahCornerPainter extends CustomPainter {
  const _AyahCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strong = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.gold.withValues(alpha: 0.7);
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.4);
    final dot = Paint()..color = AppColors.gold.withValues(alpha: 0.85);

    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final c in corners) {
      canvas.drawCircle(c, 27, soft);
      canvas.drawCircle(c, 21, strong);
      for (final rotation in [0.0, math.pi / 4]) {
        final square = Path();
        for (var i = 0; i < 4; i++) {
          final angle = rotation + i * math.pi / 2;
          final p = Offset(
            c.dx + 15 * math.cos(angle),
            c.dy + 15 * math.sin(angle),
          );
          if (i == 0) {
            square.moveTo(p.dx, p.dy);
          } else {
            square.lineTo(p.dx, p.dy);
          }
        }
        square.close();
        canvas.drawPath(square, strong);
      }
      canvas.drawCircle(c, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
