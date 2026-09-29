import 'package:flutter/material.dart';

class Dua {
  final String id;
  final String textAr;
  final String textEn;
  final String reference;
  final String? virtueAr;
  final String? virtueEn;

  const Dua({
    required this.id,
    required this.textAr,
    required this.textEn,
    required this.reference,
    this.virtueAr,
    this.virtueEn,
  });
}

class DuaCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;
  final IconData icon;
  final List<Dua> items;

  const DuaCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.icon,
    required this.items,
  });
}

const List<DuaCategory> kDuaCategories = [
  // ==================== أدعية قرآنية ====================
  DuaCategory(
    id: 'quranic',
    nameAr: 'أدعية قرآنية',
    nameEn: 'Quranic Duas',
    descAr: 'أدعية وردت في القرآن الكريم',
    descEn: 'Duas from the Holy Quran',
    icon: Icons.menu_book_rounded,
    items: [
      Dua(
        id: 'q_01',
        textAr:
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        textEn:
            'Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.',
        reference: 'البقرة: 201',
      ),
      Dua(
        id: 'q_02',
        textAr:
            'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
        textEn:
            'Our Lord, do not impose blame upon us if we have forgotten or erred.',
        reference: 'البقرة: 286',
      ),
      Dua(
        id: 'q_03',
        textAr:
            'رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا',
        textEn:
            'Our Lord, and lay not upon us a burden like that which You laid upon those before us.',
        reference: 'البقرة: 286',
      ),
      Dua(
        id: 'q_04',
        textAr:
            'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
        textEn:
            'Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy. Indeed, You are the Bestower.',
        reference: 'آل عمران: 8',
      ),
      Dua(
        id: 'q_05',
        textAr:
            'رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ',
        textEn:
            'Our Lord, indeed we have believed, so forgive us our sins and protect us from the punishment of the Fire.',
        reference: 'آل عمران: 16',
      ),
      Dua(
        id: 'q_06',
        textAr:
            'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
        textEn:
            'Our Lord, grant us from among our wives and offspring comfort to our eyes and make us an example for the righteous.',
        reference: 'الفرقان: 74',
      ),
      Dua(
        id: 'q_07',
        textAr:
            'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
        textEn:
            'My Lord, make me an establisher of prayer, and [many] from my descendants. Our Lord, and accept my supplication.',
        reference: 'إبراهيم: 40',
      ),
      Dua(
        id: 'q_08',
        textAr:
            'رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ',
        textEn:
            'Our Lord, forgive us and our brothers who preceded us in faith.',
        reference: 'الحشر: 10',
      ),
      Dua(
        id: 'q_09',
        textAr:
            'رَبِّ زِدْنِي عِلْمًا',
        textEn: 'My Lord, increase me in knowledge.',
        reference: 'طه: 114',
      ),
      Dua(
        id: 'q_10',
        textAr:
            'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
        textEn:
            'My Lord, expand for me my breast [with assurance] and ease for me my task.',
        reference: 'طه: 25-26',
      ),
      Dua(
        id: 'q_11',
        textAr:
            'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَى وَالِدَيَّ',
        textEn:
            'My Lord, enable me to be grateful for Your favor which You have bestowed upon me and upon my parents.',
        reference: 'الأحقاف: 15',
      ),
      Dua(
        id: 'q_12',
        textAr:
            'رَبَّنَا عَلَيْكَ تَوَكَّلْنَا وَإِلَيْكَ أَنَبْنَا وَإِلَيْكَ الْمَصِيرُ',
        textEn:
            'Our Lord, upon You we have relied, and to You we have returned, and to You is the destination.',
        reference: 'الممتحنة: 4',
      ),
      Dua(
        id: 'q_13',
        textAr:
            'رَبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ',
        textEn:
            'My Lord, forgive and have mercy, and You are the best of the merciful.',
        reference: 'المؤمنون: 118',
      ),
      Dua(
        id: 'q_14',
        textAr:
            'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
        textEn:
            'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
        reference: 'الأنبياء: 87',
      ),
      Dua(
        id: 'q_15',
        textAr:
            'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        textEn: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
        reference: 'آل عمران: 173',
      ),
    ],
  ),

  // ==================== أدعية نبوية ====================
  DuaCategory(
    id: 'prophetic',
    nameAr: 'أدعية نبوية',
    nameEn: 'Prophetic Duas',
    descAr: 'أدعية علّمها النبي ﷺ',
    descEn: 'Duas taught by the Prophet ﷺ',
    icon: Icons.auto_awesome_rounded,
    items: [
      Dua(
        id: 'p_01',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
        textEn:
            'O Allah, I ask You for guidance, piety, chastity and self-sufficiency.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 'p_02',
        textAr:
            'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ',
        textEn:
            'O Allah, guide me among those You have guided, grant me health among those You have granted health, take me into Your charge among those You have taken into Your charge, bless me in what You have given, and protect me from the evil of what You have decreed.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'p_03',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
        textEn:
            'O Allah, I seek refuge in You from the removal of Your blessing, the change of Your protection, the suddenness of Your punishment, and all that displeases You.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 'p_04',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنَ الْخَيْرِ كُلِّهِ عَاجِلِهِ وَآجِلِهِ، مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ',
        textEn:
            'O Allah, I ask You for all that is good, in this world and the Hereafter, what I know and what I do not know.',
        reference: 'رواه ابن ماجه',
      ),
      Dua(
        id: 'p_05',
        textAr:
            'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي',
        textEn:
            'O Allah, set right my religion which is the safeguard of my affairs, set right my worldly affairs in which is my livelihood, and set right my Hereafter to which is my return.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 'p_06',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
        textEn:
            'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.',
        reference: 'رواه ابن ماجه',
      ),
      Dua(
        id: 'p_07',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ',
        textEn:
            'O Allah, I ask You for Paradise and I seek refuge in You from the Fire.',
        reference: 'رواه أبو داود',
      ),
      Dua(
        id: 'p_08',
        textAr:
            'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        textEn:
            'O Allah, help me to remember You, to thank You, and to worship You in the best manner.',
        reference: 'رواه أبو داود',
      ),
      Dua(
        id: 'p_09',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عِلْمٍ لَا يَنْفَعُ، وَمِنْ قَلْبٍ لَا يَخْشَعُ، وَمِنْ نَفْسٍ لَا تَشْبَعُ، وَمِنْ دَعْوَةٍ لَا يُسْتَجَابُ لَهَا',
        textEn:
            'O Allah, I seek refuge in You from knowledge that does not benefit, a heart that is not humble, a soul that is not satisfied, and a supplication that is not answered.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 'p_10',
        textAr:
            'اللَّهُمَّ أَغْنِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
        textEn:
            'O Allah, suffice me with what You have made lawful against what You have made unlawful, and make me independent of all others besides You.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'p_11',
        textAr:
            'اللَّهُمَّ اقْسِمْ لَنَا مِنْ خَشْيَتِكَ مَا تَحُولُ بِهِ بَيْنَنَا وَبَيْنَ مَعَاصِيكَ، وَمِنْ طَاعَتِكَ مَا تُبَلِّغُنَا بِهِ جَنَّتَكَ',
        textEn:
            'O Allah, apportion for us a fear of You that prevents us from disobeying You, and an obedience to You that leads us to Your Paradise.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'p_12',
        textAr:
            'اللَّهُمَّ طَهِّرْ قَلْبِي مِنَ النِّفَاقِ، وَعَمَلِي مِنَ الرِّيَاءِ، وَلِسَانِي مِنَ الْكَذِبِ، وَعَيْنِي مِنَ الْخِيَانَةِ',
        textEn:
            'O Allah, purify my heart from hypocrisy, my deeds from showing off, my tongue from lies, and my eyes from betrayal.',
        reference: 'رواه الخطيب',
      ),
      Dua(
        id: 'p_13',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ حُبَّكَ، وَحُبَّ مَنْ يُحِبُّكَ، وَحُبَّ عَمَلٍ يُقَرِّبُنِي إِلَى حُبِّكَ',
        textEn:
            'O Allah, I ask You for Your love, the love of those who love You, and the love of deeds that bring me closer to Your love.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'p_14',
        textAr:
            'اللَّهُمَّ بَارِكْ لَنَا فِي أَعْمَارِنَا، وَأَصِحَّ لَنَا أَبْدَانَنَا، وَنَوِّرْ لَنَا قُلُوبَنَا، وَثَبِّتْ لَنَا إِيمَانَنَا',
        textEn:
            'O Allah, bless our lives, keep our bodies healthy, illuminate our hearts, and strengthen our faith.',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'p_15',
        textAr:
            'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        textEn:
            'Allah is sufficient for me. There is no god but Him. In Him I put my trust, and He is the Lord of the Mighty Throne.',
        reference: 'رواه ابن السني',
      ),
    ],
  ),

  // ==================== أدعية الطعام والشراب ====================
  DuaCategory(
    id: 'food',
    nameAr: 'أدعية الطعام والشراب',
    nameEn: 'Food & Drink',
    descAr: 'ما يُقال قبل وبعد الطعام',
    descEn: 'What to say before and after eating',
    icon: Icons.restaurant_rounded,
    items: [
      Dua(
        id: 'f_01',
        textAr: 'بِسْمِ اللَّهِ',
        textEn: 'In the name of Allah.',
        reference: 'قبل الطعام',
      ),
      Dua(
        id: 'f_02',
        textAr:
            'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
        textEn: 'In the name of Allah at its beginning and its end.',
        reference: 'إذا نسي في أوله',
      ),
      Dua(
        id: 'f_03',
        textAr:
            'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
        textEn:
            'Praise be to Allah Who has fed me this and provided it for me without any might or power on my part.',
        reference: 'رواه أبو داود',
      ),
      Dua(
        id: 'f_04',
        textAr:
            'اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَأَطْعِمْنَا خَيْرًا مِنْهُ',
        textEn:
            'O Allah, bless it for us and feed us better than it.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'f_05',
        textAr:
            'اللَّهُمَّ أَطْعِمْ مَنْ أَطْعَمَنِي، وَاسْقِ مَنْ سَقَانِي',
        textEn:
            'O Allah, feed the one who fed me and give drink to the one who gave me drink.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 'f_06',
        textAr:
            'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
        textEn:
            'Praise be to Allah Who has fed us, given us drink, and made us Muslims.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'f_07',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ أَنْ تَغْفِرَ لِي',
        textEn:
            'O Allah, I ask You by Your mercy which encompasses all things to forgive me.',
        reference: 'بعد شرب اللبن',
      ),
    ],
  ),

  // ==================== أدعية السفر ====================
  DuaCategory(
    id: 'travel',
    nameAr: 'أدعية السفر',
    nameEn: 'Travel',
    descAr: 'أدعية المسافر والركوب',
    descEn: 'Duas for travel and riding',
    icon: Icons.flight_takeoff_rounded,
    items: [
      Dua(
        id: 't_01',
        textAr:
            'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        textEn:
            'Exalted is He who has subjected this to us, and we could not have [otherwise] subdued it. And indeed we, to our Lord, will [surely] return.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 't_02',
        textAr:
            'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ',
        textEn:
            'O Allah, we ask You in this journey of ours for righteousness, piety, and deeds that please You. O Allah, make this journey easy for us and shorten its distance.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 't_03',
        textAr:
            'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْقُرْآنِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ',
        textEn:
            'O Allah, Lord of the seven heavens and Lord of the Mighty Throne, our Lord and Lord of all things, Splitter of the seed and the date stone, Revealer of the Torah, the Gospel, and the Quran. I seek refuge in You from the evil of everything You hold by its forelock.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 't_04',
        textAr:
            'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
        textEn:
            'O Allah, grant my body health. O Allah, grant my hearing health. O Allah, grant my sight health.',
        reference: 'رواه أبو داود',
      ),
      Dua(
        id: 't_05',
        textAr:
            'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        textEn:
            'I seek refuge in the perfect words of Allah from the evil of what He created.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 't_06',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ، وَكَآبَةِ الْمَنْظَرِ، وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالْأَهْلِ',
        textEn:
            'O Allah, I seek refuge in You from the hardship of travel, from having a change of heart, and from an evil outcome in wealth and family.',
        reference: 'رواه مسلم',
      ),
    ],
  ),

  // ==================== أدعية المرض والشفاء ====================
  DuaCategory(
    id: 'sickness',
    nameAr: 'أدعية المرض والشفاء',
    nameEn: 'Sickness & Healing',
    descAr: 'أدعية الشفاء والعافية',
    descEn: 'Duas for healing and well-being',
    icon: Icons.healing_rounded,
    items: [
      Dua(
        id: 's_01',
        textAr:
            'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
        textEn:
            'I ask Allah the Mighty, Lord of the Mighty Throne, to cure you.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 's_02',
        textAr:
            'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَاسَ، اشْفِ أَنْتَ الشَّافِي، لَا شَافِيَ إِلَّا أَنْتَ، اشْفِ شِفَاءً لَا يُغَادِرُ سَقَمًا',
        textEn:
            'O Allah, Lord of the people, remove the hardship, cure — You are the Curer, there is no curer but You, cure with a cure that leaves no illness.',
        reference: 'رواه البخاري',
      ),
      Dua(
        id: 's_03',
        textAr:
            'بِسْمِ اللَّهِ (٣ مرات)، أَعُوذُ بِعِزَّةِ اللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (٧ مرات)',
        textEn:
            'In the name of Allah (3 times). I seek refuge in the might of Allah and His power from the evil of what I feel and fear (7 times).',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 's_04',
        textAr:
            'أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
        textEn:
            'I seek refuge in Allah and His power from the evil of what I feel and fear.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 's_05',
        textAr:
            'اللَّهُمَّ مُصَرِّفَ الْقُلُوبِ صَرِّفْ قُلُوبَنَا عَلَى طَاعَتِكَ',
        textEn:
            'O Allah, Turner of hearts, turn our hearts to Your obedience.',
        reference: 'رواه مسلم',
      ),
      Dua(
        id: 's_06',
        textAr:
            'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَنِي',
        textEn:
            'I ask Allah the Mighty, Lord of the Mighty Throne, to cure me.',
        reference: 'رواه أبو داود',
      ),
    ],
  ),

  // ==================== أدعية الفرج والهم ====================
  DuaCategory(
    id: 'distress',
    nameAr: 'أدعية الفرج والهم',
    nameEn: 'Distress & Relief',
    descAr: 'أدعية عند الكرب والهم والضيق',
    descEn: 'Duas at times of distress and anxiety',
    icon: Icons.spa_rounded,
    items: [
      Dua(
        id: 'd_01',
        textAr:
            'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
        textEn:
            'There is no god but Allah, the Mighty, the Forbearing. There is no god but Allah, Lord of the Mighty Throne. There is no god but Allah, Lord of the heavens, Lord of the earth, and Lord of the Noble Throne.',
        reference: 'دعاء الكرب - البخاري',
      ),
      Dua(
        id: 'd_02',
        textAr:
            'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
        textEn:
            'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
        reference: 'دعاء يونس - الأنبياء: 87',
      ),
      Dua(
        id: 'd_03',
        textAr:
            'اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ، سَمَّيْتَ بِهِ نَفْسَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجِلَاءَ حُزْنِي، وَذَهَابَ هَمِّي',
        textEn:
            'O Allah, I am Your servant, son of Your servant, son of Your maidservant. My forelock is in Your hand. Your command over me is forever executed and Your decree over me is just. I ask You by every name belonging to You which You have named Yourself with, to make the Quran the life of my heart, the light of my breast, the departure of my sorrow and the relief of my distress.',
        reference: 'رواه أحمد',
      ),
      Dua(
        id: 'd_04',
        textAr:
            'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        textEn:
            'Allah is sufficient for us, and He is the best Disposer of affairs.',
        reference: 'آل عمران: 173',
      ),
      Dua(
        id: 'd_05',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
        textEn:
            'O Allah, I seek refuge in You from worry and grief, weakness and laziness, miserliness and cowardice, the burden of debt, and being overpowered by men.',
        reference: 'رواه البخاري',
      ),
      Dua(
        id: 'd_06',
        textAr:
            'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
        textEn:
            'O Allah, suffice me with what You have made lawful against what You have made unlawful, and make me independent of all others besides You.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'd_07',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
        textEn:
            'O Allah, I ask You for forgiveness and well-being in my religion, my worldly affairs, my family and my wealth.',
        reference: 'رواه أبو داود',
      ),
      Dua(
        id: 'd_08',
        textAr:
            'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي',
        textEn:
            'O Ever-Living, O Sustainer, by Your mercy I seek relief. Set right all my affairs, and do not leave me to myself.',
        reference: 'رواه النسائي',
      ),
      Dua(
        id: 'd_09',
        textAr:
            'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
        textEn:
            'I seek the forgiveness of Allah the Mighty, whom there is no god but He, the Ever-Living, the Sustainer, and I repent to Him.',
        reference: 'رواه أبو داود',
      ),
      Dua(
        id: 'd_10',
        textAr:
            'اللَّهُمَّ رَحْمَتَكَ أَرْجُو، فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لَا إِلَهَ إِلَّا أَنْتَ',
        textEn:
            'O Allah, I hope for Your mercy; do not leave me to myself even for the blink of an eye. Set right all my affairs. There is no god but You.',
        reference: 'رواه أبو داود',
      ),
    ],
  ),

  // ==================== أدعية متفرقة ====================
  DuaCategory(
    id: 'misc',
    nameAr: 'أدعية متفرقة',
    nameEn: 'Miscellaneous',
    descAr: 'أدعية متنوعة لكل الأحوال',
    descEn: 'Various duas for all situations',
    icon: Icons.favorite_rounded,
    items: [
      Dua(
        id: 'm_01',
        textAr:
            'اللَّهُمَّ أَعْطِنِي فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنِي عَذَابَ النَّارِ',
        textEn:
            'O Allah, give me good in this world and good in the Hereafter, and protect me from the punishment of the Fire.',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'm_02',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْفِرْدَوْسَ الْأَعْلَى مِنَ الْجَنَّةِ',
        textEn:
            'O Allah, I ask You for Al-Firdaws, the highest level of Paradise.',
        reference: 'رواه البخاري',
      ),
      Dua(
        id: 'm_03',
        textAr:
            'اللَّهُمَّ بَارِكْ لِي فِي مَالِي وَوَلَدِي وَأَهْلِي',
        textEn:
            'O Allah, bless me in my wealth, my children, and my family.',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'm_04',
        textAr:
            'اللَّهُمَّ اجْعَلْ آخِرَ كَلَامِي مِنَ الدُّنْيَا لَا إِلَهَ إِلَّا اللَّهُ',
        textEn:
            'O Allah, make the last of my words in this world: "There is no god but Allah."',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'm_05',
        textAr:
            'اللَّهُمَّ ثَبِّتْنِي عَلَى الْإِسْلَامِ حَتَّى أَلْقَاكَ',
        textEn:
            'O Allah, keep me steadfast on Islam until I meet You.',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'm_06',
        textAr:
            'اللَّهُمَّ ارْزُقْنِي حُسْنَ الْخَاتِمَةِ',
        textEn: 'O Allah, grant me a good ending.',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'm_07',
        textAr:
            'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا',
        textEn:
            'Our Lord, let not our hearts deviate after You have guided us.',
        reference: 'آل عمران: 8',
      ),
      Dua(
        id: 'm_08',
        textAr:
            'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
        textEn:
            'O Allah, make me among those who repent and among those who purify themselves.',
        reference: 'رواه الترمذي',
      ),
      Dua(
        id: 'm_09',
        textAr:
            'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا، وَفِي سَمْعِي نُورًا، وَفِي بَصَرِي نُورًا',
        textEn:
            'O Allah, place light in my heart, light in my hearing, and light in my sight.',
        reference: 'رواه البخاري',
      ),
      Dua(
        id: 'm_10',
        textAr:
            'اللَّهُمَّ أَعِنِّي وَلَا تُعِنْ عَلَيَّ، وَانْصُرْنِي وَلَا تَنْصُرْ عَلَيَّ',
        textEn:
            'O Allah, help me and do not help against me; grant me victory and do not grant victory over me.',
        reference: 'رواه الترمذي',
      ),
    ],
  ),
];
