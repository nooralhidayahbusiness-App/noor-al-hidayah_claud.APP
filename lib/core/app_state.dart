import 'package:flutter/material.dart';

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
    return table[key] ?? key;
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
  'comingSoon': 'هذه الصفحة قادمة في الخطوة التالية',
  'credit': 'By Abdel Rahmen Ben Romdhan',
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
  'comingSoon': 'This page arrives in the next step',
  'credit': 'By Abdel Rahmen Ben Romdhan',
};
