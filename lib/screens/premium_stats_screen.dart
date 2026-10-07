import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/premium_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _statsTr = {
  'ar': {
    'title': 'إحصائياتك',
    'membership': 'العضوية',
    'plan': 'الخطة',
    'expiresAt': 'تنتهي في',
    'daysLeft': 'باقي {n} يوم',
    'progress': 'التقدم',
    'points': 'النقاط',
    'level': 'المستوى',
    'streak': 'أيام متتالية',
    'challenges': 'تحديات مكتملة',
    'correctAnswers': 'إجابات صحيحة',
    'khatmas': 'ختمات القرآن',
    'aiScore': 'نقاط المعلم',
    'ads': 'الإعلانات',
    'adsToday': 'اليوم',
    'adsTotal': 'الإجمالي',
    'trialStatus': 'التجربة المجانية',
    'trialUsed': 'استُخدمت',
    'trialAvailable': 'متاحة',
    'noPremium': 'لست Premium حالياً',
    'noPremiumDesc': 'اشترك للاستفادة من كل الميزات',
    'member': 'عضو',
    'lifetime': 'مدى الحياة',
    'owner': 'المالك',
    'premium': 'Premium',
  },
  'en': {
    'title': 'Your Stats',
    'membership': 'Membership',
    'plan': 'Plan',
    'expiresAt': 'Expires on',
    'daysLeft': '{n} days left',
    'progress': 'Progress',
    'points': 'Points',
    'level': 'Level',
    'streak': 'Day streak',
    'challenges': 'Challenges Done',
    'correctAnswers': 'Correct Answers',
    'khatmas': 'Quran Khatmas',
    'aiScore': 'Teacher Score',
    'ads': 'Ads',
    'adsToday': 'Today',
    'adsTotal': 'Total',
    'trialStatus': 'Free Trial',
    'trialUsed': 'Used',
    'trialAvailable': 'Available',
    'noPremium': 'Not Premium',
    'noPremiumDesc': 'Subscribe to unlock all features',
    'member': 'Member',
    'lifetime': 'Lifetime',
    'owner': 'Owner',
    'premium': 'Premium',
  },
  'fr': {
    'title': 'Vos statistiques',
    'membership': 'Adhésion',
    'plan': 'Forfait',
    'expiresAt': 'Expire le',
    'daysLeft': '{n} jours restants',
    'progress': 'Progression',
    'points': 'Points',
    'level': 'Niveau',
    'streak': 'Jours consécutifs',
    'challenges': 'Défis terminés',
    'correctAnswers': 'Réponses correctes',
    'khatmas': 'Khatmas du Coran',
    'aiScore': 'Score du maître',
    'ads': 'Pubs',
    'adsToday': "Aujourd'hui",
    'adsTotal': 'Total',
    'trialStatus': 'Essai gratuit',
    'trialUsed': 'Utilisé',
    'trialAvailable': 'Disponible',
    'noPremium': 'Pas Premium',
    'noPremiumDesc': 'Abonnez-vous pour tout débloquer',
    'member': 'Membre',
    'lifetime': 'À vie',
    'owner': 'Propriétaire',
    'premium': 'Premium',
  },
  'ur': {
    'title': 'آپ کے اعداد و شمار',
    'membership': 'رکنیت',
    'plan': 'پلان',
    'expiresAt': 'ختم ہوگا',
    'daysLeft': '{n} دن باقی',
    'progress': 'پیشرفت',
    'points': 'پوائنٹس',
    'level': 'سطح',
    'streak': 'مسلسل دن',
    'challenges': 'مکمل چیلنجز',
    'correctAnswers': 'صحیح جوابات',
    'khatmas': 'قرآن ختم',
    'aiScore': 'استاد اسکور',
    'ads': 'اشتہارات',
    'adsToday': 'آج',
    'adsTotal': 'کل',
    'trialStatus': 'مفت آزمائش',
    'trialUsed': 'استعمال شدہ',
    'trialAvailable': 'دستیاب',
    'noPremium': 'پریمیم نہیں',
    'noPremiumDesc': 'سبسکرائب کریں',
    'member': 'ممبر',
    'lifetime': 'تاحیات',
    'owner': 'مالک',
    'premium': 'پریمیم',
  },
  'ne': {
    'title': 'तपाईंको तथ्याङ्क',
    'membership': 'सदस्यता',
    'plan': 'योजना',
    'expiresAt': 'समाप्त हुने',
    'daysLeft': '{n} दिन बाँकी',
    'progress': 'प्रगति',
    'points': 'अंक',
    'level': 'स्तर',
    'streak': 'लगातार दिन',
    'challenges': 'पूरा चुनौती',
    'correctAnswers': 'सही जवाफ',
    'khatmas': 'कुरान खत्म',
    'aiScore': 'शिक्षक स्कोर',
    'ads': 'विज्ञापन',
    'adsToday': 'आज',
    'adsTotal': 'कुल',
    'trialStatus': 'नि:शुल्क परीक्षण',
    'trialUsed': 'प्रयोग भयो',
    'trialAvailable': 'उपलब्ध',
    'noPremium': 'प्रिमियम होइन',
    'noPremiumDesc': 'सदस्यता लिनुहोस्',
    'member': 'सदस्य',
    'lifetime': 'आजीवन',
    'owner': 'मालिक',
    'premium': 'प्रिमियम',
  },
  'id': {
    'title': 'Statistik Anda',
    'membership': 'Keanggotaan',
    'plan': 'Paket',
    'expiresAt': 'Berakhir',
    'daysLeft': '{n} hari tersisa',
    'progress': 'Kemajuan',
    'points': 'Poin',
    'level': 'Level',
    'streak': 'Hari berturut',
    'challenges': 'Tantangan Selesai',
    'correctAnswers': 'Jawaban Benar',
    'khatmas': 'Khatam Quran',
    'aiScore': 'Skor Guru',
    'ads': 'Iklan',
    'adsToday': 'Hari ini',
    'adsTotal': 'Total',
    'trialStatus': 'Uji Coba Gratis',
    'trialUsed': 'Digunakan',
    'trialAvailable': 'Tersedia',
    'noPremium': 'Bukan Premium',
    'noPremiumDesc': 'Berlangganan untuk semua fitur',
    'member': 'Anggota',
    'lifetime': 'Seumur hidup',
    'owner': 'Pemilik',
    'premium': 'Premium',
  },
  'ms': {
    'title': 'Statistik Anda',
    'membership': 'Keahlian',
    'plan': 'Pelan',
    'expiresAt': 'Tamat',
    'daysLeft': '{n} hari berbaki',
    'progress': 'Kemajuan',
    'points': 'Mata',
    'level': 'Tahap',
    'streak': 'Hari berturut',
    'challenges': 'Cabaran Selesai',
    'correctAnswers': 'Jawapan Betul',
    'khatmas': 'Khatam Quran',
    'aiScore': 'Skor Guru',
    'ads': 'Iklan',
    'adsToday': 'Hari ini',
    'adsTotal': 'Jumlah',
    'trialStatus': 'Percubaan Percuma',
    'trialUsed': 'Digunakan',
    'trialAvailable': 'Tersedia',
    'noPremium': 'Bukan Premium',
    'noPremiumDesc': 'Langgan untuk semua ciri',
    'member': 'Ahli',
    'lifetime': 'Seumur hidup',
    'owner': 'Pemilik',
    'premium': 'Premium',
  },
};

