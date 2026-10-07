import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../services/ads_service.dart';
import '../services/premium_service.dart';

class RewardedAdCard extends StatefulWidget {
  final VoidCallback? onRewardEarned;

  const RewardedAdCard({super.key, this.onRewardEarned});

  @override
  State<RewardedAdCard> createState() => _RewardedAdCardState();
}

class _RewardedAdCardState extends State<RewardedAdCard>
    with SingleTickerProviderStateMixin {
  int _adsWatchedToday = 0;
  int _totalAdsWatched = 0;
  bool _premiumTrialUsed = false;
  bool _loading = true;
  bool _showing = false;
  bool _isPremium = false; // ✅ جديد: إخفاء البطاقة لمن لديه Premium

  late final AnimationController _pulse;

  static const Map<String, Map<String, String>> _tr = {
    'ar': {
      'title': 'شاهد إعلاناً واربح 50 نقطة',
      'subtitle': 'ادعمنا بمشاهدة إعلان قصير',
      'watchedToday': 'شوهدت اليوم',
      'limitReached': 'وصلت للحد اليومي! عد غداً',
      'premiumProgress':
          'باقي {n} إعلانات لتفعيل Premium مجاناً (3 أيام)',
      'premiumUnlocked': '🎉 تم تفعيل Premium مجاناً لمدة 3 أيام!',
      'error': 'تعذّر تحميل الإعلان، حاول مرة أخرى',
      'support':
          'تطبيقنا مجاني بالكامل ولم يُصنع للربح. مشاهدة الإعلان طريقة بسيطة لدعمنا لنستمر في تطويره. كل مشاهدة تمنحك 50 نقطة لتزيين تطبيقك.',
    },
    'en': {
      'title': 'Watch an ad & earn 50 points',
      'subtitle': 'Support us by watching a short ad',
      'watchedToday': 'Watched today',
      'limitReached': 'Daily limit reached! Come back tomorrow',
      'premiumProgress': '{n} more ads to unlock free Premium (3 days)',
      'premiumUnlocked': '🎉 Free Premium for 3 days unlocked!',
      'error': 'Failed to load ad, please try again',
      'support':
          'Our app is completely free and not made for profit. Watching an ad is a simple way to support us so we can keep improving it. Each view earns you 50 points to decorate your app.',
    },
    'fr': {
      'title': 'Regardez une pub & gagnez 50 points',
      'subtitle': 'Soutenez-nous en regardant une courte pub',
      'watchedToday': "Vues aujourd'hui",
      'limitReached': 'Limite quotidienne atteinte ! Revenez demain',
      'premiumProgress':
          '{n} pubs pour débloquer Premium gratuit (3 jours)',
      'premiumUnlocked': '🎉 Premium gratuit 3 jours débloqué !',
      'error': 'Échec du chargement, réessayez',
      'support':
          'Notre application est entièrement gratuite. Regarder une pub est un moyen simple de nous soutenir.',
    },
    'ur': {
      'title': 'اشتہار دیکھیں اور 50 پوائنٹس پائیں',
      'subtitle': 'مختصر اشتہار دیکھ کر ہماری مدد کریں',
      'watchedToday': 'آج دیکھے گئے',
      'limitReached': 'روزانہ کی حد مکمل! کل واپس آئیں',
      'premiumProgress': '{n} مزید اشتہار مفت Premium کے لیے',
      'premiumUnlocked': '🎉 مفت Premium 3 دن کے لیے فعال!',
      'error': 'اشتہار لوڈ نہیں ہو سکا',
      'support':
          'ہماری ایپ مکمل طور پر مفت ہے۔ اشتہار دیکھنا ہماری مدد کا آسان طریقہ ہے۔',
    },
    'ne': {
      'title': 'विज्ञापन हेर्नुहोस् र 50 अंक कमाउनुहोस्',
      'subtitle': 'छोटो विज्ञापन हेरेर हामीलाई सहयोग गर्नुहोस्',
      'watchedToday': 'आज हेरिएको',
      'limitReached': 'दैनिक सीमा पुग्यो! भोलि फर्कनुहोस्',
      'premiumProgress': '{n} थप विज्ञापन नि:शुल्क Premium को लागि',
      'premiumUnlocked': '🎉 3 दिनको लागि नि:शुल्क Premium!',
      'error': 'विज्ञापन लोड गर्न सकिएन',
      'support':
          'हाम्रो एप पूर्ण रूपमा नि:शुल्क छ। विज्ञापन हेर्नु सहयोगको सजिलो तरिका हो।',
    },
    'id': {
      'title': 'Tonton iklan & dapatkan 50 poin',
      'subtitle': 'Dukung kami dengan menonton iklan singkat',
      'watchedToday': 'Ditonton hari ini',
      'limitReached': 'Batas harian tercapai! Kembali besok',
      'premiumProgress': '{n} iklan lagi untuk Premium gratis',
      'premiumUnlocked': '🎉 Premium gratis 3 hari diaktifkan!',
      'error': 'Gagal memuat iklan',
      'support':
          'Aplikasi kami sepenuhnya gratis. Menonton iklan adalah cara mudah untuk mendukung kami.',
    },
    'ms': {
      'title': 'Tonton iklan & dapatkan 50 mata',
      'subtitle': 'Sokong kami dengan menonton iklan pendek',
      'watchedToday': 'Ditonton hari ini',
      'limitReached': 'Had harian dicapai! Kembali esok',
      'premiumProgress': '{n} iklan lagi untuk Premium percuma',
      'premiumUnlocked': '🎉 Premium percuma 3 hari diaktifkan!',
      'error': 'Gagal memuat iklan',
      'support':
          'Aplikasi kami sepenuhnya percuma. Menonton iklan adalah cara mudah untuk menyokong kami.',
    },
  };

  String _t(String key) {
    final m = _tr[appState.languageCode] ?? _tr['ar']!;
    return m[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _loadStats();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // ✅ جديد: افحص Premium أولاً
    final isPremium = await PremiumService.fetchIsUserPremium(uid);

    // إذا Premium → أخفِ البطاقة فوراً
    if (isPremium) {
      if (mounted) {
        setState(() {
          _isPremium = true;
          _loading = false;
        });
      }
      return;
    }

    final stats = await adsService.loadStats(uid);
    if (mounted) {
      setState(() {
        _adsWatchedToday = stats['adsWatchedToday'] as int? ?? 0;
        _totalAdsWatched = stats['totalAdsWatched'] as int? ?? 0;
        _premiumTrialUsed = stats['premiumTrialUsed'] as bool? ?? false;
        _loading = false;
      });
    }
  }

  bool get _limitReached => _adsWatchedToday >= AdsService.dailyAdLimit;

  Future<void> _watchAd() async {
    if (_showing) return;
    if (_limitReached) {
      _snack(_t('limitReached'), error: true);
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _showing = true);

    final loaded = await adsService.loadAd();
    if (!loaded) {
      if (mounted) setState(() => _showing = false);
      _snack(_t('error'), error: true);
      return;
    }

    bool earned = false;
    await adsService.showAd(
      onUserEarnedReward: (amount, type) {
        earned = true;
      },
    );

    if (!earned) {
      if (mounted) setState(() => _showing = false);
      return;
    }

    final result = await adsService.rewardAd(uid);
    if (!mounted) return;

    setState(() => _showing = false);

    if (result.success) {
      setState(() {
        _adsWatchedToday = result.adsWatchedToday;
        _totalAdsWatched += 1;
        if (result.grantedPremiumTrial) _premiumTrialUsed = true;
      });

      if (result.grantedPremiumTrial) {
        _snack(_t('premiumUnlocked'));
      } else {
        _snack('+${result.pointsEarned} ${appState.tr('points')} 🎉');
      }

      widget.onRewardEarned?.call();
    } else if (result.limitReached) {
      _snack(_t('limitReached'), error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFF5C1F1F) : AppColors.emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_isPremium) return const SizedBox.shrink(); // ✅ جديد: إخفاء لـ Premium
    if (!adsService.isSupported) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = _pulse.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.15 + 0.05 * t),
                  AppColors.deepGreen.withValues(alpha: 0.9),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.5 + 0.3 * t),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2 + 0.15 * t),
                  blurRadius: 12 + 6 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: _limitReached || _showing ? null : _watchAd,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.2),
                          border:
                              Border.all(color: AppColors.gold, width: 1.5),
                        ),
                        child: _showing
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gold,
                                ),
                              )
                            : Icon(
                                _limitReached
                                    ? Icons.timer_outlined
                                    : Icons.play_circle_fill_rounded,
                                color: AppColors.gold,
                                size: 26,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('title'),
                              style: const TextStyle(
                                color: AppColors.softGold,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _limitReached
                                  ? _t('limitReached')
                                  : _t('subtitle'),
                              style: TextStyle(
                                color:
                                    AppColors.cream.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _t('watchedToday'),
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_adsWatchedToday / ${AdsService.dailyAdLimit}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _adsWatchedToday / AdsService.dailyAdLimit,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(
                        _limitReached ? Colors.grey : AppColors.gold,
                      ),
                    ),
                  ),
                  if (!_premiumTrialUsed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _t('premiumProgress').replaceAll(
                                '{n}',
                                '${(AdsService.adsForPremiumTrial - _totalAdsWatched).clamp(0, 10)}',
                              ),
                              style: const TextStyle(
                                color: AppColors.softGold,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: AppColors.gold.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _t('support'),
                            style: TextStyle(
                              color: AppColors.cream.withValues(alpha: 0.6),
                              fontSize: 10.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
