import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'prayer_countdown_service.dart';

/// يعرض سجل آخر انهيار حدث في التطبيق (Android) لتشخيص المشاكل.
/// عند وجود سجل: يُعطَّل الإشعار الدائم المخصّص في هذه الجلسة (وضع آمن).
class CrashReport {
  CrashReport._();
  static final CrashReport instance = CrashReport._();

  static const MethodChannel _channel = MethodChannel('noor/prayer_countdown');

  Future<void> checkAndShow(GlobalKey<NavigatorState> navigatorKey) async {
    if (kIsWeb || !Platform.isAndroid) return;

    String? text;
    try {
      text = await _channel.invokeMethod<String>('lastCrash');
    } catch (_) {
      return;
    }
    if (text == null || text.trim().isEmpty) return;

    // وضع آمن: لا نشغّل الإشعار المخصّص حتى لا يتكرر الانهيار
    prayerCountdownService.safeMode = true;

    await Future.delayed(const Duration(seconds: 2));
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final shown = text.length > 3500 ? text.substring(0, 3500) : text;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سجل آخر انهيار'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              shown,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 10.5, height: 1.3),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text!));
            },
            child: const Text('نسخ'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _channel.invokeMethod('clearCrash');
              } catch (_) {}
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('إغلاق ومسح'),
          ),
        ],
      ),
    );
  }
}

final CrashReport crashReport = CrashReport.instance;
