import 'dart:io';

import 'package:flutter/foundation.dart';
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

  OnPrayerTap? onPrayerTap;

  NotificationResponse? _pendingLaunchResponse;

  static const _prayerIds = {
    'fajr': 100,
    'dhuhr': 101,
    'asr': 102,
    'maghrib': 103,
    'isha': 104,
  };

  static const _dailyChallengeId = 300;
  static const _quranReminderId = 301;
  static const _dailyVerseId = 302;

  // ✅ ID للإشعار الدائم
  static const int _ongoingId = 400;

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
      } catch (_) {}

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

      try {
        final details = await _plugin.getNotificationAppLaunchDetails();
        if (details?.didNotificationLaunchApp == true) {
          _pendingLaunchResponse = details?.notificationResponse;
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Notification init error: $e');
      _supported = false;
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

    // تجاهل الإشعار الدائم (لا payload)
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

        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {}

        // ✅ صلاحية الشاشة الكاملة (Android 14+)
        try {
          await android.requestFullScreenIntentPermission();
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
    } catch (_) {
      return false;
    }
  }

  Future<void> openExactAlarmSettings() async {
    if (!_supported) return;
    try {
      await Permission.scheduleExactAlarm.request();
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_supported) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  // ============================================================
  // ✅ الإشعار الدائم (الصلاة القادمة + العد التنازلي)
  // ============================================================
  Future<void> showOngoingPrayer({
    required String title,
    required String body,
  }) async {
    if (!_supported) return;
    try {
      await _plugin.show(
        _ongoingId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'ongoing_prayer_channel',
            appState.tr('notifChannelPrayer'),
            channelDescription: 'Next prayer countdown',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
            ongoing: true,
            autoCancel: false,
            showWhen: false,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
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
    } catch (e) {
      debugPrint('showOngoingPrayer error: $e');
    }
  }

  Future<void> hideOngoingPrayer() async {
    if (!_supported) return;
    try {
      await _plugin.cancel(_ongoingId);
    } catch (_) {}
  }

  // ============================================================
  // جدولة الإشعارات
  // ============================================================
  Future<void> reschedule({required List<PrayerEntry> prayers}) async {
    if (!_supported) return;

    await cancelAll();

    final settings = await userService.loadSettings();
    final notifs = (settings['notifications'] as Map?) ?? {};
    final beforeMin =
        (notifs['adhanBeforeMinutes'] as num?)?.toInt() ?? 0;

    for (final p in prayers) {
      final enabled = notifs[p.name] == true;
      if (!enabled) continue;

      final notifyAt = p.time.subtract(Duration(minutes: beforeMin));
      if (notifyAt.isBefore(DateTime.now())) continue;

      await _schedulePrayer(
        id: _prayerIds[p.name] ?? 100,
        name: p.name,
        at: p.time,
        notifyAt: notifyAt,
        beforeMin: beforeMin,
      );
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
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(notifyAt, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel_v3',
            appState.tr('notifChannelPrayer'),
            channelDescription: 'Adhan notifications',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            visibility: NotificationVisibility.public,
            ticker: title,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('✅ Scheduled $name at $notifyAt');
    } catch (e) {
      debugPrint('❌ Schedule error ($name): $e');
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
    if (first.isBefore(now)) {
      first = first.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(first, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel_v2',
            appState.tr('notifChannelDaily'),
            channelDescription: appState.tr('notifChannelDailyDesc'),
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
      debugPrint('Daily schedule error ($id): $e');
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
