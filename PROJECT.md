# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل يجمع مواقيت الصلاة، القرآن الكريم، الأذكار، الأدعية، التحديات اليومية، ومتجر النقاط في تجربة واحدة هادئة وفاخرة.

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** abdelrahmenbenromdhan11@gmail.com / vevocom888@gmail.com  
**GitHub:** nooralhidayahbusiness-App/noor-al-hidayah_claud.APP  
**آخر تحديث:** 2026-09-27  
**الإصدار:** Beta 0.2

---

## 📌 نظرة عامة

### الهدف
تطبيق إسلامي كامل مع:
- حسابات مستخدمين مشتركة بين الموقع والتطبيق (Firebase).
- مزامنة بيانات المستخدم بين الأجهزة.
- نظام نقاط ومستويات وتحديات يومية.
- متجر لشراء الخلفيات والأصوات والألوان بالنقاط.
- شعار توثيق للمستخدمين المميزين.
- خلفيات VIP متحركة بـ animations.
- دعم متعدد اللغات.
- إشعارات ذكية (أذان، آية يومية، تحديات).

### التقنيات
- **Flutter** — الواجهة الأمامية.
- **Firebase Authentication** — تسجيل ودخول.
- **Firebase Firestore** — قاعدة بيانات سحابية.
- **SharedPreferences** — تخزين محلي للمزامنة السريعة.
- **Codespaces + GitHub** — بيئة التطوير.
- **GitHub Pages** — نشر مبدئي للويب.

---

## 🎨 نظام التصميم

### الألوان (`lib/core/theme.dart`)

- `deepGreen` — `#041F18` — الخلفية الأساسية
- `green` — `#0B3D2E` — أخضر ثانوي
- `emerald` — `#14664C` — زمردي
- `gold` — `#D4AF37` — الذهبي الأساسي
- `softGold` — `#F1DC9A` — ذهبي فاتح
- `cream` — `#FFF8E7` — الكريمي للنصوص

### الخطوط
- **العناوين:** خط عربي فاخر (Amiri / Noto Naskh).
- **الآيات:** `GoogleFonts.amiriQuran` (حجم 26) أو `notoNaskhArabic` (24).
- **النصوص العادية:** Cairo أو Noto Sans Arabic.

### الأسلوب البصري
- خلفية خضراء داكنة مع نقشات إسلامية ذهبية.
- تدرجات ذهبية على الأزرار والعناصر المهمة.
- توهج (Glow) حول العناصر النشطة.
- بطاقات زجاجية (GlassCard) شفافة مع حدود ذهبية.
- زخارف نجمية في الزوايا (نجوم ثمانية).
- حركات ناعمة (AnimatedSwitcher, AnimatedOpacity, pulse).

---

## 📂 بنية الملفات

