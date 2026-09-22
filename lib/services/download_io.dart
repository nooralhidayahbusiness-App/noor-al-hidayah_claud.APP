import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/reciter.dart';

/// Real offline downloads (used in the installed app, not the web preview).
class AudioDownloadService {
  static Future<Directory> _dir(String reciterId, int surah) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/quran_audio/$reciterId/$surah');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File> _file(String reciterId, int surah, int ayah) async {
    final dir = await _dir(reciterId, surah);
    return File('${dir.path}/$ayah.mp3');
  }

  static Future<bool> isDownloaded(
    String reciterId,
    int surah,
    int ayahCount,
  ) async {
    for (var a = 1; a <= ayahCount; a++) {
      if (!await (await _file(reciterId, surah, a)).exists()) return false;
    }
    return true;
  }

  static Future<String?> localPathIfExists(
    String reciterId,
    int surah,
    int ayah,
  ) async {
    final f = await _file(reciterId, surah, ayah);
    return await f.exists() ? f.path : null;
  }

  static Future<void> downloadSurah(
    Reciter reciter,
    int surah,
    int ayahCount,
    void Function(int done, int total) onProgress,
  ) async {
    for (var a = 1; a <= ayahCount; a++) {
      final f = await _file(reciter.id, surah, a);
      if (!await f.exists()) {
        final response = await http
            .get(Uri.parse(reciter.ayahUrl(surah, a)))
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          await f.writeAsBytes(response.bodyBytes);
        }
      }
      onProgress(a, ayahCount);
    }
  }

  static Future<void> deleteSurah(String reciterId, int surah) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/quran_audio/$reciterId/$surah');
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
