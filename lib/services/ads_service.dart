import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// نتيجة مشاهدة إعلان
class AdRewardResult {
  final bool success;
  final bool limitReached;
  final int pointsEarned;
  final int adsWatchedToday;
  final bool grantedPremiumTrial;

  const AdRewardResult({
    this.success = false,
    this.limitReached = false,
    this.pointsEarned = 0,
    this.adsWatchedToday = 0,
    this.grantedPremiumTrial = false,
  });
}

/// خدمة الإعلانات المكافئة (Rewarded Video Ads)
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // معرفات AdMob
  // ============================================================
  static const String _androidAppId =
      'ca-app-pub-7354273374998913~5567231375';
  static const String _iosAppId =
      'ca-app-pub-7354274273374998913~4615890593';

  static const String _androidRewardedId =
      'ca-app-pub-7354273374998913/5755827856';
  static const String _iosRewardedId =
      'ca-app-pub-7354273374998913/8080492888';

  // ============================================================
  // إعدادات المكافآت
  // ============================================================
  static const int pointsPerAd = 50;
  static const int dailyAdLimit = 20;
  static const int adsForPremiumTrial = 10;
  static const int premiumTrialDays = 3;

  // ============================================================
  // AdMob State
  // ============================================================
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _initialized = false;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isReady => _rewardedAd != null;

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) return _androidRewardedId;
    if (Platform.isIOS) return _iosRewardedId;
    return '';
  }

  // ============================================================
  // تهيئة AdMob (تُستدعى مرة واحدة عند بدء التطبيق)
  // ============================================================
  Future<void> initialize() async {
    if (_initialized) return;
    if (!isSupported) return;
    _initialized = true;

    try {
      await MobileAds.instance.initialize();
      // تحميل أول إعلان
      loadAd();
    } catch (e) {
      debugPrint('AdMob init error: $e');
    }
  }

  // ============================================================
  // تحميل إعلان جديد
  // ============================================================
  Future<bool> loadAd() async {
    if (!isSupported) return false;
    if (_rewardedAd != null) return true;
    if (_isLoading) return false;
    _isLoading = true;

    final completer = Completer<bool>();

    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoading = false;
            debugPrint('RewardedAd load failed: ${error.message}');
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  // ============================================================
  // عرض إعلان
  // ============================================================
  /// يرجّع true لو المستخدم أكمل الإعلان واستحق المكافأة
  Future<bool> showAd({
    required void Function(int amount, String type) onUserEarnedReward,
  }) async {
    if (!isSupported) return false;

    // لو ما فيه إعلان → حاول تحميل واحد
    if (_rewardedAd == null) {
      final loaded = await loadAd();
      if (!loaded) return false;
    }

    final ad = _rewardedAd;
    if (ad == null) return false;

    bool rewarded = false;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _rewardedAd = null;
        // حمّل الإعلان التالي مسبقاً
        loadAd();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _rewardedAd = null;
        loadAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );

    return completer.future;
  }

  // ============================================================
  // Firestore — إحصائيات الإعلانات
  // ============================================================
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// يقرأ إحصائيات الإعلانات للمستخدم
  Future<Map<String, dynamic>> loadStats(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final stats = (snap.data()?['stats'] as Map?) ?? {};
      final lastDate = (stats['lastAdDate'] as String?) ?? '';
      final today = _todayString();
      final isNewDay = lastDate != today;

      return {
        'adsWatchedToday':
            isNewDay ? 0 : ((stats['adsWatchedToday'] as num?)?.toInt() ?? 0),
        'totalAdsWatched': (stats['totalAdsWatched'] as num?)?.toInt() ?? 0,
        'premiumTrialUsed': (stats['premiumTrialUsed'] as bool?) ?? false,
      };
    } catch (e) {
      return {
        'adsWatchedToday': 0,
        'totalAdsWatched': 0,
        'premiumTrialUsed': false,
      };
    }
  }

  // ============================================================
  // منح المكافأة (نقاط + عداد + Premium trial)
  // ============================================================
  Future<AdRewardResult> rewardAd(String uid) async {
    final today = _todayString();
    final ref = _db.collection('users').doc(uid);

    try {
      return await _db.runTransaction<AdRewardResult>((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) {
          return const AdRewardResult();
        }

        final data = snap.data() ?? {};
        final stats = (data['stats'] as Map?) ?? {};
        final profile = (data['profile'] as Map?) ?? {};

        // ── 1) اقرأ الحالة الحالية ──
        final lastDate = (stats['lastAdDate'] as String?) ?? '';
        final isNewDay = lastDate != today;

        int adsToday =
            isNewDay ? 0 : ((stats['adsWatchedToday'] as num?)?.toInt() ?? 0);

        // ── 2) فحص الحد اليومي ──
        if (adsToday >= dailyAdLimit) {
          return const AdRewardResult(limitReached: true);
        }

        final totalWatched =
            ((stats['totalAdsWatched'] as num?)?.toInt() ?? 0) + 1;
        final currentPoints = (stats['points'] as num?)?.toInt() ?? 0;
        final newPoints = currentPoints + pointsPerAd;
        final newAdsToday = adsToday + 1;

        // ── 3) فحص Premium Trial ──
        final trialUsed = (stats['premiumTrialUsed'] as bool?) ?? false;
        bool grantedTrial = false;

        final updates = <String, dynamic>{
          'stats.adsWatchedToday': newAdsToday,
          'stats.lastAdDate': today,
          'stats.totalAdsWatched': totalWatched,
          'stats.points': newPoints,
        };

        if (!trialUsed && totalWatched >= adsForPremiumTrial) {
          final now = DateTime.now();
          final expiresAt = now.add(const Duration(days: premiumTrialDays));

          updates['stats.premiumTrialUsed'] = true;
          updates['profile.premium'] = {
            'active': true,
            'plan': 'trial',
            'startedAt': Timestamp.fromDate(now),
            'expiresAt': Timestamp.fromDate(expiresAt),
          };
          grantedTrial = true;
        }

        tx.update(ref, updates);

        return AdRewardResult(
          success: true,
          pointsEarned: pointsPerAd,
          adsWatchedToday: newAdsToday,
          grantedPremiumTrial: grantedTrial,
        );
      });
    } catch (e) {
      debugPrint('rewardAd error: $e');
      return const AdRewardResult();
    }
  }
}

final adsService = AdsService.instance;
