# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل يجمع مواقيت الصلاة، القرآن الكريم، الأذكار، الأدعية، التحديات اليومية، ومتجر النقاط في تجربة واحدة هادئة وفاخرة.

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** vevocom888@gmail.com  
**GitHub:** nooralhidayahbusiness-App/noor-al-hidayah_claud.APP

---

## 📌 نظرة عامة

### الهدف
تطبيق إسلامي كامل مع:
- حسابات مستخدمين مشتركة بين الموقع والتطبيق (Firebase).
- مزامنة بيانات المستخدم بين الأجهزة.
- نظام نقاط ومستويات وتحديات يومية.
- متجر لشراء الخلفيات والأصوات والألوان بالنقاط.
- شعار توثيق للمستخدمين المميزين.
- دعم متعدد اللغات.
- إشعارات ذكية (أذان، آية يومية، تحديات).

### التقنيات
- **Flutter** (الواجهة الأمامية).
- **Firebase Authentication** (تسجيل ودخول).
- **Firebase Firestore** (قاعدة بيانات سحابية).
- **SharedPreferences** (تخزين محلي للمزامنة السريعة).
- **Codespaces + GitHub** (بيئة التطوير).
- **GitHub Pages** (نشر مبدئي للويب).

### البنية المعمارية
```
lib/
├── core/
│   ├── app_flow.dart          → مسار التطبيق بعد الدخول
│   ├── app_state.dart         → حالة اللغة والترجمات
│   ├── prayer_state.dart      → مواقيت الصلاة
│   ├── profile_state.dart     → صورة واسم المستخدم
│   ├── theme.dart             → الألوان والتصميم
│   ├── fonts.dart             → الخطوط
│   ├── validators.dart        → التحقق من المدخلات
│   ├── navigation.dart        → التنقل
│   ├── quran_prefs.dart       → تفضيلات القرآن
│   ├── reciter_prefs.dart     → تفضيلات القارئ
│   ├── divine_names.dart      → أسماء الله الحسنى
│   └── strings_prayer.dart    → نصوص الصلاة
├── models/
│   ├── quran.dart
│   └── saved_location.dart
├── services/
│   ├── auth_service.dart      → التسجيل والدخول + بنية Firestore
│   ├── user_service.dart      → بيانات المستخدم الكاملة
│   ├── storage_service.dart   → حفظ الموقع (محلي + سحابي)
│   ├── location_service.dart  → خدمة الموقع الجغرافي
│   ├── quran_audio_service.dart → تشغيل التلاوة
│   ├── tafsir_service.dart    → التفسير
│   └── share_service.dart     → مشاركة الآيات
├── screens/
│   ├── welcome_screen.dart    → شاشة البداية
│   ├── login_screen.dart      → تسجيل الدخول
│   ├── register_screen.dart   → إنشاء حساب
│   ├── location_screen.dart   → اختيار الموقع
│   ├── home_shell.dart        → الإطار الرئيسي
│   ├── account_screen.dart    → الملف الشخصي
│   ├── edit_profile_screen.dart → تعديل الملف
│   ├── challenge_screen.dart  → التحديات والكوبون
│   └── tabs/
│       ├── home_tab.dart
│       ├── quran_browser_tab.dart
│       ├── community_tab.dart
│       ├── more_tab.dart
│       └── soon_tabs.dart
└── widgets/
    ├── asset_icon.dart        → أيقونة من الصور
    ├── profile_avatar.dart    → صورة بروفايل مع حلقة ذهبية
    ├── verified_badge.dart    → شعار التوثيق
    ├── auth_widgets.dart      → عناصر واجهات التسجيل
    ├── glass_card.dart        → بطاقة شفافة
    ├── glow_sparks.dart       → توهج الأزرار
    ├── star_badge.dart        → شعار النجوم
    └── app_branding.dart      → هوية التطبيق
```

---

## 🎨 نظام التصميم (Design System)

### الألوان
```dart
class AppColors {
  static const deepGreen = Color(0xFF0A1F17);   // الخلفية الأساسية
  static const green     = Color(0xFF13382A);   // أخضر ثانوي
  static const gold      = Color(0xFFD4AF37);   // الذهبي الأساسي
  static const softGold  = Color(0xFFE8D9A0);   // ذهبي فاتح
  static const cream     = Color(0xFFF5EFD8);   // الكريمي للنصوص
  static const error     = Color(0xFFFF8A80);   // أحمر للخطأ
}
```

