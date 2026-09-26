import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';

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

  Future<void> _changeAvatar() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(appState.tr('chooseAvatar'),
            style: const TextStyle(color: AppColors.softGold)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AvatarOption(
              icon: Icons.face_6,
              label: appState.tr('man'),
              selected: profileState.avatar == 'man',
              onTap: () => Navigator.pop(ctx, 'man'),
            ),
            _AvatarOption(
              icon: Icons.face_3,
              label: appState.tr('woman'),
              selected: profileState.avatar == 'woman',
              onTap: () => Navigator.pop(ctx, 'woman'),
            ),
          ],
        ),
      ),
    );
    if (choice != null) {
      await profileState.setAvatar(choice);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _changeAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.gold, width: 2),
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: Icon(
                                profileState.avatar == 'woman'
                                    ? Icons.face_3
                                    : Icons.face_6,
                                size: 65,
                                color: AppColors.gold,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit,
                                    size: 16, color: AppColors.deepGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        appState.tr('tapToChangeAvatar'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cream.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    GlassCard(
                      child: SwitchListTile(
                        value: _isPublic,
                        onChanged: (v) => setState(() => _isPublic = v),
                        activeColor: AppColors.gold,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.3),
                width: selected ? 3 : 1.5,
              ),
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Icon(icon, size: 42, color: AppColors.gold),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.gold : AppColors.cream,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