String _st(String key) {
  final m = _statsTr[appState.languageCode] ?? _statsTr['ar']!;
  return m[key] ?? key;
}

class PremiumStatsScreen extends StatelessWidget {
  const PremiumStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.deepGreen,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Directionality(
      textDirection: appState.direction,
      child: Scaffold(
        body: ThemedBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        );
                      }
                      final data = snap.data!.data() ?? {};
                      return _buildContent(context, data);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _st('title'),
        style: TextStyle(
          color: AppColors.softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final profile = (data['profile'] as Map?) ?? {};
    final premium = (profile['premium'] as Map?) ?? {};
    final stats = (data['stats'] as Map?) ?? {};

    final email = (data['email'] as String?)?.toLowerCase() ?? '';
    final isOwner = _ownerEmails.contains(email);
    final isPremium = PremiumService.isUserPremium(
      profile.cast<String, dynamic>(),
    );

    final active = premium['active'] == true;
    final plan = (premium['plan'] as String?) ?? 'monthly';
    final expTs = premium['expiresAt'];
    DateTime? expiry;
    if (expTs is Timestamp) expiry = expTs.toDate();
    final daysLeft = PremiumService.daysRemaining(expiry);

    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        // بطاقة العضوية
        AnimatedEntry(
          child: _buildMembershipCard(
            context,
            isOwner: isOwner,
            isPremium: isPremium,
            active: active,
            plan: plan,
            expiry: expiry,
            daysLeft: daysLeft,
          ),
        ),
        SizedBox(height: R.s(context, 16)),

        // عنوان: التقدم
        AnimatedEntry(
          delay: const Duration(milliseconds: 100),
          child: Text(
            _st('progress'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: R.s(context, 10)),

        // شبكة الإحصائيات
        AnimatedEntry(
          delay: const Duration(milliseconds: 150),
          child: _buildStatsGrid(context, stats),
        ),
        SizedBox(height: R.s(context, 16)),

        // عنوان: الإعلانات
        AnimatedEntry(
          delay: const Duration(milliseconds: 200),
          child: Text(
            _st('ads'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: R.s(context, 10)),

        // بطاقة الإعلانات
        AnimatedEntry(
          delay: const Duration(milliseconds: 250),
          child: _buildAdsCard(context, stats),
        ),
      ],
    );
  }

  // ============================================================
  // بطاقة العضوية
  // ============================================================
  Widget _buildMembershipCard(
    BuildContext context, {
    required bool isOwner,
    required bool isPremium,
    required bool active,
    required String plan,
    DateTime? expiry,
    required int daysLeft,
  }) {
    final isVip = isOwner || isPremium;

    return Container(
      padding: EdgeInsets.all(R.s(context, 20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R.s(context, 24)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isVip
              ? [
                  AppColors.gold.withValues(alpha: 0.25),
                  AppColors.deepGreen.withValues(alpha: 0.9),
                ]
              : [
                  AppColors.cream.withValues(alpha: 0.08),
                  AppColors.deepGreen.withValues(alpha: 0.9),
                ],
        ),
        border: Border.all(
          color: isVip
              ? AppColors.gold.withValues(alpha: 0.6)
              : AppColors.cream.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: isVip
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.s(context, 12)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isVip
                      ? AppColors.gold.withValues(alpha: 0.2)
                      : AppColors.cream.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isVip ? AppColors.gold : AppColors.cream,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isOwner
                      ? Icons.workspace_premium_rounded
                      : (isPremium
                          ? Icons.star_rounded
                          : Icons.person_outline_rounded),
                  color: isVip ? AppColors.gold : AppColors.cream,
                  size: R.s(context, 28),
                ),
              ),
              SizedBox(width: R.s(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwner
                          ? _st('owner')
                          : (isPremium ? _st('premium') : _st('noPremium')),
                      style: TextStyle(
                        color: isVip ? AppColors.softGold : AppColors.cream,
                        fontSize: R.f(context, 18),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: R.s(context, 3)),
                    if (!isVip)
                      Text(
                        _st('noPremiumDesc'),
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.6),
                          fontSize: R.f(context, 11.5),
                        ),
                      ),
                    if (isVip && active)
                      Text(
                        '${_st('plan')}: $plan',
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.75),
                          fontSize: R.f(context, 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isVip && active && expiry != null) ...[
            SizedBox(height: R.s(context, 14)),
            Divider(
              height: 1,
              color: AppColors.gold.withValues(alpha: 0.2),
            ),
            SizedBox(height: R.s(context, 14)),
            Row(
              children: [
                Expanded(
                  child: _buildMiniInfo(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: _st('expiresAt'),
                    value:
                        '${expiry.day}/${expiry.month}/${expiry.year}',
                  ),
                ),
                Container(
                  width: 1,
                  height: R.s(context, 32),
                  color: AppColors.gold.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildMiniInfo(
                    context,
                    icon: Icons.hourglass_bottom_rounded,
                    label: _st('daysLeft').replaceAll('{n}', '$daysLeft'),
                    value: '$daysLeft',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: R.s(context, 18)),
        SizedBox(height: R.s(context, 4)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.softGold,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: R.s(context, 2)),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.6),
            fontSize: R.f(context, 10),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // شبكة الإحصائيات (2 أعمدة)
  // ============================================================
  Widget _buildStatsGrid(
    BuildContext context,
    Map<dynamic, dynamic> stats,
  ) {
    final points = (stats['points'] as num?)?.toInt() ?? 0;
    final level = (stats['level'] as num?)?.toInt() ?? 1;
    final streak = (stats['streak'] as num?)?.toInt() ?? 0;
    final challenges =
        (stats['challengesCompleted'] as num?)?.toInt() ?? 0;
    final correct =
        (stats['totalCorrectAnswers'] as num?)?.toInt() ?? 0;
    final khatmas = (stats['quranKhatmas'] as num?)?.toInt() ?? 0;
    final aiScore = (stats['aiTeacherScore'] as num?)?.toInt() ?? 0;

    final items = <_StatItem>[
      _StatItem(
        icon: Icons.stars_rounded,
        label: _st('points'),
        value: _formatNumber(points),
        color: AppColors.gold,
      ),
      _StatItem(
        icon: Icons.military_tech_rounded,
        label: _st('level'),
        value: '$level',
        color: const Color(0xFFFFA000),
      ),
      _StatItem(
        icon: Icons.local_fire_department_rounded,
        label: _st('streak'),
        value: '$streak',
        color: const Color(0xFFE84E6A),
      ),
      _StatItem(
        icon: Icons.emoji_events_rounded,
        label: _st('challenges'),
        value: '$challenges',
        color: AppColors.emerald,
      ),
      _StatItem(
        icon: Icons.check_circle_rounded,
        label: _st('correctAnswers'),
        value: '$correct',
        color: const Color(0xFF4CAF50),
      ),
      _StatItem(
        icon: Icons.menu_book_rounded,
        label: _st('khatmas'),
        value: '$khatmas',
        color: const Color(0xFF2196F3),
      ),
      _StatItem(
        icon: Icons.school_rounded,
        label: _st('aiScore'),
        value: '$aiScore',
        color: const Color(0xFF9C27B0),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: R.s(context, 10),
      mainAxisSpacing: R.s(context, 10),
      children: items
          .map((item) => _StatTile(item: item))
          .toList(),
    );
  }

  // ============================================================
  // بطاقة الإعلانات
  // ============================================================
  Widget _buildAdsCard(
    BuildContext context,
    Map<dynamic, dynamic> stats,
  ) {
    final adsToday = (stats['adsWatchedToday'] as num?)?.toInt() ?? 0;
    final adsTotal = (stats['totalAdsWatched'] as num?)?.toInt() ?? 0;
    final trialUsed = (stats['premiumTrialUsed'] as bool?) ?? false;

    return GlassCard(
      ornament: false,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAdsStat(
                  context,
                  icon: Icons.today_rounded,
                  label: _st('adsToday'),
                  value: '$adsToday',
                  color: AppColors.gold,
                ),
              ),
              Container(
                width: 1,
                height: R.s(context, 40),
                color: AppColors.gold.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildAdsStat(
                  context,
                  icon: Icons.all_inclusive_rounded,
                  label: _st('adsTotal'),
                  value: '$adsTotal',
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 14)),
          Divider(
            height: 1,
            color: AppColors.gold.withValues(alpha: 0.15),
          ),
          SizedBox(height: R.s(context, 12)),
          Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: trialUsed
                    ? AppColors.cream.withValues(alpha: 0.5)
                    : AppColors.gold,
                size: R.s(context, 18),
              ),
              SizedBox(width: R.s(context, 8)),
              Expanded(
                child: Text(
                  _st('trialStatus'),
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.75),
                    fontSize: R.f(context, 12),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 10),
                  vertical: R.s(context, 4),
                ),
                decoration: BoxDecoration(
                  color: trialUsed
                      ? AppColors.cream.withValues(alpha: 0.1)
                      : AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(R.s(context, 12)),
                  border: Border.all(
                    color: trialUsed
                        ? AppColors.cream.withValues(alpha: 0.3)
                        : AppColors.gold,
                  ),
                ),
                child: Text(
                  trialUsed ? _st('trialUsed') : _st('trialAvailable'),
                  style: TextStyle(
                    color: trialUsed
                        ? AppColors.cream.withValues(alpha: 0.6)
                        : AppColors.gold,
                    fontSize: R.f(context, 11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdsStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: R.s(context, 22)),
        SizedBox(height: R.s(context, 6)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: R.f(context, 20),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: R.s(context, 2)),
        Text(
          label,
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.65),
            fontSize: R.f(context, 11),
          ),
        ),
      ],
    );
  }

  static String _formatNumber(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) {
      final k = n / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    final m = n / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }

  static const Set<String> _ownerEmails = {
    'abdelrahmenbenromdhan11@gmail.com',
    'vevocom888@gmail.com',
    'nooralimanechannel@gmail.com',
    'nooralhidayahbusiness@gmail.com',
  };
}

// ============================================================
// _StatItem + _StatTile
// ============================================================
class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatTile extends StatelessWidget {
  final _StatItem item;

  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: R.s(context, 22)),
          SizedBox(height: R.s(context, 6)),
          Text(
            item.value,
            style: TextStyle(
              color: item.color,
              fontSize: R.f(context, 18),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: R.s(context, 2)),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.7),
              fontSize: R.f(context, 10.5),
            ),
          ),
        ],
      ),
    );
  }
}