### الخطوط
- **العناوين:** خط عربي فاخر (Amiri / Noto Naskh).
- **الآيات:** `GoogleFonts.amiriQuran` (حجم 26) أو `notoNaskhArabic` (حجم 24).
- **النصوص العادية:** Cairo أو Noto Sans Arabic.

### الأسلوب البصري
- **خلفية خضراء داكنة** مع نقشات إسلامية ذهبية خفيفة.
- **تدرجات ذهبية** على الأزرار والعناصر المهمة.
- **توهج (Glow)** حول العناصر النشطة.
- **بطاقات زجاجية (GlassCard)** شفافة مع حدود ذهبية.
- **زخارف نجمية** في الزوايا (نجوم ثمانية).
- **حركات ناعمة** (AnimatedSwitcher, AnimatedOpacity, pulse).

### الأيقونات المخصصة (assets/icons/)
- `challenge.png` — تبويب التحديات (ذهبي).
- `coupon.png` — زر الكوبون (ذهبي).
- `more.png` — تبويب المزيد (ذهبي).
- `Setting.png` — زر الإعدادات (ذهبي).
- `true.me.png` — شعار توثيق المالك (ذهبي، ملفوف).
- `true.users.png` — شعار توثيق المستخدم (ذهبي).

### الصور الشخصية (assets/images/)
- `Me.png` — حسابات المالك (vevocom888 / abdelrahmenbenromdhan11).
- `logo.png` — حسابات نور الهداية (nooralimanechannel / nooralhidayahbusiness).
- `avatar_man.png` — المستخدم العادي (رجل).
- `avatar_woman.png` — المستخدمة العادية (امرأة).

