import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    'plan': 'الخطة',
    'amount': 'المبلغ',
    'paypal': 'PayPal',
    'paymentMethod': 'طريقة الدفع',
    'paymentMethodDesc':
        '💳 يتم الدفع عبر PayPal (سهل وآمن). بعد الدفع، أكّد طلبك في التطبيق وسيتم التفعيل خلال 24 ساعة.',
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
    'plan': 'Plan',
    'amount': 'Amount',
    'paypal': 'PayPal',
    'paymentMethod': 'Payment Method',
    'paymentMethodDesc':
        '💳 Payment via PayPal (easy & secure). After paying, confirm your request in the app — activated within 24h.',
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
    'plan': 'Forfait',
    'amount': 'Montant',
    'paypal': 'PayPal',
    'paymentMethod': 'Mode de paiement',
    'paymentMethodDesc':
        '💳 Paiement via PayPal. Après paiement, confirmez — activation sous 24h.',
  },
  'ur': {
    'title': 'پریمیم',
    'hero': 'اپنا تجربہ بہتر بنائیں',
    'heroDesc': 'خصوصی خصوصیات',
    'features': 'خصوصیات',
    'plans': 'اپنا پلان منتخب کریں',
    'monthly': 'ماہانہ',
    'quarterly': '3 ماہ',
    'yearly': 'سالانہ',
    'subscribe': 'سبسکرائب کریں',
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
    'rejectedDesc': 'دوبارہ کوشش کریں',
    'tryAgain': 'دوبارہ کوشش',
    'daysLeft': '{n} دن باقی',
    'plan': 'پلان',
    'amount': 'رقم',
    'paypal': 'PayPal',
    'paymentMethod': 'ادائیگی کا طریقہ',
    'paymentMethodDesc': '💳 PayPal کے ذریعے ادائیگی۔',
  },
  'ne': {
    'title': 'प्रिमियम',
    'hero': 'आफ्नो अनुभव सुधार्नुहोस्',
    'heroDesc': 'विशेष सुविधाहरू',
    'features': 'सुविधाहरू',
    'plans': 'योजना छान्नुहोस्',
    'monthly': 'मासिक',
    'quarterly': '3 महिना',
    'yearly': 'वार्षिक',
    'subscribe': 'सदस्यता लिनुहोस्',
    'popular': 'लोकप्रिय',
    'save25': '25% बचत',
    'perMonth': '/महिना',
    'perQuarter': '/3 महिना',
    'perYear': '/वर्ष',
    'pending': 'अनुरोध लम्बित',
    'pendingDesc': '24 घण्टामा सक्रिय',
    'approved': 'तपाईं Premium 🎉',
    'approvedDesc': 'समाप्त हुने',
    'rejected': 'अनुरोध अस्वीकृत',
    'rejectedDesc': 'फेरि प्रयास',
    'tryAgain': 'फेरि प्रयास',
    'daysLeft': '{n} दिन बाँकी',
    'plan': 'योजना',
    'amount': 'रकम',
    'paypal': 'PayPal',
    'paymentMethod': 'भुक्तानी विधि',
    'paymentMethodDesc': '💳 PayPal मार्फत।',
  },
  'id': {
    'title': 'Premium',
    'hero': 'Tingkatkan Pengalaman Anda',
    'heroDesc': 'Fitur eksklusif + dukungan',
    'features': 'Fitur',
    'plans': 'Pilih Paket Anda',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'subscribe': 'Berlangganan',
    'popular': 'Terpopuler',
    'save25': 'Hemat 25%',
    'perMonth': '/bln',
    'perQuarter': '/3 bln',
    'perYear': '/thn',
    'pending': 'Permintaan tertunda',
    'pendingDesc': 'Aktif dalam 24 jam',
    'approved': 'Anda Premium 🎉',
    'approvedDesc': 'Berakhir',
    'rejected': 'Permintaan ditolak',
    'rejectedDesc': 'Coba lagi',
    'tryAgain': 'Coba Lagi',
    'daysLeft': '{n} hari tersisa',
    'plan': 'Paket',
    'amount': 'Jumlah',
    'paypal': 'PayPal',
    'paymentMethod': 'Metode Pembayaran',
    'paymentMethodDesc': '💳 Pembayaran via PayPal.',
  },
  'ms': {
    'title': 'Premium',
    'hero': 'Tingkatkan Pengalaman Anda',
    'heroDesc': 'Ciri eksklusif',
    'features': 'Ciri-ciri',
    'plans': 'Pilih Pelan Anda',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'subscribe': 'Langgan',
    'popular': 'Popular',
    'save25': 'Jimat 25%',
    'perMonth': '/bln',
    'perQuarter': '/3 bln',
    'perYear': '/thn',
    'pending': 'Permintaan tertunda',
    'pendingDesc': 'Aktif dalam 24 jam',
    'approved': 'Anda Premium 🎉',
    'approvedDesc': 'Tamat',
    'rejected': 'Permintaan ditolak',
    'rejectedDesc': 'Cuba lagi',
    'tryAgain': 'Cuba Lagi',
    'daysLeft': '{n} hari berbaki',
    'plan': 'Pelan',
    'amount': 'Jumlah',
    'paypal': 'PayPal',
    'paymentMethod': 'Kaedah Pembayaran',
    'paymentMethodDesc': '💳 Pembayaran melalui PayPal.',
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
                          if (req != null && req.isPending) {
                            return _buildPending(context, req);
                          }
                          if (req != null && req.isRejected) {
                            return _buildRejected(context, req);
                          }
                          if (req != null && req.isApproved) {
                            return _buildApproved(context, req);
                          }
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

  Widget _buildMain(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        AnimatedEntry(child: _buildHero(context)),
        SizedBox(height: R.s(context, 20)),
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
          child: _buildFeaturesList(context),
        ),
        SizedBox(height: R.s(context, 20)),
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
                    onTap: () => setState(() => _selectedPlanId = plan.id),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: R.s(context, 14)),
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
              icon: Icon(Icons.workspace_premium_rounded,
                  size: R.s(context, 22)),
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
        AnimatedEntry(
          delay: const Duration(milliseconds: 350),
          child: _buildPaymentInfo(context),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
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
            child: Icon(Icons.workspace_premium_rounded,
                color: AppColors.gold, size: R.s(context, 42)),
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
    );
  }

  // ============================================================
  // ✅ الميزات مع الصور الفعلية
  // ============================================================
  Widget _buildFeaturesList(BuildContext context) {
    return GlassCard(
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
            _buildFeatureRow(context, premiumFeatures[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, PremiumFeatureItem feature) {
    return Row(
      children: [
        SizedBox(
          width: R.s(context, 26),
          height: R.s(context, 22),
          child: feature.assetIcons != null
              // ✅ عرض الصور
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < feature.assetIcons!.length; i++) ...[
                      if (i > 0) SizedBox(width: R.s(context, 2)),
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          AppColors.gold,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          feature.assetIcons![i],
                          width: R.s(context, 18),
                          height: R.s(context, 18),
                          errorBuilder: (_, _, _) => Icon(
                            feature.icon,
                            color: AppColors.gold,
                            size: R.s(context, 18),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              // ✅ عرض الأيقونة
              : Icon(
                  feature.icon,
                  color: AppColors.gold,
                  size: R.s(context, 18),
                ),
        ),
        SizedBox(width: R.s(context, 10)),
        Expanded(
          child: Text(
            appState.isArabic ? feature.textAr : feature.textEn,
            style: TextStyle(
              color: AppColors.cream,
              fontSize: R.f(context, 13),
              height: 1.5,
            ),
          ),
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
              Icon(Icons.info_outline_rounded,
                  color: AppColors.gold, size: R.s(context, 18)),
              SizedBox(width: R.s(context, 8)),
              Text(
                _pr('paymentMethod'),
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
            _pr('paymentMethodDesc'),
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
  // الحالة 2: pending
  // ============================================================
  Widget _buildPending(BuildContext context, PremiumRequest req) {
    return Center(
      child: SingleChildScrollView(
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
              child: Icon(Icons.hourglass_top_rounded,
                  color: AppColors.gold, size: R.s(context, 48)),
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
                  _rowInfo(context, _pr('plan'),
                      appState.isArabic ? req.planLabel : req.plan),
                  SizedBox(height: R.s(context, 6)),
                  _rowInfo(context, _pr('amount'),
                      '\$${req.amount.toInt()}'),
                  SizedBox(height: R.s(context, 6)),
                  _rowInfo(context, _pr('paypal'), req.paypalAccount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الحالة 3: rejected
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
              child: Icon(Icons.cancel_outlined,
                  color: Colors.redAccent, size: R.s(context, 48)),
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
  // الحالة 4: approved
  // ============================================================
  Widget _buildApproved(BuildContext context, PremiumRequest req) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(req.uid)
          .snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        final profile = (data['profile'] as Map?) ?? {};
        final premium = (profile['premium'] as Map?) ?? {};

        final expTs = premium['expiresAt'];
        DateTime? expiry;
        if (expTs is Timestamp) {
          expiry = expTs.toDate();
        }

        final daysLeft = PremiumService.daysRemaining(expiry);

        return Center(
          child: SingleChildScrollView(
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
                  child: Icon(Icons.workspace_premium_rounded,
                      color: AppColors.gold, size: R.s(context, 54)),
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
                  SizedBox(height: R.s(context, 10)),
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
                      _pr('daysLeft').replaceAll('{n}', '$daysLeft'),
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
                      _rowInfo(context, _pr('plan'),
                          appState.isArabic ? req.planLabel : req.plan),
                      SizedBox(height: R.s(context, 6)),
                      _rowInfo(context, _pr('amount'),
                          '\$${req.amount.toInt()}'),
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
