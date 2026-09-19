/// Where the user wants prayer times for: GPS coordinates or a typed address.
class SavedLocation {
  const SavedLocation({
    required this.label,
    this.latitude,
    this.longitude,
    this.address,
  });

  final String label;
  final double? latitude;
  final double? longitude;
  final String? address;

  bool get hasCoordinates => latitude != null && longitude != null;
}
