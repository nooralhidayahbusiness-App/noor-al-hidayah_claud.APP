import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/user_service.dart';
import '../services/verification_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class VerificationRequestScreen extends StatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  State<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState
    extends State<VerificationRequestScreen> {
  Uint8List? _pickedBytes;
  bool _sending = false;
  bool _loading = true;
  String _currentStatus = 'none'; // none | pending | verified
  String _currentType = 'none'; // none | user | me | owner

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await userService.loadProfile();
      final type = (profile['verifiedType'] as String?) ?? 'none';
      final verified = (profile['verified'] as bool?) ?? false;

      String status = 'none';
      if (verified && (type == 'user' || type == 'me' || type == 'owner')) {
        status = 'verified';
      } else {
        final pending = await verificationService.hasPendingRequest();
        if (pending) status = 'pending';
      }

      if (mounted) {
        setState(() {
          _currentStatus = status;
          _currentType = type;
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
      if (mounted) {
        setState(() => _pickedBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('${appState.tr('verificationPhotoRequired')}: $e',
            error: true);
      }
    }
  }

  Future<void> _send() async {
    if (_pickedBytes == null) {
      _showSnack(appState.tr('verificationPhotoRequired'), error: true);
      return;
    }

    setState(() => _sending = true);
    try {
      final base64Str = base64Encode(_pickedBytes!);
      final name = profileState.name.isEmpty
          ? 'User'
          : profileState.name;
      final gender = profileState.avatar ?? 'man';

      await verificationService.submitRequest(
        photoBase64: base64Str,
        name: name,
        gender: gender,
      );

      if (mounted) {
        _showSnack(appState.tr('verificationSent'));
        await _load();
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
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
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('verificationRequest'),
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
                    : _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // حالة: موثّق مسبقاً
    if (_currentStatus == 'verified') {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(R.s(context, 24)),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.gold,
                  size: R.s(context, 60),
                ),
                SizedBox(height: R.s(context, 12)),
                Text(
                  appState.tr('verificationAlreadyVerified'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
                SizedBox(height: R.s(context, 8)),
                Text(
                  _currentType == 'me' || _currentType == 'owner'
                      ? '⭐ ${appState.tr('adminApproveMe')}'
                      : '✓ ${appState.tr('adminApproveUser')}',
                  style: TextStyle(
                    fontSize: R.f(context, 13),
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // حالة: قيد المراجعة
    if (_currentStatus == 'pending') {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(R.s(context, 24)),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.gold,
                  size: R.s(context, 60),
                ),
                SizedBox(height: R.s(context, 12)),
                Text(
                  appState.tr('verificationPending'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
                SizedBox(height: R.s(context, 8)),
                Text(
                  appState.tr('verificationPendingDesc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 12.5),
                    color: AppColors.cream.withValues(alpha: 0.75),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // حالة: غير موثّق → نموذج
    return ListView(
      padding: EdgeInsets.all(R.s(context, 20)),
      children: [
        GlassCard(
          child: Column(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.gold,
                size: R.s(context, 54),
              ),
              SizedBox(height: R.s(context, 12)),
              Text(
                appState.tr('verificationRequest'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGold,
                ),
              ),
              SizedBox(height: R.s(context, 8)),
              Text(
                appState.tr('verificationRequestDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 12.5),
                  color: AppColors.cream.withValues(alpha: 0.75),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: R.s(context, 20)),

        // اختيار الصورة
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: R.s(context, 200),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: _pickedBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.gold,
                        size: R.s(context, 46),
                      ),
                      SizedBox(height: R.s(context, 10)),
                      Text(
                        appState.tr('verificationUploadPhoto'),
                        style: TextStyle(
                          fontSize: R.f(context, 13),
                          color: AppColors.softGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.memory(
                      _pickedBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),

        SizedBox(height: R.s(context, 22)),

        // زر الإرسال
        ElevatedButton.icon(
          onPressed: _sending ? null : _send,
          icon: _sending
              ? SizedBox(
                  width: R.s(context, 18),
                  height: R.s(context, 18),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.deepGreen,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: R.s(context, 20),
                ),
          label: Text(
            appState.tr('verificationSend'),
            style: TextStyle(
              fontSize: R.f(context, 15),
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.deepGreen,
            minimumSize: Size.fromHeight(R.s(context, 56)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 6,
            shadowColor: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
