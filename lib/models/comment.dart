import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String uid;
  final String userName;
  final String userAvatar;
  final bool userVerified;
  final String userVerifiedType;
  final List<String> userBadges;
  final String text;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<String> likes;
  final int likesCount;
  final bool isDeleted;

  Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.userName,
    required this.userAvatar,
    required this.userVerified,
    this.userVerifiedType = 'none',
    this.userBadges = const [],
    required this.text,
    required this.createdAt,
    this.editedAt,
    this.likes = const [],
    this.likesCount = 0,
    this.isDeleted = false,
  });

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      userVerified: map['userVerified'] ?? false,
      userVerifiedType: map['userVerifiedType'] ?? 'none',
      userBadges: List<String>.from(map['userBadges'] ?? const []),
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
      likes: List<String>.from(map['likes'] ?? const []),
      likesCount: map['likesCount'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'userVerified': userVerified,
      'userVerifiedType': userVerifiedType,
      'userBadges': userBadges,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'likes': likes,
      'likesCount': likesCount,
      'isDeleted': isDeleted,
    };
  }

  Comment copyWith({
    String? text,
    DateTime? editedAt,
    List<String>? likes,
    int? likesCount,
    bool? isDeleted,
  }) {
    return Comment(
      id: id,
      postId: postId,
      uid: uid,
      userName: userName,
      userAvatar: userAvatar,
      userVerified: userVerified,
      userVerifiedType: userVerifiedType,
      userBadges: userBadges,
      text: text ?? this.text,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool isLikedBy(String uid) => likes.contains(uid);
  bool isOwner(String uid) => this.uid == uid;
  bool get isEdited => editedAt != null;

  List<String> get badges {
    if (userBadges.isNotEmpty) {
      return userBadges;
    }
    if (!userVerified) {
      return const [];
    }
    if (userVerifiedType == 'owner' ||
        userVerifiedType == 'me' ||
        userVerifiedType == 'user') {
      return [userVerifiedType];
    }
    return const ['user'];
  }

  String get badgeType {
    if (!userVerified) {
      return 'none';
    }
    if (userVerifiedType == 'owner' ||
        userVerifiedType == 'me' ||
        userVerifiedType == 'user') {
      return userVerifiedType;
    }
    return 'user';
  }
}
