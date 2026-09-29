import 'package:flutter/material.dart';

class ProhibitionItem {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final String evidenceAr;
  final String evidenceEn;
  final String reference;
  final bool isMajor; // كبيرة أم صغيرة

  const ProhibitionItem({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.evidenceAr,
    required this.evidenceEn,
    required this.reference,
    this.isMajor = true,
  });
}

class ProhibitionCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;
  final IconData icon;
  final List<ProhibitionItem> items;

  const ProhibitionCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.icon,
    required this.items,
  });
}

const List<ProhibitionCategory> kHaramCategories = [
  // ==================== 1) في العقيدة ====================
  ProhibitionCategory(
    id: 'aqeedah',
    nameAr: 'في العقيدة',
    nameEn: 'In Faith',
    descAr: 'أعظم المحرمات وأخطرها',
    descEn: 'The greatest and most dangerous prohibitions',
    icon: Icons.heart_broken_rounded,
    items: [
      ProhibitionItem(
        id: 'a_01',
        titleAr: 'الشرك بالله',
        titleEn: 'Shirk (associating partners with Allah)',
        descAr:
            'أن تجعل لله شريكاً في الربوبية أو الألوهية أو الأسماء والصفات. وهو أعظم الذنوب، لا يغفره الله لمن مات عليه.',
        descEn:
            'Associating any partner with Allah in His Lordship, Divinity, Names or Attributes. It is the greatest sin, unforgivable if one dies upon it.',
        evidenceAr:
            'إِنَّ اللَّهَ لَا يَغْفِرُ أَن يُشْرَكَ بِهِ وَيَغْفِرُ مَا دُونَ ذَٰلِكَ لِمَن يَشَاءُ',
        evidenceEn:
            'Indeed, Allah does not forgive association with Him, but He forgives what is less than that for whom He wills.',
        reference: 'النساء: 48',
      ),
      ProhibitionItem(
        id: 'a_02',
        titleAr: 'السحر',
        titleEn: 'Magic / Sorcery',
        descAr:
            'تعلّم السحر وتعليمه وعمله من الكبائر الموبقات. وهو كفر بالله تعالى.',
        descEn:
            'Learning, teaching, or practicing magic is among the destructive major sins. It is disbelief in Allah.',
        evidenceAr:
            'وَمَا يُعَلِّمَانِ مِنْ أَحَدٍ حَتَّىٰ يَقُولَا إِنَّمَا نَحْنُ فِتْنَةٌ فَلَا تَكْفُرْ',
        evidenceEn:
            'But the two angels do not teach anyone unless they say, "We are a trial, so do not disbelieve."',
        reference: 'البقرة: 102',
      ),
      ProhibitionItem(
        id: 'a_03',
        titleAr: 'الكفر والنفاق',
        titleEn: 'Disbelief & Hypocrisy',
        descAr:
            'الكفر: جحود الحق. النفاق: إظهار الإيمان وإبطان الكفر. وهو أشد من الكفر في بعض الأحوال.',
        descEn:
            'Disbelief: rejecting the truth. Hypocrisy: showing faith while hiding disbelief. In some cases it is worse than disbelief.',
        evidenceAr:
            'إِنَّ الْمُنَافِقِينَ فِي الدَّرْكِ الْأَسْفَلِ مِنَ النَّارِ',
        evidenceEn:
            'Indeed, the hypocrites will be in the lowest depths of the Fire.',
        reference: 'النساء: 145',
      ),
      ProhibitionItem(
        id: 'a_04',
        titleAr: 'سبّ الله أو رسوله أو الدين',
        titleEn: 'Insulting Allah, His Messenger or the Religion',
        descAr:
            'من سبّ الله أو رسوله ﷺ أو استهزأ بالدين فقد كفر بإجماع العلماء.',
        descEn:
            'Whoever insults Allah, His Messenger ﷺ, or mocks the religion has committed disbelief by consensus.',
        evidenceAr:
            'قُلْ أَبِاللَّهِ وَآيَاتِهِ وَرَسُولِهِ كُنتُمْ تَسْتَهْزِئُونَ',
        evidenceEn:
            'Say: "Was it Allah and His verses and His Messenger that you were mocking?"',
        reference: 'التوبة: 65',
      ),
      ProhibitionItem(
        id: 'a_05',
        titleAr: 'البدعة في الدين',
        titleEn: 'Innovation in Religion (Bid\'ah)',
        descAr:
            'إحداث شيء في الدين لم يشرعه الله ولا رسوله ﷺ. كل بدعة في الدين مردودة.',
        descEn:
            'Introducing something into the religion that Allah or His Messenger ﷺ did not legislate. Every innovation in religion is rejected.',
        evidenceAr:
            'مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ',
        evidenceEn:
            'Whoever introduces into this matter of ours something that is not part of it, it will be rejected.',
        reference: 'رواه البخاري ومسلم',
      ),
    ],
  ),

  // ==================== 2) في العبادات ====================
  ProhibitionCategory(
    id: 'worship',
    nameAr: 'في العبادات',
    nameEn: 'In Worship',
    descAr: 'ما حُرّم من العبادات والفرائض',
    descEn: 'Prohibited matters in acts of worship',
    icon: Icons.mosque_rounded,
    items: [
      ProhibitionItem(
        id: 'w_01',
        titleAr: 'ترك الصلاة',
        titleEn: 'Abandoning Prayer',
        descAr:
            'ترك الصلاة المفروضة من أعظم الكبائر، وهو فرق بين المسلم والكافر.',
        descEn:
            'Abandoning the obligatory prayer is among the greatest sins. It distinguishes a Muslim from a disbeliever.',
        evidenceAr:
            'بَيْنَ الرَّجُلِ وَبَيْنَ الْكُفْرِ وَالشِّرْكِ تَرْكُ الصَّلَاةِ',
        evidenceEn:
            'Between a man and disbelief and polytheism is abandoning the prayer.',
        reference: 'رواه مسلم',
      ),
      ProhibitionItem(
        id: 'w_02',
        titleAr: 'منع الزكاة',
        titleEn: 'Withholding Zakat',
        descAr:
            'منع الزكاة الواجبة مع القدرة عليها من الكبائر، وقد تُوعد فاعلها بعذاب أليم.',
        descEn:
            'Withholding obligatory Zakat despite being able to pay is a major sin with a severe warning.',
        evidenceAr:
            'وَالَّذِينَ يَكْنِزُونَ الذَّهَبَ وَالْفِضَّةَ وَلَا يُنفِقُونَهَا فِي سَبِيلِ اللَّهِ فَبَشِّرْهُم بِعَذَابٍ أَلِيمٍ',
        evidenceEn:
            'And those who hoard gold and silver and spend it not in the way of Allah — give them tidings of a painful punishment.',
        reference: 'التوبة: 34',
      ),
      ProhibitionItem(
        id: 'w_03',
        titleAr: 'الفطر في رمضان بلا عذر',
        titleEn: 'Breaking the Fast in Ramadan Without Excuse',
        descAr:
            'الفطر في نهار رمضان بلا عذر شرعي من الكبائر، مع وجوب القضاء والكفارة في بعض الحالات.',
        descEn:
            'Breaking the fast during Ramadan without a valid excuse is a major sin, requiring make-up and expiation.',
        evidenceAr:
            'وَمَن كَانَ مَرِيضًا أَوْ عَلَىٰ سَفَرٍ فَعِدَّةٌ مِّنْ أَيَّامٍ أُخَرَ',
        evidenceEn:
            'Whoever is ill or on a journey — then an equal number of other days.',
        reference: 'البقرة: 184',
      ),
      ProhibitionItem(
        id: 'w_04',
        titleAr: 'الرياء في العبادة',
        titleEn: 'Showing Off (Riya) in Worship',
        descAr:
            'إرادة غير وجه الله بالعمل الصالح. وهو شرك أصغر، ويُحبط العمل.',
        descEn:
            'Seeking other than Allah\'s Face through righteous deeds. It is minor shirk and invalidates the deed.',
        evidenceAr:
            'مَنْ عَمِلَ عَمَلًا أَشْرَكَ فِيهِ مَعِي غَيْرِي فَهُوَ لَهُ',
        evidenceEn:
            'Whoever does a deed in which he associates others with Me, it is for that other.',
        reference: 'رواه مسلم',
      ),
      ProhibitionItem(
        id: 'w_05',
        titleAr: 'الحلف بغير الله',
        titleEn: 'Swearing by Other Than Allah',
        descAr:
            'الحلف بغير الله كالنبي أو الكعبة أو الأمانة من الشرك، إلا إذا اعتقد أن للمحلوف به قدرة كقدرة الله.',
        descEn:
            'Swearing by other than Allah — like the Prophet, the Kaaba, or one\'s honor — is shirk unless one believes it has power like Allah\'s.',
        evidenceAr:
            'مَنْ حَلَفَ بِغَيْرِ اللَّهِ فَقَدْ كَفَرَ أَوْ أَشْرَكَ',
        evidenceEn:
            'Whoever swears by other than Allah has disbelieved or associated partners with Him.',
        reference: 'رواه الترمذي',
      ),
    ],
  ),

  // ==================== 3) في المعاملات ====================
  ProhibitionCategory(
    id: 'transactions',
    nameAr: 'في المعاملات',
    nameEn: 'In Transactions',
    descAr: 'ما حُرّم في البيع والشراء والأموال',
    descEn: 'Prohibited matters in trade and wealth',
    icon: Icons.gavel_rounded,
    items: [
      ProhibitionItem(
        id: 't_01',
        titleAr: 'الربا',
        titleEn: 'Riba (Interest/Usury)',
        descAr:
            'الزيادة في القرض أو البيع. من أكبر الكبائر، وقد أعلن الله الحرب على آكله.',
        descEn:
            'An increase in loan or sale. It is among the greatest sins, and Allah declared war on those who consume it.',
        evidenceAr:
            'فَإِن لَّمْ تَفْعَلُوا فَأْذَنُوا بِحَرْبٍ مِّنَ اللَّهِ وَرَسُولِهِ',
        evidenceEn:
            'But if you do not, then be informed of a war [against you] from Allah and His Messenger.',
        reference: 'البقرة: 279',
      ),
      ProhibitionItem(
        id: 't_02',
        titleAr: 'أكل مال اليتيم',
        titleEn: 'Consuming Orphan\'s Wealth',
        descAr:
            'التعدّي على مال اليتيم ظلماً من الموبقات السبع.',
        descEn:
            'Unjustly consuming the orphan\'s wealth is among the seven destructive sins.',
        evidenceAr:
            'إِنَّ الَّذِينَ يَأْكُلُونَ أَمْوَالَ الْيَتَامَىٰ ظُلْمًا إِنَّمَا يَأْكُلُونَ فِي بُطُونِهِمْ نَارًا',
        evidenceEn:
            'Indeed, those who devour the wealth of orphans unjustly only consume fire into their bellies.',
        reference: 'النساء: 10',
      ),
      ProhibitionItem(
        id: 't_03',
        titleAr: 'الغش',
        titleEn: 'Deception / Fraud',
        descAr:
            'الغش في البيع والشراء أو الصنعة أو العمل. من غشّ فليس منا.',
        descEn:
            'Deception in trade, work, or craft. Whoever cheats is not one of us.',
        evidenceAr:
            'مَنْ غَشَّ فَلَيْسَ مِنِّي',
        evidenceEn:
            'Whoever cheats is not one of us.',
        reference: 'رواه مسلم',
      ),
      ProhibitionItem(
        id: 't_04',
        titleAr: 'الرشوة',
        titleEn: 'Bribery',
        descAr:
            'الرشوة في الأحكام والوظائف من الكبائر، والراشي والمرتشي في النار.',
        descEn:
            'Bribery in judgments and positions is a major sin; both the giver and receiver are cursed.',
        evidenceAr:
            'لَعَنَ رَسُولُ اللَّهِ ﷺ الرَّاشِي وَالْمُرْتَشِي',
        evidenceEn:
            'The Messenger of Allah ﷺ cursed the one who gives a bribe and the one who takes it.',
        reference: 'رواه أبو داود',
      ),
      ProhibitionItem(
        id: 't_05',
        titleAr: 'الاحتكار',
        titleEn: 'Monopoly / Hoarding',
        descAr:
            'حبس السلع الضرورية لرفع أسعارها. لا يحتكر إلا خاطئ.',
        descEn:
            'Hoarding essential goods to raise prices. None hoards except a sinner.',
        evidenceAr:
            'لَا يَحْتَكِرُ إِلَّا خَاطِئٌ',
        evidenceEn:
            'No one hoards except a sinner.',
        reference: 'رواه مسلم',
      ),
      ProhibitionItem(
        id: 't_06',
        titleAr: 'السرقة',
        titleEn: 'Theft',
        descAr:
            'أخذ مال الغير بغير حق. من الكبائر التي يجب فيها الحد الشرعي.',
        descEn:
            'Taking others\' wealth unjustly. A major sin with a prescribed legal punishment.',
        evidenceAr:
            'وَالسَّارِقُ وَالسَّارِقَةُ فَاقْطَعُوا أَيْدِيَهُمَا',
        evidenceEn:
            'The thief, male or female, cut off their hands.',
        reference: 'المائدة: 38',
      ),
      ProhibitionItem(
        id: 't_07',
        titleAr: 'شهادة الزور',
        titleEn: 'False Testimony',
        descAr:
            'شهادة بغير الحق. تعدل الشرك بالله، ومن الكبائر.',
        descEn:
            'Testifying falsely. It is equal to shirk with Allah and among major sins.',
        evidenceAr:
            'وَقَوْلِ الزُّورِ',
        evidenceEn:
            'And false statements.',
        reference: 'الحج: 30',
      ),
      ProhibitionItem(
        id: 't_08',
        titleAr: 'القمار (الميسر)',
        titleEn: 'Gambling',
        descAr:
            'كل ما فيه رهان ومخاطرة بمال. من عمل الشيطان.',
        descEn:
            'Any betting or risk of wealth. It is the work of Satan.',
        evidenceAr:
            'يَا أَيُّهَا الَّذِينَ آمَنُوا إِنَّمَا الْخَمْرُ وَالْمَيْسِرُ وَالْأَنصَابُ وَالْأَزْلَامُ رِجْسٌ مِّنْ عَمَلِ الشَّيْطَانِ',
        evidenceEn:
            'O you who have believed, indeed intoxicants, gambling, and divination are defilement from the work of Satan.',
        reference: 'المائدة: 90',
      ),
    ],
  ),

  // ==================== 4) في الآداب ====================
  ProhibitionCategory(
    id: 'manners',
    nameAr: 'في الآداب والأخلاق',
    nameEn: 'In Manners & Ethics',
    descAr: 'ما حُرّم على اللسان والقلب',
    descEn: 'Prohibited matters of the tongue and heart',
    icon: Icons.psychology_rounded,
    items: [
      ProhibitionItem(
        id: 'm_01',
        titleAr: 'الغيبة',
        titleEn: 'Backbiting (Gheebah)',
        descAr:
            'ذكر الإنسان بما يكره في غيبته مما هو فيه. كأكل لحم أخيك ميتاً.',
        descEn:
            'Mentioning a person in his absence with what he dislikes, even if true. Like eating your dead brother\'s flesh.',
        evidenceAr:
            'وَلَا يَغْتَب بَّعْضُكُم بَعْضًا ۚ أَيُحِبُّ أَحَدُكُمْ أَن يَأْكُلَ لَحْمَ أَخِيهِ مَيْتًا',
        evidenceEn:
            'And do not backbite one another. Would one of you like to eat the flesh of his dead brother?',
        reference: 'الحجرات: 12',
      ),
      ProhibitionItem(
        id: 'm_02',
        titleAr: 'النميمة',
        titleEn: 'Tale-carrying (Nameemah)',
        descAr:
            'نقل الكلام بين الناس للإفساد بينهم. لا يدخل الجنة نمّام.',
        descEn:
            'Carrying words between people to cause corruption. The tale-carrier will not enter Paradise.',
        evidenceAr:
            'لَا يَدْخُلُ الْجَنَّةَ نَمَّامٌ',
        evidenceEn:
            'The tale-carrier will not enter Paradise.',
        reference: 'رواه مسلم',
      ),
      ProhibitionItem(
        id: 'm_03',
        titleAr: 'الكذب',
        titleEn: 'Lying',
        descAr:
            'الإخبار بغير الحقيقة عمداً. من الكبائر، والكذب يهدي إلى الفجور.',
        descEn:
            'Intentionally reporting other than the truth. A major sin; lying leads to wickedness.',
        evidenceAr:
            'وَإِنَّ الْكَذِبَ يَهْدِي إِلَى الْفُجُورِ',
        evidenceEn:
            'And indeed lying leads to wickedness.',
        reference: 'رواه البخاري',
      ),
      ProhibitionItem(
        id: 'm_04',
        titleAr: 'الحسد',
        titleEn: 'Envy (Hasad)',
        descAr:
            'كراهية نعمة الله على الغير وتمني زوالها. يأكل الحسنات كما تأكل النار الحطب.',
        descEn:
            'Disliking Allah\'s blessing upon others and wishing it removed. It consumes good deeds like fire consumes wood.',
        evidenceAr:
            'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        evidenceEn:
            'And from the evil of an envier when he envies.',
        reference: 'الفلق: 5',
      ),
      ProhibitionItem(
        id: 'm_05',
        titleAr: 'السخرية والاستهزاء',
        titleEn: 'Mockery / Ridicule',
        descAr:
            'احتقار الآخرين والاستهزاء بهم. من الكبائر إذا كان بمسلم.',
        descEn:
            'Belittling and mocking others. A major sin when directed at a Muslim.',
        evidenceAr:
            'يَا أَيُّهَا الَّذِينَ آمَنُوا لَا يَسْخَرْ قَوْمٌ مِّن قَوْمٍ',
        evidenceEn:
            'O you who have believed, let not a people ridicule another people.',
        reference: 'الحجرات: 11',
      ),
      ProhibitionItem(
        id: 'm_06',
        titleAr: 'الغدر ونقض العهد',
        titleEn: 'Treachery & Breaking Promises',
        descAr:
            'نقض العهد وإخلاف الوعد من صفات المنافقين.',
        descEn:
            'Breaking covenants and promises is among the traits of hypocrites.',
        evidenceAr:
            'وَإِذَا عَاهَدُوا عَهْدًا نَّقَضُوهُ',
        evidenceEn:
            'And when they made a covenant, they broke it.',
        reference: 'البقرة: 100',
      ),
      ProhibitionItem(
        id: 'm_07',
        titleAr: 'العجب والكبر',
        titleEn: 'Arrogance & Conceit',
        descAr:
            'الكِبر: رد الحق واحتقار الخلق. لا يدخل الجنة من كان في قلبه مثقال ذرة من كبر.',
        descEn:
            'Arrogance: rejecting the truth and despising people. No one with a mustard seed of arrogance will enter Paradise.',
        evidenceAr:
            'لَا يَدْخُلُ الْجَنَّةَ مَنْ كَانَ فِي قَلْبِهِ مِثْقَالُ ذَرَّةٍ مِنْ كِبْرٍ',
        evidenceEn:
            'No one who has a mustard seed of arrogance in his heart will enter Paradise.',
        reference: 'رواه مسلم',
      ),
    ],
  ),

  // ==================== 5) في البدن ====================
  ProhibitionCategory(
    id: 'body',
    nameAr: 'في البدن والجوارح',
    nameEn: 'In the Body & Limbs',
    descAr: 'ما حُرّم على البدن والنظر',
    descEn: 'Prohibited matters of the body and sight',
    icon: Icons.warning_amber_rounded,
    items: [
      ProhibitionItem(
        id: 'b_01',
        titleAr: 'قتل النفس',
        titleEn: 'Murder',
        descAr:
            'قتل النفس التي حرّم الله إلا بالحق. من أكبر الكبائر بعد الشرك.',
        descEn:
            'Killing a soul that Allah has forbidden, except by right. Among the greatest sins after shirk.',
        evidenceAr:
            'وَمَن يَقْتُلْ مُؤْمِنًا مُّتَعَمِّدًا فَجَزَاؤُهُ جَهَنَّمُ',
        evidenceEn:
            'And whoever kills a believer intentionally, his recompense is Hell.',
        reference: 'النساء: 93',
      ),
      ProhibitionItem(
        id: 'b_02',
        titleAr: 'الزنا',
        titleEn: 'Adultery / Fornication',
        descAr:
            'إتيان الفاحشة. من أكبر الكبائر، وقد قُرن بالشرك وقتل النفس.',
        descEn:
            'Committing immorality. Among the greatest sins, mentioned alongside shirk and murder.',
        evidenceAr:
            'وَلَا تَقْرَبُوا الزِّنَىٰ إِنَّهُ كَانَ فَاحِشَةً وَسَاءَ سَبِيلًا',
        evidenceEn:
            'And do not approach unlawful sexual intercourse. Indeed, it is immorality and an evil way.',
        reference: 'الإسراء: 32',
      ),
      ProhibitionItem(
        id: 'b_03',
        titleAr: 'الخمر والمسكرات',
        titleEn: 'Alcohol & Intoxicants',
        descAr:
            'كل مسكر حرام، وهو أم الخبائث، وقد لُعن شاربها وبائعها وحاملها.',
        descEn:
            'Every intoxicant is forbidden. It is the mother of all evils.',
        evidenceAr:
            'كُلُّ مُسْكِرٍ حَرَامٌ',
        evidenceEn:
            'Every intoxicant is forbidden.',
        reference: 'رواه البخاري ومسلم',
      ),
      ProhibitionItem(
        id: 'b_04',
        titleAr: 'المخدرات',
        titleEn: 'Drugs',
        descAr:
            'كل ما يُغيّب العقل أو يُفسد البدن من المخدرات حرام، وهو من الخبائث.',
        descEn:
            'All drugs that impair the mind or harm the body are forbidden and impure.',
        evidenceAr:
            'وَيُحَرِّمُ عَلَيْهِمُ الْخَبَائِثَ',
        evidenceEn:
            'And he prohibits for them the impure things.',
        reference: 'الأعراف: 157',
      ),
      ProhibitionItem(
        id: 'b_05',
        titleAr: 'النظر المحرم',
        titleEn: 'Forbidden Gaze',
        descAr:
            'النظر إلى ما حرّم الله من النساء أو الرجال بشهوة. غض البصر واجب.',
        descEn:
            'Looking at what Allah has forbidden with desire. Lowering the gaze is obligatory.',
        evidenceAr:
            'قُل لِّلْمُؤْمِنِينَ يَغُضُّوا مِنْ أَبْصَارِهِمْ',
        evidenceEn:
            'Tell the believing men to lower their gaze.',
        reference: 'النور: 30',
      ),
      ProhibitionItem(
        id: 'b_06',
        titleAr: 'عقوق الوالدين',
        titleEn: 'Disobeying Parents',
        descAr:
            'إيذاء الوالدين أو إغضابهما أو رفعهما. من أكبر الكبائر.',
        descEn:
            'Harm, anger, or harshness toward parents. One of the greatest sins.',
        evidenceAr:
            'وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا',
        evidenceEn:
            'And your Lord has decreed that you worship none but Him, and that you be dutiful to your parents.',
        reference: 'الإسراء: 23',
      ),
    ],
  ),
];
