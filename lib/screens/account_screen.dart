import 'package:flutter/material.dart';
import '../widgets/verified_badge.dart';
import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';
import 'edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic> _stats = {};
Map<String, dynamic> _profile = {};
bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
String _verifiedType() {
  final vt = _profile['verifiedType'] as String?;
  if (vt == 'owner' || vt == 'user') return vt!;
  return 'none';
}
  }

  Future<void> _load() async {
  setState(() => _loading = true);
  try {
    final results = await Future.wait([
      userService.loadStats(),
      userService.loadProfile(),
    ]);
    if (mounted) {
      setState(() {
        _stats = results[0];
        _profile = results[1];
      });
    }
  } catch (e) {
    debugPrint('AccountScreen load error: $e');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
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
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.deepGreen, Color(0xFF0A1F17)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: appState.tr('back'),
                          color: AppColors.softGold,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Text(
                          appState.tr('account'),
                          style: const TextStyle(
                            fontSize: 18,
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
                            padding: const EdgeInsets.all(20),
                            children: [
                              _buildHeader(user?.email ?? ''),
                              const SizedBox(height: 20),
                              _buildStatsGrid(points, level, streak),
                              const SizedBox(height: 16),
                              _buildLevelProgress(
                                  points, level, nextLevelPoints, progress),
                              const SizedBox(height: 20),
                              _buildActions(),
                              const SizedBox(height: 20),
                              _buildSignOut(),
                              const SizedBox(height: 20),
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
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                avatar == 'woman'
                    ? 'assets/images/avatar_woman.png'
                    : 'assets/images/avatar_man.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  avatar == 'woman' ? Icons.face_3 : Icons.face_6,
                  size: 60,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      profileState.name.isEmpty
          ? appState.tr('noName')
          : profileState.name,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.softGold,
      ),
    ),
    const SizedBox(width: 6),
    VerifiedBadge(type: _verifiedType(), size: 22),
  ],
),
          if (profileState.bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              profileState.bio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.cream.withValues(alpha: 0.75),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                profileState.isPublic
                    ? Icons.public_rounded
                    : Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.gold.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                appState.tr(profileState.isPublic ? 'public' : 'private'),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.cream.withValues(alpha: 0.55),
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
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
          icon: Icons.military_tech_rounded,
          label: appState.tr('level'),
          value: '$level',
        )),
        const SizedBox(width: 12),
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
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                appState.tr('levelProgress'),
                style: const TextStyle(
                  color: AppColors.softGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '$points / $nextLevelPoints',
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
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
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
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
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.cream,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.softGold.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}
