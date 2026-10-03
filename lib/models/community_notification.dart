import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityNotification {
  final String id;
  final String type; // 'follow' | 'like' | 'comment' | 'repost'
  final String fromUid;
  final String fromName;
  final String fromAvatar;
  final bool fromVerified;
  final String fromVerifiedType;
  final List<String> fromBadges;
  final String? targetId;
  final DateTime createdAt;
  final bool isRead;

  const CommunityNotification({
    required this.id,
    required this.type,
    required this.fromUid,
    required this.fromName,
    required this.fromAvatar,
    required this.fromVerified,
    this.fromVerifiedType = 'none',
    this.fromBadges = const [],
    this.targetId,
    required this.createdAt,
    required this.isRead,
  });

  factory CommunityNotification.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CommunityNotification(
      id: id,
      type: map['type'] ?? 'follow',
      fromUid: map['fromUid'] ?? '',
      fromName: map['fromName'] ?? '',
      fromAvatar: map['fromAvatar'] ?? 'man',
      fromVerified: map['fromVerified'] ?? false,
      fromVerifiedType: map['fromVerifiedType'] ?? 'none',
      fromBadges: List<String>.from(map['fromBadges'] ?? const []),
      targetId: map['targetId'],
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'fromUid': fromUid,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'fromVerified': fromVerified,
      'fromVerifiedType': fromVerifiedType,
      'fromBadges': fromBadges,
      'targetId': targetId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  List<String> get badges {
    if (fromBadges.isNotEmpty) {
      return fromBadges;
    }
    if (!fromVerified) {
      return const [];
    }
    if (fromVerifiedType == 'owner' ||
        fromVerifiedType == 'me' ||
        fromVerifiedType == 'user') {
      return [fromVerifiedType];
    }
    return const ['user'];
  }

  String get badgeType {
    if (!fromVerified) {
      return 'none';
    }
    if (fromVerifiedType == 'owner' ||
        fromVerifiedType == 'me' ||
        fromVerifiedType == 'user') {
      return fromVerifiedType;
    }
    return 'user';
  }
}
