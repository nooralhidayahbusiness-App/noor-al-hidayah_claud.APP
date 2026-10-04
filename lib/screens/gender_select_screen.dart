import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';

// ============ ترجمات هذه الشاشة (محلية) ============
const Map<String, Map<String, String>> _gsTr = {
  'ar': {
    'title': 'أكمل ملفك الشخصي',
    'subtitle': 'املأ البيانات التالية للبدء في استخدام التطبيق',
    'firstName': 'الاسم الأول',
    'lastName': 'اسم العائلة',
    'gender': 'الجنس',
    'male': 'ذكر',
    'female': 'أنثى',
    'country': 'الجنسية (اختياري)',
    'continue': 'متابعة',
    'errFirstName': 'أدخل اسمك الأول',
    'errLastName': 'أدخل اسم العائلة',
    'errGender': 'اختر الجنس',
    'errSave': 'تعذّر الحفظ، حاول مرة أخرى',
  },
  'en': {
    'title': 'Complete your profile',
    'subtitle': 'Fill in the following details to get started',
    'firstName': 'First name',
    'lastName': 'Last name',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'country': 'Nationality (optional)',
    'continue': 'Continue',
    'errFirstName': 'Enter your first name',
    'errLastName': 'Enter your last name',
    'errGender': 'Choose your gender',
    'errSave': 'Save failed, please try again',
  },
  'fr': {
    'title': 'Complétez votre profil',
    'subtitle': 'Remplissez les détails suivants pour commencer',
    'firstName': 'Prénom',
    'lastName': 'Nom',
    'gender': 'Genre',
    'male': 'Homme',
    'female': 'Femme',
    'country': 'Nationalité (optionnel)',
    'continue': 'Continuer',
    'errFirstName': 'Entrez votre prénom',
    'errLastName': 'Entrez votre nom',
    'errGender': 'Choisissez votre genre',
    'errSave': 'Échec de l\'enregistrement',
  },
  'ur': {
    'title': 'اپنی پروفائل مکمل کریں',
    'subtitle': 'شروع کرنے کے لیے درج ذیل تفصیلات بھریں',
    'firstName': 'پہلا نام',
    'lastName': 'خاندانی نام',
    'gender': 'جنس',
    'male': 'مرد',
    'female': 'عورت',
    'country': 'قومیت (اختیاری)',
    'continue': 'جاری رکھیں',
    'errFirstName': 'اپنا پہلا نام درج کریں',
    'errLastName': 'اپنا خاندانی نام درج کریں',
    'errGender': 'اپنی جنس منتخب کریں',
    'errSave': 'محفوظ نہیں ہو سکا',
  },
  'ne': {
    'title': 'आफ्नो प्रोफाइल पूरा गर्नुहोस्',
    'subtitle': 'सुरु गर्न तलका विवरणहरू भर्नुहोस्',
    'firstName': 'पहिलो नाम',
    'lastName': 'थर',
    'gender': 'लिङ्ग',
    'male': 'पुरुष',
    'female': 'महिला',
    'country': 'राष्ट्रियता (वैकल्पिक)',
    'continue': 'जारी राख्नुहोस्',
    'errFirstName': 'आफ्नो पहिलो नाम प्रविष्ट गर्नुहोस्',
    'errLastName': 'आफ्नो थर प्रविष्ट गर्नुहोस्',
    'errGender': 'आफ्नो लिङ्ग छान्नुहोस्',
    'errSave': 'सुरक्षित गर्न सकिएन',
  },
  'id': {
    'title': 'Lengkapi profil Anda',
    'subtitle': 'Isi detail berikut untuk memulai',
    'firstName': 'Nama depan',
    'lastName': 'Nama belakang',
    'gender': 'Jenis kelamin',
    'male': 'Pria',
    'female': 'Wanita',
    'country': 'Kebangsaan (opsional)',
    'continue': 'Lanjutkan',
    'errFirstName': 'Masukkan nama depan Anda',
    'errLastName': 'Masukkan nama belakang Anda',
    'errGender': 'Pilih jenis kelamin',
    'errSave': 'Gagal menyimpan',
  },
  'ms': {
    'title': 'Lengkapkan profil anda',
    'subtitle': 'Isi butiran berikut untuk bermula',
    'firstName': 'Nama pertama',
    'lastName': 'Nama keluarga',
    'gender': 'Jantina',
    'male': 'Lelaki',
    'female': 'Wanita',
    'country': 'Kewarganegaraan (pilihan)',
    'continue': 'Teruskan',
    'errFirstName': 'Masukkan nama pertama anda',
    'errLastName': 'Masukkan nama keluarga anda',
    'errGender': 'Pilih jantina anda',
    'errSave': 'Gagal menyimpan',
  },
};

