/// آية قرآنية للتدريب.
class LearningVerse {
  final String id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String textAr;
  final String textEn;
  final String audioUrl;

  const LearningVerse({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.textAr,
    required this.textEn,
    required this.audioUrl,
  });
}

/// آيات قرآنية للتدريب (من جزء عمّ + الفاتحة).
const List<LearningVerse> kLearningVerses = [
  // ==================== سورة الفاتحة ====================
  LearningVerse(
    id: 'fatihah_1',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 1,
    textAr: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    textEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
  ),
  LearningVerse(
    id: 'fatihah_2',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 2,
    textAr: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    textEn: '[All] praise is [due] to Allah, Lord of the worlds.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/2.mp3',
  ),
  LearningVerse(
    id: 'fatihah_3',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 3,
    textAr: 'الرَّحْمَٰنِ الرَّحِيمِ',
    textEn: 'The Entirely Merciful, the Especially Merciful.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/3.mp3',
  ),
  LearningVerse(
    id: 'fatihah_4',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 4,
    textAr: 'مَالِكِ يَوْمِ الدِّينِ',
    textEn: 'Sovereign of the Day of Recompense.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/4.mp3',
  ),
  LearningVerse(
    id: 'fatihah_5',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 5,
    textAr: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    textEn: 'It is You we worship and You we ask for help.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/5.mp3',
  ),
  LearningVerse(
    id: 'fatihah_6',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 6,
    textAr: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    textEn: 'Guide us to the straight path.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6.mp3',
  ),
  LearningVerse(
    id: 'fatihah_7',
    surahNumber: 1,
    surahName: 'الفاتحة',
    ayahNumber: 7,
    textAr:
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    textEn:
        'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/7.mp3',
  ),

  // ==================== سورة الإخلاص ====================
  LearningVerse(
    id: 'ikhlas_1',
    surahNumber: 112,
    surahName: 'الإخلاص',
    ayahNumber: 1,
    textAr: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
    textEn: 'Say: He is Allah, [who is] One.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6222.mp3',
  ),
  LearningVerse(
    id: 'ikhlas_2',
    surahNumber: 112,
    surahName: 'الإخلاص',
    ayahNumber: 2,
    textAr: 'اللَّهُ الصَّمَدُ',
    textEn: 'Allah, the Eternal Refuge.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6223.mp3',
  ),
  LearningVerse(
    id: 'ikhlas_3',
    surahNumber: 112,
    surahName: 'الإخلاص',
    ayahNumber: 3,
    textAr: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
    textEn: 'He neither begets nor is born.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6224.mp3',
  ),
  LearningVerse(
    id: 'ikhlas_4',
    surahNumber: 112,
    surahName: 'الإخلاص',
    ayahNumber: 4,
    textAr: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    textEn: 'Nor is there to Him any equivalent.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6225.mp3',
  ),

  // ==================== سورة الفلق ====================
  LearningVerse(
    id: 'falaq_1',
    surahNumber: 113,
    surahName: 'الفلق',
    ayahNumber: 1,
    textAr: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
    textEn: 'Say: I seek refuge in the Lord of daybreak.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
  ),
  LearningVerse(
    id: 'falaq_2',
    surahNumber: 113,
    surahName: 'الفلق',
    ayahNumber: 2,
    textAr: 'مِن شَرِّ مَا خَلَقَ',
    textEn: 'From the evil of that which He created.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6227.mp3',
  ),
  LearningVerse(
    id: 'falaq_3',
    surahNumber: 113,
    surahName: 'الفلق',
    ayahNumber: 3,
    textAr: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
    textEn: 'And from the evil of darkness when it settles.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
  ),
  LearningVerse(
    id: 'falaq_4',
    surahNumber: 113,
    surahName: 'الفلق',
    ayahNumber: 4,
    textAr: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
    textEn: 'And from the evil of the blowers in knots.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
  ),
  LearningVerse(
    id: 'falaq_5',
    surahNumber: 113,
    surahName: 'الفلق',
    ayahNumber: 5,
    textAr: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    textEn: 'And from the evil of an envier when he envies.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
  ),

  // ==================== سورة الناس ====================
  LearningVerse(
    id: 'nas_1',
    surahNumber: 114,
    surahName: 'الناس',
    ayahNumber: 1,
    textAr: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    textEn: 'Say: I seek refuge in the Lord of mankind.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6231.mp3',
  ),
  LearningVerse(
    id: 'nas_2',
    surahNumber: 114,
    surahName: 'الناس',
    ayahNumber: 2,
    textAr: 'مَلِكِ النَّاسِ',
    textEn: 'The Sovereign of mankind.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6232.mp3',
  ),
  LearningVerse(
    id: 'nas_3',
    surahNumber: 114,
    surahName: 'الناس',
    ayahNumber: 3,
    textAr: 'إِلَٰهِ النَّاسِ',
    textEn: 'The God of mankind.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6233.mp3',
  ),
  LearningVerse(
    id: 'nas_4',
    surahNumber: 114,
    surahName: 'الناس',
    ayahNumber: 4,
    textAr: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
    textEn: 'From the evil of the retreating whisperer.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6234.mp3',
  ),
  LearningVerse(
    id: 'nas_5',
    surahNumber: 114,
    surahName: 'الناس',
    ayahNumber: 5,
    textAr: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
    textEn: 'Who whispers [evil] into the breasts of mankind.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6235.mp3',
  ),
  LearningVerse(
    id: 'nas_6',
    surahNumber: 114,
    surahName: 'الناس',
    ayahNumber: 6,
    textAr: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
    textEn: 'From among the jinn and mankind.',
    audioUrl:
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6236.mp3',
  ),
];

/// تجميع الآيات حسب السورة.
Map<String, List<LearningVerse>> groupVersesBySurah() {
  final map = <String, List<LearningVerse>>{};
  for (final v in kLearningVerses) {
    map.putIfAbsent(v.surahName, () => []).add(v);
  }
  return map;
}
