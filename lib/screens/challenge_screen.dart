import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/themed_colors.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import '../services/user_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/rewarded_ad_card.dart';
import 'challenge_play_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool _isPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPremium();
  }

  Future<void> _loadPremium() async {
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
    final appState = AppState.of(context);
    final uid = AuthService.currentUid;

    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          appState.tr('challenge'),
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: EdgeInsets.all(R.s(context, 16)),
              child: Column(
                children: [
                  // بطاقة الإعلان المكافئ (تختفي لـ Premium)
                  if (!_isPremium) const RewardedAdCard(),

                  // بطاقة Premium banner
                  if (!_isPremium) _buildPremiumBanner(context, appState),

                  // بطاقة النقاط الحالية
                  _buildPointsCard(context, appState, uid),

                  SizedBox(height: R.s(context, 16)),

                  // زر بدء التحدي
                  _buildStartButton(context, appState),
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context, AppState appState) {
    return AnimatedEntry(
      delay: 100,
      child: Container(
        margin: EdgeInsets.only(bottom: R.s(context, 12)),
        padding: EdgeInsets.all(R.s(context, 14)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gold.withOpacity(0.2), AppColors.emerald.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(R.s(context, 14)),
          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.star, color: AppColors.gold, size: R.s(context, 24)),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Text(
                appState.tr('premium_double_points_hint'),
                style: TextStyle(color: AppColors.cream, fontSize: R.f(context, 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, AppState appState, String? uid) {
    return GlassCard(
      child: StreamBuilder<DocumentSnapshot>(
        stream: uid != null
            ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
            : const Stream.empty(),
        builder: (context, snap) {
          final data = snap.data?.data() as Map<String, dynamic>?;
          final stats = (data?['stats'] ?? {}) as Map<String, dynamic>;
          final points = (stats['points'] ?? 0) as int;
          final completed = (stats['challengesCompleted'] ?? 0) as int;

          return Column(
            children: [
              Icon(Icons.emoji_events, color: AppColors.gold, size: R.s(context, 48)),
              SizedBox(height: R.s(context, 8)),
              Text(
                '$points',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: R.f(context, 32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                appState.tr('points'),
                style: TextStyle(color: AppColors.cream.withOpacity(0.7), fontSize: R.f(context, 14)),
              ),
              SizedBox(height: R.s(context, 12)),
              Text(
                '${appState.tr('challenges_completed')}: $completed',
                style: TextStyle(color: AppColors.cream.withOpacity(0.8), fontSize: R.f(context, 14)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, AppState appState) {
    return AnimatedEntry(
      delay: 200,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.deepGreen,
            padding: EdgeInsets.symmetric(vertical: R.s(context, 16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.s(context, 14)),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChallengePlayScreen(isPremium: _isPremium),
              ),
            );
          },
          child: Text(
            appState.tr('start_challenge'),
            style: TextStyle(fontSize: R.f(context, 18), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
