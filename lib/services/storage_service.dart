import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_location.dart';

/// Keeps the chosen location on the device.
class StorageService {
  static const _lat = 'location_lat';
  static const _lng = 'location_lng';
  static const _address = 'location_address';
  static const _label = 'location_label';

  Future<SavedLocation?> loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final label = prefs.getString(_label);
    if (label == null) return null;
    return SavedLocation(
      label: label,
      latitude: prefs.getDouble(_lat),
      longitude: prefs.getDouble(_lng),
      address: prefs.getString(_address),
    );
  }

  Future<void> saveLocation(SavedLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_label, location.label);
    final lat = location.latitude;
    final lng = location.longitude;
    if (lat != null && lng != null) {
      await prefs.setDouble(_lat, lat);
      await prefs.setDouble(_lng, lng);
      await prefs.remove(_address);
    } else {
      await prefs.remove(_lat);
      await prefs.remove(_lng);
      await prefs.setString(_address, location.address ?? location.label);
    }
  }
}