### نمط الأيقونات في الشريط السفلي
- 6 أيقونات: الرئيسية، القرآن، الأذكار، **التحديات**، المجتمع، المزيد.
- الأيقونات المخصصة (challenge, more) بلون ذهبي مع شفافية 0.75 عند عدم التحديد.
- النشطة ذهبية بالكامل.

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email: string
├── createdAt: timestamp
├── avatar: "man" | "woman"
├── location_label: string
├── location_lat: double
├── location_lng: double
├── location_address: string
│
├── profile: {
│   ├── name: string
│   ├── bio: string
│   ├── isPublic: bool
│   ├── country: string
│   ├── verified: bool
│   ├── verifiedType: "owner" | "user" | "none"
│   └── faceScanDone: bool
│ }
│
├── stats: {
│   ├── points: int
│   ├── level: int
│   ├── streak: int
│   ├── lastActiveDate: timestamp
│   ├── challengesCompleted: int
│   ├── totalCorrectAnswers: int
│   ├── quranKhatmas: int
│   ├── aiTeacherScore: int
│   └── redeemedCoupons: [string]
│ }
│
├── inventory: {
│   ├── backgrounds: [string]
│   ├── voices: [string]
│   ├── themes: [string]
│   ├── activeBackground: string
│   ├── activeVoice: string
│   └── activeTheme: string
│ }
│
├── settings: {
│   ├── language: "ar" | "en" | "fr" | ...
│   ├── theme: "dark" | "light"
│   └── notifications: {
│       ├── fajr: bool
│       ├── dhuhr: bool
│       ├── asr: bool
│       ├── maghrib: bool
│       ├── isha: bool
│       ├── adhanEnabled: bool
│       ├── adhanBeforeMinutes: int
│       ├── dailyChallenge: bool
│       ├── quranReminder: bool
│       └── dailyVerse: bool
│     }
│ }
│
└── progress: {
    ├── challenges: {}
    ├── quran: {}
    └── aiTeacher: {}
}
```

### قواعد Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## ✅ المنجز حتى الآن

### 1) الحسابات والمصادقة
- [x] تسجيل حساب جديد → ينشئ في Firebase Auth + Firestore.
- [x] تسجيل دخول → يقرأ من Firebase.
- [x] قائمة الأخطاء مترجمة.
- [x] تسجيل خروج.

### 2) المزامنة
- [x] صورة البروفايل (رجل/امرأة) — محلي + Firestore.
- [x] الموقع الجغرافي — محلي + Firestore.
- [x] بيانات الملف الشخصي — محلي + Firestore.
- [x] الحسابات مشتركة مع الموقع.

### 3) الملف الشخصي
- [x] شاشة "حسابي" كاملة.
- [x] تعديل الاسم، النبذة، الخصوصية.
- [x] تغيير الصورة (رجل/امرأة).
- [x] عرض النقاط، المستوى، streak.
- [x] شريط تقدم المستوى.
- [x] صورة بروفايل مع حلقة ذهبية دوّارة.
- [x] توهج نابض حول الصورة.
- [x] شعار التوثيق (true.me / true.users).

### 4) نظام النقاط
- [x] بنية stats في Firestore.
- [x] دالة addPoints.
- [x] حساب المستوى تلقائياً.
- [x] كود الكوبون NAH2026 = 1000 نقطة (مرة واحدة).
- [x] منع استخدام الكوبون مرتين.

### 5) التحديات (أساسي)
- [x] تبويب التحديات في الشريط السفلي.
- [x] شاشة التحدي + عرض النقاط.
- [x] زر استبدال الكوبون.
- [x] زر "ابدأ التحدي" (يعرض "قريباً").

### 6) التصميم
- [x] ثيم داكن (أخضر + ذهبي).
- [x] أيقونات مخصصة PNG في الشريط السفلي.
- [x] زر الإعدادات في الأعلى.
- [x] ترجمات عربية وإنجليزية.

### 7) القرآن والأذكار
- [x] عرض القرآن كامل.
- [x] تلاوة صوتية.
- [x] تفسير.
- [x] نسخ ومشاركة الآيات.
- [x] الأحاديث.
- [x] الأذكار (تبويب موجود).
- [x] مواقيت الصلاة (تعمل).

---

## ⏳ قيد التنفيذ / الخطوات القادمة

### أ) التوثيق
- [ ] زر "وثّق حسابي الآن" للمستخدم العادي.
  - يضيف صورة شخصية حقيقية.
  - فحص وجه (Face Scan).
  - يحصل على true.users.png تلقائياً.
- [ ] زر توثيق سري في "حسابي" يظهر فقط لأصحاب الإيميلات الأربعة (لترقية حساباتهم القديمة إلى owner).

### ب) التحديات الكاملة
- [ ] 5 أسئلة يومية (تتجدد تلقائياً كل يوم).
- [ ] كل سؤال صحيح = 20 نقطة.
- [ ] لا يمكن إعادة التحدي في نفس اليوم.
- [ ] عرض "أكملت تحدي اليوم".
- [ ] streak يتحدث تلقائياً عند إكمال التحدي اليومي.

### ج) المتجر
- [ ] شاشة متجر بنقاط.
- [ ] خلفيات (default + premium).
- [ ] أصوات شيوخ (قراء).
- [ ] مؤذنون (10 أصوات).
- [ ] ألوان ثيمات.
- [ ] أسعار حسب الندرة.
- [ ] "تملك / اشتر" + تفعيل.

### د) المعلم الذكي (AI)
- [ ] ربط مع خدمة AI (OpenAI/Anthropic/Gemini).
- [ ] حفظ تقدم كل مستخدم.
- [ ] مستويات.
- [ ] تصحيح التلاوة.

### هـ) الإعدادات الكاملة
- [ ] شاشة إعدادات من زر Setting.png.
- [ ] إعدادات الإشعارات (لكل صلاة).
- [ ] تفعيل/تعطيل الأذان.
- [ ] تذكير قبل الأذان (0/5/10 دقائق).
- [ ] الوضع الليلي/النهاري.
- [ ] اختيار اللغة.

### و) اللغات
- [ ] العربية (موجود).
- [ ] الإنجليزية (موجود).
- [ ] الفرنسية.
- [ ] الأوردو.
- [ ] النيبالية.
- [ ] الإندونيسية.
- [ ] المليزية.

### ز) الإشعارات
- [ ] إشعارات محلية (Local Notifications) للأذان.
- [ ] إشعار "التحدي اليومي تجدد".
- [ ] إشعار "أكمل ختمتك".
- [ ] آية يومية على شاشة الهاتف.
- [ ] دعاء يومي.

### ح) الأذان
- [ ] شاشة أذان كاملة.
- [ ] 10 أصوات مؤذنين.
- [ ] تشغيل تلقائي عند دخول الوقت.

### ط) شاشة المجتمع
- [ ] نشر منشورات.
- [ ] تفاعل (إعجاب، تعليق).
- [ ] عرض شعار التوثيق بجانب اسم الناشر.

### ي) محتوى
- [ ] الأذكار الكاملة.
- [ ] الأدعية.
- [ ] القبلة (بوصلة).
- [ ] التسبيح (عداد).
- [ ] المساجد القريبة (خريطة).
- [ ] خطة ختم القرآن (تتبع الصفحات).
- [ ] حساب الزكاة.
- [ ] المحرمات.
- [ ] المكروهات.

---

## 🌗 الوضع الليلي/النهاري

### الوضع الليلي (الحالي - Default)
- خلفية: أخضر داكن `#0A1F17`.
- نصوص: كريمي `#F5EFD8`.
- ذهبي: `#D4AF37`.

