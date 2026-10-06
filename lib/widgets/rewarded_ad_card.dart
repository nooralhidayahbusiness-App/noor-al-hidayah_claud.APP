import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/ads_service.dart';
import '../services/premium_service.dart';

class RewardedAdCard extends StatefulWidget {
  const RewardedAdCard({super.key});

  @override
  State<RewardedAdCard> createState() => _RewardedAdCardState();
}

class _RewardedAdCardState extends State<RewardedAdCard> {
  bool _isPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final uid = AuthService.currentUid;
    if (uid != null) {
      final p = await PremiumService.isUserPremium(uid);
      if (mounted) setState(() { _isPremium = p; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_isPremium) return const SizedBox.shrink(); // Premium: لا إعلانات

    final appState = AppState.of(context);
    final uid = AuthService.currentUid;

    return StreamBuilder<DocumentSnapshot>(
      stream: uid != null
          ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
          : const Stream.empty(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final stats = (data?['stats'] ?? {}) as Map<String, dynamic>;
        final watched = (stats['adsWatchedToday'] ?? 0) as int;
        final lastAdDate = (stats['lastAdDate'] ?? '') as String;
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final effectiveWatched = lastAdDate == today ? watched : 0;
        final remaining = 20 - effectiveWatched;

        return Container(
          margin: EdgeInsets.only(bottom: R.s(context, 12)),
          padding: EdgeInsets.all(R.s(context, 14)),
          decoration: BoxDecoration(
            color: AppColors.emerald.withOpacity(0.15),
            borderRadius: BorderRadius.circular(R.s(context, 14)),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.play_circle, color: AppColors.gold, size: R.s(context, 32)),
                  SizedBox(width: R.s(context, 10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.tr('watch_ad_reward'),
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: R.f(context, 14)),
                        ),
                        Text(
                          '$remaining ${appState.tr('ads_remaining')}',
                          style: TextStyle(color: AppColors.cream.withOpacity(0.7), fontSize: R.f(context, 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 10)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.deepGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.s(context, 10))),
                  ),
                  onPressed: remaining > 0
                      ? () async {
                          final rewarded = await AdsService.showRewardedAd();
                          if (rewarded && mounted) {
                            // منح 50 نقطة
                            await FirebaseFirestore.instance.collection('users').doc(uid).update({
                              'stats.points': FieldValue.increment(50),
                              'stats.adsWatchedToday': FieldValue.increment(1),
                              'stats.lastAdDate': today,
                              'stats.totalAdsWatched': FieldValue.increment(1),
                            });
                          }
                        }
                      : null,
                  child: Text(
                    remaining > 0 ? appState.tr('watch_ad') : appState.tr('no_ads_left'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: R.s(context, 6)),
              Text(
                appState.tr('support_app_hint'),
                style: TextStyle(color: AppColors.cream.withOpacity(0.5), fontSize: R.f(context, 10)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
