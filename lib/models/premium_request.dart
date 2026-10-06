import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PremiumRequestStatus {
  pending,
  approved,
  rejected,
}

class PremiumRequest {
  final String uid;
  final String name;
  final String email;
  final String paypalAccount;
  final String plan;
  final double amount;
  final String status;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  const PremiumRequest({
    required this.uid,
    required this.name,
    required this.email,
    required this.paypalAccount,
    required this.plan,
    required this.amount,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory PremiumRequest.fromMap(String uid, Map<String, dynamic> m) {
    DateTime? parseTs(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }

    return PremiumRequest(
      uid: uid,
      name: (m['name'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      paypalAccount: (m['paypalAccount'] as String?) ?? '',
      plan: (m['plan'] as String?) ?? 'monthly',
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      status: (m['status'] as String?) ?? 'pending',
      requestedAt: parseTs(m['requestedAt']) ?? DateTime.now(),
      reviewedAt: parseTs(m['reviewedAt']),
      reviewedBy: m['reviewedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'paypalAccount': paypalAccount,
      'plan': plan,
      'amount': amount,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'reviewedAt':
          reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  int get daysForPlan {
    switch (plan) {
      case 'monthly':
        return 30;
      case 'quarterly':
        return 90;
      case 'yearly':
        return 365;
      default:
        return 30;
    }
  }

  String get planLabel {
    switch (plan) {
      case 'monthly':
        return 'شهري';
      case 'quarterly':
        return '3 أشهر';
      case 'yearly':
        return 'سنوي';
      default:
        return plan;
    }
  }
}

// ============================================================
// Premium Plan
// ============================================================
class PremiumPlan {
  final String id;
  final String labelAr;
  final String labelEn;
  final double price;
  final int days;
  final String? badge;

  const PremiumPlan({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    required this.price,
    required this.days,
    this.badge,
  });
}

const List<PremiumPlan> premiumPlans = [
  PremiumPlan(
    id: 'monthly',
    labelAr: 'شهري',
    labelEn: 'Monthly',
    price: 5,
    days: 30,
  ),
  PremiumPlan(
    id: 'quarterly',
    labelAr: '3 أشهر',
    labelEn: '3 Months',
    price: 13,
    days: 90,
    badge: 'الأكثر شهرة',
  ),
  PremiumPlan(
    id: 'yearly',
    labelAr: 'سنوي',
    labelEn: 'Yearly',
    price: 45,
    days: 365,
    badge: 'وفّر 25%',
  ),
];

// ============================================================
// Premium Feature — مع دعم الصور والأيقونات
// ============================================================
class PremiumFeatureItem {
  final String textAr;
  final String textEn;
  final IconData icon;
  final List<String>? assetIcons;

  const PremiumFeatureItem({
    required this.textAr,
    required this.textEn,
    required this.icon,
    this.assetIcons,
  });
}

/// 15 ميزة Premium
const List<PremiumFeatureItem> premiumFeatures = [
  PremiumFeatureItem(
    icon: Icons.workspace_premium_rounded,
    textAr: 'تاج متحرك فوق اسمك',
    textEn: 'Animated crown above your name',
  ),
  PremiumFeatureItem(
    icon: Icons.auto_awesome_rounded,
    textAr: 'دائرة ذهبية متحركة حول صورتك',
    textEn: 'Animated gold ring around your photo',
  ),
  PremiumFeatureItem(
    icon: Icons.verified_rounded,
    assetIcons: [
      'assets/icons/premium.png',
      'assets/icons/true.me.png',
    ],
    textAr: 'شارات مميزة',
    textEn: 'Premium badges',
  ),
  PremiumFeatureItem(
    icon: Icons.block_rounded,
    textAr: 'بدون إعلانات',
    textEn: 'No ads',
  ),
  PremiumFeatureItem(
    icon: Icons.palette_rounded,
    textAr: 'كل الألوان والخلفيات والثيمات مجانية',
    textEn: 'All colors, backgrounds & themes free',
  ),
  PremiumFeatureItem(
    icon: Icons.stars_rounded,
    textAr: '10,000 نقطة شهرياً',
    textEn: '10,000 points monthly',
  ),
  PremiumFeatureItem(
    icon: Icons.push_pin_rounded,
    textAr: 'تثبيت 3 منشورات',
    textEn: 'Pin 3 posts',
  ),
  PremiumFeatureItem(
    icon: Icons.edit_rounded,
    textAr: 'اسم ذهبي متوهج',
    textEn: 'Glowing gold name',
  ),
  PremiumFeatureItem(
    icon: Icons.article_rounded,
    textAr: 'منشورات أطول (1000 حرف)',
    textEn: 'Longer posts (1000 chars)',
  ),
  PremiumFeatureItem(
    icon: Icons.trending_up_rounded,
    textAr: 'أولوية في الـ Feed',
    textEn: 'Priority in feed',
  ),
  PremiumFeatureItem(
    icon: Icons.track_changes_rounded,
    textAr: 'ضعف نقاط التحديات',
    textEn: 'Double challenge points',
  ),
  PremiumFeatureItem(
    icon: Icons.visibility_rounded,
    textAr: 'رؤية الحسابات الخاصة',
    textEn: 'View private accounts',
  ),
  PremiumFeatureItem(
    icon: Icons.bar_chart_rounded,
    textAr: 'إحصاءات متقدمة',
    textEn: 'Advanced statistics',
  ),
  PremiumFeatureItem(
    icon: Icons.card_giftcard_rounded,
    textAr: 'هدية شهرية (مؤذن VIP)',
    textEn: 'Monthly gift (VIP reciter)',
  ),
  PremiumFeatureItem(
    icon: Icons.favorite_rounded,
    textAr: 'دعم مباشر للتطوير',
    textEn: 'Direct support for development',
  ),
];
