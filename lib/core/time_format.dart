import 'app_state.dart';

/// "16:05" becomes "4:05 م" (or "4:05 PM" in English).
String formatTime12(String hhmm) {
  final parts = hhmm.split(':');
  final hour = int.parse(parts[0]);
  final arabic = appState.isArabic;
  final suffix = hour >= 12 ? (arabic ? 'م' : 'PM') : (arabic ? 'ص' : 'AM');
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour12:${parts[1]} $suffix';
}

/// A duration becomes "01:45:11".
String formatCountdown(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = (total ~/ 3600).toString().padLeft(2, '0');
  final m = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (total % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
