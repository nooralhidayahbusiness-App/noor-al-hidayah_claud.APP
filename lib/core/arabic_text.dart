final RegExp _diacritics = RegExp('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]');
final RegExp _alefForms = RegExp('[\u0622\u0623\u0625\u0671]');

/// Removes diacritics and unifies letter forms, so searching works
/// with or without tashkeel.
String normalizeArabic(String text) {
  return text
      .replaceAll(_diacritics, '')
      .replaceAll(_alefForms, '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u0629', '\u0647');
}
