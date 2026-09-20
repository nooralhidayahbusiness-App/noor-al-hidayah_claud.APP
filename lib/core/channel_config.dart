/// YouTube channel settings. Edit this file to change the channel or videos.
const String kChannelName = 'Noor AlHidayah | نور الهداية';
const String kChannelHandle = '@NoorAlHidayahOFF';
const String kChannelUrl = 'https://www.youtube.com/@NoorAlHidayahOFF';

class ChannelVideo {
  const ChannelVideo({required this.title, required this.url});

  final String title;
  final String url;

  /// YouTube video id (used for the thumbnail).
  String? get videoId {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    final segments = uri.pathSegments;
    for (final marker in ['shorts', 'embed', 'live']) {
      final i = segments.indexOf(marker);
      if (i >= 0 && i + 1 < segments.length) return segments[i + 1];
    }
    return null;
  }

  String? get thumbnailUrl {
    final id = videoId;
    return id == null ? null : 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }
}

/// Videos shown in "قناتي" (newest first). Format of each video:
/// ChannelVideo(title: 'Title', url: 'https://youtu.be/VIDEO_ID'),
const List<ChannelVideo> kChannelVideos = [
  ChannelVideo(
    title: 'لماذا رفض إبليس السجود؟ قصة آدم التي لا تعرفها كاملة',
    url: 'https://youtu.be/mr5Q4n48gX0',
  ),
  ChannelVideo(
    title: 'قصة إدريس ونوح عليهما السلام | Prophets Enoch & Noah | English Subtitles',
    url: 'https://youtu.be/VUxB8kSz34o',
  ),
  ChannelVideo(
    title: 'هود عليه السلام الريح التي محت أعظم حضارة | Prophet Hud | English Subtitles',
    url: 'https://youtu.be/SEdhm6BglZw',
  ),
  ChannelVideo(
    title: 'صالح عليه السلام ناقة الله وقصة قوم ثمود | Prophet Salih English Subtitles',
    url: 'https://youtu.be/1D5H23gRp9Y',
  ),
  ChannelVideo(
    title: 'فيلم النور كل الأنبياء في فيلم واحد بطريقة سينمائية',
    url: 'https://youtu.be/AMplM1C4Iq8',
  ),
];
