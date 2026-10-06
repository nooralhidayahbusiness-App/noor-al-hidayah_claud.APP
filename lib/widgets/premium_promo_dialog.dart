import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/premium_request.dart';
import '../screens/premium_screen.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _promoTr = {
  'ar': {
    'badge': 'ميزة جديدة',
    'title': 'جرّب Premium',
    'subtitle': 'ارتقِ بتجربة تطبيقك',
    'features': 'ميزات مختارة',
    'plans': 'خطط الأسعار',
    'subscribe': 'اشترك الآن',
    'stayFree': 'سأبقى في المجاني',
    'monthly': 'شهري',
    'quarterly': '3 أشهر',
    'yearly': 'سنوي',
    'popular': 'الأكثر شهرة',
    'save25': 'وفّر 25%',
    'perMonth': '/شهر',
    'perQuarter': '/3 أشهر',
    'perYear': '/سنة',
  },
  'en': {
    'badge': 'New Feature',
    'title': 'Try Premium',
    'subtitle': 'Upgrade your experience',
    'features': 'Selected Features',
    'plans': 'Pricing Plans',
    'subscribe': 'Subscribe Now',
    'stayFree': 'Stay on Free',
    'monthly': 'Monthly',
    'quarterly': '3 Months',
    'yearly': 'Yearly',
    'popular': 'Most Popular',
    'save25': 'Save 25%',
    'perMonth': '/mo',
    'perQuarter': '/quarter',
    'perYear': '/year',
  },
  'fr': {
    'badge': 'Nouveauté',
    'title': 'Essayez Premium',
    'subtitle': 'Améliorez votre expérience',
    'features': 'Fonctionnalités',
    'plans': 'Forfaits',
    'subscribe': "S'abonner",
    'stayFree': 'Rester gratuit',
    'monthly': 'Mensuel',
    'quarterly': '3 mois',
    'yearly': 'Annuel',
    'popular': 'Populaire',
    'save25': '25% de réduction',
    'perMonth': '/mois',
    'perQuarter': '/3 mois',
    'perYear': '/an',
  },
  'ur': {
    'badge': 'نئی خصوصیت',
    'title': 'Premium آزمائیں',
    'subtitle': 'اپنا تجربہ بہتر بنائیں',
    'features': 'منتخب خصوصیات',
    'plans': 'قیمتوں کے پلان',
    'subscribe': 'سبسکرائب کریں',
    'stayFree': 'مفت میں رہیں',
    'monthly': 'ماہانہ',
    'quarterly': '3 ماہ',
    'yearly': 'سالانہ',
    'popular': 'مقبول ترین',
    'save25': '25% بچائیں',
    'perMonth': '/ماہ',
    'perQuarter': '/3 ماہ',
    'perYear': '/سال',
  },
  'ne': {
    'badge': 'नयाँ सुविधा',
    'title': 'Premium प्रयास गर्नुहोस्',
    'subtitle': 'आफ्नो अनुभव सुधार्नुहोस्',
    'features': 'चयनित सुविधाहरू',
    'plans': 'मूल्य योजनाहरू',
    'subscribe': 'सदस्यता लिनुहोस्',
    'stayFree': 'नि:शुल्क रहनुहोस्',
    'monthly': 'मासिक',
    'quarterly': '3 महिना',
    'yearly': 'वार्षिक',
    'popular': 'लोकप्रिय',
    'save25': '25% बचत',
    'perMonth': '/महिना',
    'perQuarter': '/3 महिना',
    'perYear': '/वर्ष',
  },
  'id': {
    'badge': 'Fitur Baru',
    'title': 'Coba Premium',
    'subtitle': 'Tingkatkan pengalaman Anda',
    'features': 'Fitur Pilihan',
    'plans': 'Paket Harga',
    'subscribe': 'Berlangganan',
    'stayFree': 'Tetap Gratis',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'popular': 'Terpopuler',
    'save25': 'Hemat 25%',
    'perMonth': '/bln',
    'perQuarter': '/3 bln',
    'perYear': '/thn',
  },
  'ms': {
    'badge': 'Ciri Baharu',
    'title': 'Cuba Premium',
    'subtitle': 'Tingkatkan pengalaman anda',
    'features': 'Ciri Terpilih',
    'plans': 'Pelan Harga',
    'subscribe': 'Langgan',
    'stayFree': 'Kekal Percuma',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'popular': 'Popular',
    'save25': 'Jimat 25%',
    'perMonth': '/bln',
    'perQuarter': '/3 bln',
    'perYear': '/thn',
  },
};

