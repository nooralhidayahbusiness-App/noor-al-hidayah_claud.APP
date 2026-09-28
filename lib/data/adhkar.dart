import 'package:flutter/material.dart';

class Dhikr {
  final String id;
  final String textAr;
  final String textEn;
  final int count;
  final String? virtueAr;
  final String? virtueEn;
  final String? reference;

  const Dhikr({
    required this.id,
    required this.textAr,
    required this.textEn,
    required this.count,
    this.virtueAr,
    this.virtueEn,
    this.reference,
  });
}

class AdhkarCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;
  final IconData icon;
  final List<Dhikr> items;

  const AdhkarCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.icon,
    required this.items,
  });
}

const List<AdhkarCategory> kAdhkarCategories = [
  // ==================== أذكار الصباح ====================
  AdhkarCategory(
    id: 'morning',
    nameAr: 'أذكار الصباح',
    nameEn: 'Morning Adhkar',
    descAr: 'تُقال بعد الفجر إلى طلوع الشمس',
    descEn: 'Recited between Fajr and sunrise',
    icon: Icons.wb_sunny_rounded,
    items: [
      Dhikr(
        id: 'm_ayat_kursi',
        textAr:
            'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
        textEn:
            'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence...',
        count: 1,
        virtueAr: 'من قالها حين يصبح أُجير من الجن حتى يمسي',
        virtueEn: 'Whoever recites it in the morning is protected from jinn until evening',
        reference: 'آية الكرسي - البقرة 255',
      ),
      Dhikr(
        id: 'm_ikhlas',
        textAr:
            'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        textEn:
            'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born. Nor is there to Him any equivalent.',
        count: 3,
        virtueAr: 'من قالها ثلاثاً كفته من كل شيء',
        virtueEn: 'Whoever says it three times, it suffices him from everything',
        reference: 'سورة الإخلاص',
      ),
      Dhikr(
        id: 'm_falaq',
        textAr: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ...',
        textEn: 'Say: I seek refuge in the Lord of daybreak...',
        count: 3,
        reference: 'سورة الفلق',
      ),
      Dhikr(
        id: 'm_nas',
        textAr: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
        textEn: 'Say: I seek refuge in the Lord of mankind...',
        count: 3,
        reference: 'سورة الناس',
      ),
      Dhikr(
        id: 'm_asbahna',
        textAr:
            'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        textEn:
            'We have entered a new day and with it all dominion belongs to Allah. Praise is to Allah. None has the right to be worshipped but Allah alone, Who has no partner. His is the dominion and His is the praise, and He is Able to do all things.',
        count: 1,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'm_sayyid_istighfar',
        textAr:
            'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي',
        textEn:
            'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant. I shall keep Your covenant and promise as much as I can. I seek refuge in You from the evil I have done. I acknowledge Your favor upon me and I acknowledge my sin. Forgive me.',
        count: 1,
        virtueAr:
            'سيد الاستغفار - من قالها موقناً بها حين يصبح فمات من يومه دخل الجنة',
        virtueEn:
            'The master of seeking forgiveness — whoever says it in the morning with certainty and dies that day enters Paradise',
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'm_bika_asbahna',
        textAr:
            'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
        textEn:
            'O Allah, by You we enter the morning, by You we enter the evening, by You we live, by You we die, and to You is the resurrection.',
        count: 1,
        reference: 'رواه الترمذي',
      ),
      Dhikr(
        id: 'm_ashhad',
        textAr:
            'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
        textEn:
            'O Allah, I call upon You to witness, and I call the bearers of Your Throne, Your angels, and all Your creation to witness that You are Allah, there is no god but You alone, without partner, and that Muhammad is Your servant and messenger.',
        count: 4,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'm_hasbiyallah',
        textAr:
            'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        textEn:
            'Allah is sufficient for me. There is no god but Him. In Him I put my trust, and He is the Lord of the Mighty Throne.',
        count: 7,
        virtueAr: 'من قالها كفاه الله ما أهمّه من أمر الدنيا والآخرة',
        virtueEn:
            'Whoever says it, Allah will suffice him from the concerns of this life and the Hereafter',
        reference: 'رواه ابن السني',
      ),
      Dhikr(
        id: 'm_bismillah',
        textAr:
            'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        textEn:
            'In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
        count: 3,
        virtueAr: 'لم يضره شيء',
        virtueEn: 'Nothing will harm him',
        reference: 'رواه الترمذي',
      ),
      Dhikr(
        id: 'm_raditu',
        textAr:
            'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا',
        textEn:
            'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad ﷺ as my prophet.',
        count: 3,
        virtueAr: 'كان حقاً على الله أن يرضيه يوم القيامة',
        virtueEn: 'It is a right upon Allah to please him on the Day of Judgement',
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'm_ya_hayyu',
        textAr:
            'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي',
        textEn:
            'O Ever-Living, O Sustainer, by Your mercy I seek relief. Set right all my affairs, and do not leave me to myself.',
        count: 1,
        reference: 'رواه النسائي',
      ),
      Dhikr(
        id: 'm_fitra',
        textAr:
            'أَصْبَحْتُ عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
        textEn:
            'I have entered the morning upon the natural religion of Islam, upon the word of sincerity, upon the religion of our Prophet Muhammad ﷺ, and upon the way of our father Ibrahim, who was upright and a Muslim and not of the polytheists.',
        count: 1,
        reference: 'رواه أحمد',
      ),
      Dhikr(
        id: 'm_subhan100',
        textAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        textEn: 'Glory be to Allah and praise be to Him.',
        count: 100,
        virtueAr:
            'من قالها مئة مرة حين يصبح وحين يمسي لم يأتِ أحد بأفضل مما جاء به',
        virtueEn:
            'Whoever says it 100 times morning and evening, none will come with better than what he came with',
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'm_tahlil_10',
        textAr:
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        textEn:
            'None has the right to be worshipped but Allah alone, Who has no partner. His is the dominion and His is the praise, and He is Able to do all things.',
        count: 10,
        virtueAr:
            'كانت له عدل عشر رقاب، وكتبت له مئة حسنة، ومحيت عنه مئة سيئة',
        virtueEn:
            'It is equivalent to freeing ten slaves, 100 good deeds are written, and 100 sins are erased',
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'm_afwa_afiya',
        textAr:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي',
        textEn:
            'O Allah, I ask You for forgiveness and well-being in this world and the Hereafter. O Allah, I ask You for forgiveness and well-being in my religion, my worldly affairs, my family and my wealth. O Allah, conceal my faults and calm my fears.',
        count: 1,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'm_alim_ghayb',
        textAr:
            'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَشَرِّ الشَّيْطَانِ وَشِرْكِهِ',
        textEn:
            'O Allah, Knower of the unseen and the seen, Originator of the heavens and the earth, Lord and Sovereign of all things, I bear witness that there is no god but You. I seek refuge in You from the evil of my soul and the evil of Satan and his polytheism.',
        count: 1,
        reference: 'رواه الترمذي',
      ),
      Dhikr(
        id: 'm_kufr_faqr',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ',
        textEn:
            'O Allah, I seek refuge in You from disbelief and poverty, and I seek refuge in You from the punishment of the grave.',
        count: 3,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'm_hamm_hazan',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
        textEn:
            'O Allah, I seek refuge in You from worry and grief, weakness and laziness, miserliness and cowardice, the burden of debt, and from being overpowered by men.',
        count: 1,
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'm_afini_badani',
        textAr:
            'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
        textEn:
            'O Allah, grant my body health. O Allah, grant my hearing health. O Allah, grant my sight health. There is no god but You.',
        count: 3,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'm_zawal_nima',
        textAr:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
        textEn:
            'O Allah, I seek refuge in You from the removal of Your blessing, the change of Your protection, the suddenness of Your punishment, and all that displeases You.',
        count: 1,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'm_istighfar100',
        textAr: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
        textEn: 'I seek forgiveness from Allah and repent to Him.',
        count: 100,
        reference: 'رواه مسلم',
      ),
    ],
  ),

  // ==================== أذكار المساء ====================
  AdhkarCategory(
    id: 'evening',
    nameAr: 'أذكار المساء',
    nameEn: 'Evening Adhkar',
    descAr: 'تُقال بعد العصر إلى المغرب',
    descEn: 'Recited between Asr and Maghrib',
    icon: Icons.nights_stay_rounded,
    items: [
      Dhikr(
        id: 'e_ayat_kursi',
        textAr:
            'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
        textEn:
            'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence...',
        count: 1,
        virtueAr: 'من قالها حين يمسي أُجير من الجن حتى يصبح',
        virtueEn:
            'Whoever recites it in the evening is protected from jinn until morning',
        reference: 'آية الكرسي - البقرة 255',
      ),
      Dhikr(
        id: 'e_ikhlas',
        textAr:
            'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        textEn:
            'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born. Nor is there to Him any equivalent.',
        count: 3,
        reference: 'سورة الإخلاص',
      ),
      Dhikr(
        id: 'e_falaq',
        textAr: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ...',
        textEn: 'Say: I seek refuge in the Lord of daybreak...',
        count: 3,
        reference: 'سورة الفلق',
      ),
      Dhikr(
        id: 'e_nas',
        textAr: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
        textEn: 'Say: I seek refuge in the Lord of mankind...',
        count: 3,
        reference: 'سورة الناس',
      ),
      Dhikr(
        id: 'e_amsayna',
        textAr:
            'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        textEn:
            'We have entered the evening and with it all dominion belongs to Allah. Praise is to Allah...',
        count: 1,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'e_sayyid_istighfar',
        textAr:
            'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ...',
        textEn:
            'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant...',
        count: 1,
        virtueAr:
            'من قالها موقناً بها حين يمسي فمات من ليلته دخل الجنة',
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'e_bika_amsayna',
        textAr:
            'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
        textEn:
            'O Allah, by You we enter the evening, by You we enter the morning, by You we live, by You we die, and to You is the final destination.',
        count: 1,
        reference: 'رواه الترمذي',
      ),
      Dhikr(
        id: 'e_ashhad',
        textAr:
            'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ...',
        textEn:
            'O Allah, I call upon You to witness in the evening, and I call the bearers of Your Throne...',
        count: 4,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'e_authu_kalimat',
        textAr:
            'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        textEn:
            'I seek refuge in the perfect words of Allah from the evil of what He created.',
        count: 3,
        virtueAr: 'لم يضره شيء تلك الليلة',
        virtueEn: 'Nothing will harm him that night',
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'e_hasbiyallah',
        textAr:
            'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        textEn:
            'Allah is sufficient for me. There is no god but Him. In Him I put my trust...',
        count: 7,
        reference: 'رواه ابن السني',
      ),
      Dhikr(
        id: 'e_bismillah',
        textAr:
            'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        textEn:
            'In the name of Allah, with whose name nothing can cause harm...',
        count: 3,
        reference: 'رواه الترمذي',
      ),
      Dhikr(
        id: 'e_raditu',
        textAr:
            'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا',
        textEn:
            'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad ﷺ as my prophet.',
        count: 3,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'e_subhan100',
        textAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        textEn: 'Glory be to Allah and praise be to Him.',
        count: 100,
        reference: 'رواه مسلم',
      ),
    ],
  ),

  // ==================== أذكار بعد الصلاة ====================
  AdhkarCategory(
    id: 'after_prayer',
    nameAr: 'أذكار بعد الصلاة',
    nameEn: 'After Prayer',
    descAr: 'تُقال بعد كل صلاة مفروضة',
    descEn: 'Recited after each obligatory prayer',
    icon: Icons.mosque_rounded,
    items: [
      Dhikr(
        id: 'p_istighfar',
        textAr: 'أَسْتَغْفِرُ اللَّهَ',
        textEn: 'I seek forgiveness from Allah.',
        count: 3,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'p_salam',
        textAr:
            'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        textEn:
            'O Allah, You are Peace and from You is peace. Blessed are You, O Owner of majesty and honor.',
        count: 1,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'p_la_hawla',
        textAr:
            'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        textEn:
            'There is no might nor power except with Allah. None has the right to be worshipped but Allah alone...',
        count: 1,
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'p_ayat_kursi',
        textAr: 'آيَةُ الْكُرْسِيِّ',
        textEn: 'Ayat al-Kursi',
        count: 1,
        virtueAr: 'من قالها بعد كل صلاة لم يمنعه من دخول الجنة إلا الموت',
        reference: 'رواه النسائي',
      ),
      Dhikr(
        id: 'p_muawwidhat',
        textAr: 'المُعَوِّذَات (الإخلاص والفلق والناس)',
        textEn: 'Al-Muawwidhat (Al-Ikhlas, Al-Falaq, An-Nas)',
        count: 1,
        reference: 'رواه أبو داود',
      ),
      Dhikr(
        id: 'p_subhan33',
        textAr: 'سُبْحَانَ اللَّهِ',
        textEn: 'Glory be to Allah.',
        count: 33,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'p_hamd33',
        textAr: 'الْحَمْدُ لِلَّهِ',
        textEn: 'Praise be to Allah.',
        count: 33,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'p_akbar33',
        textAr: 'اللَّهُ أَكْبَرُ',
        textEn: 'Allah is the Greatest.',
        count: 33,
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'p_tahlil',
        textAr:
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        textEn: 'None has the right to be worshipped but Allah alone...',
        count: 1,
        virtueAr: 'غُفرت خطاياه وإن كانت مثل زبد البحر',
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'p_aini_ala_dhikrik',
        textAr:
            'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        textEn:
            'O Allah, help me to remember You, to thank You, and to worship You in the best manner.',
        count: 1,
        reference: 'رواه أبو داود',
      ),
    ],
  ),

  // ==================== أذكار النوم ====================
  AdhkarCategory(
    id: 'sleep',
    nameAr: 'أذكار النوم',
    nameEn: 'Sleep Adhkar',
    descAr: 'تُقال قبل النوم',
    descEn: 'Recited before sleeping',
    icon: Icons.bedtime_rounded,
    items: [
      Dhikr(
        id: 's_bismika',
        textAr: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        textEn: 'In Your name, O Allah, I die and I live.',
        count: 1,
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 's_ayat_kursi',
        textAr: 'آيَةُ الْكُرْسِيِّ',
        textEn: 'Ayat al-Kursi',
        count: 1,
        virtueAr: 'من قرأها عند نومه لم يزل عليه من الله حافظ، ولا يقربه شيطان',
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 's_muawwidhat',
        textAr: 'المُعَوِّذَات',
        textEn: 'Al-Muawwidhat',
        count: 3,
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 's_aslamtu',
        textAr:
            'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
        textEn:
            'O Allah, I submit myself to You, I turn my face to You, I entrust my affairs to You...',
        count: 1,
        virtueAr:
            'من قالها ومات من ليلته مات على الفطرة',
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 's_subhan33',
        textAr: 'سُبْحَانَ اللَّهِ',
        textEn: 'Glory be to Allah.',
        count: 33,
      ),
      Dhikr(
        id: 's_hamd33',
        textAr: 'الْحَمْدُ لِلَّهِ',
        textEn: 'Praise be to Allah.',
        count: 33,
      ),
      Dhikr(
        id: 's_akbar34',
        textAr: 'اللَّهُ أَكْبَرُ',
        textEn: 'Allah is the Greatest.',
        count: 34,
        virtueAr: 'خير له من خادم',
        reference: 'رواه البخاري',
      ),
    ],
  ),

  // ==================== أذكار الاستيقاظ ====================
  AdhkarCategory(
    id: 'wakeup',
    nameAr: 'أذكار الاستيقاظ',
    nameEn: 'Waking Up',
    descAr: 'تُقال عند الاستيقاظ من النوم',
    descEn: 'Recited upon waking up',
    icon: Icons.wb_twilight_rounded,
    items: [
      Dhikr(
        id: 'w_hamd',
        textAr:
            'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        textEn:
            'Praise be to Allah Who gave us life after He caused us to die, and to Him is the return.',
        count: 1,
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'w_ayats',
        textAr: 'خَاتِمَة سُورَةِ آلِ عِمْرَان (إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ...)',
        textEn: 'Last verses of Aal-Imran',
        count: 1,
        reference: 'رواه البخاري',
      ),
      Dhikr(
        id: 'w_istighfar',
        textAr: 'أَسْتَغْفِرُ اللَّهَ',
        textEn: 'I seek forgiveness from Allah.',
        count: 3,
      ),
    ],
  ),

  // ==================== أذكار متفرقة ====================
  AdhkarCategory(
    id: 'misc',
    nameAr: 'أذكار متفرقة',
    nameEn: 'Miscellaneous',
    descAr: 'أذكار متنوعة لكل وقت',
    descEn: 'Various adhkar for all times',
    icon: Icons.auto_awesome_rounded,
    items: [
      Dhikr(
        id: 'x_subhan_allah',
        textAr: 'سُبْحَانَ اللَّهِ',
        textEn: 'Glory be to Allah.',
        count: 1,
      ),
      Dhikr(
        id: 'x_alhamd',
        textAr: 'الْحَمْدُ لِلَّهِ',
        textEn: 'Praise be to Allah.',
        count: 1,
      ),
      Dhikr(
        id: 'x_allahuakbar',
        textAr: 'اللَّهُ أَكْبَرُ',
        textEn: 'Allah is the Greatest.',
        count: 1,
      ),
      Dhikr(
        id: 'x_tahlil',
        textAr: 'لَا إِلَهَ إِلَّا اللَّهُ',
        textEn: 'None has the right to be worshipped but Allah.',
        count: 1,
      ),
      Dhikr(
        id: 'x_hawla',
        textAr: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        textEn: 'There is no might nor power except with Allah.',
        count: 1,
      ),
      Dhikr(
        id: 'x_salat_nabi',
        textAr:
            'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
        textEn:
            'O Allah, send Your peace and blessings upon Muhammad and his family.',
        count: 10,
        virtueAr: 'من صلى عليّ صلاة صلى الله عليه عشراً',
        reference: 'رواه مسلم',
      ),
      Dhikr(
        id: 'x_istighfar',
        textAr: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
        textEn: 'I seek forgiveness from Allah and repent to Him.',
        count: 100,
      ),
    ],
  ),
];
