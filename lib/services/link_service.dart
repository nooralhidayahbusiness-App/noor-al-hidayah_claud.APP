import 'package:url_launcher/url_launcher.dart';

/// Opens a link outside the app (YouTube app or the browser).
Future<bool> openExternalLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Channel link that asks YouTube to show the subscribe confirmation.
String subscribeUrl(String channelUrl) {
  final separator = channelUrl.contains('?') ? '&' : '?';
  return '$channelUrl${separator}sub_confirmation=1';
}
