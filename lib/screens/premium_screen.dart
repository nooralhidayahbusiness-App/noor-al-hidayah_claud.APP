import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/premium_request.dart';
import '../services/premium_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';
import 'premium_checkout_screen.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _premTr = {
  'ar': {
    'title': 'بريميوم',
    'hero': 'ارتقِ بتجربتك',
    'heroDesc': 'ميزات حصرية + دعم مباشر للتطوير',
    'features': 'الميزات',
    'plans': 'اختر خطتك',
    'monthly': 'شهري',
    'quarterly': '3 أشهر',
    'yearly': 'سنوي',
    'subscribe': 'اشترك الآن',
    'popular': 'الأكثر شهرة',
    'save25': 'وفّر 25%',
    'perMonth': '/شهر',
    'perQuarter': '/3 أشهر',
    'perYear': '/سنة',
    'pending': 'طلبك قيد المراجعة',
    'pendingDesc': 'سيتم التفعيل خلال 24 ساعة',
    'approved': 'أنت Premium 🎉',
    'approvedDesc': 'ينتهي في',
    'rejected': 'تم رفض الطلب',
    'rejectedDesc': 'يمكنك المحاولة مجدداً',
    'tryAgain': 'حاول مجدداً',
    'daysLeft': 'باقي {n} يوم',
    'trial': 'تجربة مجانية',
    'trialDesc': 'شاهد 10 إعلانات لتفعيل 3 أيام مجاناً',
  },
  'en': {
    'title': 'Premium',
    'hero': 'Upgrade Your Experience',
    'heroDesc': 'Exclusive features + direct support',
    'features': 'Features',
    'plans': 'Choose Your Plan',
    'monthly': 'Monthly',
    'quarterly': '3 Months',
    'yearly': 'Yearly',
    'subscribe': 'Subscribe Now',
    'popular': 'Most Popular',
    'save25': 'Save 25%',
    'perMonth': '/month',
    'perQuarter': '/quarter',
    'perYear': '/year',
    'pending': 'Your request is pending',
    'pendingDesc': 'Will be activated within 24h',
    'approved': 'You are Premium 🎉',
    'approvedDesc': 'Expires on',
    'rejected': 'Request rejected',
    'rejectedDesc': 'You can try again',
    'tryAgain': 'Try Again',
    'daysLeft': '{n} days left',
    'trial': 'Free Trial',
    'trialDesc': 'Watch 10 ads to unlock 3 days free',
  },
  'fr': {
    'title': 'Premium',
    'hero': 'Améliorez votre expérience',
    'heroDesc': 'Fonctionnalités exclusives',
    'features': 'Fonctionnalités',
    'plans': 'Choisissez votre forfait',
    'monthly': 'Mensuel',
    'quarterly': '3 mois',
    'yearly': 'Annuel',
    'subscribe': "S'abonner",
    'popular': 'Populaire',
    'save25': '25% de réduction',
    'perMonth': '/mois',
    'perQuarter': '/3 mois',
    'perYear': '/an',
    'pending': 'Demande en cours',
    'pendingDesc': 'Activé sous 24h',
    'approved': 'Vous êtes Premium 🎉',
    'approvedDesc': 'Expire le',
    'rejected': 'Demande refusée',
    'rejectedDesc': 'Vous pouvez réessayer',
    'tryAgain': 'Réessayer',
    'daysLeft': '{n} jours restants',
    'trial': 'Essai gratuit',
    'trialDesc': '10 pubs = 3 jours gratuits',
  },
  'ur': {
    'title': 'پریمیم',
    'hero': 'اپنا تجربہ بہتر بنائیں',
    'heroDesc': 'خصوصی خصوصیات + براہ راست تعاون',
    'features': 'خصوصیات',
    'plans': 'اپنا پلان منتخب کریں',
    'monthly': 'ماہانہ',
    'quarterly': '3 ماہ',
    'yearly': 'سالانہ',
    'subscribe': 'ابھی سبسکرائب کریں',
    'popular': 'مقبول ترین',
    'save25': '25% بچائیں',
    'perMonth': '/ماہ',
    'perQuarter': '/3 ماہ',
    'perYear': '/سال',
    'pending': 'آپ کی درخواست زیر التواء',
    'pendingDesc': '24 گھنٹوں میں فعال',
    'approved': 'آپ پریمیم ہیں 🎉',
    'approvedDesc': 'ختم ہوگا',
    'rejected': 'درخواست مسترد',
    'rejectedDesc': 'آپ دوبارہ کوشش کر سکتے ہیں',
    'tryAgain': 'دوبارہ کوشش',
    'daysLeft': '{n} دن باقی',
    'trial': 'مفت ٹرائل',
    'trialDesc': '10 اشتہار = 3 دن مفت',
  },
  'ne': {
    'title': 'प्रिमियम',
    'hero': 'आफ्नो अनुभव सुधार्नुहोस्',
    'heroDesc': 'विशेष सुविधाहरू',
    'features': 'सुविधाहरू',
    'plans': 'आफ्नो योजना छान्नुहोस्',
    'monthly': 'मासिक',
    'quarterly': '3 महिना',
    'yearly': 'वार्षिक',
    'subscribe': 'अहिले सदस्यता लिनुहोस्',
    'popular': 'लोकप्रिय',
    'save25': '25% बचत',
    'perMonth': '/महिना',
    'perQuarter': '/3 महिना',
    'perYear': '/वर्ष',
    'pending': 'तपाईंको अनुरोध लम्बित',
    'pendingDesc': '24 घण्टामा सक्रिय',
    'approved': 'तपाईं Premium हुनुहुन्छ 🎉',
    'approvedDesc': 'समाप्त हुने मिति',
    'rejected': 'अनुरोध अस्वीकृत',
    'rejectedDesc': 'फेरि प्रयास गर्नुहोस्',
    'tryAgain': 'फेरि प्रयास',
    'daysLeft': '{n} दिन बाँकी',
    'trial': 'नि:शुल्क परीक्षण',
    'trialDesc': '10 विज्ञापन = 3 दिन नि:शुल्क',
  },
  'id': {
    'title': 'Premium',
    'hero': 'Tingkatkan Pengalaman Anda',
    'heroDesc': 'Fitur eksklusif + dukungan langsung',
    'features': 'Fitur',
    'plans': 'Pilih Paket Anda',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'subscribe': 'Berlangganan Sekarang',
    'popular': 'Terpopuler',
    'save25': 'Hemat 25%',
    'perMonth': '/bulan',
    'perQuarter': '/3 bulan',
    'perYear': '/tahun',
    'pending': 'Permintaan Anda tertunda',
    'pendingDesc': 'Diaktifkan dalam 24 jam',
    'approved': 'Anda Premium 🎉',
    'approvedDesc': 'Berakhir pada',
    'rejected': 'Permintaan ditolak',
    'rejectedDesc': 'Anda bisa mencoba lagi',
    'tryAgain': 'Coba Lagi',
    'daysLeft': '{n} hari tersisa',
    'trial': 'Uji Coba Gratis',
    'trialDesc': '10 iklan = 3 hari gratis',
  },
  'ms': {
    'title': 'Premium',
    'hero': 'Tingkatkan Pengalaman Anda',
    'heroDesc': 'Ciri eksklusif + sokongan',
    'features': 'Ciri-ciri',
    'plans': 'Pilih Pelan Anda',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'subscribe': 'Langgan Sekarang',
    'popular': 'Paling Popular',
    'save25': 'Jimat 25%',
    'perMonth': '/bulan',
    'perQuarter': '/3 bulan',
    'perYear': '/tahun',
    'pending': 'Permintaan anda tertunda',
    'pendingDesc': 'Diaktifkan dalam 24 jam',
    'approved': 'Anda Premium 🎉',
    'approvedDesc': 'Tamat pada',
    'rejected': 'Permintaan ditolak',
    'rejectedDesc': 'Anda boleh cuba lagi',
    'tryAgain': 'Cuba Lagi',
    'daysLeft': '{n} hari berbaki',
    'trial': 'Percubaan Percuma',
    'trialDesc': '10 iklan = 3 hari percuma',
  },
};

