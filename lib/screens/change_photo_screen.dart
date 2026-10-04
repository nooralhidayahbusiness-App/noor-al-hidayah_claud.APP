import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/user_brief.dart';
import '../services/auth_service.dart';
import '../services/verification_service.dart';
import '../widgets/glass_card.dart';

const Map<String, Map<String, String>> _cpTr = {
  'ar': {
    'title': 'تغيير صورة البروفايل',
    'currentPhoto': 'الصورة الحالية',
    'uploadPhoto': 'رفع صورة',
    'changePhoto': 'تغيير الصورة',
    'pendingTitle': 'طلبك قيد المراجعة',
    'pendingBody': 'سيتم مراجعة صورتك الجديدة وردّ عليك قريباً',
    'pendingNote': 'لا يمكنك رفع صورة أخرى حتى يتم الرد',
    'cooldownTitle': 'لا يمكن التغيير الآن',
    'cooldownBody': 'متبقي {n} ساعة للتغيير التالي',
    'verifiedWarning': 'أنت موثّق — أي تغيير يحتاج موافقة المالك',
    'saveSuccess': 'تم حفظ التغيير',
    'sendSuccess': 'تم إرسال طلب التغيير',
    'errorGeneric': 'حدث خطأ',
    'confirm': 'موافق',
    'cancel': 'إلغاء',
    'removePhoto': 'إزالة الصورة',
    'removeConfirm': 'هل تريد الرجوع لرمز افتراضي؟',
    'verifiedCantRemove': 'أنت موثق — لا يمكن إزالة الصورة إلا بإلغاء التوثيق من لوحة التحكم',
    'ownerMode': 'وضع المالك — بلا قيود',
  },
  'en': {
    'title': 'Change Profile Photo',
    'currentPhoto': 'Current photo',
    'uploadPhoto': 'Upload photo',
    'changePhoto': 'Change photo',
    'pendingTitle': 'Your request is under review',
    'pendingBody': 'Your new photo will be reviewed soon',
    'pendingNote': 'You cannot upload another until reviewed',
    'cooldownTitle': 'Cannot change now',
    'cooldownBody': '{n} hours until next change',
    'verifiedWarning': 'You are verified — changes require owner approval',
    'saveSuccess': 'Change saved',
    'sendSuccess': 'Change request sent',
    'errorGeneric': 'Error occurred',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'removePhoto': 'Remove photo',
    'removeConfirm': 'Return to default symbol?',
    'verifiedCantRemove': 'You are verified — cannot remove photo without revoking',
    'ownerMode': 'Owner mode — unlimited',
  },
  'fr': {
    'title': 'Changer la photo de profil',
    'currentPhoto': 'Photo actuelle',
    'uploadPhoto': 'Télécharger une photo',
    'changePhoto': 'Changer la photo',
    'pendingTitle': 'Votre demande est en cours',
    'pendingBody': 'Votre nouvelle photo sera examinée',
    'pendingNote': 'Vous ne pouvez pas en télécharger une autre',
    'cooldownTitle': 'Impossible maintenant',
    'cooldownBody': '{n} heures avant le prochain changement',
    'verifiedWarning': 'Vous êtes vérifié — les changements nécessitent une approbation',
    'saveSuccess': 'Modification enregistrée',
    'sendSuccess': 'Demande envoyée',
    'errorGeneric': 'Erreur',
    'confirm': 'Confirmer',
    'cancel': 'Annuler',
    'removePhoto': 'Supprimer la photo',
    'removeConfirm': 'Revenir au symbole par défaut ?',
    'verifiedCantRemove': 'Vous êtes vérifié — impossible de supprimer',
    'ownerMode': 'Mode propriétaire — illimité',
  },
  'ur': {
    'title': 'پروفائل تصویر تبدیل کریں',
    'currentPhoto': 'موجودہ تصویر',
    'uploadPhoto': 'تصویر اپ لوڈ کریں',
    'changePhoto': 'تصویر تبدیل کریں',
    'pendingTitle': 'آپ کی درخواست زیر جائزہ ہے',
    'pendingBody': 'آپ کی نئی تصویر کا جائزہ لیا جائے گا',
    'pendingNote': 'جائزے تک دوسری اپ لوڈ نہیں کر سکتے',
    'cooldownTitle': 'ابھی تبدیل نہیں ہو سکتا',
    'cooldownBody': 'اگلی تبدیلی میں {n} گھنٹے باقی',
    'verifiedWarning': 'آپ تصدیق شدہ ہیں — تبدیلی کے لیے منظوری ضروری',
    'saveSuccess': 'تبدیلی محفوظ',
    'sendSuccess': 'درخواست بھیج دی',
    'errorGeneric': 'خرابی',
    'confirm': 'تصدیق',
    'cancel': 'منسوخ',
    'removePhoto': 'تصویر ہٹائیں',
    'removeConfirm': 'ڈیفالٹ علامت پر واپس؟',
    'verifiedCantRemove': 'آپ تصدیق شدہ ہیں — ہٹانا ممکن نہیں',
    'ownerMode': 'مالک موڈ — لامحدود',
  },
  'ne': {
    'title': 'प्रोफाइल फोटो परिवर्तन',
    'currentPhoto': 'हालको फोटो',
    'uploadPhoto': 'फोटो अपलोड',
    'changePhoto': 'फोटो परिवर्तन',
    'pendingTitle': 'तपाईंको अनुरोध समीक्षामा',
    'pendingBody': 'नयाँ फोटो चाँडै समीक्षा गरिनेछ',
    'pendingNote': 'समीक्षा नभएसम्म अर्को अपलोड गर्न सकिँदैन',
    'cooldownTitle': 'अहिले परिवर्तन सम्भव छैन',
    'cooldownBody': 'अर्को परिवर्तनमा {n} घण्टा बाँकी',
    'verifiedWarning': 'तपाईं प्रमाणित हुनुहुन्छ — परिवर्तनको लागि स्वीकृति चाहिन्छ',
    'saveSuccess': 'परिवर्तन सुरक्षित',
    'sendSuccess': 'अनुरोध पठाइयो',
    'errorGeneric': 'त्रुटि',
    'confirm': 'पुष्टि',
    'cancel': 'रद्द',
    'removePhoto': 'फोटो हटाउनुहोस्',
    'removeConfirm': 'पूर्वनिर्धारित प्रतीकमा फर्कने?',
    'verifiedCantRemove': 'तपाईं प्रमाणित हुनुहुन्छ — हटाउन सकिँदैन',
    'ownerMode': 'मालिक मोड — असीमित',
  },
  'id': {
    'title': 'Ubah Foto Profil',
    'currentPhoto': 'Foto saat ini',
    'uploadPhoto': 'Unggah foto',
    'changePhoto': 'Ubah foto',
    'pendingTitle': 'Permintaan Anda dalam tinjauan',
    'pendingBody': 'Foto baru akan ditinjau segera',
    'pendingNote': 'Tidak bisa mengunggah lain sampai ditinjau',
    'cooldownTitle': 'Tidak bisa ubah sekarang',
    'cooldownBody': '{n} jam sampai perubahan berikutnya',
    'verifiedWarning': 'Anda terverifikasi — perubahan butuh persetujuan',
    'saveSuccess': 'Perubahan disimpan',
    'sendSuccess': 'Permintaan dikirim',
    'errorGeneric': 'Terjadi kesalahan',
    'confirm': 'Konfirmasi',
    'cancel': 'Batal',
    'removePhoto': 'Hapus foto',
    'removeConfirm': 'Kembali ke simbol default?',
    'verifiedCantRemove': 'Anda terverifikasi — tidak bisa dihapus',
    'ownerMode': 'Mode pemilik — tanpa batas',
  },
  'ms': {
    'title': 'Tukar Foto Profil',
    'currentPhoto': 'Foto semasa',
    'uploadPhoto': 'Muat naik foto',
    'changePhoto': 'Tukar foto',
    'pendingTitle': 'Permintaan anda dalam semakan',
    'pendingBody': 'Foto baru akan disemak tidak lama lagi',
    'pendingNote': 'Tidak boleh muat naik lain sehingga disemak',
    'cooldownTitle': 'Tidak boleh tukar sekarang',
    'cooldownBody': '{n} jam sehingga perubahan seterusnya',
    'verifiedWarning': 'Anda disahkan — perubahan perlu kelulusan',
    'saveSuccess': 'Perubahan disimpan',
    'sendSuccess': 'Permintaan dihantar',
    'errorGeneric': 'Ralat',
    'confirm': 'Sah',
    'cancel': 'Batal',
    'removePhoto': 'Buang foto',
    'removeConfirm': 'Kembali ke simbol lalai?',
    'verifiedCantRemove': 'Anda disahkan — tidak boleh dibuang',
    'ownerMode': 'Mod pemilik — tanpa had',
  },
};

