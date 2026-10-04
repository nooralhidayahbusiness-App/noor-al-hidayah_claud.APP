import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/themed_background.dart';
import 'change_photo_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late bool _isPublic;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: profileState.name);
    _bio = TextEditingController(text: profileState.bio);
    _isPublic = profileState.isPublic;
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await profileState.updateProfile(
        newName: _name.text.trim(),
        newBio: _bio.text.trim(),
        newPublic: _isPublic,
      );
      if (!mounted) return;
      showAuthMessage(context, appState.tr('profileSaved'));
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        showAuthMessage(context, 'خطأ: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openChangePhoto() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChangePhotoScreen(),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
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
                      appState.tr('editProfile'),
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
                child: ListenableBuilder(
                  listenable: profileState,
                  builder: (context, _) {
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // ===== الصورة الحالية =====
                        Center(
                          child: GestureDetector(
                            onTap: _openChangePhoto,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ProfileAvatar(
                                  email: '',
                                  avatar: profileState.avatar ?? 'man',
                                  size: R.s(context, 100),
                                  photoBytes: profileState.photoBytes,
                                ),
                                Container(
                                  padding: EdgeInsets.all(R.s(context, 5)),
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: R.s(context, 14),
                                    color: AppColors.deepGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            appState.isArabic
                                ? 'اضغط على الصورة لتغييرها'
                                : 'Tap the photo to change it',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.cream.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== الاسم والنبذة =====
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              GoldTextField(
                                controller: _name,
                                label: appState.tr('name'),
                                icon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  if (v == null || v.trim().length < 2) {
                                    return appState.tr('errNameShort');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              GoldTextField(
                                controller: _bio,
                                label: appState.tr('bio'),
                                icon: Icons.info_outline_rounded,
                                textInputAction: TextInputAction.done,
                                validator: (v) {
                                  if ((v ?? '').length > 200) {
                                    return appState.tr('errBioLong');
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ===== خصوصية الحساب =====
                        GlassCard(
                          child: SwitchListTile(
                            value: _isPublic,
                            onChanged: (v) => setState(() => _isPublic = v),
                            activeThumbColor: AppColors.gold,
                            title: Text(
                              appState.tr('profileVisibility'),
                              style: const TextStyle(
                                color: AppColors.cream,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              appState.tr(_isPublic ? 'public' : 'private'),
                              style: TextStyle(
                                color: AppColors.cream.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        GoldButton(
                          label: appState.tr('save'),
                          loading: _saving,
                          onPressed: _save,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
