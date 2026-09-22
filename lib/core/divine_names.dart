import 'package:flutter/material.dart';

import 'arabic_text.dart';

const Color kDivineGold = Color(0xFFFFD86B);

final RegExp _allah = RegExp(r'^(و|ف|ب|وب|فب|ت|وت|ك)?(الله|لله|اللهم)$');
final RegExp _rabb = RegExp(r'^(و|ف|ب|ل|وب|ول|فب|فل)?رب(ي|ك|كم|كما|نا|هم|هما|ه|ها|هن)?$');
final RegExp _prefix = RegExp(r'^(و|ف|ب|ل|ك|وب|ول|فب|فل|وك)');

/// Common names of Allah (without prefixes). Covers the frequent forms;
/// not every grammatical variant.
const Set<String> _namesOfAllah = {
  'الرحمن', 'الرحيم', 'الملك', 'القدوس', 'السلام', 'المؤمن', 'المهيمن', 'العزيز',
  'الجبار', 'المتكبر', 'الخالق', 'البارئ', 'المصور', 'الغفار', 'القهار', 'الوهاب',
  'الرزاق', 'الفتاح', 'العليم', 'القابض', 'الباسط', 'الخافض', 'الرافع', 'المعز',
  'المذل', 'السميع', 'البصير', 'الحكم', 'العدل', 'اللطيف', 'الخبير', 'الحليم',
  'العظيم', 'الغفور', 'الشكور', 'العلي', 'الكبير', 'الحفيظ', 'المقيت', 'الحسيب',
  'الجليل', 'الكريم', 'الرقيب', 'المجيب', 'الواسع', 'الحكيم', 'الودود', 'المجيد',
  'الباعث', 'الشهيد', 'الحق', 'الوكيل', 'القوي', 'المتين', 'الولي', 'الحميد',
  'المحصي', 'المبدئ', 'المعيد', 'المحيي', 'المميت', 'الحي', 'القيوم', 'الواجد',
  'الماجد', 'الواحد', 'الاحد', 'الصمد', 'القادر', 'المقتدر', 'المقدم', 'المؤخر',
  'الاول', 'الاخر', 'الظاهر', 'الباطن', 'الوالي', 'المتعالي', 'البر', 'التواب',
  'المنتقم', 'العفو', 'الرؤوف', 'المقسط', 'الجامع', 'الغني', 'المغني', 'المانع',
  'الضار', 'النافع', 'النور', 'الهادي', 'البديع', 'الباقي', 'الوارث', 'الرشيد',
  'الصبور',
};

/// Whether a Quran word is Allah, a form of "Rabb", or one of the names of
/// Allah (checked after stripping a common prefix like و ف ب ل ك).
bool isDivineName(String word) {
  final normalized = normalizeArabic(word);
  if (normalized.isEmpty) return false;
  if (_allah.hasMatch(normalized) || _rabb.hasMatch(normalized)) return true;
  var stripped = normalized;
  final m = _prefix.firstMatch(stripped);
  if (m != null) stripped = stripped.substring(m.end);
  return _namesOfAllah.contains(stripped);
}

/// Splits Quran text into spans.
/// - Names of Allah: always gold, with a glow whose intensity is [glowAlpha]
///   (pass an animated value while the verse is being read, to make them
///   shimmer instead of changing color).
/// - Other words: normal color, unless [activeColor] is given (used to turn
///   the whole verse gold while a reciter is reading it).
List<InlineSpan> quranSpans(
  String text,
  TextStyle base, {
  double scale = 1.14,
  Color? activeColor,
  double glowAlpha = 0.45,
}) {
  final spans = <InlineSpan>[];
  final plain = StringBuffer();

  void flushPlain() {
    if (plain.isEmpty) return;
    if (activeColor != null) {
      spans.add(TextSpan(text: plain.toString(), style: TextStyle(color: activeColor)));
    } else {
      spans.add(TextSpan(text: plain.toString()));
    }
    plain.clear();
  }

  final words = text.split(' ');
  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    final space = i == words.length - 1 ? '' : ' ';
    if (word.isNotEmpty && isDivineName(word)) {
      flushPlain();
      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            color: kDivineGold,
            fontSize: (base.fontSize ?? 20) * scale,
            shadows: [
              Shadow(color: kDivineGold.withValues(alpha: glowAlpha), blurRadius: 8),
            ],
          ),
        ),
      );
      plain.write(space);
    } else {
      plain.write(word);
      plain.write(space);
    }
  }
  flushPlain();
  return spans;
}
