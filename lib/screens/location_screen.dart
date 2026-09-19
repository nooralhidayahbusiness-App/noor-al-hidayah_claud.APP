import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/navigation.dart';
import '../core/theme.dart';
import '../models/saved_location.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../widgets/auth_widgets.dart';
import 'prayer_times_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _manual = TextEditingController();
  final _locationService = LocationService();
  final _storage = StorageService();
  bool _loadingGps = false;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  String _errorKey(LocationFailure failure) => switch (failure) {
        LocationFailure.serviceDisabled => 'locErrService',
        LocationFailure.denied => 'locErrDenied',
        LocationFailure.deniedForever => 'locErrDeniedForever',
        LocationFailure.unavailable => 'locErrUnavailable',
      };

  void _openTimes() {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const PrayerTimesScreen()),
      (route) => false,
    );
  }

  Future<void> _useGps() async {
    setState(() => _loadingGps = true);
    try {
      final coords = await _locationService.current();
      final name = await _locationService.placeName(
        coords,
        arabic: appState.isArabic,
      );
      await _storage.saveLocation(
        SavedLocation(
          label: name ?? appState.tr('currentLocation'),
          latitude: coords.latitude,
          longitude: coords.longitude,
        ),
      );
      if (!mounted) return;
      _openTimes();
    } on LocationException catch (e) {
      if (!mounted) return;
      showAuthMessage(context, appState.tr(_errorKey(e.failure)), error: true);
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  Future<void> _useManual() async {
    final text = _manual.text.trim();
    if (text.length < 2) {
      showAuthMessage(context, appState.tr('locErrManualEmpty'), error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    await _storage.saveLocation(SavedLocation(label: text, address: text));
    if (!mounted) return;
    _openTimes();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return AuthScaffold(
          title: appState.tr('locTitle'),
          subtitle: appState.tr('locSub'),
          footer: Text(
            appState.tr('locPrivacy'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.cream.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.gold,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              GoldButton(
                label: appState.tr('locAllow'),
                loading: _loadingGps,
                onPressed: _useGps,
              ),
              const SizedBox(height: 18),
              _OrDivider(text: appState.tr('locOr')),
              const SizedBox(height: 18),
              GoldTextField(
                controller: _manual,
                label: appState.tr('locManualLabel'),
                icon: Icons.location_city_rounded,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _useManual(),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _useManual,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.softGold,
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(appState.tr('locManualButton')),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: AppColors.gold.withValues(alpha: 0.25)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(color: AppColors.cream.withValues(alpha: 0.6)),
          ),
        ),
        line,
      ],
    );
  }
}
