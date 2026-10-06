import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/community_notification.dart';
import '../services/community_notification_service.dart';
import '../widgets/profile_avatar.dart';
import 'user_profile_screen.dart';

const Map<String, Map<String, String>> _localTr = {
  'ar': {
    'title': 'الإشعارات',
    'empty': 'لا توجد إشعارات بعد',
    'emptyDesc': 'ستظهر هنا عندما يتابعك أحد أو يتفاعل مع منشوراتك',
    'markAllRead': 'تحديد الكل كمقروء',
    'clearAll': 'حذف الكل',
    'clearAllConfirm': 'هل تريد حذف جميع الإشعارات؟',
    'followed': 'بدأ متابعتك',
    'liked': 'أعجب بمنشورك',
    'commented': 'علّق على منشورك',
    'reposted': 'أعاد نشر منشورك',
    'photo_approved': 'تمت الموافقة على صورة بروفايلك ✓',
    'photo_rejected': 'تم رفض طلب تغيير الصورة',
    'verified_me': '⭐ تم ترقيتك إلى موثّق مميز',
    'verified_user': '✓ تم توثيق حسابك',
    'verify_rejected': 'تم رفض طلب التوثيق',
    'new_video': 'نشر فيديو جديد في القناة 🎬',
    'new_reel': 'نشر ريل جديد في القناة 🎞️',
    'premium_approved': '🎉 تم تفعيل اشتراكك في Premium!',
    'premium_rejected': 'تم رفض طلب Premium، حاول مجدداً',
    'admin_sender': 'الإدارة',
  },
  'en': {
    'title': 'Notifications',
    'empty': 'No notifications yet',
    'emptyDesc':
        "You'll see them here when someone follows or interacts with your posts",
    'markAllRead': 'Mark all as read',
    'clearAll': 'Clear all',
    'clearAllConfirm': 'Delete all notifications?',
    'followed': 'started following you',
    'liked': 'liked your post',
    'commented': 'commented on your post',
    'reposted': 'reposted your post',
    'photo_approved': 'Your profile photo was approved ✓',
    'photo_rejected': 'Your photo change request was rejected',
    'verified_me': '⭐ You were upgraded to Premium Verified',
    'verified_user': '✓ Your account is now verified',
    'verify_rejected': 'Your verification request was rejected',
    'new_video': 'Published a new video 🎬',
    'new_reel': 'Published a new reel 🎞️',
    'premium_approved': '🎉 Your Premium subscription is active!',
    'premium_rejected': 'Premium request rejected, please try again',
    'admin_sender': 'Admin',
  },
  'fr': {
    'title': 'Notifications',
    'empty': 'Aucune notification',
    'emptyDesc':
        "Elles apparaîtront ici quand quelqu'un vous suit ou interagit avec vos posts",
    'markAllRead': 'Tout marquer comme lu',
    'clearAll': 'Tout effacer',
    'clearAllConfirm': 'Supprimer toutes les notifications ?',
    'followed': 'a commencé à vous suivre',
    'liked': 'a aimé votre post',
    'commented': 'a commenté votre post',
    'reposted': 'a reposté votre post',
    'photo_approved': 'Votre photo de profil a été approuvée ✓',
    'photo_rejected': 'Votre demande de changement de photo a été refusée',
    'verified_me': '⭐ Vous êtes passé en Vérifié Premium',
    'verified_user': '✓ Votre compte est maintenant vérifié',
    'verify_rejected': 'Votre demande de vérification a été refusée',
    'new_video': 'A publié une nouvelle vidéo 🎬',
    'new_reel': 'A publié un nouveau reel 🎞️',
    'premium_approved': '🎉 Votre abonnement Premium est actif !',
    'premium_rejected': 'Demande Premium refusée, réessayez',
    'admin_sender': 'Admin',
  },
  'ur': {
    'title': 'اطلاعات',
    'empty': 'ابھی کوئی اطلاع نہیں',
    'emptyDesc':
        'جب کوئی آپ کو فالو کرے یا آپ کی پوسٹ پر رد عمل دے تو یہاں دکھے گا',
    'markAllRead': 'سب کو پڑھا ہوا نشان زد کریں',
    'clearAll': 'سب حذف کریں',
    'clearAllConfirm': 'تمام اطلاعات حذف کریں؟',
    'followed': 'نے آپ کو فالو کیا',
    'liked': 'نے آپ کی پوسٹ لائک کی',
    'commented': 'نے آپ کی پوسٹ پر تبصرہ کیا',
    'reposted': 'نے آپ کی پوسٹ دوبارہ پوسٹ کی',
    'photo_approved': 'آپ کی پروفائل تصویر منظور ہو گئی ✓',
    'photo_rejected': 'تصویر تبدیلی کی درخواست مسترد',
    'verified_me': '⭐ پریمیم تصدیق شدہ میں اپ گریڈ',
    'verified_user': '✓ آپ کا اکاؤنٹ تصدیق شدہ',
    'verify_rejected': 'تصدیق کی درخواست مسترد',
    'new_video': 'چینل میں نئی ویڈیو 🎬',
    'new_reel': 'چینل میں نیا ریل 🎞️',
    'premium_approved': '🎉 آپ کی Premium سبسکرپشن فعال!',
    'premium_rejected': 'Premium درخواست مسترد، دوبارہ کوشش کریں',
    'admin_sender': 'ایڈمن',
  },
  'ne': {
    'title': 'सूचनाहरू',
    'empty': 'अझै कुनै सूचना छैन',
    'emptyDesc':
        'कसैले तपाईंलाई फलो गरे वा पोस्टमा प्रतिक्रिया दिए यहाँ देखिनेछ',
    'markAllRead': 'सबै पढेको चिन्ह लगाउनुहोस्',
    'clearAll': 'सबै मेट्नुहोस्',
    'clearAllConfirm': 'सबै सूचनाहरू मेट्ने?',
    'followed': 'ले तपाईंलाई फलो गरे',
    'liked': 'ले तपाईंको पोस्ट लाइक गरे',
    'commented': 'ले तपाईंको पोस्टमा टिप्पणी गरे',
    'reposted': 'ले तपाईंको पोस्ट पुनः पोस्ट गरे',
    'photo_approved': 'तपाईंको प्रोफाइल फोटो स्वीकृत ✓',
    'photo_rejected': 'फोटो परिवर्तन अनुरोध अस्वीकृत',
    'verified_me': '⭐ प्रिमियम प्रमाणितमा अपग्रेड',
    'verified_user': '✓ तपाईंको खाता प्रमाणित',
    'verify_rejected': 'प्रमाणीकरण अनुरोध अस्वीकृत',
    'new_video': 'च्यानलमा नयाँ भिडियो 🎬',
    'new_reel': 'च्यानलमा नयाँ रील 🎞️',
    'premium_approved': '🎉 तपाईंको Premium सदस्यता सक्रिय!',
    'premium_rejected': 'Premium अनुरोध अस्वीकृत, फेरि प्रयास गर्नुहोस्',
    'admin_sender': 'एडमिन',
  },
  'id': {
    'title': 'Notifikasi',
    'empty': 'Belum ada notifikasi',
    'emptyDesc':
        'Akan muncul di sini saat seseorang mengikuti atau berinteraksi',
    'markAllRead': 'Tandai semua dibaca',
    'clearAll': 'Hapus semua',
    'clearAllConfirm': 'Hapus semua notifikasi?',
    'followed': 'mulai mengikuti Anda',
    'liked': 'menyukai postingan Anda',
    'commented': 'mengomentari postingan Anda',
    'reposted': 'memposting ulang postingan Anda',
    'photo_approved': 'Foto profil Anda disetujui ✓',
    'photo_rejected': 'Permintaan ubah foto ditolak',
    'verified_me': '⭐ Anda diupgrade ke Verified Premium',
    'verified_user': '✓ Akun Anda terverifikasi',
    'verify_rejected': 'Permintaan verifikasi ditolak',
    'new_video': 'Video baru di saluran 🎬',
    'new_reel': 'Reel baru di saluran 🎞️',
    'premium_approved': '🎉 Langganan Premium Anda aktif!',
    'premium_rejected': 'Permintaan Premium ditolak, coba lagi',
    'admin_sender': 'Admin',
  },
  'ms': {
    'title': 'Pemberitahuan',
    'empty': 'Belum ada pemberitahuan',
    'emptyDesc':
        'Akan muncul di sini apabila seseorang mengikuti atau berinteraksi',
    'markAllRead': 'Tanda semua dibaca',
    'clearAll': 'Hapus semua',
    'clearAllConfirm': 'Hapus semua pemberitahuan?',
    'followed': 'mula mengikuti anda',
    'liked': 'menyukai catatan anda',
    'commented': 'mengulas catatan anda',
    'reposted': 'mencatat semula catatan anda',
    'photo_approved': 'Foto profil anda diluluskan ✓',
    'photo_rejected': 'Permintaan tukar foto ditolak',
    'verified_me': '⭐ Anda dinaikkan ke Verified Premium',
    'verified_user': '✓ Akaun anda disahkan',
    'verify_rejected': 'Permintaan pengesahan ditolak',
    'new_video': 'Video baru di saluran 🎬',
    'new_reel': 'Reel baru di saluran 🎞️',
    'premium_approved': '🎉 Langganan Premium anda aktif!',
    'premium_rejected': 'Permintaan Premium ditolak, cuba lagi',
    'admin_sender': 'Admin',
  },
};

