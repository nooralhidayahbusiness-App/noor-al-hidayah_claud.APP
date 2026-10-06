import 'package:cloud_firestore/cloud_firestore.dart';

/// حالة الطلب
enum PremiumRequestStatus {
  pending,
  approved,
  rejected,
}

class PremiumRequest {
  final String uid;
  final String name;
  final String email;
  final String paypalAccount; // @username أو email
  final String plan; // 'monthly' | 'quarterly' | 'yearly'
  final double amount; // بالدولار
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
    return PremiumRequest(
      uid: uid,
      name: (m['name'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      paypalAccount: (m['paypalAccount'] as String?) ?? '',
      plan: (m['plan'] as String?) ?? 'monthly',
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      status: (m['status'] as String?) ?? 'pending',
      requestedAt:
          (m['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (m['reviewedAt'] as Timestamp?)?.toDate(),
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

/// خطط Premium
class PremiumPlan {
  final String id;
  final String labelAr;
  final String labelEn;
  final double price;
  final int days;
  final String? badge; // "الأكثر شهرة" أو "وفّر 25%"

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

/// قائمة الـ 15 ميزة
const List<Map<String, String>> premiumFeatures = [
  {'ar': '👑 تاج متحرك فوق اسمك', 'en': '👑 Animated crown above your name'},
  {'ar': '✨ دائرة ذهبية متحركة حول صورتك', 'en': '✨ Animated gold ring around your photo'},
  {'ar': '🏷️ شارات premium.png + true.me.png', 'en': '🏷️ premium.png + true.me.png badges'},
  {'ar': '🚫 بدون إعلانات', 'en': '🚫 No ads'},
  {'ar': '🎨 كل الألوان والخلفيات والثيمات مجانية', 'en': '🎨 All colors, backgrounds & themes free'},
  {'ar': '💰 10,000 نقطة شهرياً', 'en': '💰 10,000 points monthly'},
  {'ar': '📌 تثبيت 3 منشورات', 'en': '📌 Pin 3 posts'},
  {'ar': '✍️ اسم ذهبي متوهج', 'en': '✍️ Glowing gold name'},
  {'ar': '📝 منشورات أطول (1000 حرف)', 'en': '📝 Longer posts (1000 chars)'},
  {'ar': '🚀 أولوية في الـ Feed', 'en': '🚀 Priority in feed'},
  {'ar': '🎯 ضعف نقاط التحديات', 'en': '🎯 Double challenge points'},
  {'ar': '👁️ رؤية الحسابات الخاصة', 'en': '👁️ View private accounts'},
  {'ar': '📊 إحصاءات متقدمة', 'en': '📊 Advanced statistics'},
  {'ar': '🎁 هدية شهرية (مؤذن VIP)', 'en': '🎁 Monthly gift (VIP reciter)'},
  {'ar': '⭐ دعم مباشر للتطوير', 'en': '⭐ Direct support for development'},
];
