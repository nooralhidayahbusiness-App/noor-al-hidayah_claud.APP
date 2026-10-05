import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/community_notification_service.dart';
import '../../services/verification_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _prTr = {
  'ar': {
    'title': 'طلبات تغيير الصورة',
    'empty': 'لا توجد طلبات حالياً',
    'current': 'الحالية',
    'proposed': 'المقترحة',
    'approve': 'موافقة',
    'reject': 'رفض',
    'approved': 'تمت الموافقة ✓',
    'rejected': 'تم الرفض',
    'error': 'خطأ',
    'user': 'مستخدم',
  },
  'en': {
    'title': 'Photo Change Requests',
    'empty': 'No requests currently',
    'current': 'Current',
    'proposed': 'Proposed',
    'approve': 'Approve',
    'reject': 'Reject',
    'approved': 'Approved ✓',
    'rejected': 'Rejected',
    'error': 'Error',
    'user': 'User',
  },
  'fr': {
    'title': 'Demandes de changement de photo',
    'empty': 'Aucune demande actuellement',
    'current': 'Actuelle',
    'proposed': 'Proposée',
    'approve': 'Approuver',
    'reject': 'Refuser',
    'approved': 'Approuvée ✓',
    'rejected': 'Refusée',
    'error': 'Erreur',
    'user': 'Utilisateur',
  },
  'ur': {
    'title': 'تصویر تبدیلی کی درخواستیں',
    'empty': 'ابھی کوئی درخواست نہیں',
    'current': 'موجودہ',
    'proposed': 'تجویز کردہ',
    'approve': 'منظور',
    'reject': 'مسترد',
    'approved': 'منظور ✓',
    'rejected': 'مسترد',
    'error': 'خرابی',
    'user': 'صارف',
  },
  'ne': {
    'title': 'फोटो परिवर्तन अनुरोधहरू',
    'empty': 'अहिले कुनै अनुरोध छैन',
    'current': 'हालको',
    'proposed': 'प्रस्तावित',
    'approve': 'स्वीकार',
    'reject': 'अस्वीकार',
    'approved': 'स्वीकृत ✓',
    'rejected': 'अस्वीकृत',
    'error': 'त्रुटि',
    'user': 'प्रयोगकर्ता',
  },
  'id': {
    'title': 'Permintaan Ubah Foto',
    'empty': 'Tidak ada permintaan saat ini',
    'current': 'Saat ini',
    'proposed': 'Diusulkan',
    'approve': 'Setujui',
    'reject': 'Tolak',
    'approved': 'Disetujui ✓',
    'rejected': 'Ditolak',
    'error': 'Kesalahan',
    'user': 'Pengguna',
  },
  'ms': {
    'title': 'Permintaan Tukar Foto',
    'empty': 'Tiada permintaan sekarang',
    'current': 'Semasa',
    'proposed': 'Dicadangkan',
    'approve': 'Luluskan',
    'reject': 'Tolak',
    'approved': 'Diluluskan ✓',
    'rejected': 'Ditolak',
    'error': 'Ralat',
    'user': 'Pengguna',
  },
};

String _pr(String key) {
  final m = _prTr[appState.languageCode] ?? _prTr['ar']!;
  return m[key] ?? key;
}

class PhotoRequestsScreen extends StatefulWidget {
  const PhotoRequestsScreen({super.key});

  @override
  State<PhotoRequestsScreen> createState() => _PhotoRequestsScreenState();
}

