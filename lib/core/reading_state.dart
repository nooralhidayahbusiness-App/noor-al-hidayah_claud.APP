import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A place in the Quran: a verse (lines mode) or a page (mushaf mode).
class ReadingPosition {
  const ReadingPosition({
    required this.surah,
    required this.ayah,
    required this.page,
    required this.pageMode,
  });

  final int surah;
  final int ayah;
  final int page;
  final bool pageMode;

  String encode() => '$surah|$ayah|$page|${pageMode ? 1 : 0}';

  static ReadingPosition? decode(String? raw) {
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length != 4) return null;
    final numbers = [for (final p in parts) int.tryParse(p)];
    if (numbers.any((n) => n == null)) return null;
    return ReadingPosition(
      surah: numbers[0]!,
      ayah: numbers[1]!,
      page: numbers[2]!,
      pageMode: numbers[3] == 1,
    );
  }
}

/// Last read place (saved automatically) and the bookmark (saved by the user).
class ReadingState extends ChangeNotifier {
  static const _lastKey = 'reading_last';
  static const _bookmarkKey = 'reading_bookmark';

  ReadingPosition? last;
  ReadingPosition? bookmark;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    last = ReadingPosition.decode(prefs.getString(_lastKey));
    bookmark = ReadingPosition.decode(prefs.getString(_bookmarkKey));
    notifyListeners();
  }

  Future<void> saveLast(ReadingPosition position) async {
    last = position;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastKey, position.encode());
  }

  Future<void> saveBookmark(ReadingPosition position) async {
    bookmark = position;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookmarkKey, position.encode());
  }
}

final ReadingState readingState = ReadingState();
