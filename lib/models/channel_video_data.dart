class ChannelVideoData {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final String videoId;
  final int createdAt;
  final String addedBy;

  const ChannelVideoData({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.videoId,
    required this.createdAt,
    required this.addedBy,
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
    };
  }

  DateTime get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt);
}
