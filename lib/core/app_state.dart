import 'package:flutter/material.dart';

import 'strings_prayer.dart';

class AppState extends ChangeNotifier {
  bool _arabic = true;

  bool get isArabic => _arabic;

  TextDirection get direction =>
      _arabic ? TextDirection.rtl : TextDirection.ltr;

  void toggleLanguage() {
    _arabic = !_arabic;
    notifyListeners();
  }

  String tr(String key) {
    final table = _arabic ? _ar : _en;
    return table[key] ??
        (_arabic ? prayerStringsAr : prayerStringsEn)[key] ??
        key;
  }
}

final AppState appState = AppState();

const Map<String, String> _ar = {
  'appName': 'نور الهداية',
  'appNameSub': 'Noor Al-Hidayah',
  'tagline': 'رفيقك اليومي في الصلاة والقرآن والأذكار',
  'description':
      'تطبيق إسلامي شامل يجمع مواقيت الصلاة والقرآن الكريم والأذكار والأدعية في تجربة واحدة هادئة وموثوقة.',
  'getStarted': 'ابدأ الآن',
  'haveAccount': 'لدي حساب بالفعل',
  'switchLanguage': 'English',
  'credit': 'By Abdel Rahmen Ben Romdhan',
  'back': 'رجوع',
  'createAccount': 'إنشاء حساب',
  'createAccountSub': 'ابدأ رحلتك مع نور الهداية بحساب مجاني',
  'login': 'تسجيل الدخول',
  'loginSub': 'أهلًا بعودتك، أكمل رحلتك من حيث توقفت',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'showPassword': 'إظهار كلمة المرور',
  'hidePassword': 'إخفاء كلمة المرور',
  'haveAccountQ': 'لديك حساب بالفعل؟',
  'noAccountQ': 'ليس لديك حساب؟',
  'errEmailEmpty': 'أدخل بريدك الإلكتروني',
  'errEmailInvalid': 'البريد الإلكتروني غير صالح',
  'errPasswordEmpty': 'أدخل كلمة المرور',
  'errPasswordShort': 'كلمة المرور يجب ألا تقل عن 8 أحرف',
  'errPasswordMismatch': 'كلمتا المرور غير متطابقتين',
  'successDemo': 'البيانات صحيحة. ربط الحساب بالخادم قادم في الخطوة التالية.',
};

const Map<String, String> _en = {
  'appName': 'Noor Al-Hidayah',
  'appNameSub': 'نور الهداية',
  'tagline': 'Your daily companion for prayer, Quran and remembrance',
  'description':
      'A complete Islamic app bringing prayer times, the Holy Quran, adhkar and duas together in one calm, trustworthy experience.',
  'getStarted': 'Get Started',
  'haveAccount': 'I already have an account',
  'switchLanguage': 'العربية',
  'credit': 'By Abdel Rahmen Ben Romdhan',
  'back': 'Back',
  'createAccount': 'Create Account',
  'createAccountSub': 'Start your journey with Noor Al-Hidayah with a free account',
  'login': 'Sign In',
  'loginSub': 'Welcome back, continue where you left off',
  'email': 'Email',
  'password': 'Password',
  'confirmPassword': 'Confirm password',
  'showPassword': 'Show password',
  'hidePassword': 'Hide password',
  'haveAccountQ': 'Already have an account?',
  'noAccountQ': 'Don’t have an account?',
  'errEmailEmpty': 'Enter your email',
  'errEmailInvalid': 'This email is not valid',
  'errPasswordEmpty': 'Enter your password',
  'errPasswordShort': 'Password must be at least 8 characters',
  'errPasswordMismatch': 'Passwords do not match',
  'successDemo': 'Details look good. Connecting accounts to the server comes in the next step.',
};
