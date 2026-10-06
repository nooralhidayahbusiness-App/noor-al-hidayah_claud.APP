import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/premium_service.dart';
import '../../services/verification_service.dart';
import '../../services/youtube_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';
import 'add_video_screen.dart';
import 'photo_requests_screen.dart';
import 'premium_requests_screen.dart';
import 'verification_requests_screen.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _apTr = {
  'ar': {
    'title': 'لوحة التحكم',
    'requestsVerify': 'طلبات التوثيق',
    'requestsPhoto': 'طلبات تغيير الصورة',
    'requestsPremium': 'طلبات Premium',
    'addVideo': 'إضافة فيديو للقناة',
    'pending': 'قيد الانتظار',
    'noRequests': 'لا توجد طلبات حالياً',
    'videos': 'فيديو منشور',
    'noVideos': 'لا توجد فيديوهات بعد',
  },
  'en': {
    'title': 'Admin Panel',
    'requestsVerify': 'Verification Requests',
    'requestsPhoto': 'Photo Change Requests',
    'requestsPremium': 'Premium Requests',
    'addVideo': 'Add Video to Channel',
    'pending': 'pending',
    'noRequests': 'No pending requests',
    'videos': 'videos published',
    'noVideos': 'No videos yet',
  },
  'fr': {
    'title': 'Panneau Admin',
    'requestsVerify': 'Demandes de vérification',
    'requestsPhoto': 'Demandes de changement de photo',
    'requestsPremium': 'Demandes Premium',
    'addVideo': 'Ajouter une vidéo',
    'pending': 'en attente',
    'noRequests': 'Aucune demande',
    'videos': 'vidéos publiées',
    'noVideos': 'Aucune vidéo',
  },
  'ur': {
    'title': 'ایڈمن پینل',
    'requestsVerify': 'تصدیق کی درخواستیں',
    'requestsPhoto': 'تصویر تبدیلی کی درخواستیں',
    'requestsPremium': 'پریمیم درخواستیں',
    'addVideo': 'چینل میں ویڈیو شامل کریں',
    'pending': 'زیر التواء',
    'noRequests': 'کوئی درخواست نہیں',
    'videos': 'ویڈیوز شائع',
    'noVideos': 'ابھی کوئی ویڈیو نہیں',
  },
  'ne': {
    'title': 'एडमिन प्यानल',
    'requestsVerify': 'प्रमाणीकरण अनुरोधहरू',
    'requestsPhoto': 'फोटो परिवर्तन अनुरोधहरू',
    'requestsPremium': 'प्रिमियम अनुरोधहरू',
    'addVideo': 'च्यानलमा भिडियो थप्नुहोस्',
    'pending': 'पर्खाइमा',
    'noRequests': 'कुनै अनुरोध छैन',
    'videos': 'भिडियो प्रकाशित',
    'noVideos': 'अझै कुनै भिडियो छैन',
  },
  'id': {
    'title': 'Panel Admin',
    'requestsVerify': 'Permintaan Verifikasi',
    'requestsPhoto': 'Permintaan Ubah Foto',
    'requestsPremium': 'Permintaan Premium',
    'addVideo': 'Tambah Video',
    'pending': 'tertunda',
    'noRequests': 'Tidak ada permintaan',
    'videos': 'video dipublikasikan',
    'noVideos': 'Belum ada video',
  },
  'ms': {
    'title': 'Panel Admin',
    'requestsVerify': 'Permintaan Pengesahan',
    'requestsPhoto': 'Permintaan Tukar Foto',
    'requestsPremium': 'Permintaan Premium',
    'addVideo': 'Tambah Video',
    'pending': 'tertunda',
    'noRequests': 'Tiada permintaan',
    'videos': 'video diterbitkan',
    'noVideos': 'Belum ada video',
  },
};

String _ap(String key) {
  final m = _apTr[appState.languageCode] ?? _apTr['ar']!;
  return m[key] ?? key;
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _pendingVerifications = 0;
  int _pendingPhotoUpdates = 0;
  int _pendingPremium = 0;
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
      premiumService.pendingCount(),
      youtubeService.count(),
    ]);
    if (mounted) {
      setState(() {
        _pendingVerifications = results[0];
        _pendingPhotoUpdates = results[1];
        _pendingPremium = results[2];
        _videosCount = results[3];
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

  Future<void> _openPremiumRequests() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PremiumRequestsScreen(),
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
                            color: AppColors.softGold,
                            iconSize: R.s(context, 22),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          Text(
                            _ap('title'),
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
                                          _ap('title'),
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
                                    title: _ap('requestsVerify'),
                                    subtitle: _pendingVerifications > 0
                                        ? '$_pendingVerifications ${_ap('pending')}'
                                        : _ap('noRequests'),
                                    badge: _pendingVerifications,
                                    onTap: _openRequests,
                                  ),
                                  SizedBox(height: R.s(context, 10)),

                                  // ===== 2) طلبات تغيير الصورة =====
                                  _AdminCard(
                                    icon: Icons.photo_camera_back_rounded,
                                    title: _ap('requestsPhoto'),
                                    subtitle: _pendingPhotoUpdates > 0
                                        ? '$_pendingPhotoUpdates ${_ap('pending')}'
                                        : _ap('noRequests'),
                                    badge: _pendingPhotoUpdates,
                                    onTap: _openPhotoRequests,
                                  ),
                                  SizedBox(height: R.s(context, 10)),

                                  // ===== 3) طلبات Premium =====
                                  _AdminCard(
                                    icon: Icons.workspace_premium_rounded,
                                    title: _ap('requestsPremium'),
                                    subtitle: _pendingPremium > 0
                                        ? '$_pendingPremium ${_ap('pending')}'
                                        : _ap('noRequests'),
                                    badge: _pendingPremium,
                                    onTap: _openPremiumRequests,
                                  ),
                                  SizedBox(height: R.s(context, 10)),

                                  // ===== 4) إضافة فيديو =====
                                  _AdminCard(
                                    icon: Icons.play_circle_fill_rounded,
                                    title: _ap('addVideo'),
                                    subtitle: _videosCount > 0
                                        ? '$_videosCount ${_ap('videos')}'
                                        : _ap('noVideos'),
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
          ),
        );
      },
    );
  }
}

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