String _tr(String key) {
  final m = _localTr[appState.languageCode] ?? _localTr['ar']!;
  return m[key] ?? key;
}

const Set<String> _communityTypes = {
  'follow',
  'like',
  'comment',
  'repost',
};

const Set<String> _adminTypes = {
  'photo_approved',
  'photo_rejected',
  'verified_me',
  'verified_user',
  'verify_rejected',
  'new_video',
  'new_reel',
  'premium_approved',
  'premium_rejected',
};

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final CommunityNotificationService _service =
      CommunityNotificationService();
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: Scaffold(
            backgroundColor: AppColors.deepGreen,
            appBar: _buildAppBar(),
            body: _uid == null
                ? _buildEmpty()
                : StreamBuilder<List<CommunityNotification>>(
                    stream: _service.stream(_uid!),
                    builder: (context, snap) {
                      if (snap.connectionState ==
                              ConnectionState.waiting &&
                          !snap.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return _buildError();
                      }
                      final notifs = snap.data ?? [];
                      if (notifs.isEmpty) return _buildEmpty();
                      return RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                        },
                        color: AppColors.gold,
                        backgroundColor: AppColors.green,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: R.s(context, 6),
                          ),
                          itemCount: notifs.length,
                          itemBuilder: (context, i) {
                            final n = notifs[i];
                            return _NotifTile(
                              notif: n,
                              onTap: () => _onTap(n),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _tr('title'),
        style: TextStyle(
          color: AppColors.softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_uid != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.softGold,
              size: R.s(context, 22),
            ),
            color: AppColors.green,
            onSelected: (v) {
              if (v == 'mark') {
                _service.markAllRead(_uid!);
              } else if (v == 'clear') {
                _confirmClear();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'mark',
                child: Row(
                  children: [
                    const Icon(
                      Icons.done_all,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tr('markAllRead'),
                      style: const TextStyle(color: AppColors.cream),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tr('clearAll'),
                      style: const TextStyle(color: AppColors.cream),
                    ),
                  ],
                ),
              ),
            ],
          ),
        SizedBox(width: R.s(context, 6)),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.s(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(R.s(context, 18)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.5),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Icon(
                Icons.notifications_none,
                color: AppColors.gold,
                size: R.s(context, 42),
              ),
            ),
            SizedBox(height: R.s(context, 14)),
            Text(
              _tr('empty'),
              style: TextStyle(
                color: AppColors.softGold,
                fontSize: R.f(context, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.s(context, 6)),
            Text(
              _tr('emptyDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.6),
                fontSize: R.f(context, 12),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          appState.tr('cUserDataError'),
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
      ),
    );
  }

  void _onTap(CommunityNotification n) {
    _service.markAllRead(_uid!);

    if (_communityTypes.contains(n.type)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(profileUid: n.fromUid),
        ),
      );
    }
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: appState.direction,
        child: AlertDialog(
          backgroundColor: AppColors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          title: Text(
            _tr('clearAll'),
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 15),
            ),
          ),
          content: Text(
            _tr('clearAllConfirm'),
            style: TextStyle(
              color: AppColors.cream,
              fontSize: R.f(context, 13),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                appState.tr('cancel'),
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.7),
                  fontSize: R.f(context, 13),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _tr('clearAll'),
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok == true && _uid != null) {
      await _service.clearAll(_uid!);
    }
  }
}

