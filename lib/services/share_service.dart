import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../models/quran.dart';
import '../widgets/auth_widgets.dart';

/// Shares or copies one ayah (image/text).
Future<void> shareAyahImage(
  BuildContext context, {
  required QuranSurah surah,
  required QuranAyah ayah,
}) async {
  // نبني نص الآية مع المرجع
  final text = StringBuffer()
    ..writeln(ayah.uthmani)
    ..writeln()
    ..writeln('${surah.nameAr} • الآية ${ayah.number}')
    ..writeln('سورة ${surah.nameAr} - ${surah.nameEn}')
    ..write('نور الهداية');

  // حالياً: انسخ النص للحافظة واعرض رسالة
  await Clipboard.setData(ClipboardData(text: text.toString()));
  if (context.mounted) {
    showAuthMessage(context, appState.tr('copied'));
  }
}
