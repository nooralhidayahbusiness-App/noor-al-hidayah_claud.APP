import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/divine_names.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import 'islamic_pattern.dart';
import 'star_badge.dart';

/// The image that is shared for a verse (with translation and tafsir if wanted).
/// It is drawn off screen, so it avoids Expanded, Spacer and scrolling widgets.
class AyahShareCard extends StatelessWidget {
  const AyahShareCard({
    super.key,
    required this.surah,
    required this.ayah,
    required this.simpleFont,
    required this.translation,
    required this.tafsir,
    required this.tafsirSource,
  });

  final QuranSurah surah;
  final QuranAyah ayah;
  final bool simpleFont;
  final String translation;
  final String tafsir;
  final String tafsirSource;

  @override
  Widget build(BuildContext context) {
    final arabicUi = appState.isArabic;
    final arabic = simpleFont ? ayah.simple : ayah.uthmani;
    final arabicStyle = simpleFont
        ? GoogleFonts.notoNaskhArabic(
            fontSize: 26,
            height: 2.1,
            color: AppColors.cream,
          )
        : GoogleFonts.amiriQuran(
            fontSize: 28,
            height: 2.1,
            color: AppColors.cream,
          );
    final surahLabel = arabicUi ? surah.nameAr : 'Surah ${surah.nameEn}';
    final shortTafsir =
        tafsir.length > 900 ? '${tafsir.substring(0, 900)}…' : tafsir;

    Widget divider() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Divider(
            height: 1,
            color: AppColors.gold.withValues(alpha: 0.35),
          ),
        );

    return SizedBox(
      width: 380,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.green, AppColors.deepGreen],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: IslamicPattern(opacity: 0.07)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppColors.deepGreen.withValues(alpha: 0.6),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.75),
                    width: 1.6,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: CustomPaint(
                    painter: const _ShareCornerPainter(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StarBadge(number: ayah.number, size: 46),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  surahLabel,
                                  style: GoogleFonts.amiriQuran(
                                    fontSize: 26,
                                    color: AppColors.softGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          divider(),
                          Text.rich(
                            TextSpan(children: quranSpans(arabic, arabicStyle)),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: arabicStyle,
                          ),
                          if (translation.isNotEmpty) ...[
                            divider(),
                            Text(
                              translation,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.65,
                                color: AppColors.cream.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                          if (shortTafsir.isNotEmpty) ...[
                            divider(),
                            Text(
                              appState.tr('tafsirTitle'),
                              textAlign:
                                  arabicUi ? TextAlign.right : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              shortTafsir,
                              textDirection: arabicUi
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              textAlign:
                                  arabicUi ? TextAlign.right : TextAlign.left,
                              style: arabicUi
                                  ? GoogleFonts.notoNaskhArabic(
                                      fontSize: 17,
                                      height: 1.9,
                                      color: AppColors.cream
                                          .withValues(alpha: 0.92),
                                    )
                                  : TextStyle(
                                      fontSize: 15,
                                      height: 1.65,
                                      color: AppColors.cream
                                          .withValues(alpha: 0.88),
                                    ),
                            ),
                            if (tafsirSource.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                tafsirSource,
                                textAlign:
                                    arabicUi ? TextAlign.right : TextAlign.left,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gold.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                          divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(width: 34, height: 34),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'نور الهداية • Noor Al-Hidayah',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCornerPainter extends CustomPainter {
  const _ShareCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strong = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.gold.withValues(alpha: 0.8);
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.45);
    final dot = Paint()..color = AppColors.gold;

    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final c in corners) {
      canvas.drawCircle(c, 30, soft);
      canvas.drawCircle(c, 23, strong);
      for (final rotation in [0.0, math.pi / 4]) {
        final square = Path();
        for (var i = 0; i < 4; i++) {
          final angle = rotation + i * math.pi / 2;
          final p = Offset(
            c.dx + 17 * math.cos(angle),
            c.dy + 17 * math.sin(angle),
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
      canvas.drawCircle(c, 3.8, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
