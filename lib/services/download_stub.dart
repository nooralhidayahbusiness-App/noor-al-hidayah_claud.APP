import '../models/reciter.dart';

/// Web preview: offline downloads are not supported by the browser sandbox.
class AudioDownloadService {
  static Future<bool> isDownloaded(
    String reciterId,
    int surah,
    int ayahCount,
  ) async =>
      false;

  static Future<String?> localPathIfExists(
    String reciterId,
    int surah,
    int ayah,
  ) async =>
      null;

  static Future<void> downloadSurah(
    Reciter reciter,
    int surah,
    int ayahCount,
    void Function(int done, int total) onProgress,
  ) async {
    throw UnsupportedError('offline download only works in the installed app');
  }

  static Future<void> deleteSurah(String reciterId, int surah) async {}
}
