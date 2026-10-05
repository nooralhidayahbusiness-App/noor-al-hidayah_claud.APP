import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/verification_service.dart';
import '../../services/youtube_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';
import 'add_video_screen.dart';
import 'photo_requests_screen.dart';
import 'verification_requests_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _pendingVerifications = 0;
  int _pendingPhotoUpdates = 0;
  int _videosCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      verificationService.pendingCount(),
      verificationService.pendingPhotoUpdatesCount(),
      youtubeService.count(),
    ]);
    if (mounted) {
      setState(() {
        _pendingVerifications = results[0];
        _pendingPhotoUpdates = results[1];
        _videosCount = results[2];
        _loading = false;
      });
    }
  }

  Future<void> _openRequests() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VerificationRequestsScreen(),
      ),
    );
    await _load();
  }

  Future<void> _openPhotoRequests() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PhotoRequestsScreen(),
      ),
    );
    await _load();
  }

  Future<void> _openAddVideo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddVideoScreen(),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===== الشريط العلوي =====
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
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('adminPanel'),
                      style: TextStyle(
                        fontSize: R.f(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),
              SizedBox(height: R.s(context, 6)),

              // ===== المحتوى =====
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.gold,
                        backgroundColor: AppColors.deepGreen,
                        child: ListView(
                          padding: EdgeInsets.all(R.s(context, 20)),
                          children: [
                            // ===== الرأس =====
                            GlassCard(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: AppColors.gold,
                                    size: R.s(context, 56),
                                  ),
                                  SizedBox(height: R.s(context, 12)),
                                  Text(
                                    appState.tr('adminPanel'),
                                    style: TextStyle(
                                      fontSize: R.f(context, 18),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.softGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: R.s(context, 14)),

                            // ===== 1) طلبات التوثيق =====
                            _AdminCard(
                              icon: Icons.verified_user_rounded,
                              title: appState.tr('adminVerificationRequests'),
                              subtitle: _pendingVerifications > 0
                                  ? '$_pendingVerifications ${appState.tr('adminPending')}'
                                  : appState.tr('adminNoRequests'),
                              badge: _pendingVerifications,
                              onTap: _openRequests,
                            ),
                            SizedBox(height: R.s(context, 10)),

                            // ===== 2) طلبات تغيير الصورة =====
                            _AdminCard(
                              icon: Icons.photo_camera_back_rounded,
                              title: 'طلبات تغيير الصورة',
                              subtitle: _pendingPhotoUpdates > 0
                                  ? '$_pendingPhotoUpdates قيد الانتظار'
                                  : 'لا توجد طلبات حالياً',
                              badge: _pendingPhotoUpdates,
                              onTap: _openPhotoRequests,
                            ),
                            SizedBox(height: R.s(context, 10)),

                            // ===== 3) إضافة فيديو YouTube =====
                            _AdminCard(
                              icon: Icons.play_circle_fill_rounded,
                              title: 'إضافة فيديو للقناة',
                              subtitle: _videosCount > 0
                                  ? '$_videosCount فيديو منشور'
                                  : 'لا توجد فيديوهات بعد',
                              badge: 0,
                              onTap: _openAddVideo,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _AdminCard
// ============================================================
class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int badge;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        ornament: false,
        child: Row(
          children: [
            Container(
              width: R.s(context, 48),
              height: R.s(context, 48),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.gold,
                size: R.s(context, 24),
              ),
            ),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: R.f(context, 14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  SizedBox(height: R.s(context, 3)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      color: badge > 0
                          ? AppColors.gold
                          : AppColors.cream.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (badge > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 10),
                  vertical: R.s(context, 4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: TextStyle(
                    fontSize: R.f(context, 12),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(width: R.s(context, 6)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.softGold.withValues(alpha: 0.7),
              size: R.s(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}