String _pt(String key) {
  final m = _promoTr[appState.languageCode] ?? _promoTr['ar']!;
  return m[key] ?? key;
}

// ===== الميزات المعروضة (6 فقط) =====
class _PromoFeature {
  final IconData icon;
  final List<String>? assetIcons;
  final String textAr;
  final String textEn;

  const _PromoFeature({
    required this.icon,
    required this.textAr,
    required this.textEn,
    this.assetIcons,
  });
}

const List<_PromoFeature> _promoFeatures = [
  _PromoFeature(
    icon: Icons.workspace_premium_rounded,
    textAr: 'تاج متحرك فوق اسمك',
    textEn: 'Animated crown above your name',
  ),
  _PromoFeature(
    icon: Icons.verified_rounded,
    assetIcons: [
      'assets/icons/premium.png',
      'assets/icons/true.me.png',
    ],
    textAr: 'شارات مميزة',
    textEn: 'Premium badges',
  ),
  _PromoFeature(
    icon: Icons.block_rounded,
    textAr: 'بدون إعلانات',
    textEn: 'No ads',
  ),
  _PromoFeature(
    icon: Icons.stars_rounded,
    textAr: '10,000 نقطة شهرياً',
    textEn: '10,000 points monthly',
  ),
  _PromoFeature(
    icon: Icons.palette_rounded,
    textAr: 'كل الخلفيات والثيمات مجانية',
    textEn: 'All backgrounds & themes free',
  ),
  _PromoFeature(
    icon: Icons.visibility_rounded,
    textAr: 'رؤية الحسابات الخاصة',
    textEn: 'View private accounts',
  ),
];

/// يعرض نافذة Premium Promo
Future<void> showPremiumPromoDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (dialogContext) => Directionality(
      textDirection: appState.direction,
      child: const _PremiumPromoDialog(),
    ),
  );
}

class _PremiumPromoDialog extends StatefulWidget {
  const _PremiumPromoDialog();

  @override
  State<_PremiumPromoDialog> createState() => _PremiumPromoDialogState();
}

