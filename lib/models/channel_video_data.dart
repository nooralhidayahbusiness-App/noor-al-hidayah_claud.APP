class ChannelVideoData {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final String videoId;
  final int createdAt;
  final String addedBy;
  final bool isReel; // 9:16 ريلز / 16:9 فيديو عادي

  const ChannelVideoData({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.videoId,
    required this.createdAt,
    required this.addedBy,
    this.isReel = false,
  });

  factory ChannelVideoData.fromMap(String id, Map<String, dynamic> m) {
    return ChannelVideoData(
      id: id,
      title: (m['title'] as String?) ?? '',
      url: (m['url'] as String?) ?? '',
      thumbnailUrl: (m['thumbnailUrl'] as String?) ?? '',
      videoId: (m['videoId'] as String?) ?? '',
      createdAt: (m['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      addedBy: (m['addedBy'] as String?) ?? '',
      isReel: (m['isReel'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'videoId': videoId,
      'createdAt': createdAt,
      'addedBy': addedBy,
      'isReel': isReel,
    };
  }

  DateTime get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt);
}
