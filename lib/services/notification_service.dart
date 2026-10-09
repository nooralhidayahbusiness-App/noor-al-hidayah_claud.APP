import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/app_state.dart';
import '../core/prayer_state.dart';
import 'user_service.dart';

class PrayerEntry {
  final String name;
  final DateTime time;
  const PrayerEntry(this.name, this.time);
}

typedef OnPrayerTap = void Function(String prayerKey, DateTime prayerTime);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _supported = false;

  /// آخر خطأ حدث أثناء الجدولة (يظهر في رسالة الاختبار)
  String lastError = '';

  OnPrayerTap? onPrayerTap;
  NotificationResponse? _pendingLaunchResponse;

  static const _prayerIds = {
    'fajr': 100,
    'dhuhr': 101,
    'asr': 102,
    'maghrib': 103,
    'isha': 104,
  };

  /// عدد الأيام التي تُجدول مسبقاً (اليوم + الأيام التالية)
  static const int _daysAhead = 3;

  static const _dailyChallengeId = 300;
  static const _quranReminderId = 301;
  static const _dailyVerseId = 302;
  static const int _ongoingId = 400;
  static const int _testAdhanId = 999;

  static const Color _goldColor = Color(0xFFD4AF37);

  bool get isSupported => _supported;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      _supported = false;
      return;
    }

    try {
      tzdata.initializeTimeZones();

      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
        debugPrint('[ALARM] Timezone = $name');
      } catch (e) {
        debugPrint('[ERROR] Timezone: $e');
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onTap,
      );

      _supported = Platform.isAndroid || Platform.isIOS;

      await _createChannels();

      try {
        final details = await _plugin.getNotificationAppLaunchDetails();
        if (details?.didNotificationLaunchApp == true) {
          _pendingLaunchResponse = details?.notificationResponse;
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('[ERROR] init: $e');
      _supported = false;
    }
  }

  Future<void> _createChannels() async {
    if (!Platform.isAndroid) return;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_channel_v4',
          'Prayer Notifications',
          description: 'Adhan notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'ongoing_prayer_channel_v4',
          'Next Prayer Countdown',
          description: 'Persistent next prayer countdown',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_channel_v3',
          'Daily Reminders',
          description: 'Daily reminders',
          importance: Importance.defaultImportance,
        ),
      );

      debugPrint('[ALARM] Channels created');
    } catch (e) {
      debugPrint('[ERROR] createChannels: $e');
    }
  }

  void consumePendingLaunch() {
    final resp = _pendingLaunchResponse;
    if (resp == null) return;
    _pendingLaunchResponse = null;
    _onTap(resp);
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    if (parts.isEmpty) return;

    final prayerKey = parts[0];
    if (prayerKey.isEmpty) return;

    DateTime when;
    if (parts.length > 1) {
      final ms = int.tryParse(parts[1]);
      when = ms != null
          ? DateTime.fromMillisecondsSinceEpoch(ms)
          : DateTime.now();
    } else {
      when = DateTime.now();
    }

    if (onPrayerTap == null) {
      _pendingLaunchResponse = response;
      return;
    }

    onPrayerTap?.call(prayerKey, when);
  }

  Future<bool> requestPermissions() async {
    if (!_supported) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      bool granted = false;

      if (android != null) {
        final res = await android.requestNotificationsPermission();
        granted = res ?? false;
        debugPrint('[NOTIFICATION] Permission = $granted');

        try {
          await android.requestFullScreenIntentPermission();
        } catch (_) {}

        try {
          await Permission.ignoreBatteryOptimizations.request();
        } catch (_) {}
      }

      if (ios != null) {
        final res = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = res ?? false;
      }

      return granted;
    } catch (e) {
      debugPrint('[ERROR] requestPermissions: $e');
      return false;
    }
  }

  Future<void> cancelAll() async {
    if (!_supported) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// ✅ جدولة بدقة عالية (alarmClock) مع بديل احتياطي (inexact)
  Future<void> _zonedScheduleSafe({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required NotificationDetails details,
    String? payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[ALARM] alarmClock failed ($e) → fallback inexact');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  NotificationDetails _prayerDetails({Color? color}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel_v4',
        appState.tr('notifChannelPrayer'),
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
        color: color,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showImmediateNotification() async {
    if (!_supported) return;
    try {
      await _plugin.show(
        _testAdhanId,
        appState.isArabic ? 'اختبار فوري' : 'Immediate Test',
        appState.isArabic ? 'اضغط لفتح شاشة الأذان' : 'Tap to open Adhan',
        _prayerDetails(),
        payload: 'asr|${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint('[TEST] Immediate failed: $e');
    }
  }

  Future<bool> scheduleTestAdhan() async {
    lastError = '';
    if (!_supported) {
      lastError = 'not supported';
      return false;
    }

    final target = DateTime.now().add(const Duration(seconds: 30));
    debugPrint('[TEST] Target: $target');

    try {
      await _zonedScheduleSafe(
        id: _testAdhanId,
        title: appState.isArabic ? 'اختبار الأذان' : 'Adhan Test',
        body: appState.isArabic ? 'سيتم فتح شاشة الأذان' : 'Adhan will open',
        when: tz.TZDateTime.from(target, tz.local),
        details: _prayerDetails(),
        payload: 'asr|${target.millisecondsSinceEpoch}',
      );
      debugPrint('[TEST] ✅ Scheduled');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('[TEST] ❌ Failed: $e');
      return false;
    }
  }

  Future<void> showOngoingPrayer({
    required String prayerName,
    required DateTime targetTime,
    required bool urgent,
    String? hijriDate,
  }) async {
    if (!_supported) return;

    try {
      final now = DateTime.now();
      final today = now;

      final months = appState.isArabic
          ? [
              'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
              'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
            ]
          : [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
            ];

      final weekday = appState.isArabic
          ? [
              'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
              'الجمعة', 'السبت', 'الأحد',
            ][today.weekday - 1]
          : [
              'Mon', 'Tue', 'Wed', 'Thu',
              'Fri', 'Sat', 'Sun',
            ][today.weekday - 1];

      final dateStr = '$weekday، ${today.day} ${months[today.month - 1]}';

      final title = appState.isArabic
          ? 'Noor Al-Hidayah • الصلاة القادمة: $prayerName'
          : 'Noor Al-Hidayah • Next prayer: $prayerName';

      final hijri = (hijriDate ?? '').trim();
      final body = hijri.isNotEmpty ? '$dateStr • $hijri' : dateStr;

      final expanded = appState.isArabic
          ? 'الصلاة القادمة: $prayerName\n$body\nالوقت المتبقي بالعد التنازلي'
          : 'Next prayer: $prayerName\n$body\nLive countdown';

      await _plugin.show(
        _ongoingId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'ongoing_prayer_channel_v4',
            appState.tr('notifChannelPrayer'),
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
            ongoing: true,
            autoCancel: false,
            showWhen: true,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            usesChronometer: true,
            chronometerCountDown: true,
            when: targetTime.millisecondsSinceEpoch,
            styleInformation: BigTextStyleInformation(
              expanded,
              contentTitle: title,
              summaryText: hijri.isNotEmpty ? hijri : null,
            ),
            color: urgent
                ? const Color(0xFFFFA000)
                : const Color(0xFF4CAF50),
            colorized: false,
            category: AndroidNotificationCategory.status,
            visibility: NotificationVisibility.public,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
      debugPrint('[NOTIFICATION] Ongoing shown: $prayerName');
    } catch (e) {
      debugPrint('[ERROR] Ongoing: $e');
    }
  }

  Future<void> hideOngoingPrayer() async {
    if (!_supported) return;
    try {
      await _plugin.cancel(_ongoingId);
    } catch (_) {}
  }

  /// معرّف إشعار الصلاة ليوم معيّن (0 = اليوم، 1 = غداً ...)
  int _prayerNotifId(String name, int dayOffset) {
    final base = _prayerIds[name] ?? 100;
    return base + (dayOffset * 10);
  }

  Future<void> reschedule({required List<PrayerEntry> prayers}) async {
    if (!_supported) return;

    debugPrint('[ALARM] Rescheduling ${prayers.length} prayers');

    // ✅ نلغي إشعارات الصلاة والتذكيرات فقط
    // (cancelAll كان يمسح الإشعار الدائم وإشعار الاختبار أيضاً)
    try {
      for (int d = 0; d < _daysAhead; d++) {
        for (final name in _prayerIds.keys) {
          await _plugin.cancel(_prayerNotifId(name, d));
        }
      }
      await _plugin.cancel(_dailyChallengeId);
      await _plugin.cancel(_quranReminderId);
      await _plugin.cancel(_dailyVerseId);
    } catch (_) {}

    final settings = await userService.loadSettings();
    final notifs = (settings['notifications'] as Map?) ?? {};
    final beforeMin =
        (notifs['adhanBeforeMinutes'] as num?)?.toInt() ?? 0;

    final now = DateTime.now();

    for (int d = 0; d < _daysAhead; d++) {
      for (final p in prayers) {
        final enabled = notifs[p.name] == true;
        if (!enabled) continue;

        final prayerAt = DateTime(
          p.time.year,
          p.time.month,
          p.time.day + d,
          p.time.hour,
          p.time.minute,
        );
        final notifyAt = prayerAt.subtract(Duration(minutes: beforeMin));
        if (notifyAt.isBefore(now)) continue;

        await _schedulePrayer(
          id: _prayerNotifId(p.name, d),
          name: p.name,
          at: prayerAt,
          notifyAt: notifyAt,
          beforeMin: beforeMin,
        );
      }
    }

    if (notifs['dailyChallenge'] == true) {
      await _scheduleDaily(
        id: _dailyChallengeId,
        title: appState.tr('notifDailyChallengeTitle'),
        body: appState.tr('notifDailyChallengeBody'),
        hour: 9,
        minute: 0,
      );
    }
    if (notifs['quranReminder'] == true) {
      await _scheduleDaily(
        id: _quranReminderId,
        title: appState.tr('notifQuranReminderTitle'),
        body: appState.tr('notifQuranReminderBody'),
        hour: 6,
        minute: 0,
      );
    }
    if (notifs['dailyVerse'] == true) {
      await _scheduleDaily(
        id: _dailyVerseId,
        title: appState.tr('notifDailyVerseTitle'),
        body: appState.tr('notifDailyVerseBody'),
        hour: 7,
        minute: 0,
      );
    }
  }

  Future<void> _schedulePrayer({
    required int id,
    required String name,
    required DateTime at,
    required DateTime notifyAt,
    required int beforeMin,
  }) async {
    final prayerName = appState.tr(name);
    final title = beforeMin == 0
        ? '${appState.tr('notifAdhanNow')} · $prayerName'
        : '${appState.tr('notifAdhanBefore')} $beforeMin ${appState.tr('minutes')} · $prayerName';
    final body = appState.tr('notifAdhanBody');
    final payload = '$name|${at.millisecondsSinceEpoch}';

    try {
      await _zonedScheduleSafe(
        id: id,
        title: title,
        body: body,
        when: tz.TZDateTime.from(notifyAt, tz.local),
        details: _prayerDetails(color: _goldColor),
        payload: payload,
      );
      debugPrint('[ALARM] ✅ $name at $notifyAt');
    } catch (e) {
      lastError = e.toString();
      debugPrint('[ERROR] $name: $e');
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (first.isBefore(now)) first = first.add(const Duration(days: 1));

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(first, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel_v3',
            appState.tr('notifChannelDaily'),
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[ERROR] Daily ($id): $e');
    }
  }

  List<PrayerEntry> collectPrayerTimes() {
    final list = <PrayerEntry>[];
    final data = prayerState.data;
    if (data == null) return list;

    try {
      final now = DateTime.now();
      void add(String key, String value) {
        final parsed = _parseTimeText(value, now);
        if (parsed != null) list.add(PrayerEntry(key, parsed));
      }

      add('fajr', data.fajr);
      add('dhuhr', data.dhuhr);
      add('asr', data.asr);
      add('maghrib', data.maghrib);
      add('isha', data.isha);
    } catch (_) {}

    return list;
  }

  DateTime? _parseTimeText(String text, DateTime day) {
    try {
      final isAm = text.contains('ص') || text.toUpperCase().contains('AM');
      final isPm = text.contains('م') || text.toUpperCase().contains('PM');
      final cleaned = text
          .replaceAll('ص', '')
          .replaceAll('م', '')
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .replaceAll('am', '')
          .replaceAll('pm', '')
          .trim();
      final parts = cleaned.split(':');
      if (parts.length < 2) return null;
      var h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      if (isPm && h < 12) h += 12;
      if (isAm && h == 12) h = 0;
      return DateTime(day.year, day.month, day.day, h, m);
    } catch (_) {
      return null;
    }
  }
}

final notificationService = NotificationService.instance;