String _cp(String key) {
  final m = _cpTr[appState.languageCode] ?? _cpTr['ar']!;
  return m[key] ?? key;
}

class ChangePhotoScreen extends StatefulWidget {
  const ChangePhotoScreen({super.key});

  @override
  State<ChangePhotoScreen> createState() => _ChangePhotoScreenState();
}

class _ChangePhotoScreenState extends State<ChangePhotoScreen> {
  bool _loading = true;
  bool _busy = false;
  bool _hasPending = false;
  bool _isVerified = false;
  bool _isOwner = false;
  String _gender = 'man';
  String _currentPhotoBase64 = '';
  Uint8List? _pickedBytes;
  int _cooldownHours = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await authService.loadUserData() ?? {};
      final profile = (data['profile'] as Map?) ?? {};

      final email = (data['email'] as String?) ?? '';
      final isOwner = kOwnerEmails.contains(email.toLowerCase());

      final verified = (profile['verified'] as bool?) ?? false;
      final verifiedType = (profile['verifiedType'] as String?) ?? 'none';
      final isVerified = verified &&
          (verifiedType == 'me' ||
              verifiedType == 'user' ||
              verifiedType == 'owner' ||
              verifiedType == 'premium');

      // المالك: لا pending ولا cooldown
      final pending = isOwner
          ? false
          : await verificationService.hasPendingPhotoChange();
      final hours = isOwner
          ? 0
          : await verificationService.hoursUntilNextPhotoChange();

