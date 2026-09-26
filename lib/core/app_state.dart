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
// شاشة الحساب والملف الشخصي
'noName': 'بدون اسم',
'points': 'نقاط',
'level': 'مستوى',
'streak': 'أيام متتالية',
'levelProgress': 'التقدم للمستوى القادم',
'editProfile': 'تعديل الملف الشخصي',
'signOut': 'تسجيل الخروج',
'signOutConfirmTitle': 'تسجيل الخروج؟',
'signOutConfirmBody': 'هل أنت متأكد من تسجيل الخروج من الحساب؟',
'cancel': 'إلغاء',
'public': 'عام',
'private': 'خاص',
'profileVisibility': 'ظهور الملف الشخصي',
'name': 'الاسم',
'bio': 'نبذة تعريفية',
'save': 'حفظ',
'profileSaved': 'تم حفظ التعديلات بنجاح',
'chooseAvatar': 'اختر الصورة الرمزية',
'man': 'رجل',
'woman': 'امرأة',
'tapToChangeAvatar': 'اضغط على الصورة لتغييرها',
'errNameShort': 'الاسم يجب أن يكون حرفين على الأقل',
'errBioLong': 'النبذة طويلة جداً (200 حرف كحد أقصى)',
// التحديات والكوبون
'tabChallenge': 'التحديات',
'challenges': 'التحديات',
'dailyChallengeTitle': 'تحدي اليوم',
'dailyChallengeDesc': '5 أسئلة تتجدد كل يوم. كل إجابة صحيحة = 20 نقطة',
'startChallenge': 'ابدأ التحدي',
'redeemCoupon': 'استبدال كوبون',
'redeemCouponDesc': 'أدخل كود الخصم للحصول على نقاط',
'enterCouponCode': 'أدخل الكود...',
'redeem': 'استبدال',
'couponSuccess': 'تم! حصلت على 1000 نقطة 🎉',
'couponInvalid': 'الكود غير صالح',
'settings': 'الإعدادات',
'couponAlreadyUsed': 'لقد استخدمت هذا الكود مسبقاً',
'verified': 'موثوق',
'getVerified': 'توثيق الحساب',
'getVerifiedDesc': 'أضف صورة شخصية وفحص وجه للحصول على شعار التوثيق',
'verifyNow': 'وثّق حسابي الآن',
'verifiedDone': '🎉 تم توثيق حسابك!',
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
'noName': 'No name',
'points': 'Points',
'level': 'Level',
'streak': 'Day streak',
'levelProgress': 'Progress to next level',
'editProfile': 'Edit Profile',
'signOut': 'Sign Out',
'signOutConfirmTitle': 'Sign out?',
'signOutConfirmBody': 'Are you sure you want to sign out?',
'cancel': 'Cancel',
'public': 'Public',
'private': 'Private',
'profileVisibility': 'Profile visibility',
'name': 'Name',
'bio': 'Bio',
'save': 'Save',
'profileSaved': 'Changes saved successfully',
'chooseAvatar': 'Choose avatar',
'man': 'Man',
'woman': 'Woman',
'tapToChangeAvatar': 'Tap the image to change it',
'errNameShort': 'Name must be at least 2 characters',
'errBioLong': 'Bio is too long (max 200 characters)',
'tabChallenge': 'Challenges',
'challenges': 'Challenges',
'dailyChallengeTitle': 'Daily Challenge',
'dailyChallengeDesc': '5 questions renew daily. 20 points per correct answer.',
'startChallenge': 'Start Challenge',
'redeemCoupon': 'Redeem Coupon',
'redeemCouponDesc': 'Enter a coupon code to get points',
'enterCouponCode': 'Enter code...',
'redeem': 'Redeem',
'couponSuccess': 'Success! You got 1000 points 🎉',
'couponInvalid': 'Invalid code',
'settings': 'Settings',
'couponAlreadyUsed': 'You already used this coupon',
'verified': 'Verified',
'getVerified': 'Get Verified',
'getVerifiedDesc': 'Add a profile picture and face scan to get the badge',
'verifyNow': 'Verify My Account',
'verifiedDone': '🎉 Your account is verified!',
};
