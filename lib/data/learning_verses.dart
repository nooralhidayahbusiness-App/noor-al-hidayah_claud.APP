/// آية قرآنية للتدريب.
class LearningVerse {
  final String id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String textAr;
  final String textEn;

  const LearningVerse({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.textAr,
    required this.textEn,
  });

  /// رابط الصوت من everyayah (صوت مشاري العفاسي).
  String get audioUrl {
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
  }
}

/// آيات قرآنية للتدريب.
const List<LearningVerse> kLearningVerses = [
  // ==================== الفاتحة ====================
  LearningVerse(
    id: 'fatihah_1',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 1,
    textAr: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    textEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
  ),
  LearningVerse(
    id: 'fatihah_2',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 2,
    textAr: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    textEn: '[All] praise is [due] to Allah, Lord of the worlds.',
  ),
  LearningVerse(
    id: 'fatihah_3',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 3,
    textAr: 'الرَّحْمَٰنِ الرَّحِيمِ',
    textEn: 'The Entirely Merciful, the Especially Merciful.',
  ),
  LearningVerse(
    id: 'fatihah_4',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 4,
    textAr: 'مَالِكِ يَوْمِ الدِّينِ',
    textEn: 'Sovereign of the Day of Recompense.',
  ),
  LearningVerse(
    id: 'fatihah_5',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 5,
    textAr: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    textEn: 'It is You we worship and You we ask for help.',
  ),
  LearningVerse(
    id: 'fatihah_6',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 6,
    textAr: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    textEn: 'Guide us to the straight path.',
  ),
  LearningVerse(
    id: 'fatihah_7',
    surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 7,
    textAr: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    textEn: 'The path of those upon whom You have bestowed favor, not of those who have evoked anger or of those who are astray.',
  ),

  // ==================== العصر ====================
  LearningVerse(
    id: 'asr_1',
    surahNumber: 103, surahName: 'العصر', ayahNumber: 1,
    textAr: 'وَالْعَصْرِ',
    textEn: 'By time,',
  ),
  LearningVerse(
    id: 'asr_2',
    surahNumber: 103, surahName: 'العصر', ayahNumber: 2,
    textAr: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
    textEn: 'Indeed, mankind is in loss,',
  ),
  LearningVerse(
    id: 'asr_3',
    surahNumber: 103, surahName: 'العصر', ayahNumber: 3,
    textAr: 'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ',
    textEn: 'Except for those who have believed and done righteous deeds and advised each other to truth and advised each other to patience.',
  ),

  // ==================== الفيل ====================
  LearningVerse(
    id: 'feel_1',
    surahNumber: 105, surahName: 'الفيل', ayahNumber: 1,
    textAr: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ',
    textEn: 'Have you not considered, how your Lord dealt with the companions of the elephant?',
  ),
  LearningVerse(
    id: 'feel_2',
    surahNumber: 105, surahName: 'الفيل', ayahNumber: 2,
    textAr: 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
    textEn: 'Did He not make their plan into misguidance?',
  ),
  LearningVerse(
    id: 'feel_3',
    surahNumber: 105, surahName: 'الفيل', ayahNumber: 3,
    textAr: 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
    textEn: 'And He sent against them birds in flocks,',
  ),
  LearningVerse(
    id: 'feel_4',
    surahNumber: 105, surahName: 'الفيل', ayahNumber: 4,
    textAr: 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
    textEn: 'Striking them with stones of hard clay,',
  ),
  LearningVerse(
    id: 'feel_5',
    surahNumber: 105, surahName: 'الفيل', ayahNumber: 5,
    textAr: 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ',
    textEn: 'And He made them like eaten straw.',
  ),

  // ==================== قريش ====================
  LearningVerse(
    id: 'quraysh_1',
    surahNumber: 106, surahName: 'قريش', ayahNumber: 1,
    textAr: 'لِإِيلَافِ قُرَيْشٍ',
    textEn: 'For the accustomed security of the Quraysh,',
  ),
  LearningVerse(
    id: 'quraysh_2',
    surahNumber: 106, surahName: 'قريش', ayahNumber: 2,
    textAr: 'إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ',
    textEn: 'Their accustomed security in the journey of winter and summer,',
  ),
  LearningVerse(
    id: 'quraysh_3',
    surahNumber: 106, surahName: 'قريش', ayahNumber: 3,
    textAr: 'فَلْيَعْبُدُوا رَبَّ هَٰذَا الْبَيْتِ',
    textEn: 'Let them worship the Lord of this House,',
  ),
  LearningVerse(
    id: 'quraysh_4',
    surahNumber: 106, surahName: 'قريش', ayahNumber: 4,
    textAr: 'الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ',
    textEn: 'Who has fed them, [saving them] from hunger and made them safe, [saving them] from fear.',
  ),

  // ==================== الماعون ====================
  LearningVerse(
    id: 'maun_1',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 1,
    textAr: 'أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ',
    textEn: 'Have you seen the one who denies the Recompense?',
  ),
  LearningVerse(
    id: 'maun_2',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 2,
    textAr: 'فَذَٰلِكَ الَّذِي يَدُعُّ الْيَتِيمَ',
    textEn: 'For that is the one who drives away the orphan,',
  ),
  LearningVerse(
    id: 'maun_3',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 3,
    textAr: 'وَلَا يَحُضُّ عَلَىٰ طَعَامِ الْمِسْكِينِ',
    textEn: 'And does not encourage the feeding of the poor.',
  ),
  LearningVerse(
    id: 'maun_4',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 4,
    textAr: 'فَوَيْلٌ لِّلْمُصَلِّينَ',
    textEn: 'So woe to those who pray,',
  ),
  LearningVerse(
    id: 'maun_5',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 5,
    textAr: 'الَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ',
    textEn: '[But] who are heedless of their prayer,',
  ),
  LearningVerse(
    id: 'maun_6',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 6,
    textAr: 'الَّذِينَ هُمْ يُرَاءُونَ',
    textEn: 'Those who make a show [of their deeds],',
  ),
  LearningVerse(
    id: 'maun_7',
    surahNumber: 107, surahName: 'الماعون', ayahNumber: 7,
    textAr: 'وَيَمْنَعُونَ الْمَاعُونَ',
    textEn: 'And withhold [simple] assistance.',
  ),

  // ==================== الكوثر ====================
  LearningVerse(
    id: 'kawthar_1',
    surahNumber: 108, surahName: 'الكوثر', ayahNumber: 1,
    textAr: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
    textEn: 'Indeed, We have granted you al-Kawthar.',
  ),
  LearningVerse(
    id: 'kawthar_2',
    surahNumber: 108, surahName: 'الكوثر', ayahNumber: 2,
    textAr: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
    textEn: 'So pray to your Lord and sacrifice [to Him alone].',
  ),
  LearningVerse(
    id: 'kawthar_3',
    surahNumber: 108, surahName: 'الكوثر', ayahNumber: 3,
    textAr: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
    textEn: 'Indeed, your enemy is the one cut off.',
  ),

  // ==================== الكافرون ====================
  LearningVerse(
    id: 'kafirun_1',
    surahNumber: 109, surahName: 'الكافرون', ayahNumber: 1,
    textAr: 'قُلْ يَا أَيُّهَا الْكَافِرُونَ',
    textEn: 'Say: O disbelievers,',
  ),
  LearningVerse(
    id: 'kafirun_2',
    surahNumber: 109, surahName: 'الكافرون', ayahNumber: 2,
    textAr: 'لَا أَعْبُدُ مَا تَعْبُدُونَ',
    textEn: 'I do not worship what you worship.',
  ),
  LearningVerse(
    id: 'kafirun_3',
    surahNumber: 109, surahName: 'الكافرون', ayahNumber: 3,
    textAr: 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
    textEn: 'Nor are you worshippers of what I worship.',
  ),
  LearningVerse(
    id: 'kafirun_4',
    surahNumber: 109, surahName: 'الكافرون', ayahNumber: 4,
    textAr: 'وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ',
    textEn: 'Nor will I be a worshipper of what you worship.',
  ),
  LearningVerse(
    id: 'kafirun_5',
    surahNumber: 109, surahName: 'الكافرون', ayahNumber: 5,
    textAr: 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
    textEn: 'Nor will you be worshippers of what I worship.',
  ),
  LearningVerse(
    id: 'kafirun_6',
    surahNumber: 109, surahName: 'الكافرون', ayahNumber: 6,
    textAr: 'لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
    textEn: 'For you is your religion, and for me is my religion.',
  ),

  // ==================== النصر ====================
  LearningVerse(
    id: 'nasr_1',
    surahNumber: 110, surahName: 'النصر', ayahNumber: 1,
    textAr: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
    textEn: 'When the victory of Allah has come and the conquest,',
  ),
  LearningVerse(
    id: 'nasr_2',
    surahNumber: 110, surahName: 'النصر', ayahNumber: 2,
    textAr: 'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
    textEn: 'And you see the people entering into the religion of Allah in multitudes,',
  ),
  LearningVerse(
    id: 'nasr_3',
    surahNumber: 110, surahName: 'النصر', ayahNumber: 3,
    textAr: 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا',
    textEn: 'Then exalt Him with praise of your Lord and ask forgiveness of Him. Indeed, He is ever Accepting of repentance.',
  ),

  // ==================== الإخلاص ====================
  LearningVerse(
    id: 'ikhlas_1',
    surahNumber: 112, surahName: 'الإخلاص', ayahNumber: 1,
    textAr: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
    textEn: 'Say: He is Allah, [who is] One.',
  ),
  LearningVerse(
    id: 'ikhlas_2',
    surahNumber: 112, surahName: 'الإخلاص', ayahNumber: 2,
    textAr: 'اللَّهُ الصَّمَدُ',
    textEn: 'Allah, the Eternal Refuge.',
  ),
  LearningVerse(
    id: 'ikhlas_3',
    surahNumber: 112, surahName: 'الإخلاص', ayahNumber: 3,
    textAr: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
    textEn: 'He neither begets nor is born.',
  ),
  LearningVerse(
    id: 'ikhlas_4',
    surahNumber: 112, surahName: 'الإخلاص', ayahNumber: 4,
    textAr: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    textEn: 'Nor is there to Him any equivalent.',
  ),

  // ==================== الفلق ====================
  LearningVerse(
    id: 'falaq_1',
    surahNumber: 113, surahName: 'الفلق', ayahNumber: 1,
    textAr: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
    textEn: 'Say: I seek refuge in the Lord of daybreak.',
  ),
  LearningVerse(
    id: 'falaq_2',
    surahNumber: 113, surahName: 'الفلق', ayahNumber: 2,
    textAr: 'مِن شَرِّ مَا خَلَقَ',
    textEn: 'From the evil of that which He created.',
  ),
  LearningVerse(
    id: 'falaq_3',
    surahNumber: 113, surahName: 'الفلق', ayahNumber: 3,
    textAr: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
    textEn: 'And from the evil of darkness when it settles.',
  ),
  LearningVerse(
    id: 'falaq_4',
    surahNumber: 113, surahName: 'الفلق', ayahNumber: 4,
    textAr: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
    textEn: 'And from the evil of the blowers in knots.',
  ),
  LearningVerse(
    id: 'falaq_5',
    surahNumber: 113, surahName: 'الفلق', ayahNumber: 5,
    textAr: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    textEn: 'And from the evil of an envier when he envies.',
  ),

  // ==================== الناس ====================
  LearningVerse(
    id: 'nas_1',
    surahNumber: 114, surahName: 'الناس', ayahNumber: 1,
    textAr: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    textEn: 'Say: I seek refuge in the Lord of mankind,',
  ),
  LearningVerse(
    id: 'nas_2',
    surahNumber: 114, surahName: 'الناس', ayahNumber: 2,
    textAr: 'مَلِكِ النَّاسِ',
    textEn: 'The Sovereign of mankind,',
  ),
  LearningVerse(
    id: 'nas_3',
    surahNumber: 114, surahName: 'الناس', ayahNumber: 3,
    textAr: 'إِلَٰهِ النَّاسِ',
    textEn: 'The God of mankind,',
  ),
  LearningVerse(
    id: 'nas_4',
    surahNumber: 114, surahName: 'الناس', ayahNumber: 4,
    textAr: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
    textEn: 'From the evil of the retreating whisperer,',
  ),
  LearningVerse(
    id: 'nas_5',
    surahNumber: 114, surahName: 'الناس', ayahNumber: 5,
    textAr: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
    textEn: 'Who whispers [evil] into the breasts of mankind,',
  ),
  LearningVerse(
    id: 'nas_6',
    surahNumber: 114, surahName: 'الناس', ayahNumber: 6,
    textAr: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
    textEn: 'From among the jinn and mankind.',
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