String _g(String key) {
  final m = _gsTr[appState.languageCode] ?? _gsTr['ar']!;
  return m[key] ?? key;
}

class GenderSelectScreen extends StatefulWidget {
  const GenderSelectScreen({super.key});

  @override
  State<GenderSelectScreen> createState() => _GenderSelectScreenState();
}

class _GenderSelectScreenState extends State<GenderSelectScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _country = TextEditingController();
  String _gender = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // لو مستخدم Google → نعبّي الاسم الأول من displayName
    final user = authService.currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      _firstName.text = parts.first;
      if (parts.length > 1) {
        _lastName.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final fn = _firstName.text.trim();
    final ln = _lastName.text.trim();

    if (fn.isEmpty) {
      showAuthMessage(context, _g('errFirstName'), error: true);
      return;
    }
    if (ln.isEmpty) {
      showAuthMessage(context, _g('errLastName'), error: true);
      return;
    }
    if (_gender.isEmpty) {
      showAuthMessage(context, _g('errGender'), error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final fullName = '$fn $ln';

      await authService.saveUserData({
        'avatar': _gender, // backward compat
        'profile': {
          'name': fullName,
          'gender': _gender,
          'country': _country.text.trim(),
          'photoMode': 'symbol',
          'setupComplete': true,
        },
      });

      // حدّث ProfileState
      await userService.saveProfile(name: fullName);

      if (!mounted) return;
      await goAfterAuth(context);
    } catch (e) {
      if (mounted) {
        showAuthMessage(context, _g('errSave'), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: AuthScaffold(
            title: _g('title'),
            subtitle: _g('subtitle'),
            footer: const SizedBox.shrink(),
            child: Column(
              children: [
                GoldTextField(
                  controller: _firstName,
                  label: _g('firstName'),
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _lastName,
                  label: _g('lastName'),
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _country,
                  label: _g('country'),
                  icon: Icons.public_rounded,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: R.s(context, 8)),
                    child: Text(
                      _g('gender'),
                      style: TextStyle(
                        fontSize: R.f(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        label: _g('male'),
                        imagePath: 'assets/images/arabian.png',
                        selected: _gender == 'man',
                        onTap: () => setState(() => _gender = 'man'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderCard(
                        label: _g('female'),
                        imagePath: 'assets/images/hijab.png',
                        selected: _gender == 'woman',
                        onTap: () => setState(() => _gender = 'woman'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                GoldButton(
                  label: _g('continue'),
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// _GenderCard — بطاقة اختيار الجنس
// ============================================================
class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 110);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(vertical: R.s(context, 12)),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(R.s(context, 18)),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            ClipOval(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person_rounded,
                    color: AppColors.gold,
                    size: 50,
                  ),
                ),
              ),
            ),
            SizedBox(height: R.s(context, 8)),
            Text(
              label,
              style: TextStyle(
                fontSize: R.f(context, 14),
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? AppColors.gold : AppColors.cream,
              ),
            ),
            if (selected) ...[
              SizedBox(height: R.s(context, 4)),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.gold,
                size: R.s(context, 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
