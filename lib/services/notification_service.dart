import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

/// دالة تُستدعى عند الضغط على إشعار الصلاة.
typedef OnPrayerTap = void Function(String prayerKey, DateTime prayerTime);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _supported = false;

  OnPrayerTap? onPrayerTap;

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
        const InitializationSettings(
          android: android,
          iOS: ios,
        ),
        onDidReceiveNotificationResponse: _onTap,
      );

      _supported = Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      debugPrint('Notification init error: $e');
      _supported = false;
    }
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    // الصيغة: "prayerKey|timestampMs"
    final parts = payload.split('|');
    if (parts.isEmpty) return;

    final prayerKey = parts[0];
    DateTime when;
    if (parts.length > 1) {
      final ms = int.tryParse(parts[1]);
      when = ms != null
          ? DateTime.fromMillisecondsSinceEpoch(ms)
          : DateTime.now();
    } else {
      when = DateTime.now();
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

      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {}
        return granted ?? false;
      }
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelAll() async {
    if (!_supported) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> reschedule({
    required List<PrayerEntry> prayers,
  }) async {
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
            'prayer_channel',
            appState.tr('notifChannelPrayer'),
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Schedule error ($id): $e');
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
            'daily_channel',
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
      final dyn = data as dynamic;
      final now = DateTime.now();

      void add(String key, dynamic value) {
        if (value is DateTime) {
          list.add(PrayerEntry(key, value));
        } else if (value is String) {
          final parsed = _parseTimeText(value, now);
          if (parsed != null) list.add(PrayerEntry(key, parsed));
        }
      }

      try {
        add('fajr', dyn.fajr);
      } catch (_) {}
      try {
        add('dhuhr', dyn.dhuhr);
      } catch (_) {}
      try {
        add('asr', dyn.asr);
      } catch (_) {}
      try {
        add('maghrib', dyn.maghrib);
      } catch (_) {}
      try {
        add('isha', dyn.isha);
      } catch (_) {}

      if (list.isEmpty) {
        try {
          final prayers = dyn.prayers as List;
          for (final p in prayers) {
            final pd = p as dynamic;
            final name = (pd.name ?? pd.key) as String?;
            final at = pd.at ?? pd.time;
            if (name != null && at is DateTime) {
              list.add(PrayerEntry(name.toLowerCase(), at));
            }
          }
        } catch (_) {}
      }
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
