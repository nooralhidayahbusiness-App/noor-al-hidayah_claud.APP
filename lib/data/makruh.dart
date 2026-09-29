import 'package:flutter/material.dart';

import 'haram.dart';

const List<ProhibitionCategory> kMakruhCategories = [
  // ==================== 1) في العبادات ====================
  ProhibitionCategory(
    id: 'worship',
    nameAr: 'في العبادات',
    nameEn: 'In Worship',
    descAr: 'ما يُكره في الصلاة والوضوء',
    descEn: 'Disliked matters in prayer and ablution',
    icon: Icons.mosque_rounded,
    items: [
      ProhibitionItem(
        id: 'mw_01',
        titleAr: 'الكلام أثناء الوضوء بلا حاجة',
        titleEn: 'Talking during ablution without need',
        descAr:
            'يُكره الكلام أثناء الوضوء بغير حاجة، لما فيه من انقطاع الذكر.',
        descEn:
            'Talking during ablution without need is disliked, as it interrupts remembrance.',
        evidenceAr: 'يُكره عند الجمهور',
        evidenceEn: 'Disliked by the majority of scholars',
        reference: 'الفتاوى الفقهية',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mw_02',
        titleAr: 'رفع الصوت في المسجد',
        titleEn: 'Raising the voice in the mosque',
        descAr:
            'يُكره رفع الصوت في المسجد إلا في الذكر والتعليم.',
        descEn:
            'Raising the voice in the mosque is disliked except for remembrance and teaching.',
        evidenceAr:
            'وَأَنْ تَجْهَرُوا بِالْقَوْلِ كَجَهْرِ بَعْضِكُمْ لِبَعْضٍ',
        evidenceEn:
            'Nor speak loudly to one another as you speak loudly to one another.',
        reference: 'الحجرات: 2',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mw_03',
        titleAr: 'المرور أمام المصلي',
        titleEn: 'Passing in front of a praying person',
        descAr:
            'يُكره المرور بين يدي المصلي إلا من وراء سترة أو بعيد.',
        descEn:
            'Passing in front of one who is praying is disliked, unless beyond a sutrah or far away.',
        evidenceAr:
            'لَوْ يَعْلَمُ الْمَارُّ بَيْنَ يَدَيِ الْمُصَلِّي مَاذَا عَلَيْهِ لَكَانَ أَنْ يَقِفَ أَرْبَعِينَ خَيْرًا لَهُ مِنْ أَنْ يَمُرَّ',
        evidenceEn:
            'If the one passing in front of a praying person knew what was upon him, standing 40 would be better for him than passing.',
        reference: 'رواه البخاري',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mw_04',
        titleAr: 'تشبيك الأصابع في المسجد',
        titleEn: 'Interlacing fingers in the mosque',
        descAr:
            'يُكره تشبيك الأصابع في المسجد أو أثناء انتظار الصلاة.',
        descEn:
            'Interlacing fingers in the mosque or while waiting for prayer is disliked.',
        evidenceAr: 'يُكره عند الجمهور',
        evidenceEn: 'Disliked by the majority of scholars',
        reference: 'الفتاوى الفقهية',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mw_05',
        titleAr: 'النظر إلى السماء في الصلاة',
        titleEn: 'Looking at the sky during prayer',
        descAr:
            'يُكره رفع البصر إلى السماء في الصلاة، ويُستحب النظر إلى موضع السجود.',
        descEn:
            'Raising the gaze to the sky during prayer is disliked; looking at the place of prostration is preferred.',
        evidenceAr:
            'لَيَنْتَهِيَنَّ الَّذِينَ يَرْفَعُونَ أَبْصَارَهُمْ إِلَى السَّمَاءِ فِي الصَّلَاةِ أَوْ لَتُخْطَفَنَّ أَبْصَارُهُمْ',
        evidenceEn:
            'Those who raise their eyes to the sky during prayer must stop or their sight will be taken away.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
    ],
  ),

  // ==================== 2) في الطعام والشراب ====================
  ProhibitionCategory(
    id: 'food',
    nameAr: 'في الطعام والشراب',
    nameEn: 'In Food & Drink',
    descAr: 'آداب الطعام والشراب',
    descEn: 'Etiquettes of eating and drinking',
    icon: Icons.restaurant_rounded,
    items: [
      ProhibitionItem(
        id: 'mf_01',
        titleAr: 'الشرب بنفس واحد',
        titleEn: 'Drinking in one breath',
        descAr:
            'يُكره الشرب بنفس واحد، والسنة الشرب على ثلاث مرات.',
        descEn:
            'Drinking in one breath is disliked; the Sunnah is to drink in three sips.',
        evidenceAr:
            'كَانَ يَشْرَبُ بِثَلَاثَةِ أَنْفَاسٍ',
        evidenceEn:
            'He used to drink in three breaths.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mf_02',
        titleAr: 'التنفس في الإناء',
        titleEn: 'Breathing into the vessel',
        descAr:
            'يُكره التنفس في الإناء أثناء الشرب.',
        descEn:
            'Breathing into the vessel while drinking is disliked.',
        evidenceAr:
            'إِذَا شَرِبَ أَحَدُكُمْ فَلَا يَتَنَفَّسْ فِي الْإِنَاءِ',
        evidenceEn:
            'When one of you drinks, let him not breathe into the vessel.',
        reference: 'رواه البخاري',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mf_03',
        titleAr: 'النفخ في الطعام والشراب',
        titleEn: 'Blowing on food or drink',
        descAr:
            'يُكره النفخ في الطعام والشراب لغير حاجة.',
        descEn:
            'Blowing on food or drink without need is disliked.',
        evidenceAr: 'نَهَى عَنِ النَّفْخِ فِي الطَّعَامِ وَالشَّرَابِ',
        evidenceEn:
            'He forbade blowing on food and drink.',
        reference: 'رواه أبو داود',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mf_04',
        titleAr: 'الأكل متكئاً',
        titleEn: 'Eating while reclining',
        descAr:
            'يُكره الأكل والشرب متكئاً على ما ذهب إليه الجمهور.',
        descEn:
            'Eating and drinking while reclining is disliked per the majority.',
        evidenceAr:
            'أَمَا إِنِّي لَا آكُلُ مُتَّكِئًا',
        evidenceEn:
            'I do not eat while reclining.',
        reference: 'رواه البخاري',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mf_05',
        titleAr: 'الأكل والشرب بالشمال',
        titleEn: 'Eating and drinking with the left hand',
        descAr:
            'يُكره الأكل والشرب بالشمال، والسنة باليمين.',
        descEn:
            'Eating and drinking with the left hand is disliked; the Sunnah is the right.',
        evidenceAr:
            'إِذَا أَكَلَ أَحَدُكُمْ فَلْيَأْكُلْ بِيَمِينِهِ',
        evidenceEn:
            'When one of you eats, let him eat with his right hand.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
    ],
  ),

  // ==================== 3) في المعاملات ====================
  ProhibitionCategory(
    id: 'transactions',
    nameAr: 'في المعاملات',
    nameEn: 'In Transactions',
    descAr: 'ما يُكره في البيع والشراء',
    descEn: 'Disliked matters in trade',
    icon: Icons.shopping_bag_rounded,
    items: [
      ProhibitionItem(
        id: 'mt_01',
        titleAr: 'البيع على بيع أخيك',
        titleEn: 'Selling over your brother\'s sale',
        descAr:
            'يُكره أن يبيع على بيع أخيه بعد اتفاقه مع المشتري.',
        descEn:
            'Selling over your brother\'s sale after he agreed with the buyer is disliked.',
        evidenceAr:
            'لَا يَبِيعُ الرَّجُلُ عَلَى بَيْعِ أَخِيهِ',
        evidenceEn:
            'A man should not sell over the sale of his brother.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mt_02',
        titleAr: 'السوم على سوم أخيك',
        titleEn: 'Bidding over your brother\'s bid',
        descAr:
            'يُكره أن يزيد في السوم بعد أن استقر سعر أخيه.',
        descEn:
            'Increasing the bid after your brother\'s price is settled is disliked.',
        evidenceAr:
            'وَلَا يَسُومُ عَلَى سَوْمِ أَخِيهِ',
        evidenceEn:
            'And he should not bid over his brother\'s bid.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mt_03',
        titleAr: 'النجش',
        titleEn: 'Najsh (fake bidding)',
        descAr:
            'الزيادة في السلعة بلا رغبة حقيقية لإغواء المشتري.',
        descEn:
            'Bidding up a product without intention to buy, to lure the buyer.',
        evidenceAr:
            'وَلَا تَنَاجَشُوا',
        evidenceEn:
            'And do not practice Najsh.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mt_04',
        titleAr: 'كثرة الحلف في البيع',
        titleEn: 'Excessive swearing in trade',
        descAr:
            'يُكره الحلف كثيراً في البيع، فقد يمحق البركة.',
        descEn:
            'Excessive swearing in trade is disliked; it may erase blessings.',
        evidenceAr:
            'الْحَلِفُ مُنْفِقَةٌ لِلسِّلْعَةِ مَمْحَقَةٌ لِلْبَرَكَةِ',
        evidenceEn:
            'Swearing is a means of selling but erases blessing.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
    ],
  ),

  // ==================== 4) في الآداب ====================
  ProhibitionCategory(
    id: 'manners',
    nameAr: 'في الآداب',
    nameEn: 'In Manners',
    descAr: 'ما يُكره في التعامل والسلوك',
    descEn: 'Disliked matters in behavior',
    icon: Icons.psychology_rounded,
    items: [
      ProhibitionItem(
        id: 'mm_01',
        titleAr: 'الضحك بصوت عالٍ',
        titleEn: 'Laughing loudly',
        descAr:
            'يُكره القهقهة ورفع الصوت في الضحك، لا سيما في المسجد أو عند سماع القرآن.',
        descEn:
            'Loud laughing and raising the voice is disliked, especially in the mosque.',
        evidenceAr: 'يُكره عند الجمهور',
        evidenceEn: 'Disliked by the majority',
        reference: 'الفتاوى الفقهية',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mm_02',
        titleAr: 'كثرة الحلف بغير الله',
        titleEn: 'Frequent swearing by other than Allah',
        descAr:
            'يُكره كثرة الحلف، وأشدّ منه بغير الله.',
        descEn:
            'Frequent swearing is disliked; worse is by other than Allah.',
        evidenceAr:
            'وَلَا تَكْثِرُوا الْحَلِفَ',
        evidenceEn:
            'And do not swear excessively.',
        reference: 'المزمل: حكم',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mm_03',
        titleAr: 'النوم قبل العشاء والحديث بعده',
        titleEn: 'Sleeping before Isha and talking after it',
        descAr:
            'يُكره النوم قبل صلاة العشاء، والحديث بعدها في غير خير.',
        descEn:
            'Sleeping before Isha and talking after it without good is disliked.',
        evidenceAr:
            'كَانَ يَكْرَهُ النَّوْمَ قَبْلَ الْعِشَاءِ وَالْحَدِيثَ بَعْدَهَا',
        evidenceEn:
            'He disliked sleeping before Isha and talking after it.',
        reference: 'رواه البخاري',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mm_04',
        titleAr: 'تشميت العاطس الكافر',
        titleEn: 'Saying "Yarhamuk Allah" to a non-Muslim who sneezes',
        descAr:
            'لا يُشمّت الكافر عند العطاس، بل يُقال له: "يهديكم الله ويصلح بالكم".',
        descEn:
            'A non-Muslim is not given the sneeze response; instead say: "May Allah guide you and set your affairs right."',
        evidenceAr:
            'إِذَا عَطَسَ أَحَدُكُمْ فَحَمِدَ اللَّهَ فَشَمِّتُوهُ',
        evidenceEn:
            'When one of you sneezes and praises Allah, respond to him.',
        reference: 'رواه مسلم',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mm_05',
        titleAr: 'الاستماع إلى الغناء اللهوي',
        titleEn: 'Listening to idle music',
        descAr:
            'يُكره الاستماع إلى الغناء الذي يلهي عن ذكر الله، ويُحرَّم إذا اقترن بمحرم.',
        descEn:
            'Listening to music that distracts from remembrance is disliked; it becomes forbidden when combined with other prohibitions.',
        evidenceAr: 'خلاف بين العلماء',
        evidenceEn: 'Differed upon by scholars',
        reference: 'مسألة خلافية',
        isMajor: false,
      ),
      ProhibitionItem(
        id: 'mm_06',
        titleAr: 'الدخول على النساء بغير إذن',
        titleEn: 'Entering upon women without permission',
        descAr:
            'يُكره دخول الرجال على النساء بلا إذن، والسنة الاستئذان ثلاثاً.',
        descEn:
            'Entering upon women without permission is disliked; the Sunnah is to ask three times.',
        evidenceAr:
            'الِاسْتِئْذَانُ ثَلَاثًا',
        evidenceEn:
            'Seeking permission three times.',
        reference: 'رواه البخاري',
        isMajor: false,
      ),
    ],
  ),
];
