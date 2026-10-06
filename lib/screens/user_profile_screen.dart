import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/verified_badge.dart';
import '../widgets/user_badges.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _viewerIsPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkViewerPremium();
  }

  Future<void> _checkViewerPremium() async {
    final myUid = AuthService.currentUid;
    if (myUid != null) {
      final p = await PremiumService.isUserPremium(myUid);
      if (mounted) setState(() { _viewerIsPremium = p; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.deepGreen,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator(color: AppColors.gold));
          final data = snap.data!.data() as Map<String, dynamic>;
          final profile = (data['profile'] ?? {}) as Map<String, dynamic>;
          final stats = (data['stats'] ?? {}) as Map<String, dynamic>;

          final isPublic = profile['isPublic'] != false;
          final isPremiumTarget = (profile['premium']?['active'] ?? false) == true;
          final canViewPrivate = isPublic || _viewerIsPremium || widget.uid == AuthService.currentUid;

          if (!canViewPrivate) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: AppColors.gold, size: R.s(context, 64)),
                  SizedBox(height: R.s(context, 16)),
                  Text(
                    appState.tr('private_account'),
                    style: TextStyle(color: AppColors.cream, fontSize: R.f(context, 18)),
                  ),
                  SizedBox(height: R.s(context, 8)),
                  Text(
                    appState.tr('premium_to_view'),
                    style: TextStyle(color: AppColors.cream.withOpacity(0.6), fontSize: R.f(context, 14)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(R.s(context, 16)),
            child: Column(
              children: [
                AnimatedEntry(
                  child: ProfileAvatar(
                    avatar: data['avatar'] ?? 'man',
                    photoBase64: profile['photoBase64'],
                    size: R.s(context, 100),
                    showCrown: isPremiumTarget,
                  ),
                ),
                SizedBox(height: R.s(context, 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile['name'] ?? 'مستخدم',
                      style: TextStyle(
                        color: isPremiumTarget ? AppColors.gold : AppColors.cream,
                        fontSize: R.f(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile['verified'] == true) ...[
                      SizedBox(width: R.s(context, 6)),
                      VerifiedBadge(type: profile['verifiedType'] ?? 'user', size: R.s(context, 22)),
                    ],
                  ],
                ),
                SizedBox(height: R.s(context, 6)),
                if (profile['bio'] != null && profile['bio'].toString().isNotEmpty)
                  Text(
                    profile['bio'],
                    style: TextStyle(color: AppColors.cream.withOpacity(0.8), fontSize: R.f(context, 14)),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: R.s(context, 16)),
                _statsRow(context, appState, stats),
                if (profile['userBadges'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: R.s(context, 12)),
                    child: UserBadges(badges: List<String>.from(profile['userBadges']), size: R.s(context, 24)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statsRow(BuildContext context, AppState appState, Map<String, dynamic> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem(context, appState, '${stats['points'] ?? 0}', appState.tr('points')),
        _statItem(context, appState, '${stats['level'] ?? 1}', appState.tr('level')),
        _statItem(context, appState, '${stats['streak'] ?? 0}', appState.tr('streak')),
      ],
    );
  }

  Widget _statItem(BuildContext context, AppState appState, String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: AppColors.gold, fontSize: R.f(context, 20), fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.cream.withOpacity(0.7), fontSize: R.f(context, 12))),
      ],
    );
  }
}