class _PhotoRequestsScreenState extends State<PhotoRequestsScreen> {
  final CommunityNotificationService _notif =
      CommunityNotificationService();
  bool _loading = true;
  List<PhotoUpdateRequest> _requests = [];
  String? _busyUid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await verificationService.loadPendingPhotoUpdates();
    if (mounted) {
      setState(() {
        _requests = list;
        _loading = false;
      });
    }
  }

  Future<void> _approve(PhotoUpdateRequest r) async {
    setState(() => _busyUid = r.uid);
    try {
      await verificationService.approvePhotoChange(targetUid: r.uid);
      await _notif.sendFromAdmin(
        toUid: r.uid,
        type: 'photo_approved',
      );
      if (mounted) _snack(_pr('approved'));
      await _load();
    } catch (e) {
      if (mounted) _snack('${_pr('error')}: $e', error: true);
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  Future<void> _reject(PhotoUpdateRequest r) async {
    setState(() => _busyUid = r.uid);
    try {
      await verificationService.rejectPhotoChange(targetUid: r.uid);
      await _notif.sendFromAdmin(
        toUid: r.uid,
        type: 'photo_rejected',
      );
      if (mounted) _snack(_pr('rejected'));
      await _load();
    } catch (e) {
      if (mounted) _snack('${_pr('error')}: $e', error: true);
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              error ? const Color(0xFF5C1F1F) : AppColors.deepGreen,
          content: Text(
            msg,
            style: const TextStyle(color: AppColors.cream),
          ),
        ),
      );
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
                            _pr('title'),
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
                          : _requests.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(R.s(context, 20)),
                                    child: Text(
                                      _pr('empty'),
                                      style: TextStyle(
                                        fontSize: R.f(context, 14),
                                        color: AppColors.cream
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(R.s(context, 14)),
                                  itemCount: _requests.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: EdgeInsets.only(
                                        bottom: R.s(context, 10)),
                                    child: _RequestCard(
                                      request: _requests[i],
                                      busy: _busyUid == _requests[i].uid,
                                      onApprove: () =>
                                          _approve(_requests[i]),
                                      onReject: () =>
                                          _reject(_requests[i]),
                                    ),
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

class _RequestCard extends StatelessWidget {
  final PhotoUpdateRequest request;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final date = request.requestedDate;
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.gold,
                size: R.s(context, 18),
              ),
              SizedBox(width: R.s(context, 6)),
              Expanded(
                child: Text(
                  request.name.isEmpty ? _pr('user') : request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 3)),
          Text(
            request.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: R.s(context, 3)),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.gold.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: R.s(context, 12)),
          Row(
            children: [
              Expanded(
                child: _PhotoBox(
                  label: _pr('current'),
                  photoBase64: request.oldPhotoBase64,
                  isNew: false,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.s(context, 8)),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.gold,
                  size: R.s(context, 24),
                ),
              ),
              Expanded(
                child: _PhotoBox(
                  label: _pr('proposed'),
                  photoBase64: request.newPhotoBase64,
                  isNew: true,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 14)),
          if (busy)
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.check_rounded,
                    label: _pr('approve'),
                    color: AppColors.gold,
                    onTap: onApprove,
                  ),
                ),
                SizedBox(width: R.s(context, 6)),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.close_rounded,
                    label: _pr('reject'),
                    color: const Color(0xFFD32F2F),
                    onTap: onReject,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final String label;
  final String photoBase64;
  final bool isNew;

  const _PhotoBox({
    required this.label,
    required this.photoBase64,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 110);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.s(context, 8),
            vertical: R.s(context, 3),
          ),
          decoration: BoxDecoration(
            color: (isNew ? AppColors.gold : AppColors.cream)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(R.s(context, 8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isNew ? AppColors.gold : AppColors.cream,
              fontSize: R.f(context, 10.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        ClipRRect(
          borderRadius: BorderRadius.circular(R.s(context, 12)),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(
                color: isNew
                    ? AppColors.gold
                    : AppColors.cream.withValues(alpha: 0.3),
                width: isNew ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(R.s(context, 12)),
            ),
            child: photoBase64.isEmpty
                ? Icon(
                    Icons.person,
                    color: AppColors.gold,
                    size: R.s(context, 40),
                  )
                : Image.memory(
                    base64Decode(photoBase64),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.person,
                      color: AppColors.gold,
                      size: R.s(context, 40),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 8),
          vertical: R.s(context, 12),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: R.s(context, 18)),
            SizedBox(width: R.s(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
