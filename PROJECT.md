# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل يجمع مواقيت الصلاة، القرآن الكريم، الأذكار، الأدعية، التحديات اليومية، ومتجر النقاط في تجربة واحدة هادئة وفاخرة.

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** vevocom888@gmail.com  
**GitHub:** nooralhidayahbusiness-App/noor-al-hidayah_claud.APP  
**آخر تحديث:** 2026-09-27  
**الإصدار:** Beta 0.3

---

## 📌 نظرة عامة

### الهدف
تطبيق إسلامي كامل مع:
- حسابات مشتركة بين الموقع والتطبيق (Firebase).
- مزامنة بيانات المستخدم بين الأجهزة.
- نظام نقاط ومستويات وتحديات يومية.
- متجر لشراء الخلفيات والأصوات والألوان بالنقاط.
- ثيمات ديناميكية مع ألوان + خلفيات + أنيميشن.
- شعار توثيق للمستخدمين المميزين.
- خلفيات وثيمات VIP متحركة بـ animations.
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

### الألوان الافتراضية (`lib/core/theme.dart`)
- `deepGreen` — `#041F18` — الخلفية الأساسية
- `green` — `#0B3D2E` — أخضر ثانوي
- `emerald` — `#14664C` — زمردي
- `gold` — `#D4AF37` — الذهبي الأساسي (ثابت)
- `softGold` — `#F1DC9A` — ذهبي فاتح (ثابت)
- `cream` — `#FFF8E7` — الكريمي للنصوص (ثابت)

### نظام الثيمات الديناميكية
- **`ThemePalette`**: لوحة ألوان (accent، accentDark، accentLight، gold، softGold، cream).
- **`themeState`**: يحمل الثيم المختار + الخلفية + القارئ + المؤذن.
- **`ThemedColors`**: ألوان ديناميكية تُقرأ من themeState — تُستخدم بدلاً من `AppColors` في العناصر القابلة للتغيير.
- **الثيم الافتراضي + 5 ثيمات عادية** (1000-2000 نقطة).
- **3 ثيمات VIP** (2000 نقطة) مع animations (نجوم + shimmer + تدرجات متحركة).

### الخطوط
- **العناوين:** خط عربي فاخر (Amiri / Noto Naskh).
- **الآيات:** `GoogleFonts.amiriQuran` (26) أو `notoNaskhArabic` (24).
- **النصوص:** Cairo أو Noto Sans Arabic.

### الأسلوب البصري
- خلفية خضراء داكنة مع نقشات إسلامية ذهبية.
- تدرجات ذهبية على الأزرار والعناصر.
- توهج (Glow) حول العناصر النشطة.
- بطاقات زجاجية (GlassCard) شفافة مع حدود ذهبية.
- زخارف نجمية في الزوايا (نجوم ثمانية).
- حركات ناعمة (AnimatedSwitcher, AnimatedOpacity, pulse, rotation).

---

## 📂 بنية الملفات

