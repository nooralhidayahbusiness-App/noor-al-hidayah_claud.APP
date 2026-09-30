import 'package:flutter/material.dart';

/// قسم تعليمي في المعلم الذكي.
class TeacherCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;
  final IconData icon;
  final String promptAr; // أمر البداية للـ AI
  final String promptEn;

  const TeacherCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.icon,
    required this.promptAr,
    required this.promptEn,
  });
}

/// الأقسام التعليمية المتاحة.
const List<TeacherCategory> kTeacherCategories = [
  TeacherCategory(
    id: 'tajweed',
    nameAr: 'أحكام التجويد',
    nameEn: 'Tajweed Rules',
    descAr: 'تعلّم أحكام التجويد خطوة بخطوة',
    descEn: 'Learn Tajweed rules step by step',
    icon: Icons.record_voice_over_rounded,
    promptAr:
        'أريد أن تعلّمني أحكام التجويد. ابدأ بأهم قاعدة وأعطني مثالاً واضحاً. اجعل الشرح مبسطاً ومتدرجاً.',
    promptEn:
        'I want to learn Tajweed rules. Start with the most important rule and give me a clear example. Keep it simple and progressive.',
  ),
  TeacherCategory(
    id: 'recitation',
    nameAr: 'تصحيح التلاوة',
    nameEn: 'Recitation Correction',
    descAr: 'أرسل تلاوتك ودع المعلم يصحح لك',
    descEn: 'Send your recitation and let the teacher correct you',
    icon: Icons.mic_rounded,
    promptAr:
        'أريد أن أصحح تلاوتي. اقرأ لي آية من سورة الفاتحة، ثم قل لي كيف أقرأها بشكل صحيح، وما الأخطاء الشائعة في نطقها.',
    promptEn:
        'I want to correct my recitation. Read me a verse from Al-Fatihah, then tell me how to read it correctly and common pronunciation mistakes.',
  ),
  TeacherCategory(
    id: 'tafsir',
    nameAr: 'تدبر وتفسير',
    nameEn: 'Tafsir & Reflection',
    descAr: 'افهم معاني الآيات وتدبر دلالاتها',
    descEn: 'Understand verses and reflect on their meanings',
    icon: Icons.auto_stories_rounded,
    promptAr:
        'أريد أن أفهم معاني القرآن. اشرح لي آية الكرسي (البقرة: 255) بشكل مبسط، وبيّن تدبراتها العملية في حياتنا اليومية.',
    promptEn:
        'I want to understand Quran meanings. Explain Ayat al-Kursi (Al-Baqarah: 255) simply and its practical reflections in our daily life.',
  ),
  TeacherCategory(
    id: 'hifz',
    nameAr: 'خطة الحفظ',
    nameEn: 'Memorization Plan',
    descAr: 'بناء خطة حفظ واقعية ومستمرة',
    descEn: 'Build a realistic and consistent memorization plan',
    icon: Icons.psychology_rounded,
    promptAr:
        'أريد خطة لحفظ القرآن. اسألني عن: كم أحفظ يومياً، ومتى، وما السور التي أريد حفظها، ثم ابنِ لي خطة أسبوعية واقعية.',
    promptEn:
        'I want a Quran memorization plan. Ask me: how much I can memorize daily, when, and which surahs I want to memorize, then build a realistic weekly plan.',
  ),
  TeacherCategory(
    id: 'meaning',
    nameAr: 'معاني الكلمات',
    nameEn: 'Word Meanings',
    descAr: 'افهم معاني الكلمات القرآنية',
    descEn: 'Understand the meanings of Quranic words',
    icon: Icons.translate_rounded,
    promptAr:
        'أريد أن أعرف معاني الكلمات القرآنية. اختر 5 كلمات متكررة في القرآن (مثل: التقوى، الإحسان، الصبر، الإيمان، الفلاح)، واشرح كل واحدة ببساطة.',
    promptEn:
        'I want to know the meanings of Quranic words. Pick 5 frequently used words (like Taqwa, Ihsan, Sabr, Iman, Falah) and explain each simply.',
  ),
  TeacherCategory(
    id: 'free',
    nameAr: 'سؤال حر',
    nameEn: 'Free Question',
    descAr: 'اسأل المعلم عن أي شي يخص القرآن',
    descEn: 'Ask the teacher anything about the Quran',
    icon: Icons.chat_bubble_outline_rounded,
    promptAr:
        'أريد أن أسألك سؤالاً حول القرآن الكريم. ابدأ بأن تعرّفني كيف يمكنك مساعدتي.',
    promptEn:
        'I want to ask you a question about the Holy Quran. Start by telling me how you can help me.',
  ),
];

/// أسئلة جاهزة (Suggestions) تظهر تحت المحادثة.
class TeacherSuggestion {
  final String textAr;
  final String textEn;
  final String fullPromptAr;
  final String fullPromptEn;

  const TeacherSuggestion({
    required this.textAr,
    required this.textEn,
    required this.fullPromptAr,
    required this.fullPromptEn,
  });
}