// ============================================================
// _NotifTile
// ============================================================
class _NotifTile extends StatelessWidget {
  final CommunityNotification notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  bool get _isAdmin => _adminTypes.contains(notif.type);
  bool get _isPremiumApproved => notif.type == 'premium_approved';
  bool get _isPremiumRejected => notif.type == 'premium_rejected';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 14),
          vertical: R.s(context, 10),
        ),
        color: _isPremiumApproved
            ? AppColors.gold.withValues(alpha: 0.12)
            : notif.isRead
                ? Colors.transparent
                : AppColors.gold.withValues(alpha: 0.08),
        child: Row(
          children: [
            _isPremiumApproved || _isPremiumRejected
                ? _PremiumAvatar(
                    size: R.s(context, 42),
                    highlight: _isPremiumApproved,
                  )
                : _isAdmin
                    ? _AdminAvatar(size: R.s(context, 42))
                    : ProfileAvatar(
                        email: '',
                        avatar: notif.fromAvatar,
                        size: R.s(context, 42),
                      ),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _isAdmin
                              ? _tr('admin_sender')
                              : (notif.fromName.isEmpty
                                  ? appState.tr('cUserNotFound')
                                  : notif.fromName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: R.f(context, 13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (notif.fromVerified || _isAdmin) ...[
                        SizedBox(width: R.s(context, 4)),
                        Icon(
                          _isAdmin
                              ? Icons.shield_rounded
                              : Icons.verified,
                          color: AppColors.gold,
                          size: R.s(context, 14),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: R.s(context, 2)),
                  Text(
                    _actionText(),
                    style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.75),
                      fontSize: R.f(context, 12),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: R.s(context, 2)),
                  Text(
                    _formatTime(notif.createdAt),
                    style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.45),
                      fontSize: R.f(context, 10.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _iconForType(),
              color: _colorForType(),
              size: R.s(context, 20),
            ),
          ],
        ),
      ),
    );
  }

  String _actionText() {
    switch (notif.type) {
      case 'follow':
        return _tr('followed');
      case 'like':
        return _tr('liked');
      case 'comment':
        return _tr('commented');
      case 'repost':
        return _tr('reposted');
      case 'photo_approved':
        return _tr('photo_approved');
      case 'photo_rejected':
        return _tr('photo_rejected');
      case 'verified_me':
        return _tr('verified_me');
      case 'verified_user':
        return _tr('verified_user');
      case 'verify_rejected':
        return _tr('verify_rejected');
      case 'new_video':
        return _tr('new_video');
      case 'new_reel':
        return _tr('new_reel');
      case 'premium_approved':
        return _tr('premium_approved');
      case 'premium_rejected':
        return _tr('premium_rejected');
      default:
        return notif.type;
    }
  }

  IconData _iconForType() {
    switch (notif.type) {
      case 'follow':
        return Icons.person_add_alt_1;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'repost':
        return Icons.repeat;
      case 'photo_approved':
        return Icons.check_circle_outline_rounded;
      case 'photo_rejected':
        return Icons.cancel_outlined;
      case 'verified_me':
        return Icons.workspace_premium_rounded;
      case 'verified_user':
        return Icons.verified_rounded;
      case 'verify_rejected':
        return Icons.gpp_bad_outlined;
      case 'new_video':
        return Icons.smart_display_rounded;
      case 'new_reel':
        return Icons.movie_filter_rounded;
      case 'premium_approved':
        return Icons.workspace_premium_rounded;
      case 'premium_rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorForType() {
    switch (notif.type) {
      case 'like':
        return const Color(0xFFE84E6A);
      case 'comment':
        return AppColors.gold;
      case 'repost':
        return AppColors.softGold;
      case 'photo_approved':
      case 'verified_user':
        return const Color(0xFF4CAF50);
      case 'photo_rejected':
      case 'verify_rejected':
      case 'premium_rejected':
        return Colors.redAccent;
      case 'verified_me':
        return const Color(0xFFFFA000);
      case 'new_video':
      case 'new_reel':
        return AppColors.gold;
      case 'premium_approved':
        return AppColors.gold;
      default:
        return AppColors.gold;
    }
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return appState.tr('cTimeNow');
    if (diff.inMinutes < 60) {
      return appState.trn('cTimeMinutesAgo', diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return appState.trn('cTimeHoursAgo', diff.inHours);
    }
    if (diff.inDays < 7) {
      return appState.trn('cTimeDaysAgo', diff.inDays);
    }
    if (diff.inDays < 30) {
      return appState.trn('cTimeWeeksAgo', (diff.inDays / 7).floor());
    }
    if (diff.inDays < 365) {
      return appState.trn('cTimeMonthsAgo', (diff.inDays / 30).floor());
    }
    return appState.trn('cTimeYearsAgo', (diff.inDays / 365).floor());
  }
}

// ============================================================
// _AdminAvatar
// ============================================================
class _AdminAvatar extends StatelessWidget {
  final double size;

  const _AdminAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.gold.withValues(alpha: 0.25),
            AppColors.deepGreen,
          ],
        ),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        Icons.shield_rounded,
        color: AppColors.gold,
        size: size * 0.5,
      ),
    );
  }
}

// ============================================================
// _PremiumAvatar — درع Premium (نبض للموافقة)
// ============================================================
class _PremiumAvatar extends StatefulWidget {
  final double size;
  final bool highlight;

  const _PremiumAvatar({
    required this.size,
    this.highlight = false,
  });

  @override
  State<_PremiumAvatar> createState() => _PremiumAvatarState();
}

class _PremiumAvatarState extends State<_PremiumAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.highlight) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.gold.withValues(alpha: 0.3),
                AppColors.deepGreen,
              ],
            ),
            border: Border.all(
              color: AppColors.gold,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.gold.withValues(alpha: 0.3 + 0.3 * t),
                blurRadius: 8 + 8 * t,
                spreadRadius: widget.highlight ? 1 : 0,
              ),
            ],
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.gold,
            size: widget.size * 0.5,
          ),
        );
      },
    );
  }
}
