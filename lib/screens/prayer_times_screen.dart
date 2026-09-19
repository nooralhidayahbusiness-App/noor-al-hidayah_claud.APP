import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/navigation.dart';
import '../core/theme.dart';
import '../models/prayer_times_data.dart';
import '../models/saved_location.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_branding.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/number_text.dart';
import 'location_screen.dart';

enum _Status { loading, ready, error }

class _Next {
  const _Next(this.key, this.timeText, this.at);
  final String key;
  final String timeText;
  final DateTime at;
}

String _format12(String hhmm) {
  final parts = hhmm.split(':');
  final hour = int.parse(parts[0]);
  final arabic = appState.isArabic;
  final suffix = hour >= 12 ? (arabic ? 'م' : 'PM') : (arabic ? 'ص' : 'AM');
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour12:${parts[1]} $suffix';
}

String _countdown(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = (total ~/ 3600).toString().padLeft(2, '0');
  final m = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (total % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

_Next _nextPrayer(PrayerTimesData data, DateTime now) {
  DateTime at(String hhmm, {int addDays = 0}) {
    final p = hhmm.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day + addDays,
      int.parse(p[0]),
      int.parse(p[1]),
    );
  }

  for (final e in data.prayers) {
    final t = at(e.value);
    if (t.isAfter(now)) return _Next(e.key, e.value, t);
  }
  final first = data.prayers.first;
  return _Next(first.key, first.value, at(first.value, addDays: 1));
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _storage = StorageService();
  final _service = PrayerService();

  _Status _status = _Status.loading;
  SavedLocation? _location;
  PrayerTimesData? _data;
  DateTime _now = DateTime.now();
  int _loadedDay = DateTime.now().day;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      setState(() => _now = now);
      if (_status == _Status.ready && now.day != _loadedDay) {
        _loadedDay = now.day;
        _load();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final location = await _storage.loadLocation();
      if (location == null) {
        if (mounted) setState(() => _status = _Status.error);
        return;
      }
      final data = location.hasCoordinates
          ? await _service.byCoordinates(
              location.latitude!,
              location.longitude!,
            )
          : await _service.byAddress(location.address ?? location.label);
      if (!mounted) return;
      setState(() {
        _location = location;
        _data = data;
        _loadedDay = DateTime.now().day;
        _status = _Status.ready;
      });
    } catch (_) {
      if (!mounted) return;
      if (_data == null) setState(() => _status = _Status.error);
    }
  }

  void _retry() {
    setState(() => _status = _Status.loading);
    _load();
  }

  void _changeLocation() {
    Navigator.of(context).push(fadeRoute(const LocationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _changeLocation,
                          tooltip: appState.tr('changeLocation'),
                          color: AppColors.softGold,
                          icon: const Icon(Icons.edit_location_alt_outlined),
                        ),
                        const Spacer(),
                        const AuthLanguageButton(),
                      ],
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return switch (_status) {
      _Status.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      _Status.error => _ErrorView(
          onRetry: _retry,
          onChange: _changeLocation,
        ),
      _Status.ready => _buildTimes(_data!, _location!),
    };
  }

  Widget _buildTimes(PrayerTimesData data, SavedLocation location) {
    final next = _nextPrayer(data, _now);
    final remaining = next.at.difference(_now);
    final rows = <MapEntry<String, String>>[
      MapEntry('fajr', data.fajr),
      MapEntry('sunrise', data.sunrise),
      MapEntry('dhuhr', data.dhuhr),
      MapEntry('asr', data.asr),
      MapEntry('maghrib', data.maghrib),
      MapEntry('isha', data.isha),
    ];
    const icons = <String, IconData>{
      'fajr': Icons.nightlight_round,
      'sunrise': Icons.wb_sunny_outlined,
      'dhuhr': Icons.light_mode,
      'asr': Icons.brightness_medium,
      'maghrib': Icons.wb_twilight,
      'isha': Icons.dark_mode,
    };

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.green,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _LocationHeader(
            label: location.label,
            date: appState.isArabic ? data.hijriAr : data.hijriEn,
          ),
          const SizedBox(height: 18),
          _NextPrayerCard(
            name: appState.tr(next.key),
            time: _format12(next.timeText),
            remaining: _countdown(remaining),
          ),
          const SizedBox(height: 18),
          GlassCard(
            ornament: false,
            child: Column(
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: _PrayerRow(
                      icon: icons[row.key]!,
                      name: appState.tr(row.key),
                      time: _format12(row.value),
                      highlighted: row.key == next.key,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.gold,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softGold,
                ),
              ),
            ),
          ],
        ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.cream.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.name,
    required this.time,
    required this.remaining,
  });

  final String name;
  final String time;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appState.tr('nextPrayer'),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Image.asset(
                      'assets/images/clock.png',
                      width: 112,
                      height: 112,
                      color: AppColors.gold,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.access_time_rounded,
                        size: 90,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: brandStyle(
                          name,
                          fontSize: 46,
                          color: AppColors.softGold,
                          shadows: [
                            Shadow(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      TimeText(time, fontSize: 24, color: AppColors.cream),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountdownText(
                          remaining,
                          fontSize: 40,
                          color: AppColors.gold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.tr('remaining'),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.cream.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.icon,
    required this.name,
    required this.time,
    required this.highlighted,
  });

  final IconData icon;
  final String name;
  final String time;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: highlighted
            ? AppColors.gold.withValues(alpha: 0.14)
            : Colors.transparent,
        border: Border.all(
          color: highlighted
              ? AppColors.gold.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: highlighted
                ? AppColors.gold
                : AppColors.softGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
          ),
          TimeText(
            time,
            fontSize: 19,
            color: highlighted ? AppColors.gold : AppColors.cream,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.onChange});

  final VoidCallback onRetry;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          ornament: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Text(
                appState.tr('ptError'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 18),
              GoldButton(label: appState.tr('retry'), onPressed: onRetry),
              TextButton(
                onPressed: onChange,
                child: Text(
                  appState.tr('changeLocation'),
                  style: const TextStyle(color: AppColors.softGold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