```
lib/
├── core/
│   ├── app_flow.dart
│   ├── app_state.dart
│   ├── prayer_state.dart
│   ├── profile_state.dart
│   ├── theme.dart
│   ├── theme_state.dart              (جديد: الحالة العامة)
│   ├── reciter_prefs.dart            (معدّل: يزامن مع themeState)
│   ├── fonts.dart
│   ├── validators.dart
│   ├── navigation.dart
│   ├── quran_prefs.dart
│   ├── divine_names.dart
│   ├── firebase_options.dart
│   └── strings_prayer.dart
├── data/
│   ├── questions.dart                (~55 سؤال تحديات)
│   └── store_items.dart              (عناصر المتجر)
├── models/
│   ├── quran.dart
│   └── saved_location.dart
├── services/
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── storage_service.dart
│   ├── location_service.dart
│   ├── quran_audio_service.dart
│   ├── tafsir_service.dart
│   └── share_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── location_screen.dart
│   ├── home_shell.dart
│   ├── account_screen.dart
│   ├── edit_profile_screen.dart
│   ├── challenge_screen.dart
│   ├── challenge_play_screen.dart
│   ├── challenge_result_screen.dart
│   ├── store_screen.dart
│   ├── my_purchases_screen.dart
│   └── tabs/
│       ├── home_tab.dart
│       ├── quran_browser_tab.dart
│       ├── community_tab.dart
│       ├── more_tab.dart
│       └── soon_tabs.dart
└── widgets/
    ├── app_branding.dart
    ├── animated_vip_background.dart  (جديد: animations VIP)
    ├── asset_icon.dart
    ├── profile_avatar.dart
    ├── verified_badge.dart
    ├── auth_widgets.dart
    ├── glass_card.dart
    ├── glow_sparks.dart
    ├── star_badge.dart
    └── islamic_pattern.dart
```

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt, avatar ("man" | "woman")
├── location_label, location_lat, location_lng, location_address
│
├── profile: {
│     name, bio, isPublic, country,
│     verified: bool,
│     verifiedType: "owner" | "user" | "none",
│     faceScanDone: bool
│   }
│
├── stats: {
│     points, level, streak, lastActiveDate,
│     challengesCompleted, totalCorrectAnswers,
│     quranKhatmas, aiTeacherScore, redeemedCoupons: [string]
│   }
│
├── inventory: {
│     backgrounds: [string], voices: [string],
│     adhans: [string], themes: [string],
│     activeBackground, activeVoice, activeAdhan, activeTheme
│   }
│
├── settings: {
│     language, theme,
│     notifications: { fajr, dhuhr, asr, maghrib, isha,
│                     adhanEnabled, adhanBeforeMinutes,
│                     dailyChallenge, quranReminder, dailyVerse }
│   }
│
└── progress: {
      challenges: { lastPlayedDate, todayPoints, todayCorrect, totalCompleted },
      quran: {}, aiTeacher: {}
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
- [x] تسجيل حساب → Firebase Auth + Firestore.
- [x] تسجيل دخول → Firebase.
- [x] قائمة أخطاء مترجمة.
- [x] تسجيل خروج.
- [x] `authService.isOwner` للتحقق من إيميلات المالك.

### 2) المزامنة
- [x] صورة البروفايل — محلي + Firestore.
- [x] الموقع الجغرافي — محلي + Firestore.
- [x] بيانات الملف الشخصي — محلي + Firestore.
- [x] الحسابات مشتركة مع الموقع.
- [x] المزامنة بين الأجهزة.

### 3) الملف الشخصي
- [x] شاشة "حسابي" كاملة.
- [x] تعديل الاسم، النبذة، الخصوصية.
- [x] تغيير الصورة (رجل/امرأة).
- [x] عرض النقاط، المستوى، streak.
- [x] شريط تقدم المستوى.
- [x] صورة بروفايل بحلقة ذهبية دوّارة + توهج نابض.
- [x] شعار التوثيق (true.me / true.users).
- [x] صور مخصصة (Me.png / logo.png) لحسابات المالك.

### 4) نظام النقاط
- [x] بنية stats في Firestore.
- [x] `addPoints`, `incrementStats`, `setStats`.
- [x] حساب المستوى تلقائياً (كل 100 نقطة = مستوى).
- [x] كود الكوبون `NAH2026` = 1000 نقطة.
- [x] منع استخدام الكوبون مرتين (للمستخدم العادي).
- [x] الكوبون غير محدود لحسابات المالك الأربعة.

### 5) التحديات
- [x] تبويب التحديات في الشريط السفلي (challenge.png).
- [x] بنك أسئلة (~55 سؤال في `questions.dart`).
- [x] اختيار 5 أسئلة عشوائية يومياً.
- [x] 30 ثانية لكل سؤال، مؤقت أحمر عند آخر 10 ثواني.
- [x] شاشة اللعب مع 4 خيارات.
- [x] أخضر للإجابة الصحيحة، أحمر للخطأ.
- [x] شاشة النتائج مع النقاط.
- [x] 20 نقطة لكل إجابة صحيحة.
- [x] منع إعادة التحدي في نفس اليوم.
- [x] Streak تلقائي.

### 6) المتجر
- [x] 4 تبويبات: خلفيات، قراء، مؤذنون، ثيمات.
- [x] 7 خلفيات عادية (منها المجانية).
- [x] 3 خلفيات VIP (2000 نقطة) مع animations.
- [x] 6 قراء + القارئ الافتراضي.
- [x] 7 مؤذنين.
- [x] 6 ثيمات.
- [x] عرض الصور الحقيقية على البطاقات.
- [x] شارة VIP ذهبية + شارة ANIMATION.
- [x] نظام شراء كامل + خصم النقاط.
- [x] تفعيل فوري للعنصر بعد الشراء.
- [x] "مشترياتي" لعرض وتبديل العناصر المملوكة.

### 7) الخلفيات المتغيرة
- [x] `themeState.backgroundId` يحفظ الاختيار (محلي + Firestore).
- [x] `AppBackground` يقرأ ويطبق فوراً.
- [x] الصور الفعلية للخلفيات في `assets/images/backgrounds/`.
- [x] VIP animations: Zoom + Shimmer + نجوم متحركة + توهج نابض.

### 8) التصميم العام
- [x] ثيم داكن (أخضر + ذهبي).
- [x] أيقونات مخصصة PNG (challenge, more, coupon, Setting, store).
- [x] زر الإعدادات في الأعلى.
- [x] ترجمات عربية وإنجليزية.
- [x] ضبط الإيميلات الأربعة (owner).

### 9) القرآن والأذكار
- [x] عرض القرآن كامل.
- [x] تلاوة صوتية مع القارئ المُختار من المتجر.
- [x] تفسير.
- [x] نسخ ومشاركة الآيات.
- [x] الأحاديث.
- [x] مواقيت الصلاة (تعمل من الموقع المختار).

---

## ⏳ قيد التنفيذ / الخطوات القادمة

### أ) تفعيل الثيمات الفعلية
- [ ] عند شراء ثيم → الألوان الداخلية تتغير (ذهبي + اللون الجديد).
- [ ] تطبيق على الأزرار، البطاقات، الحدود.

### ب) الوضع النهاري/الليلي
- [ ] تبديل بين الوضعين.
- [ ] النهاري: أبيض + ذهبي.
- [ ] حفظ في Firestore.

### ج) شاشة الإعدادات
- [ ] زر Setting.png يفتح شاشة كاملة.
- [ ] إعدادات الإشعارات (لكل صلاة).
- [ ] تفعيل/تعطيل الأذان.
- [ ] تذكير قبل الأذان (0/5/10 دقائق).

### د) التوثيق
- [ ] زر "وثّق حسابي" للمستخدم العادي.
- [ ] رفع صورة + فحص وجه.
- [ ] الحصول على true.users.png تلقائياً.

### هـ) الإشعارات + الأذان
- [ ] إشعارات محلية للأذان.
- [ ] شاشة أذان كاملة.
- [ ] 10 أصوات مؤذنين (موجودين في المتجر).
- [ ] إشعار "التحدي اليومي تجدد".
- [ ] آية ودعاء يومي.

### و) اللغات
- [ ] العربية (موجود).
- [ ] الإنجليزية (موجود).
- [ ] الفرنسية.
- [ ] الأوردو.
- [ ] النيبالية.
- [ ] الإندونيسية.
- [ ] المليزية.

### ز) المعلم الذكي (AI)
- [ ] ربط مع خدمة AI.
- [ ] حفظ تقدم كل مستخدم.
- [ ] مستويات وتصحيح التلاوة.

### ح) شاشة المجتمع
- [ ] نشر منشورات + تفاعل.
- [ ] عرض شعار التوثيق بجانب اسم الناشر.

### ط) محتوى
- [ ] الأذكار، الأدعية، القبلة، التسبيح.
- [ ] المساجد القريبة، خطة ختم القرآن.
- [ ] حساب الزكاة، المحرمات، المكروهات.

---

## 📌 معلومات تقنية مهمة

### Firebase Config
- Project ID: `noor-al-hidayah`
- Project Number: `762471094332`
- Web App ID: `1:762471094332:web:68fe063e9282d7441d8b39`
- Database location: `nam5`

### أصول الصور (assets/)

**assets/icons/**
- Setting.png
- challenge.png
- coupon.png
- more.png
- store.png
- true.me.png
- true.users.png

**assets/images/**
- Me.png
- logo.png
- avatar_man.png
- avatar_woman.png

**assets/images/backgrounds/**
- backgroundv2.png (default — الأخضر الذهبي)
- background_blue.png (night — ليل هادئ)
- background_orange.png (sunset — غروب ذهبي)
- background_brown.png (mosque — المسجد الحرام)
- background_dark.png (kaaba — الكعبة المشرفة)
- background_purple.png (ramadan — رمضان كريم)
- background_olive.png (floral — زخارف إسلامية)
- backgroundvip1.png (vip_royal — المسجد الملكي)
- backgroundvip2.png (vip_rose — الحديقة الوردية)
- backgroundvip3.png (vip_divine — النور السماوي)

### `pubspec.yaml` — قسم Assets (مهم)

```
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/
    - assets/images/backgrounds/
```

### Git Workflow (بعد كل ميزة ناجحة)

```
flutter analyze           # يجب "No issues found!"
bash tool/preview.sh      # اختبار
git add .
git commit -m "Feature: [اسم الميزة]"
git push
```

### كودات المفعّلة
- **NAH2026** → 1000 نقطة.
  - حسابات المالك (4): غير محدود.
  - المستخدمون العاديون: مرة واحدة لكل حساب.

### حسابات المالك (Owner)
الإيميلات التالية تحصل تلقائياً على شعار `true.me.png` + صور مخصصة:

- abdelrahmenbenromdhan11@gmail.com → Me.png
- vevocom888@gmail.com → Me.png
- nooralimanechannel@gmail.com → logo.png
- nooralhidayahbusiness@gmail.com → logo.png

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

### القاعدة الذهبية:
بعد كل ميزة تنجح + `flutter analyze` = No issues + Test يشتغل:
1. `git add . && git commit -m "..." && git push`
2. حدّث `PROJECT.md` بالميزة الجديدة.
3. انتقل للمرحلة التالية.

---

## 📞 التواصل

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** abdelrahmenbenromdhan11@gmail.com / vevocom888@gmail.com  
**التطبيق:** نور الهداية — Noor Al-Hidayah  
**الشعار:** By Abdel Rahmen Ben Romdhan

---

## 🛠️ طريقة العمل بين المالك و AI (Workflow)

> ⚠️ هذا القسم دائم — لا يُحذف أبداً عند تحديث `PROJECT.md`.

### المبادئ الأساسية:

1. **ملف واحد لكل ميزة** — كل ميزة جديدة تعني ملف واحد جديد على الأقل.
2. **استبدال كامل** — عند تعديل ملف، يُنسخ المحتوى الجديد كامل ويستبدل القديم. لا تعديل بالقطع.
3. **فحص قبل الحفظ** — لا نحفظ أي شي قبل `flutter analyze` = `No issues found!` + اختبار ناجح.
4. **`PROJECT.md` يُحدّث بعد كل ميزة** — قبل الانتقال للخطوة التالية.
5. **الخطوات صغيرة** — كل رد يحتوي على خطوة واحدة واضحة، ثم اختبار، ثم الخطوة التالية.

---

### دورة العمل لكل ميزة جديدة:

**الخطوة 1 — AI يشرح الميزة ويعطي الكود:**
- يشرح ما الذي سيتغير.
- يعطي الكود كامل للملفات الجديدة أو المعدلة.
- يذكر بوضوح: "ملف جديد" أو "استبدل".

**الخطوة 2 — المالك ينسخ الملفات في GitHub (استبدال كامل):**
- **ملف جديد:** GitHub → Add file → Create new file → الصق الكود → Commit.
- **ملف موجود:** اضغط الملف → القلم ✏️ → Select All → Delete → الصق الجديد → Commit.

**الخطوة 3 — في Terminal:**
- اكتب `git pull`.
- اكتب `flutter analyze`.
- يجب أن يظهر `No issues found!` — إذا ظهرت أخطاء، توقف وأرسلها للـ AI.

**الخطوة 4 — اختبار التطبيق:**
- اكتب `bash tool/preview.sh`.
- افتح التطبيق.
- جرب الميزة الجديدة.
- تأكد أن كل شي يعمل.

**الخطوة 5 — إذا نجح الاختبار، احفظ:**
- `git add .`
- `git commit -m "Feature: [اسم الميزة]"`
- `git push`

**الخطوة 6 — حدّث `PROJECT.md`:**
- أضف الميزة في قسم "المنجز حتى الآن" بصيغة `- [x]`.
- احذفها من "قيد التنفيذ" إن كانت موجودة.
- حدّث "آخر تحديث" بالتاريخ الجديد.
- حدّث "الإصدار" (مثال: Beta 0.2 → Beta 0.3).
- لا تحذف قسم "طريقة العمل".
- احفظ → Commit.

**الخطوة 7 — ابدأ الميزة التالية.**

---

### كيف تُنشأ الملفات الجديدة؟

**ملف Flutter جديد (Dart):**
1. GitHub → انتقل للمجلد المطلوب (مثل `lib/screens/`).
2. اضغط "Add file" → "Create new file".
3. اكتب اسم الملف (مثل `my_new_screen.dart`).
4. الصق الكود.
5. اضغط "Commit changes".
6. في Terminal: `git pull`.

**ملف جديد في مجلد فرعي جديد:**
- عند كتابة اسم الملف، اكتب المسار كامل: `newfolder/newfile.dart`.
- GitHub ينشئ المجلد تلقائياً.

**صورة أو أصل جديد:**
1. ارفعها عبر "Add file" → "Upload files".
2. ضعها في المجلد الصحيح (`assets/icons/` أو `assets/images/`).
3. حدّث `pubspec.yaml` إذا كان مجلداً جديداً.
4. `git pull` + `flutter pub get`.

---

### كيف يُستبدل محتوى ملف موجود؟

1. افتح الملف على GitHub.
2. اضغط أيقونة القلم ✏️ (تعديل).
3. اضغط مطولاً على الكود → اختر "Select All".
4. اضغط حذف (Delete) — الملف يصير فاضي.
5. الصق الكود الجديد كامل.
6. اضغط "Commit changes".
7. في Terminal: `git pull`.
8. ثم: `flutter analyze`.

> ⚠️ ملاحظة مهمة: لا تحاول تعديل أسطر محددة داخل الملف. دائماً استبدل الملف كامل — هذا يمنع الأخطاء ويضمن تطابق الكود مع ما أعطاه AI.

---

### كيف يُحدّث `PROJECT.md`؟

بعد كل ميزة ناجحة:

1. لا تحذف شي — فقط أضف.
2. في قسم "المنجز حتى الآن":
   - أضف `- [x]` للبند الجديد تحت القسم المناسب.
3. في قسم "قيد التنفيذ":
   - احذف البند المنتهي.
4. في الأعلى: حدّث "آخر تحديث" بالتاريخ الجديد.
5. في الأسفل: حدّث "الإصدار" (Beta 0.2 → Beta 0.3).
6. ⚠️ لا تحذف قسم "طريقة العمل" أبداً.
7. احفظ → Commit.

---

### القواعد الذهبية الثلاث:

1. **لا حفظ بدون اختبار:** لا `git commit` قبل `flutter analyze` = `No issues found!`.
2. **لا استبدال جزئي:** انسخ الملف كامل، استبدل بالكامل.
3. **لا انتقال بدون تحديث:** لا بداية ميزة جديدة قبل تحديث `PROJECT.md`.

---

### إذا حصل خطأ:

1. لا تكمل — أوقف واذهب للخطوة السابقة.
2. انسخ رسالة الخطأ كاملة (من `flutter analyze` أو المتصفح).
3. أرسلها للـ AI مع:
   - صورة شاشة (إن أمكن).
   - اسم الملف الذي فيه الخطأ.
4. AI راح يصلح الخطأ ويعطيك كود جديد.
5. أعد من الخطوة 2 (استبدال الملف).

---

### نصائح إضافية:

- احفظ نسخة احتياطية كل أسبوع:
  ```
  git tag v0.2-stable
  git push --tags
  ```
- إذا تجرب شي خطير: أنشئ branch جديد (`git checkout -b experiment`)، وإذا نجح → ادمجه، وإذا فشل → احذفه.
- لا تخف من `git reset`: تقدر ترجع لأي commit قديم إذا احتجت.

---

**آخر تحديث لهذا القسم:** 2026-09-27 — هذا القسم ثابت ولا يُحذف.
