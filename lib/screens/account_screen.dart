import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/verification_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/themed_background.dart';
import '../widgets/user_badges.dart';
import 'change_photo_screen.dart';
import 'edit_profile_screen.dart';
import 'verification_request_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _profile = {};
  bool _loading = true;
  bool _hasPendingRequest = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        userService.loadStats(),
        userService.loadProfile(),
      ]);
      bool pending = false;
      try {
        pending = await verificationService.hasPendingRequest();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _stats = results[0];
          _profile = results[1];
          _hasPendingRequest = pending;
          _loading = false;
        });
      }
      await profileState.refresh();
    } catch (e) {
      debugPrint('AccountScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ فحص Premium
  bool _isPremiumActive() {
    final premium = (_profile['premium'] as Map?) ?? {};
    final active = (premium['active'] as bool?) ?? false;
    if (!active) return false;
    final expTs = premium['expiresAt'];
    DateTime? expiry;
    if (expTs is Timestamp) expiry = expTs.toDate();
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  // ✅ Badges — مع Premium
  List<String> _badges() {
    final list = <String>[];
    final vt = _profile['verifiedType'] as String?;
    final verified = (_profile['verified'] as bool?) ?? false;

    // Owner
    if (vt == 'owner') {
      return const ['owner'];
    }

    // Premium
    if (_isPremiumActive()) {
      list.add('premium');
    }

    // Verified
    if (verified && (vt == 'me' || vt == 'user')) {
      list.add(vt!);
    }

    return list;
  }

  bool _isVerified() {
    final vt = _profile['verifiedType'] as String?;
    return vt == 'owner' || vt == 'me' || vt == 'user';
  }

  Future<void> _openVerification() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VerificationRequestScreen(),
      ),
    );
    await _load();
  }

  Future<void> _openChangePhoto() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChangePhotoScreen(),
      ),
    );
    await _load();
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('signOutConfirmTitle'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Text(
          appState.tr('signOutConfirmBody'),
          style: const TextStyle(color: AppColors.cream),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appState.tr('signOut'),
                style: const TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await authService.signOut();
      if (mounted) {
        await goAfterSignOut(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profileState,
      builder: (context, _) {
        final user = authService.currentUser;
        final points = (_stats['points'] as num?)?.toInt() ?? 0;
        final level = (_stats['level'] as num?)?.toInt() ?? 1;
        final streak = (_stats['streak'] as num?)?.toInt() ?? 0;
        final nextLevelPoints = UserService.pointsForNextLevel(level);
        final progress = nextLevelPoints == 0
            ? 0.0
            : (points / nextLevelPoints).clamp(0.0, 1.0);

        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      R.s(context, 6),
                      R.s(context, 6),
                      R.s(context, 16),
                      0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context).maybePop(),
                          tooltip: appState.tr('back'),
                          color: AppColors.softGold,
                          iconSize: R.s(context, 22),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Text(
                          appState.tr('account'),
                          style: TextStyle(
                            fontSize: R.f(context, 15),
                            fontWeight: FontWeight.w700,
                            color: AppColors.softGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.gold))
                        : ListView(
                            padding: EdgeInsets.all(R.s(context, 16)),
                            children: [
                              _buildHeader(user?.email ?? ''),
                              SizedBox(height: R.s(context, 14)),
                              _buildStatsGrid(points, level, streak),
                              SizedBox(height: R.s(context, 12)),
                              _buildLevelProgress(
                                  points, level, nextLevelPoints, progress),
                              SizedBox(height: R.s(context, 14)),
                              _buildVerificationSection(),
                              SizedBox(height: R.s(context, 14)),
                              _buildActions(),
                              SizedBox(height: R.s(context, 14)),
                              _buildSignOut(),
                              SizedBox(height: R.s(context, 14)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String email) {
    final avatar = profileState.avatar ?? 'man';
    final isPremium = _isPremiumActive();

    return GlassCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: _openChangePhoto,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ProfileAvatar(
                  email: email,
                  avatar: avatar,
                  size: R.s(context, 78),
                  photoBytes: profileState.photoBytes,
                  showCrown: isPremium,
                ),
                Container(
                  margin: EdgeInsets.all(R.s(context, 4)),
                  padding: EdgeInsets.all(R.s(context, 5)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                    border: Border.all(
                      color: AppColors.deepGreen,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.deepGreen,
                    size: R.s(context, 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: R.s(context, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profileState.name.isEmpty
                      ? appState.tr('noName')
                      : profileState.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.f(context, 17),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(width: R.s(context, 5)),
              UserBadges(
                badges: _badges(),
                size: 16,
              ),
            ],
          ),
          if (profileState.bio.isNotEmpty) ...[
            SizedBox(height: R.s(context, 5)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.s(context, 8)),
              child: Text(
                profileState.bio,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: R.f(context, 11.5),
                  height: 1.4,
                  color: AppColors.cream.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
          SizedBox(height: R.s(context, 6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                profileState.isPublic
                    ? Icons.public_rounded
                    : Icons.lock_outline_rounded,
                size: R.s(context, 12),
                color: AppColors.gold.withValues(alpha: 0.8),
              ),
              SizedBox(width: R.s(context, 3)),
              Text(
                appState.tr(profileState.isPublic ? 'public' : 'private'),
                style: TextStyle(
                  fontSize: R.f(context, 10.5),
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 3)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.s(context, 8)),
            child: Text(
              email,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.f(context, 11),
                color: AppColors.cream.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int points, int level, int streak) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
          icon: Icons.stars_rounded,
          label: appState.tr('points'),
          value: '$points',
        )),
        SizedBox(width: R.s(context, 8)),
        Expanded(
            child: _StatCard(
          icon: Icons.military_tech_rounded,
          label: appState.tr('level'),
          value: '$level',
        )),
        SizedBox(width: R.s(context, 8)),
        Expanded(
            child: _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: appState.tr('streak'),
          value: '$streak',
        )),
      ],
    );
  }

  Widget _buildLevelProgress(
      int points, int level, int nextLevelPoints, double progress) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  color: AppColors.gold, size: R.s(context, 16)),
              SizedBox(width: R.s(context, 6)),
              Expanded(
                child: Text(
                  appState.tr('levelProgress'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontWeight: FontWeight.w700,
                    fontSize: R.f(context, 12),
                  ),
                ),
              ),
              Text(
                '$points / $nextLevelPoints',
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.75),
                  fontSize: R.f(context, 11),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: R.s(context, 8),
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    if (_isVerified()) return const SizedBox.shrink();

    if (_hasPendingRequest) {
      return GlassCard(
        ornament: false,
        child: Row(
          children: [
            Icon(Icons.hourglass_top_rounded,
                color: AppColors.gold, size: R.s(context, 22)),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.tr('verificationPending'),
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  SizedBox(height: R.s(context, 2)),
                  Text(
                    appState.tr('verificationPendingDesc'),
                    style: TextStyle(
                      fontSize: R.f(context, 10.5),
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _openVerification,
      child: GlassCard(
        ornament: false,
        child: Row(
          children: [
            Container(
              width: R.s(context, 40),
              height: R.s(context, 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(Icons.verified_user_rounded,
                  color: AppColors.gold, size: R.s(context, 20)),
            ),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.tr('verificationRequest'),
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  SizedBox(height: R.s(context, 2)),
                  Text(
                    appState.tr('verificationRequestDesc'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.f(context, 10.5),
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: R.s(context, 18),
                color: AppColors.softGold.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return GlassCard(
      child: Column(
        children: [
          _ActionRow(
            icon: Icons.edit_rounded,
            title: appState.tr('editProfile'),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const EditProfileScreen()),
              );
              await _load();
            },
          ),
          Divider(
            height: 1,
            color: AppColors.gold.withValues(alpha: 0.15),
          ),
          _ActionRow(
            icon: Icons.camera_alt_rounded,
            title: appState.tr('chooseAvatar'),
            onTap: _openChangePhoto,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOut() {
    return GlassCard(
      child: _ActionRow(
        icon: Icons.logout_rounded,
        title: appState.tr('signOut'),
        color: const Color(0xFFFF8A80),
        onTap: _signOut,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: R.s(context, 22)),
          SizedBox(height: R.s(context, 6)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.f(context, 17),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 2)),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.f(context, 10),
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 6),
          vertical: R.s(context, 12),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: R.s(context, 18)),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.cream,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: R.s(context, 18),
                color: AppColors.softGold.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}
