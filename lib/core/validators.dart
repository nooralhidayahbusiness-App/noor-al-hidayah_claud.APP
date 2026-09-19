import 'app_state.dart';

final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return appState.tr('errEmailEmpty');
  if (!_emailRegex.hasMatch(v)) return appState.tr('errEmailInvalid');
  return null;
}

/// For sign-up: at least 8 characters.
String? validateNewPassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return appState.tr('errPasswordEmpty');
  if (v.length < 8) return appState.tr('errPasswordShort');
  return null;
}

/// For login: just make sure it is not empty.
String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) return appState.tr('errPasswordEmpty');
  return null;
}
