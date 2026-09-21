import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart'
    show ShareParams, SharePlus, ShareResultStatus;

import '../core/app_state.dart';
import '../core/quran_prefs.dart';
import '../models/quran.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/ayah_share_card.dart';
import 'tafsir_service.dart';

/// Draws a beautiful image of the verse and opens the share sheet
/// (save, WhatsApp, files ...).
Future<void> shareAyahImage(
  BuildContext context, {
  required QuranSurah surah,
  required QuranAyah ayah,
}) async {
  showAuthMessage(context, appState.tr('preparingImage'));
  try {
    var tafsirText = '';
    var tafsirSource = '';
    if (quranPrefs.showTafsir) {
      final data = await TafsirService.load();
      tafsirText = data.textFor(
        arabic: appState.isArabic,
        surah: surah.number,
        ayah: ayah.number,
      );
      tafsirSource = tafsirText.isEmpty ? '' : data.sourceName(appState.isArabic);
    }
    if (!context.mounted) return;
    try {
      await precacheImage(const AssetImage('assets/images/logo.png'), context);
    } catch (_) {}
    if (!context.mounted) return;

    final card = AyahShareCard(
      surah: surah,
      ayah: ayah,
      simpleFont: quranPrefs.simpleFont,
      translation: quranPrefs.showTranslation ? ayah.translation : '',
      tafsir: tafsirText,
      tafsirSource: tafsirSource,
    );
    final bytes = await ScreenshotController().captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.transparent,
          child: MediaQuery(
            data: MediaQuery.of(context),
            child: Directionality(
              textDirection: appState.direction,
              child: card,
            ),
          ),
        ),
      ),
      pixelRatio: 3,
      delay: const Duration(milliseconds: 250),
      context: context,
      constraints: const BoxConstraints(maxWidth: 380),
    );

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'image/png')],
        fileNameOverrides: ['ayah-${surah.number}-${ayah.number}.png'],
      ),
    );
    if (result.status == ShareResultStatus.unavailable && context.mounted) {
      showAuthMessage(context, appState.tr('imageUnsupported'), error: true);
    }
  } catch (_) {
    if (context.mounted) {
      showAuthMessage(context, appState.tr('imageError'), error: true);
    }
  }
}