      if (mounted) {
        setState(() {
          _gender = (profile['gender'] as String?) ??
              (data['avatar'] as String?) ??
              'man';
          _currentPhotoBase64 =
              (profile['customPhotoBase64'] as String?) ?? '';
          _isVerified = isVerified;
          _isOwner = isOwner;
          _hasPending = pending;
          _cooldownHours = hours;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (mounted) setState(() => _pickedBytes = bytes);
    } catch (e) {
      _showSnack('${_cp('errorGeneric')}: $e', error: true);
    }
  }

  Future<void> _confirmChange() async {
    if (_pickedBytes == null) return;
    if (_hasPending) return;
    if (_cooldownHours > 0) return;

    setState(() => _busy = true);
    try {
      final base64Str = base64Encode(_pickedBytes!);

      // المالك أو غير الموثق → تطبيق فوري
      if (_isOwner || !_isVerified) {
        await verificationService.applyPhotoChangeImmediate(
          customPhotoBase64: base64Str,
          photoMode: 'custom',
        );
        await profileState.refresh();
        _showSnack(_cp('saveSuccess'));
      } else {
        // موثق غير مالك → طلب
        await verificationService.submitPhotoChangeRequest(
          oldPhotoBase64: _currentPhotoBase64,
          newPhotoBase64: base64Str,
        );
        _showSnack(_cp('sendSuccess'));
      }

      await _load();
      if (mounted) setState(() => _pickedBytes = null);
    } catch (e) {
      _showSnack('${_cp('errorGeneric')}: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _useSymbol() async {
    // الموثق غير المالك: ما يقدر يشيل صورته
    if (_isVerified && !_isOwner) {
      _showSnack(_cp('verifiedCantRemove'), error: true);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: appState.direction,
        child: AlertDialog(
          backgroundColor: AppColors.deepGreen,
          title: Text(
            _cp('removePhoto'),
            style: const TextStyle(color: AppColors.softGold),
          ),
          content: Text(
            _cp('removeConfirm'),
            style: const TextStyle(color: AppColors.cream),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                _cp('cancel'),
                style: const TextStyle(color: AppColors.softGold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                _cp('confirm'),
                style: const TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await verificationService.applyPhotoChangeImmediate(
        customPhotoBase64: null,
        photoMode: 'symbol',
      );
      await profileState.refresh();
      await _load();
      _showSnack(_cp('saveSuccess'));
    } catch (e) {
      _showSnack('${_cp('errorGeneric')}: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFF5C1F1F) : AppColors.deepGreen,
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
            body: _buildScaffold(context),
          ),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final bg = _gender == 'woman'
        ? 'assets/images/hijab.png'
        : 'assets/images/arabian.png';

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: AppColors.deepGreen),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.all(R.s(context, 16)),
                        children: [
                          if (_isOwner) ...[
                            _buildOwnerBadge(),
                            SizedBox(height: R.s(context, 12)),
                          ],
                          if (_isVerified && !_isOwner) ...[
                            _buildVerifiedNote(),
                            SizedBox(height: R.s(context, 12)),
                          ],
                          if (_hasPending) ...[
                            _buildPendingCard(),
                            SizedBox(height: R.s(context, 12)),
                          ],
                          if (_cooldownHours > 0 && !_hasPending) ...[
                            _buildCooldownCard(),
                            SizedBox(height: R.s(context, 12)),
                          ],
                          _buildCurrentSection(context, bg),
                          SizedBox(height: R.s(context, 16)),
                          _buildPickerSection(context),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _cp('title'),
        style: TextStyle(
          color: AppColors.softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOwnerBadge() {
    return Container(
      padding: EdgeInsets.all(R.s(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(R.s(context, 14)),
        border: Border.all(color: AppColors.gold, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.gold,
            size: R.s(context, 22),
          ),
          SizedBox(width: R.s(context, 10)),
          Expanded(
            child: Text(
              _cp('ownerMode'),
              style: TextStyle(
                color: AppColors.gold,
                fontSize: R.f(context, 13),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedNote() {
    return GlassCard(
      ornament: false,
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.gold,
            size: R.s(context, 20),
          ),
          SizedBox(width: R.s(context, 10)),
          Expanded(
            child: Text(
              _cp('verifiedWarning'),
              style: TextStyle(
                color: AppColors.cream,
                fontSize: R.f(context, 12),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.gold,
                size: R.s(context, 22),
              ),
              SizedBox(width: R.s(context, 10)),
              Expanded(
                child: Text(
                  _cp('pendingTitle'),
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 8)),
          Text(
            _cp('pendingBody'),
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.8),
              fontSize: R.f(context, 12),
              height: 1.5,
            ),
          ),
          SizedBox(height: R.s(context, 6)),
          Text(
            _cp('pendingNote'),
            style: TextStyle(
              color: AppColors.gold.withValues(alpha: 0.8),
              fontSize: R.f(context, 11),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCooldownCard() {
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: AppColors.gold,
                size: R.s(context, 22),
              ),
              SizedBox(width: R.s(context, 10)),
              Expanded(
                child: Text(
                  _cp('cooldownTitle'),
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 8)),
          Text(
            _cp('cooldownBody').replaceAll('{n}', '$_cooldownHours'),
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.8),
              fontSize: R.f(context, 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection(BuildContext context, String fallbackAsset) {
    final hasCustom = _currentPhotoBase64.isNotEmpty;
    return GlassCard(
      ornament: false,
      child: Column(
        children: [
          Text(
            _cp('currentPhoto'),
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 13),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          ClipOval(
            child: Container(
              width: R.s(context, 100),
              height: R.s(context, 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: hasCustom
                  ? Image.memory(
                      base64Decode(_currentPhotoBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        fallbackAsset,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      fallbackAsset,
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
      ),
    );
  }

  Widget _buildPickerSection(BuildContext context) {
    final disabled = _hasPending || _cooldownHours > 0 || _busy;

    return GlassCard(
      ornament: false,
      child: Column(
        children: [
          GestureDetector(
            onTap: disabled ? null : _pickImage,
            child: Container(
              height: R.s(context, 180),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(R.s(context, 16)),
                border: Border.all(
                  color: _pickedBytes != null
                      ? AppColors.gold
                      : AppColors.gold.withValues(alpha: 0.4),
                  width: _pickedBytes != null ? 2 : 1.2,
                ),
              ),
              child: _pickedBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: disabled
                              ? AppColors.cream.withValues(alpha: 0.3)
                              : AppColors.gold,
                          size: R.s(context, 42),
                        ),
                        SizedBox(height: R.s(context, 10)),
                        Text(
                          _cp('uploadPhoto'),
                          style: TextStyle(
                            color: disabled
                                ? AppColors.cream.withValues(alpha: 0.3)
                                : AppColors.softGold,
                            fontSize: R.f(context, 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(R.s(context, 15)),
                      child: Image.memory(
                        _pickedBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          if (_pickedBytes != null) ...[
            SizedBox(height: R.s(context, 14)),
            SizedBox(
              width: double.infinity,
              height: R.s(context, 50),
              child: ElevatedButton.icon(
                onPressed: disabled ? null : _confirmChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deepGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.s(context, 16)),
                  ),
                ),
                icon: _busy
                    ? SizedBox(
                        width: R.s(context, 18),
                        height: R.s(context, 18),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.deepGreen,
                        ),
                      )
                    : Icon(Icons.check_rounded, size: R.s(context, 20)),
                label: Text(
                  (_isVerified && !_isOwner)
                      ? _cp('sendSuccess')
                      : _cp('changePhoto'),
                  style: TextStyle(
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (_currentPhotoBase64.isNotEmpty) ...[
            SizedBox(height: R.s(context, 14)),
            SizedBox(
              width: double.infinity,
              height: R.s(context, 46),
              child: OutlinedButton.icon(
                onPressed: disabled ? null : _useSymbol,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.softGold,
                  side: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.s(context, 16)),
                  ),
                ),
                icon: Icon(
                  Icons.image_not_supported_outlined,
                  size: R.s(context, 18),
                ),
                label: Text(
                  _cp('removePhoto'),
                  style: TextStyle(
                    fontSize: R.f(context, 13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