String _pr(String key) {
  final m = _premTr[appState.languageCode] ?? _premTr['ar']!;
  return m[key] ?? key;
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlanId = 'quarterly';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: Scaffold(
            body: ThemedBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: StreamBuilder<PremiumRequest?>(
                        stream: premiumService.myRequestStream(),
                        builder: (context, snap) {
                          final req = snap.data;

                          // ===== الحالات =====
                          if (req != null && req.isPending) {
                            return _buildPending(context, req);
                          }
                          if (req != null && req.isRejected) {
                            return _buildRejected(context, req);
                          }
                          if (req != null && req.isApproved) {
                            return _buildApproved(context, req);
                          }

                          // ===== العرض الرئيسي =====
                          return _buildMain(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _pr('title'),
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

  // ============================================================
  // الحالة 1: العرض الرئيسي
  // ============================================================
  Widget _buildMain(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        // ===== Hero =====
        AnimatedEntry(
          child: Container(
            padding: EdgeInsets.all(R.s(context, 20)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R.s(context, 24)),
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.2),
                  AppColors.deepGreen.withValues(alpha: 0.9),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(R.s(context, 16)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: R.s(context, 42),
                  ),
                ),
                SizedBox(height: R.s(context, 14)),
                Text(
                  _pr('hero'),
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: R.s(context, 6)),
                Text(
                  _pr('heroDesc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.75),
                    fontSize: R.f(context, 13),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: R.s(context, 20)),

        // ===== الميزات =====
        AnimatedEntry(
          delay: const Duration(milliseconds: 100),
          child: Text(
            _pr('features'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: R.s(context, 10)),
        AnimatedEntry(
          delay: const Duration(milliseconds: 150),
          child: GlassCard(
            ornament: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < premiumFeatures.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: R.s(context, 16),
                      color: AppColors.gold.withValues(alpha: 0.15),
                    ),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.gold,
                        size: R.s(context, 18),
                      ),
                      SizedBox(width: R.s(context, 10)),
                      Expanded(
                        child: Text(
                          appState.isArabic
                              ? premiumFeatures[i]['ar']!
                              : premiumFeatures[i]['en']!,
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: R.f(context, 13),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: R.s(context, 20)),

        // ===== الخطط =====
        AnimatedEntry(
          delay: const Duration(milliseconds: 200),
          child: Text(
            _pr('plans'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: R.s(context, 10)),
        AnimatedEntry(
          delay: const Duration(milliseconds: 250),
          child: Column(
            children: [
              for (final plan in premiumPlans)
                Padding(
                  padding: EdgeInsets.only(bottom: R.s(context, 10)),
                  child: _PlanCard(
                    plan: plan,
                    selected: _selectedPlanId == plan.id,
                    onTap: () =>
                        setState(() => _selectedPlanId = plan.id),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: R.s(context, 14)),

        // ===== زر الاشتراك =====
        AnimatedEntry(
          delay: const Duration(milliseconds: 300),
          child: SizedBox(
            height: R.s(context, 54),
            child: ElevatedButton.icon(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.deepGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.s(context, 18)),
                ),
                elevation: 6,
              ),
              icon: Icon(
                Icons.workspace_premium_rounded,
                size: R.s(context, 22),
              ),
              label: Text(
                _pr('subscribe'),
                style: TextStyle(
                  fontSize: R.f(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: R.s(context, 20)),

        // ===== معلومات الدفع =====
        AnimatedEntry(
          delay: const Duration(milliseconds: 350),
          child: _buildPaymentInfo(context),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.gold,
                size: R.s(context, 18),
              ),
              SizedBox(width: R.s(context, 8)),
              Text(
                appState.isArabic
                    ? 'طريقة الدفع'
                    : 'Payment Method',
                style: TextStyle(
                  color: AppColors.softGold,
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 8)),
          Text(
            appState.isArabic
                ? '💳 يتم الدفع عبر PayPal (سهل وآمن). بعد الدفع، أكّد طلبك في التطبيق وسيتم التفعيل خلال 24 ساعة.'
                : '💳 Payment via PayPal (easy & secure). After paying, confirm your request in the app — activated within 24h.',
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.75),
              fontSize: R.f(context, 12),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // الحالة 2: قيد المراجعة
  // ============================================================
  Widget _buildPending(BuildContext context, PremiumRequest req) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.s(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(R.s(context, 24)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.gold,
                size: R.s(context, 48),
              ),
            ),
            SizedBox(height: R.s(context, 20)),
            Text(
              _pr('pending'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.softGold,
                fontSize: R.f(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.s(context, 10)),
            Text(
              _pr('pendingDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.7),
                fontSize: R.f(context, 13),
              ),
            ),
            SizedBox(height: R.s(context, 20)),
            GlassCard(
              ornament: false,
              child: Column(
                children: [
                  _rowInfo(context, 'الخطة',
                      appState.isArabic ? req.planLabel : req.plan),
                  SizedBox(height: R.s(context, 6)),
                  _rowInfo(context, 'المبلغ', '\$${req.amount.toInt()}'),
                  SizedBox(height: R.s(context, 6)),
                  _rowInfo(context, 'PayPal', req.paypalAccount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الحالة 3: مرفوض
  // ============================================================
  Widget _buildRejected(BuildContext context, PremiumRequest req) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.s(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(R.s(context, 24)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withValues(alpha: 0.15),
                border: Border.all(color: Colors.redAccent, width: 2),
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.redAccent,
                size: R.s(context, 48),
              ),
            ),
            SizedBox(height: R.s(context, 20)),
            Text(
              _pr('rejected'),
              style: TextStyle(
                color: AppColors.softGold,
                fontSize: R.f(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.s(context, 10)),
            Text(
              _pr('rejectedDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.7),
                fontSize: R.f(context, 13),
              ),
            ),
            SizedBox(height: R.s(context, 24)),
            SizedBox(
              height: R.s(context, 50),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await premiumService.deleteMyRequest();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deepGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.s(context, 18)),
                  ),
                ),
                icon: Icon(Icons.refresh_rounded, size: R.s(context, 20)),
                label: Text(
                  _pr('tryAgain'),
                  style: TextStyle(
                    fontSize: R.f(context, 15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الحالة 4: Premium نشط
  // ============================================================
  Widget _buildApproved(BuildContext context, PremiumRequest req) {
    final uid = req.uid;

    return StreamBuilder(
      stream: _userPremiumStream(uid),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        final profile = (data['profile'] as Map?) ?? {};
        final premium = (profile['premium'] as Map?) ?? {};
        final active = (premium['active'] as bool?) ?? false;
        final expTs = premium['expiresAt'];
        DateTime? expiry;
        if (expTs is dynamic) {
          try {
            expiry = expTs.toDate();
          } catch (_) {}
        }

        final isValid = premiumService.constructorHelperActive(active, expiry);
        final daysLeft = premiumService.constructorHelperDays(expiry);

        return Center(
          child: Padding(
            padding: EdgeInsets.all(R.s(context, 24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(R.s(context, 24)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: R.s(context, 54),
                  ),
                ),
                SizedBox(height: R.s(context, 20)),
                Text(
                  _pr('approved'),
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expiry != null) ...[
                  SizedBox(height: R.s(context, 10)),
                  Text(
                    '${_pr('approvedDesc')} ${expiry.day}/${expiry.month}/${expiry.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.75),
                      fontSize: R.f(context, 13),
                    ),
                  ),
                  SizedBox(height: R.s(context, 6)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 14),
                      vertical: R.s(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(R.s(context, 20)),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _pr('daysLeft').replaceAll('$daysLeft', '$daysLeft'),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: R.s(context, 20)),
                GlassCard(
                  ornament: false,
                  child: Column(
                    children: [
                      _rowInfo(context, 'الخطة',
                          appState.isArabic ? req.planLabel : req.plan),
                      SizedBox(height: R.s(context, 6)),
                      _rowInfo(context, 'المبلغ', '\$${req.amount.toInt()}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream _userPremiumStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  Widget _rowInfo(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.7),
            fontSize: R.f(context, 12),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.softGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCheckout() async {
    final plan = premiumPlans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => premiumPlans[0],
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PremiumCheckoutScreen(plan: plan),
      ),
    );
  }
}

// ============================================================
// _PlanCard
// ============================================================
class _PlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(R.s(context, 16)),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(R.s(context, 18)),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: R.s(context, 22),
              height: R.s(context, 22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.gold
                      : AppColors.cream.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: R.s(context, 12),
                        height: R.s(context, 12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: R.s(context, 14)),

            // Label + badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        appState.isArabic ? plan.labelAr : plan.labelEn,
                        style: TextStyle(
                          color: selected
                              ? AppColors.softGold
                              : AppColors.cream,
                          fontSize: R.f(context, 15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (plan.badge != null) ...[
                        SizedBox(width: R.s(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: R.s(context, 8),
                            vertical: R.s(context, 3),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(
                                R.s(context, 10)),
                          ),
                          child: Text(
                            plan.badge!,
                            style: TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: R.f(context, 9.5),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: R.s(context, 4)),
                  Text(
                    '${plan.days} ${appState.isArabic ? 'يوم' : 'days'}',
                    style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.6),
                      fontSize: R.f(context, 11.5),
                    ),
                  ),
                ],
              ),
            ),

            // السعر
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${plan.price.toInt()}',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: R.f(context, 22),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  plan.id == 'monthly'
                      ? _pr('perMonth')
                      : plan.id == 'quarterly'
                          ? _pr('perQuarter')
                          : _pr('perYear'),
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.5),
                    fontSize: R.f(context, 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to access PremiumService static methods
extension _PremiumServiceHelpers on PremiumService {
  bool constructorHelperActive(bool active, DateTime? expiry) =>
      PremiumService.isActive(premiumActive: active, expiresAt: expiry);

  int constructorHelperDays(DateTime? expiry) =>
      PremiumService.daysRemaining(expiry);
}
