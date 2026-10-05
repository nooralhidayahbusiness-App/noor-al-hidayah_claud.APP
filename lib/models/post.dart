import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String userName;
  final String userAvatar;
  final String userPhotoBase64;
  final bool userVerified;
  final String userVerifiedType;
  final List<String> userBadges;
  final String text;
  final DateTime createdAt;
  final DateTime? editedAt;

  final List<String> likes;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;

  final String? repostOf;
  final String? originalAuthorUid;
  final String? originalAuthorName;
  final String? originalAuthorAvatar;

  final bool isPinned;
  final bool isGlobalPin;
  final bool isDeleted;

  final List<String> mentions;
  final List<String> hashtags;

  Post({
    required this.id,
    required this.uid,
    required this.userName,
    required this.userAvatar,
    this.userPhotoBase64 = '',
    required this.userVerified,
    this.userVerifiedType = 'none',
    this.userBadges = const [],
    required this.text,
    required this.createdAt,
    this.editedAt,
    this.likes = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.repostOf,
    this.originalAuthorUid,
    this.originalAuthorName,
    this.originalAuthorAvatar,
    this.isPinned = false,
    this.isGlobalPin = false,
    this.isDeleted = false,
    this.mentions = const [],
    this.hashtags = const [],
  });

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? 'man',
      userPhotoBase64: map['userPhotoBase64'] ?? '',
      userVerified: map['userVerified'] ?? false,
      userVerifiedType: map['userVerifiedType'] ?? 'none',
      userBadges: List<String>.from(map['userBadges'] ?? const []),
      text: map['text'] ?? '',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
      likes: List<String>.from(map['likes'] ?? const []),
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      repostsCount: map['repostsCount'] ?? 0,
      repostOf: map['repostOf'],
      originalAuthorUid: map['originalAuthorUid'],
      originalAuthorName: map['originalAuthorName'],
      originalAuthorAvatar: map['originalAuthorAvatar'],
      isPinned: map['isPinned'] ?? false,
      isGlobalPin: map['isGlobalPin'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      mentions: List<String>.from(map['mentions'] ?? const []),
      hashtags: List<String>.from(map['hashtags'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'userPhotoBase64': userPhotoBase64,
      'userVerified': userVerified,
      'userVerifiedType': userVerifiedType,
      'userBadges': userBadges,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'likes': likes,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'repostOf': repostOf,
      'originalAuthorUid': originalAuthorUid,
      'originalAuthorName': originalAuthorName,
      'originalAuthorAvatar': originalAuthorAvatar,
      'isPinned': isPinned,
      'isGlobalPin': isGlobalPin,
      'isDeleted': isDeleted,
      'mentions': mentions,
      'hashtags': hashtags,
    };
  }

  Post copyWith({
    String? text,
    DateTime? editedAt,
    List<String>? likes,
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    bool? isPinned,
    bool? isGlobalPin,
    bool? isDeleted,
  }) {
    return Post(
      id: id,
      uid: uid,
      userName: userName,
      userAvatar: userAvatar,
      userPhotoBase64: userPhotoBase64,
      userVerified: userVerified,
      userVerifiedType: userVerifiedType,
      userBadges: userBadges,
      text: text ?? this.text,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      repostOf: repostOf,
      originalAuthorUid: originalAuthorUid,
      originalAuthorName: originalAuthorName,
      originalAuthorAvatar: originalAuthorAvatar,
      isPinned: isPinned ?? this.isPinned,
      isGlobalPin: isGlobalPin ?? this.isGlobalPin,
      isDeleted: isDeleted ?? this.isDeleted,
      mentions: mentions,
      hashtags: hashtags,
    );
  }

  bool isLikedBy(String uid) => likes.contains(uid);
  bool isOwner(String uid) => this.uid == uid;
  bool get isEdited => editedAt != null;
  bool get isRepost => repostOf != null;
  bool get hasPhoto => userPhotoBase64.isNotEmpty;

  List<String> get badges {
    if (userBadges.isNotEmpty) return userBadges;
    if (!userVerified) return const [];
    if (userVerifiedType == 'owner' ||
        userVerifiedType == 'me' ||
        userVerifiedType == 'user') {
      return [userVerifiedType];
    }
    return const ['user'];
  }

  String get badgeType {
    if (!userVerified) return 'none';
    if (userVerifiedType == 'owner' ||
        userVerifiedType == 'me' ||
        userVerifiedType == 'user') {
      return userVerifiedType;
    }
    return 'user';
  }

  static List<String> extractMentions(String text) {
    final regex = RegExp(r'@([A-Za-z0-9_\u0600-\u06FF]+)');
    return regex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toSet()
        .toList();
  }

  static List<String> extractHashtags(String text) {
    final regex = RegExp(r'#([A-Za-z0-9_\u0600-\u06FF]+)');
    return regex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toSet()
        .toList();
  }
}