const List<TeacherSuggestion> kTeacherSuggestions = [
  TeacherSuggestion(
    textAr: 'ما معنى سورة الفاتحة؟',
    textEn: 'What is the meaning of Al-Fatihah?',
    fullPromptAr:
        'اشرح لي معنى سورة الفاتحة آية آية، مع الترجمة المبسطة والدروس العملية.',
    fullPromptEn:
        'Explain Al-Fatihah verse by verse with simple translation and practical lessons.',
  ),
  TeacherSuggestion(
    textAr: 'ما هي أحكام النون الساكنة؟',
    textEn: 'What are the rules of Noon Sakinah?',
    fullPromptAr:
        'اشرح لي أحكام النون الساكنة والتنوين (الإظهار، الإدغام، الإقلاب، الإخفاء) بأمثلة من القرآن.',
    fullPromptEn:
        'Explain the rules of Noon Sakinah and Tanween (Izhar, Idgham, Iqlab, Ikhfa) with Quran examples.',
  ),
  TeacherSuggestion(
    textAr: 'أعطني خطة لحفظ جزء عم',
    textEn: 'Give me a plan to memorize Juz Amma',
    fullPromptAr:
        'أعطني خطة عملية لحفظ جزء عم في شهر واحد، مع أساليب المراجعة والربط.',
    fullPromptEn:
        'Give me a practical plan to memorize Juz Amma in one month with review techniques.',
  ),
  TeacherSuggestion(
    textAr: 'ما فضل سورة الملك؟',
    textEn: 'What is the virtue of Surah Al-Mulk?',
    fullPromptAr:
        'حدّثني عن فضل سورة الملك، ودروسها، ولماذا يُستحب قراءتها قبل النوم.',
    fullPromptEn:
        'Tell me about the virtue of Surah Al-Mulk, its lessons, and why it is read before sleep.',
  ),
  TeacherSuggestion(
    textAr: 'كيف أخشع في الصلاة؟',
    textEn: 'How do I gain khushu in prayer?',
    fullPromptAr:
        'أرشدني إلى خطوات عملية لتحقيق الخشوع في الصلاة، مع أدعية وأذكار تعين على ذلك.',
    fullPromptEn:
        'Guide me to practical steps for achieving khushu in prayer with helpful duas.',
  ),
  TeacherSuggestion(
    textAr: 'ما هي أطول آية في القرآن؟',
    textEn: 'What is the longest verse in the Quran?',
    fullPromptAr:
        'ما أطول آية في القرآن الكريم؟ اشرح لي سياقها ودلالاتها.',
    fullPromptEn:
        'What is the longest verse in the Quran? Explain its context and meanings.',
  ),
];

/// System prompt عام للمعلم.
const String kTeacherSystemPromptAr = '''
أنت "المعلم" — مساعد ذكي إسلامي في تطبيق "نور الهداية"، متخصص في تعليم القرآن الكريم.

قواعدك:
1. استخدم اللغة العربية الفصحى المبسطة، بلمسة ودّية ومحترمة.
2. اعتمد على المصادر الموثوقة: القرآن الكريم، التفسير (ابن كثير، السعدي، الطبري)، الأحاديث الصحيحة.
3. إذا سُئلت عن حكم شرعي معقد، قدّم القول الراجح باختصار وانصح المستخدم بمراجعة أهل العلم.
4. لا تفتِ في مسائل خلافية بدون توضيح، ولا تُصدر أحكاماً قاطعة على أشخاص.
5. اجعل الشرح متدرجاً: ابدأ بالمبسط، ثم التفصيل.
6. استخدم أمثلة من القرآن الكريم عند الشرح.
7. حفّز المستخدم بالتشجيع والدعاء في نهاية كل رد (مختصر).
8. إذا سألك المستخدم عن شيء خارج القرآن والعلوم الإسلامية، أرجع الموضوع بلطف.
9. الردود مختصرة ومركزة (3-6 فقرات كحد أقصى).
10. اكتب الآيات بالخط العثماني بين قوسين، وأضف رقم الآية والسورة.
''';

const String kTeacherSystemPromptEn = '''
You are "The Teacher" — an Islamic AI assistant in the "Noor Al-Hidayah" app, specialized in teaching the Holy Quran.

Your rules:
1. Use clear, friendly, respectful language.
2. Rely on trusted sources: the Quran, Tafsir (Ibn Kathir, As-Sa'di, At-Tabari), authentic Hadiths.
3. If asked about a complex Islamic ruling, present the strongest opinion briefly and advise consulting scholars.
4. Do not issue fatwas on disputed matters without noting that, and do not judge individuals.
5. Explain progressively: simple first, then details.
6. Use Quranic examples when explaining.
7. Encourage the user with brief dua at the end.
8. If asked about unrelated topics, gently redirect.
9. Keep replies concise (3-6 paragraphs max).
10. Format verses in quotes with Surah name and verse number.
''';

/// مساعد: هل هذا أول رد للمستخدم؟
const String kTeacherGreetingAr =
    'السلام عليكم! أنا **المعلم** — مساعدك الذكي في تعلم القرآن الكريم. '
    'يمكنني مساعدتك في التجويد، التفسير، التدبر، خطط الحفظ، ومعاني الكلمات.\n\n'
    'كيف يمكنني مساعدتك اليوم؟';

const String kTeacherGreetingEn =
    'Assalamu Alaikum! I am **The Teacher** — your AI assistant for learning the Holy Quran. '
    'I can help you with Tajweed, Tafsir, reflection, memorization plans, and word meanings.\n\n'
    'How can I help you today?';
