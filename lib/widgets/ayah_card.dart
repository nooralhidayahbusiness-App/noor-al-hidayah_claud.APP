import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/divine_names.dart';
import '../core/quran_prefs.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import 'auth_widgets.dart';
import 'glow_sparks.dart';
import 'star_badge.dart';

/// One verse in its own card (lines mode). It has its own corner ornament and
/// a softly pulsing light behind it, without sparks.
class AyahCard extends StatelessWidget {
  const AyahCard({super.key, required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
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
                            tooltip: appState.tr('copy'),
                            onPressed: () async {
                              final buffer = StringBuffer()
                                ..writeln(arabic)
                                ..writeln();
                              if (showTranslation) {
                                buffer
                                  ..writeln(ayah.translation)
                                  ..writeln();
                              }
                              buffer.write('${surah.nameAr} • ${ayah.number}');
                              await Clipboard.setData(
                                ClipboardData(text: buffer.toString()),
                              );
                              if (context.mounted) {
                                showAuthMessage(
                                  context,
                                  appState.tr('copied'),
                                );
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