### الوضع النهاري (قادم)
- خلفية: أبيض `#FFFFFF`.
- نصوص: رمادي داكن `#1A1A1A`.
- ذهبي: `#D4AF37` (نفس الذهبي).
- البطاقات: أبيض مع حدود ذهبية رقيقة.

**التنفيذ المطلوب:** استخدام `ThemeData.dark()` و`ThemeData.light()` في `MaterialApp` وتخزين الاختيار في Firestore + SharedPreferences.

---

## 📌 معلومات تقنية مهمة

### Firebase Config
- **Project ID:** `noor-al-hidayah`
- **Project Number:** `762471094332`
- **Web App ID:** `1:762471094332:web:68fe063e9282d7441d8b39`
- **Database location:** `nam5`

### ملفات مفقودة (تم حذفها أو لم تُنشأ)
- `lib/firebase_options.dart` — تم حذفها، يعتمد على Firebase.initializeApp مع إعدادات مباشرة.
- `assets/icons/` — موجود.
- `assets/images/` — موجود.

### Git Workflow
```bash
git pull
flutter pub get
flutter analyze
bash tool/preview.sh
```

### رفع الصور
- الصور في `assets/icons/` للأيقونات.
- الصور في `assets/images/` للصور الشخصية.
- بعد كل إضافة، يجب تحديث `pubspec.yaml`.

### تلوين الصور (Script)
لتلوين صورة سوداء إلى ذهبية:
```bash
python3 << 'PY'
from PIL import Image
GOLD = (212, 175, 55)
def recolor(path, gold=GOLD, threshold=120):
    img = Image.open(path).convert('RGBA')
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 0 and r < threshold and g < threshold and b < threshold:
                px[x, y] = (gold[0], gold[1], gold[2], a)
    img.save(path)
recolor('assets/icons/example.png')
PY
```

---

## 🔑 حسابات المالك

الإيميلات التالية تحصل تلقائياً على شعار `true.me.png` (owner) عند التسجيل:

```
abdelrahmenbenromdhan11@gmail.com
vevocom888@gmail.com
nooralimanechannel@gmail.com
nooralhidayahbusiness@gmail.com
```

بالإضافة إلى صور بروفايل مخصصة:
- `Me.png` → لأول إيميلين.
- `logo.png` → للإيميلين الأخيرين.

**الكودات المفعّلة:**
- `NAH2026` → 1000 نقطة (مرة واحدة لكل حساب).

---

## 🎯 قواعد مهمة للمطور الجديد (أي AI)

1. **قبل أي تعديل:** تأكد من عمل `flutter analyze` → "No issues found".
2. **عند تعديل ملف:** انسخه كامل، لا تعدّل بالقطع.
3. **التصميم:** اتبع نفس الألوان (ذهبي + أخضر داكن) والحركات (Glow, Rotation, Pulse).
4. **الصور:** أي أيقونة جديدة توضع في `assets/icons/` أو `assets/images/`، ثم تُضاف في `pubspec.yaml`.
5. **البيانات:** كل بيانات المستخدم تُحفظ في Firestore تحت `users/{uid}`.
6. **المزامنة:** استخدم `UserService` و`AuthService` فقط للتعامل مع Firestore.
7. **الترجمات:** كل نص جديد يُضاف في `app_state.dart` في `_ar` و`_en`.
8. **الأخطاء:** استخدم `showAuthMessage(context, msg, error: true)`.
9. **التنقل:** استخدم `Navigator.push(MaterialPageRoute(...))`.
10. **اختبار:** بعد كل تعديل، شغّل `flutter analyze` + `bash tool/preview.sh`.

---

## 📞 التواصل

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** vevocom888@gmail.com  
**التطبيق:** نور الهداية - Noor Al-Hidayah  
**الشعار:** By Abdel Rahmen Ben Romdhan

---

**آخر تحديث:** 2026-09-26  
**الإصدار:** Beta 0.1
