import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import 'notification_service.dart';

/// الإشعار الدائم المخصّص للصلاة القادمة (Android فقط).
///
/// يرسل جدول الصلوات للجزء الأصلي (Java) الذي:
///  - يعرض الإشعار بتصميم مخصص مع عدّاد حيّ
///  - يغيّر لونه تلقائياً: أخضر ← برتقالي (قبل 10 دقائق) ← أحمر بعد الأذان
///  - يحدّث نفسه بالمنبّهات حتى لو كان التطبيق مغلقاً
class PrayerCountdownService {
  PrayerCountdownService._();
  static final PrayerCountdownService instance = PrayerCountdownService._();

  static const MethodChannel _channel = MethodChannel('noor/prayer_countdown');

  /// مدة اللون البرتقالي قبل الأذان (بالدقائق)
  static const int soonMinutes = 10;

  /// مدة بقاء العدّاد الأحمر (السالب) بعد دخول وقت الصلاة (بالدقائق)
  static const int afterMinutes = 30;

  /// عدد الأيام التي تُرسل مسبقاً (لتعمل الإشعارات والتطبيق مغلق)
  static const int _daysAhead = 3;

  static const _namesAr = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  static const _namesEn = {
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
  };

  String? _lastPayload;
  DateTime? _lastSentAt;

  bool get isAvailable => !kIsWeb && Platform.isAndroid;

  /// يرسل الجدول للجزء الأصلي. يعيد true عند النجاح.
  Future<bool> sync({
    required List<PrayerEntry> today,
    String? hijri,
  }) async {
    if (!isAvailable || today.isEmpty) return false;

    final prayers = <Map<String, dynamic>>[];
    for (int d = 0; d < _daysAhead; d++) {
      for (final p in today) {
        final at = DateTime(
          p.time.year,
          p.time.month,
          p.time.day + d,
          p.time.hour,
          p.time.minute,
        );
        prayers.add({
          'key': p.name,
          'ar': _namesAr[p.name] ?? p.name,
          'en': _namesEn[p.name] ?? p.name,
          't': at.millisecondsSinceEpoch,
        });
      }
    }
    prayers.sort((a, b) => (a['t'] as int).compareTo(b['t'] as int));

    final payload = jsonEncode({
      'appName': 'Noor Al-Hidayah',
      'labelNext': appState.isArabic ? 'الصلاة القادمة' : 'Next prayer',
      'labelNow': appState.isArabic ? 'حان وقت الصلاة' : 'Prayer time',
      'hijri': (hijri ?? '').trim(),
      'lang': appState.isArabic ? 'ar' : 'en',
      'soonMinutes': soonMinutes,
      'afterMinutes': afterMinutes,
      'prayers': prayers,
    });

    // نتجنب إعادة الإرسال المتكرر لنفس البيانات
    final now = DateTime.now();
    if (payload == _lastPayload &&
        _lastSentAt != null &&
        now.difference(_lastSentAt!).inMinutes < 20) {
      return true;
    }

    try {
      await _channel.invokeMethod('update', {'json': payload});
      _lastPayload = payload;
      _lastSentAt = now;
      return true;
    } on MissingPluginException {
      debugPrint('[COUNTDOWN] native channel missing');
      return false;
    } catch (e) {
      debugPrint('[COUNTDOWN] sync failed: $e');
      return false;
    }
  }

  Future<void> cancel() async {
    if (!isAvailable) return;
    try {
      await _channel.invokeMethod('cancel');
      _lastPayload = null;
    } catch (_) {}
  }
}

final prayerCountdownService = PrayerCountdownService.instance;
