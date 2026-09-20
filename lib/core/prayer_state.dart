import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/prayer_times_data.dart';
import '../models/saved_location.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';

enum PrayerStatus { idle, loading, ready, error }

class NextPrayer {
  const NextPrayer(this.key, this.timeText, this.at);

  final String key;
  final String timeText;
  final DateTime at;
}

/// Holds the prayer times so every screen shares the same data.
class PrayerState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final PrayerService _service = PrayerService();

  /// Ticks every second (only countdowns and highlights listen to it).
  final ValueNotifier<DateTime> now = ValueNotifier<DateTime>(DateTime.now());

  PrayerStatus status = PrayerStatus.idle;
  SavedLocation? location;
  PrayerTimesData? data;

  Timer? _ticker;
  bool _loading = false;
  int _loadedDay = DateTime.now().day;

  /// Starts the clock and loads the times (safe to call more than once).
  void start() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final current = DateTime.now();
      now.value = current;
      if (status == PrayerStatus.ready && current.day != _loadedDay) {
        _loadedDay = current.day;
        load();
      }
    });
    if (status == PrayerStatus.idle) Future.microtask(load);
  }

  /// Forget everything (used after the user picks a new location).
  void reset() {
    data = null;
    location = null;
    status = PrayerStatus.idle;
    notifyListeners();
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    if (data == null) {
      status = PrayerStatus.loading;
      notifyListeners();
    }
    try {
      final saved = await _storage.loadLocation();
      if (saved == null) {
        status = PrayerStatus.error;
        return;
      }
      final result = saved.hasCoordinates
          ? await _service.byCoordinates(saved.latitude!, saved.longitude!)
          : await _service.byAddress(saved.address ?? saved.label);
      location = saved;
      data = result;
      _loadedDay = DateTime.now().day;
      status = PrayerStatus.ready;
    } catch (_) {
      if (data == null) status = PrayerStatus.error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// The next prayer after "now" (tomorrow's Fajr after Isha).
  NextPrayer? nextPrayer() {
    final d = data;
    if (d == null) return null;
    final current = now.value;

    DateTime at(String hhmm, {int addDays = 0}) {
      final p = hhmm.split(':');
      return DateTime(
        current.year,
        current.month,
        current.day + addDays,
        int.parse(p[0]),
        int.parse(p[1]),
      );
    }

    for (final e in d.prayers) {
      final t = at(e.value);
      if (t.isAfter(current)) return NextPrayer(e.key, e.value, t);
    }
    final first = d.prayers.first;
    return NextPrayer(first.key, first.value, at(first.value, addDays: 1));
  }
}

final PrayerState prayerState = PrayerState();