class _PremiumPromoDialogState extends State<_PremiumPromoDialog> {
  String _selectedPlanId = 'quarterly';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(R.s(context, 16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: R.s(context, 420),
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.s(context, 24)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.green,
              AppColors.deepGreen,
            ],
          ),
          border: Border.all(
            color: AppColors.gold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.s(context, 24)),
          child: Stack(
            children: [
              // ===== المحتوى =====
              SingleChildScrollView(
                padding: EdgeInsets.all(R.s(context, 18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // مساحة لزر X
                    SizedBox(height: R.s(context, 24)),

                    // ===== Hero =====
                    _buildHero(context),

                    SizedBox(height: R.s(context, 16)),

                    // ===== الميزات =====
                    _buildFeatures(context),

                    SizedBox(height: R.s(context, 18)),

                    // ===== الخطط =====
                    _buildPlans(context),

                    SizedBox(height: R.s(context, 16)),

                    // ===== الأزرار =====
                    _buildSubscribeButton(context),
                    SizedBox(height: R.s(context, 8)),
                    _buildStayFreeButton(context),
                  ],
                ),
              ),

              // ===== زر X =====
              Positioned(
                top: R.s(context, 8),
                right: R.s(context, 8),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.cream.withValues(alpha: 0.8),
                    size: R.s(context, 22),
                  ),
                  tooltip: appState.isArabic ? 'إغلاق' : 'Close',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Hero
  // ============================================================
  Widget _buildHero(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.s(context, 10),
            vertical: R.s(context, 4),
          ),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(R.s(context, 12)),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: Text(
            _pt('badge'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: R.f(context, 10.5),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: R.s(context, 12)),
        Container(
          padding: EdgeInsets.all(R.s(context, 14)),
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
            size: R.s(context, 38),
          ),
        ),
        SizedBox(height: R.s(context, 10)),
        Text(
          _pt('title'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.softGold,
            fontSize: R.f(context, 22),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: R.s(context, 4)),
        Text(
          _pt('subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.75),
            fontSize: R.f(context, 12.5),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Features
  // ============================================================
  Widget _buildFeatures(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(R.s(context, 12)),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(R.s(context, 14)),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: AppColors.gold,
              size: R.s(context, 16),
            ),
            SizedBox(width: R.s(context, 6)),
            Text(
              _pt('features'),
              style: TextStyle(
                color: AppColors.gold,
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: R.s(context, 10)),
        for (int i = 0; i < _promoFeatures.length; i++) ...[
          if (i > 0) SizedBox(height: R.s(context, 6)),
          _buildFeatureRow(context, _promoFeatures[i]),
        ],
      ],
    ),
  );
}

Widget _buildFeatureRow(BuildContext context, _PromoFeature feature) {
  return Row(
    children: [
      SizedBox(
        width: R.s(context, 26),
        height: R.s(context, 20),
        child: feature.assetIcons != null
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
                        width: R.s(context, 16),
                        height: R.s(context, 16),
                        errorBuilder: (_, _, _) => Icon(
                          feature.icon,
                          color: AppColors.gold,
                          size: R.s(context, 16),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : Icon(
                feature.icon,
                color: AppColors.gold,
                size: R.s(context, 16),
              ),
      ),
      SizedBox(width: R.s(context, 8)),
      Expanded(
        child: Text(
          appState.isArabic ? feature.textAr : feature.textEn,
          style: TextStyle(
            color: AppColors.cream,
            fontSize: R.f(context, 12),
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

  // ============================================================
  // Plans
  // ============================================================
  Widget _buildPlans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money_rounded,
              color: AppColors.gold,
              size: R.s(context, 16),
            ),
            SizedBox(width: R.s(context, 6)),
            Text(
              _pt('plans'),
              style: TextStyle(
                color: AppColors.gold,
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: R.s(context, 8)),
        for (final plan in premiumPlans)
          Padding(
            padding: EdgeInsets.only(bottom: R.s(context, 6)),
            child: _MiniPlanCard(
              plan: plan,
              selected: _selectedPlanId == plan.id,
              onTap: () => setState(() => _selectedPlanId = plan.id),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // Subscribe Button
  // ============================================================
  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      height: R.s(context, 50),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PremiumScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.s(context, 16)),
          ),
          elevation: 6,
          shadowColor: AppColors.gold.withValues(alpha: 0.5),
        ),
        icon: Icon(
          Icons.workspace_premium_rounded,
          size: R.s(context, 20),
        ),
        label: Text(
          _pt('subscribe'),
          style: TextStyle(
            fontSize: R.f(context, 15),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Stay Free Button
  // ============================================================
  Widget _buildStayFreeButton(BuildContext context) {
    return SizedBox(
      height: R.s(context, 44),
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cream.withValues(alpha: 0.7),
        ),
        child: Text(
          _pt('stayFree'),
          style: TextStyle(
            fontSize: R.f(context, 13),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.cream.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _MiniPlanCard
// ============================================================
class _MiniPlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _MiniPlanCard({
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
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 12),
          vertical: R.s(context, 10),
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(R.s(context, 14)),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: R.s(context, 18),
              height: R.s(context, 18),
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
                        width: R.s(context, 8),
                        height: R.s(context, 8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: R.s(context, 10)),

            // Label
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      appState.isArabic ? plan.labelAr : plan.labelEn,
                      style: TextStyle(
                        color: selected
                            ? AppColors.softGold
                            : AppColors.cream,
                        fontSize: R.f(context, 13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (plan.badge != null) ...[
                    SizedBox(width: R.s(context, 6)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.s(context, 6),
                        vertical: R.s(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(R.s(context, 8)),
                      ),
                      child: Text(
                        plan.badge!,
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: R.f(context, 8.5),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price
            Text(
              '\$${plan.price.toInt()}',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: R.f(context, 17),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