```
lib/
├── core/
│   ├── app_flow.dart
│   ├── app_state.dart                 # اللغة والترجمات
│   ├── prayer_state.dart
│   ├── profile_state.dart
│   ├── theme.dart                     # الألوان الافتراضية + buildAppTheme
│   ├── theme_palette.dart             ✅ جديد: تعريف 9 ثيمات (6 عادية + 3 VIP)
│   ├── theme_state.dart               ✅ الحالة العامة للثيم
│   ├── themed_colors.dart             ✅ جديد: ألوان ديناميكية
│   ├── reciter_prefs.dart
│   ├── fonts.dart
│   ├── validators.dart
│   ├── navigation.dart
│   ├── quran_prefs.dart
│   ├── divine_names.dart
│   ├── firebase_options.dart
│   └── strings_prayer.dart
├── data/
│   ├── questions.dart                 # ~55 سؤال تحديات
│   └── store_items.dart               # 10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات
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
│   ├── welcome_screen.dart
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
    ├── app_branding.dart              ✅ AppBackground ديناميكي
    ├── animated_vip_background.dart   ✅ animations للخلفيات VIP
    ├── themed_background.dart         ✅ جديد: طبقة الثيم + animations للثيمات VIP
    ├── theme_preview.dart             ✅ معاينة مصغّرة للثيمات
    ├── asset_icon.dart
    ├── profile_avatar.dart
    ├── verified_badge.dart
    ├── glass_card.dart                ✅ theme-aware
    ├── star_badge.dart                ✅ theme-aware
    ├── ornament_medallion.dart        ✅ theme-aware
    ├── auth_widgets.dart
    ├── glow_sparks.dart
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
- [x] 10 خلفيات (7 عادية + 3 VIP).
- [x] 3 خلفيات VIP (2000 نقطة) مع animations.
- [x] 7 قراء (المستخدم + 6 للشراء).
- [x] 7 مؤذنين.
- [x] 9 ثيمات (6 عادية + 3 VIP).
- [x] 3 ثيمات VIP (2000 نقطة) مع animations.
- [x] عرض الصور الحقيقية على بطاقات الخلفيات.
- [x] عرض معاينة مصغّرة حية على بطاقات الثيمات.
- [x] شارة VIP ذهبية + شارة ANIMATION.
- [x] نظام شراء كامل + خصم النقاط.
- [x] تفعيل فوري للعنصر بعد الشراء.
- [x] "مشترياتي" لعرض وتبديل العناصر المملوكة.

### 7) الخلفيات
- [x] `themeState.backgroundId` يحفظ الاختيار (محلي + Firestore).
- [x] `AppBackground` يقرأ ويطبق فوراً.
- [x] الصور الفعلية للخلفيات في `assets/images/backgrounds/`.
- [x] 7 خلفيات عادية (default, blue, orange, brown, dark, purple, olive).
- [x] 3 خلفيات VIP متحركة (vip1, vip2, vip3).
- [x] AnimatedVipBackground: zoom + shimmer + نجوم + overlay.

### 8) الثيمات الديناميكية
- [x] `ThemePalette` مع 9 ثيمات.
- [x] `themeState` يحفظ الثيم المختار (محلي + Firestore).
- [x] `ThemedColors` ألوان ديناميكية.
- [x] `MaterialApp` يعيد البناء عند تغيير الثيم.
- [x] الشريط السفلي يتغير مع الثيم.
- [x] GlassCard theme-aware.
- [x] StarBadge theme-aware.
- [x] OrnamentMedallion theme-aware.
- [x] SymbolImage theme-aware.
- [x] ThemedBackground (طبقة فوق الصورة).
- [x] ThemePreview (معاينة حية على بطاقات الثيمات).
- [x] 3 ثيمات VIP مع animations كاملة (نجوم + shimmer + تدرجات متحركة + توهج نابض).
- [x] يعمل مع الخلفيات VIP بدون تعارض.

### 9) التصميم العام
- [x] ثيم داكن (أخضر + ذهبي).
- [x] أيقونات مخصصة PNG (challenge, more, coupon, Setting, store).
- [x] زر الإعدادات في الأعلى.
- [x] ترجمات عربية وإنجليزية.
- [x] ضبط الإيميلات الأربعة (owner).

### 10) القرآن والأذكار
- [x] عرض القرآن كامل.
- [x] تلاوة صوتية مع القارئ المُختار من المتجر.
- [x] تفسير.
- [x] نسخ ومشاركة الآيات.
- [x] الأحاديث.
- [x] مواقيت الصلاة (تعمل من الموقع المختار).

---

## ⏳ قيد التنفيذ / الخطوات القادمة

### أ) التصغير المتجاوب (Responsive Sizes)
- [ ] `lib/core/responsive.dart` — helper للأحجام المتجاوبة.
- [ ] تعديل `welcome_screen.dart` (تصغير خفيف).
- [ ] تعديل `auth_widgets.dart` (AppLogo، الأزرار).
- [ ] تعديل `home_tab.dart` (الدوائر، البطاقات).
- [ ] تعديل `account_screen.dart` (الصورة، البطاقات).
- [ ] تعديل `challenge_screen.dart` (البطاقات).

### ب) شاشة الإعدادات
- [ ] زر Setting.png يفتح شاشة كاملة.
- [ ] إعدادات الإشعارات (لكل صلاة).
- [ ] تفعيل/تعطيل الأذان.
- [ ] تذكير قبل الأذان (0/5/10 دقائق).

### ج) الوضع النهاري/الليلي
- [ ] تبديل بين الوضعين.
- [ ] النهاري: أبيض + ذهبي.

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
- Setting.png, challenge.png, coupon.png, more.png, store.png
- true.me.png, true.users.png

**assets/images/**
- Me.png, logo.png, avatar_man.png, avatar_woman.png

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

### `pubspec.yaml` — قسم Assets
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
- abdelrahmenbenromdhan11@gmail.com → Me.png + true.me
- vevocom888@gmail.com → Me.png + true.me
- nooralimanechannel@gmail.com → logo.png + true.me
- nooralhidayahbusiness@gmail.com → logo.png + true.me

---

---

## 🙏 شكر وتقدير (Credits & Attribution)

### الأيقونات
بعض الأيقونات المستخدمة في هذا التطبيق تم تحميلها من موقع [Flaticon](https://www.flaticon.com/).

**صيغة الإسناد:**
> Icon made by Flaticon from www.flaticon.com

**المؤلفون (إذا كانوا معروفين):**
- [اسم المؤلف 1] from Flaticon
- [اسم المؤلف 2] from Flaticon

**ملاحظة قانونية:** الإسناد مطلوب حسب ترخيص Flaticon للمستخدمين المجانيين.
## 🎯 قواعد مهمة للمطور الجديد (أي AI)

1. **قبل أي تعديل:** تأكد من `flutter analyze` → "No issues found".
2. **عند تعديل ملف:** انسخه كامل، لا تعدّل بالقطع.
3. **التصميم:** اتبع الألوان (ذهبي + الثيم الحالي) والحركات (Glow, Rotation, Pulse).
4. **الصور:** أي أيقونة جديدة توضع في `assets/icons/` أو `assets/images/`، ثم `pubspec.yaml`.
5. **البيانات:** كل بيانات المستخدم في Firestore تحت `users/{uid}`.
6. **المزامنة:** استخدم `UserService` و`AuthService` فقط.
7. **الترجمات:** كل نص جديد في `app_state.dart` في `_ar` و`_en`.
8. **الألوان الديناميكية:** استخدم `ThemedColors` (وليس `AppColors`) للعناصر القابلة للتغيير.
9. **التنقل:** `Navigator.push(MaterialPageRoute(...))`.
10. **اختبار:** بعد كل تعديل، `flutter analyze` + `bash tool/preview.sh`.

### القاعدة الذهبية:
بعد كل ميزة تنجح + `flutter analyze` = No issues + Test يشتغل:
1. `git add . && git commit -m "..." && git push`
2. حدّث `PROJECT.md`.
3. انتقل للمرحلة التالية.

---

## 📞 التواصل

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** vevocom888@gmail.com  
**التطبيق:** نور الهداية — Noor Al-Hidayah  
**الشعار:** By Abdel Rahmen Ben Romdhan

---

## 🛠️ طريقة العمل بين المالك و AI (Workflow)

> ⚠️ هذا القسم دائم — لا يُحذف أبداً عند تحديث `PROJECT.md`.

### المبادئ الأساسية:

1. **ملف واحد لكل ميزة** — كل ميزة جديدة = ملف جديد على الأقل.
2. **استبدال كامل** — عند تعديل ملف، يُنسخ المحتوى الجديد كامل ويستبدل القديم.
3. **فحص قبل الحفظ** — لا نحفظ قبل `flutter analyze` = `No issues found!` + اختبار ناجح.
4. **`PROJECT.md` يُحدّث بعد كل ميزة** — قبل الانتقال للخطوة التالية.
5. **الخطوات صغيرة** — كل رد فيه خطوة واحدة واضحة.

---

### دورة العمل لكل ميزة جديدة:

**الخطوة 1 — AI يشرح الميزة ويعطي الكود:**
- يشرح ما الذي سيتغير.
- يعطي الكود كامل.
- يذكر بوضوح: "ملف جديد" أو "استبدل".

**الخطوة 2 — المالك ينسخ الملفات في GitHub (استبدال كامل):**
- **ملف جديد:** GitHub → Add file → Create new file → الصق → Commit.
- **ملف موجود:** اضغط الملف → القلم ✏️ → Select All → Delete → الصق الجديد → Commit.

**الخطوة 3 — في Terminal:**
- `git pull`
- `flutter analyze` → يجب `No issues found!` — إذا ظهرت أخطاء، أرسلها للـ AI.

**الخطوة 4 — اختبار التطبيق:**
- `bash tool/preview.sh`
- افتح التطبيق، جرب الميزة الجديدة.

**الخطوة 5 — إذا نجح، احفظ:**
- `git add .`
- `git commit -m "Feature: [اسم الميزة]"`
- `git push`

**الخطوة 6 — حدّث `PROJECT.md`:**
- أضف الميزة في "المنجز حتى الآن" بصيغة `- [x]`.
- احذفها من "قيد التنفيذ".
- حدّث "آخر تحديث" + "الإصدار".
- لا تحذف قسم "طريقة العمل".

**الخطوة 7 — ابدأ الميزة التالية.**

---

### كيف تُنشأ الملفات الجديدة؟

**ملف Flutter جديد:**
1. GitHub → انتقل للمجلد.
2. Add file → Create new file.
3. اكتب الاسم (مثل `my_new_screen.dart`).
4. الصق الكود.
5. Commit → `git pull`.

**مجلد فرعي جديد:** اكتب المسار كامل: `newfolder/newfile.dart`.

**صورة جديدة:** Add file → Upload files → ضعها في المجلد الصحيح → حدّث `pubspec.yaml` → `git pull` + `flutter pub get`.

---

### كيف يُستبدل محتوى ملف؟

1. افتح الملف على GitHub.
2. القلم ✏️.
3. Select All → Delete.
4. الصق الكود الجديد.
5. Commit changes.
6. `git pull` → `flutter analyze`.

> ⚠️ لا تحاول تعديل أسطر محددة. دائماً استبدل الملف كامل.

---

### كيف يُحدّث `PROJECT.md`؟

بعد كل ميزة ناجحة:
1. لا تحذف شي — فقط أضف.
2. في "المنجز": أضف `- [x]`.
3. في "قيد التنفيذ": احذف البند المنتهي.
4. حدّث "آخر تحديث" + "الإصدار".
5. ⚠️ لا تحذف قسم "طريقة العمل".
6. احفظ → Commit.

---

### القواعد الذهبية الثلاث:

1. **لا حفظ بدون اختبار:** لا `git commit` قبل `flutter analyze` = `No issues found!`.
2. **لا استبدال جزئي:** انسخ الملف كامل.
3. **لا انتقال بدون تحديث:** لا بداية ميزة جديدة قبل تحديث `PROJECT.md`.

---

### إذا حصل خطأ:

1. لا تكمل — أوقف.
2. انسخ رسالة الخطأ كاملة.
3. أرسلها للـ AI مع صورة الشاشة + اسم الملف.
4. AI يصلح ويعطيك كود جديد.
5. أعد من الخطوة 2.

---

### نصائح:

- احفظ نسخة احتياطية: `git tag v0.3-stable && git push --tags`.
- للتجارب الخطيرة: `git checkout -b experiment`.

---

**آخر تحديث لهذا القسم:** 2026-09-27 — ثابت ولا يُحذف.
