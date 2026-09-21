import 'package:flutter/material.dart';

import 'arabic_text.dart';

/// Distinctive gold used for the names of Allah in the Quran text.
const Color kDivineGold = Color(0xFFFFD86B);

// Allah: الله، لله، بالله، والله، فالله، تالله، اللهم ...
final RegExp _allah = RegExp(r'^(و|ف|ب|وب|فب|ت|وت|ك)?(الله|لله|اللهم)$');

// Rabb: رب، ربي، ربك، ربكم، ربنا، ربهم، ربه، وربك، بربهم، لربه ...
final RegExp _rabb = RegExp(
  r'^(و|ف|ب|ل|وب|ول|فب|فل)?رب(ي|ك|كم|كما|نا|هم|هما|ه|ها|هن)?$',
);

/// Whether a Quran word is a name of Allah that should be highlighted.
bool isDivineName(String word) {
  final normalized = normalizeArabic(word);
  if (normalized.isEmpty) return false;
  return _allah.hasMatch(normalized) || _rabb.hasMatch(normalized);
}

/// Splits Quran text into spans: names of Allah in bright gold and a bit larger.
List<InlineSpan> quranSpans(
  String text,
  TextStyle base, {
  double scale = 1.14,
}) {
  final spans = <InlineSpan>[];
  final plain = StringBuffer();

  void flushPlain() {
    if (plain.isEmpty) return;
    spans.add(TextSpan(text: plain.toString()));
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
              Shadow(
                color: kDivineGold.withValues(alpha: 0.45),
                blurRadius: 8,
              ),
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
