import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Coordinates {
  const Coordinates(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

enum LocationFailure { serviceDisabled, denied, deniedForever, unavailable }

class LocationException implements Exception {
  const LocationException(this.failure);
  final LocationFailure failure;
}

class LocationService {
  /// Asks for permission (if needed) and returns the current position.
  Future<Coordinates> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException(LocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.deniedForever);
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationException(LocationFailure.denied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return Coordinates(position.latitude, position.longitude);
    } catch (_) {
      throw const LocationException(LocationFailure.unavailable);
    }
  }

  /// Best-effort city name for the coordinates (null if unavailable).
  Future<String?> placeName(Coordinates c, {required bool arabic}) async {
    try {
      final uri = Uri.https(
        'api.bigdatacloud.net',
        '/data/reverse-geocode-client',
        {
          'latitude': '${c.latitude}',
          'longitude': '${c.longitude}',
          'localityLanguage': arabic ? 'ar' : 'en',
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final city = (json['city'] as String?)?.trim() ?? '';
      final locality = (json['locality'] as String?)?.trim() ?? '';
      final country = (json['countryName'] as String?)?.trim() ?? '';
      final place = city.isNotEmpty ? city : locality;
      final parts = [place, country].where((s) => s.isNotEmpty).toList();
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
