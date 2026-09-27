# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل يجمع مواقيت الصلاة، القرآن الكريم، الأذكار، الأدعية، التحديات اليومية، ومتجر النقاط في تجربة واحدة هادئة وفاخرة.

**المالك:** Abdel Rahmen Ben Romdhan  
**البريد:** vevocom888@gmail.com  
**GitHub:** nooralhidayahbusiness-App/noor-al-hidayah_claud.APP  
**آخر تحديث:** 2026-09-28  
**الإصدار:** Beta 0.4

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
- **SharedPreferences** — تخزين محلي.
- **Codespaces + GitHub** — بيئة التطوير.
- **GitHub Pages** — نشر مبدئي للويب.

---

## 🎨 نظام التصميم

### الألوان الافتراضية
- `deepGreen` — `#041F18`
- `green` — `#0B3D2E`
- `emerald` — `#14664C`
- `gold` — `#D4AF37` (ثابت)
- `softGold` — `#F1DC9A` (ثابت)
- `cream` — `#FFF8E7` (ثابت)

### نظام الثيمات الديناميكية
- **ThemePalette**: 9 ثيمات (6 عادية + 3 VIP).
- **themeState**: يحفظ الثيم + الخلفية + القارئ + المؤذن.
- **ThemedColors**: ألوان ديناميكية تُقرأ من themeState.
- **الأنيميشن في VIP**: نجوم متحركة + shimmer + تدرجات + توهج نابض.

### نظام الأحجام المتجاوبة (Responsive)
- **`R.scale(context)`**: معامل يعتمد على عرض الشاشة:
  - حاسوب (≥ 1000px) → 0.88
  - تابلت (≥ 700px) → 0.78
  - جوال كبير (≥ 500px) → 0.68
  - جوال صغير (< 500px) → 0.62
- **`R.s(context, base)`**: حجم مُصغّر.
- **`R.f(context, base)`**: حجم خط مُصغّر.

### الخطوط
- **العناوين:** Amiri / Noto Naskh.
- **الآيات:** `GoogleFonts.amiriQuran` (26) أو `notoNaskhArabic` (24).
- **النصوص:** Cairo / Noto Sans Arabic.

### الأسلوب البصري
- خلفية خضراء داكنة مع نقشات إسلامية ذهبية.
- تدرجات ذهبية على الأزرار.
- توهج حول العناصر النشطة.
- بطاقات زجاجية (GlassCard) شفافة theme-aware.
- زخارف نجمية في الزوايا.
- حركات ناعمة.

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
│   ├── theme_palette.dart
│   ├── theme_state.dart
│   ├── themed_colors.dart
│   ├── responsive.dart             ✅ جديد: أحجام متجاوبة
│   ├── reciter_prefs.dart
│   ├── fonts.dart
│   ├── validators.dart
│   ├── navigation.dart
│   ├── quran_prefs.dart
│   ├── divine_names.dart
│   ├── firebase_options.dart
│   └── strings_prayer.dart
├── data/
│   ├── questions.dart              # ~55 سؤال
│   └── store_items.dart            # 10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات
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
│   ├── welcome_screen.dart          ✅ responsive
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── location_screen.dart
│   ├── home_shell.dart              ✅ responsive + bottom bar
│   ├── account_screen.dart
│   ├── edit_profile_screen.dart
│   ├── challenge_screen.dart
│   ├── challenge_play_screen.dart
│   ├── challenge_result_screen.dart
│   ├── store_screen.dart
│   ├── my_purchases_screen.dart
│   └── tabs/
│       ├── home_tab.dart            ✅ responsive
│       ├── quran_browser_tab.dart
│       ├── community_tab.dart
│       ├── more_tab.dart
│       └── soon_tabs.dart
└── widgets/
    ├── app_branding.dart
    ├── animated_vip_background.dart
    ├── themed_background.dart
    ├── theme_preview.dart
    ├── asset_icon.dart
    ├── profile_avatar.dart
    ├── verified_badge.dart
    ├── glass_card.dart              # theme-aware
    ├── star_badge.dart              # theme-aware
    ├── ornament_medallion.dart      # theme-aware
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
├── profile: { name, bio, isPublic, country,
│              verified, verifiedType, faceScanDone }
│
├── stats: { points, level, streak, lastActiveDate,
│            challengesCompleted, totalCorrectAnswers,
│            quranKhatmas, aiTeacherScore, redeemedCoupons }
│
├── inventory: { backgrounds, voices, adhans, themes,
│                activeBackground, activeVoice, activeAdhan, activeTheme }
│
├── settings: { language, theme, notifications{...} }
│
└── progress: { challenges{}, quran{}, aiTeacher{} }
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
- [x] `authService.isOwner`.

### 2) المزامنة
- [x] صورة البروفايل، الموقع، بيانات الملف — محلي + Firestore.
- [x] الحسابات مشتركة مع الموقع.
- [x] المزامنة بين الأجهزة.

### 3) الملف الشخصي
- [x] شاشة "حسابي" كاملة.
- [x] تعديل الاسم، النبذة، الخصوصية.
- [x] تغيير الصورة (رجل/امرأة).
- [x] عرض النقاط، المستوى، streak.
- [x] شريط تقدم المستوى.
- [x] صورة بروفايل بحلقة ذهبية دوّارة + توهج.
- [x] شعار التوثيق (true.me / true.users).
- [x] صور مخصصة (Me.png / logo.png) لحسابات المالك.

### 4) نظام النقاط
- [x] بنية stats في Firestore.
- [x] addPoints, incrementStats, setStats.
- [x] حساب المستوى تلقائياً.
- [x] كود `NAH2026` = 1000 نقطة.
- [x] منع استخدام الكوبون مرتين (للمستخدم العادي).
- [x] الكوبون غير محدود لحسابات المالك الأربعة.

### 5) التحديات
- [x] تبويب التحديات.
- [x] بنك أسئلة (~55).
- [x] 5 أسئلة عشوائية يومياً.
- [x] 30 ثانية لكل سؤال.
- [x] 4 خيارات + أخضر/أحمر.
- [x] شاشة النتائج.
- [x] 20 نقطة لكل إجابة.
- [x] منع إعادة التحدي في نفس اليوم.
- [x] Streak تلقائي.

### 6) المتجر
- [x] 4 تبويبات: خلفيات، قراء، مؤذنون، ثيمات.
- [x] 10 خلفيات (7 عادية + 3 VIP).
- [x] 7 قراء + 7 مؤذنين.
- [x] 9 ثيمات (6 عادية + 3 VIP).
- [x] عرض الصور الحقيقية على بطاقات الخلفيات.
- [x] معاينة مصغّرة حية على بطاقات الثيمات.
- [x] شارة VIP + شارة ANIMATION.
- [x] نظام شراء كامل + خصم النقاط.
- [x] تفعيل فوري للعنصر بعد الشراء.
- [x] "مشترياتي".

### 7) الخلفيات
- [x] themeState.backgroundId.
- [x] AppBackground ديناميكي.
- [x] 7 خلفيات عادية + 3 VIP.
- [x] AnimatedVipBackground: zoom + shimmer + نجوم.
- [x] ThemedBackground: طبقة فوق الخلفية + VIP animations.

### 8) الثيمات الديناميكية
- [x] ThemePalette (9 ثيمات).
- [x] themeState + ThemedColors.
- [x] MaterialApp يعيد البناء عند تغيير الثيم.
- [x] الشريط السفلي + GlassCard + StarBadge + OrnamentMedallion + SymbolImage — كلهم theme-aware.
- [x] 3 ثيمات VIP مع animations كاملة.
- [x] يعمل مع الخلفيات VIP بدون تعارض.

### 9) التصميم العام
- [x] ثيم داكن (أخضر + ذهبي).
- [x] أيقونات مخصصة PNG.
- [x] زر الإعدادات في الأعلى.
- [x] ترجمات عربية وإنجليزية.
- [x] ضبط الإيميلات الأربعة (owner).
- [x] إسناد Flaticon في تبويب المزيد.

### 10) نظام الأحجام المتجاوب
- [x] `lib/core/responsive.dart` مع R.s() و R.f().
- [x] welcome_screen responsive.
- [x] home_tab responsive.
- [x] home_shell (bottom bar) responsive.

### 11) القرآن والأذكار
- [x] عرض القرآن كامل.
- [x] تلاوة صوتية مع القارئ المُختار من المتجر.
- [x] تفسير.
- [x] نسخ ومشاركة الآيات.
- [x] الأحاديث.
- [x] مواقيت الصلاة.

---

## ⏳ قيد التنفيذ / الخطوات القادمة

### 🔥 الأولوية القادمة (بكرة)
- [ ] **إصلاح الشريط السفلي** — لا يلمس أزرار الهاتف (Home/Back).
- [ ] **إصلاح بطاقة AI Teacher** — "QURAN TEACHER" على سطر واحد.
- [ ] **إصلاح بطاقة البروفايل** — الأسماء الطويلة لا تخرج من البطاقة.

### أ) بقية الملفات Responsive
- [ ] `ai_teacher_card.dart` — تصغير.
- [ ] `prayer_widgets.dart` — تصغير.
- [ ] `daily_cards.dart` — تصغير.
- [ ] `account_screen.dart` — تصغير.
- [ ] `challenge_screen.dart` — تصغير.
- [ ] `store_screen.dart` — تصغير.
- [ ] `edit_profile_screen.dart` — تصغير.

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
- [ ] 10 أصوات مؤذنين.
- [ ] إشعار "التحدي اليومي تجدد".
- [ ] آية ودعاء يومي.

### و) اللغات
- [ ] الفرنسية، الأوردو، النيبالية، الإندونيسية، المليزية.

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
- backgroundv2.png (default)
- background_blue.png (night)
- background_orange.png (sunset)
- background_brown.png (mosque)
- background_dark.png (kaaba)
- background_purple.png (ramadan)
- background_olive.png (floral)
- backgroundvip1.png (vip_royal)
- backgroundvip2.png (vip_rose)
- backgroundvip3.png (vip_divine)

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
  - حسابات المالك: غير محدود.
  - المستخدمون العاديون: مرة واحدة.

### حسابات المالك (Owner)
- abdelrahmenbenromdhan11@gmail.com → Me.png + true.me
- vevocom888@gmail.com → Me.png + true.me
- nooralimanechannel@gmail.com → logo.png + true.me
- nooralhidayahbusiness@gmail.com → logo.png + true.me

---

## 🙏 شكر وتقدير (Credits)

### الأيقونات
بعض الأيقونات من [Flaticon](https://www.flaticon.com/).

**صيغة الإسناد:** Icon made by Flaticon from www.flaticon.com

**ملاحظة:** الإسناد مطلوب حسب ترخيص Flaticon للمستخدمين المجانيين.
معروض في تبويب "المزيد" في التطبيق.

---

## 🎯 قواعد مهمة للمطور الجديد (أي AI)

1. **قبل أي تعديل:** تأكد من `flutter analyze` = "No issues found".
2. **عند تعديل ملف:** انسخه كامل، لا تعدّل بالقطع.
3. **التصميم:** اتبع الألوان (ذهبي + الثيم الحالي) والحركات.
4. **الصور:** أي أيقونة جديدة في `assets/icons/` أو `assets/images/` ثم `pubspec.yaml`.
5. **البيانات:** كل بيانات المستخدم في Firestore تحت `users/{uid}`.
6. **المزامنة:** استخدم `UserService` و`AuthService` فقط.
7. **الترجمات:** كل نص جديد في `app_state.dart` في `_ar` و`_en`.
8. **الألوان الديناميكية:** استخدم `ThemedColors` (وليس `AppColors`) للعناصر القابلة للتغيير.
9. **الأحجام:** استخدم `R.s(context, base)` و `R.f(context, base)` للعناصر المتجاوبة.
10. **التنقل:** `Navigator.push(MaterialPageRoute(...))`.
11. **اختبار:** بعد كل تعديل، `flutter analyze` + `bash tool/preview.sh`.

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

1. **ملف واحد لكل ميزة** — كل ميزة = ملف جديد على الأقل.
2. **استبدال كامل** — عند تعديل ملف، يُنسخ كامل ويستبدل القديم.
3. **فحص قبل الحفظ** — لا نحفظ قبل `flutter analyze` = `No issues found!` + اختبار ناجح.
4. **`PROJECT.md` يُحدّث بعد كل ميزة** — قبل الانتقال للخطوة التالية.
5. **الخطوات صغيرة** — كل رد فيه خطوة واحدة واضحة.

---

### دورة العمل لكل ميزة جديدة:

**الخطوة 1 — AI يشرح الميزة ويعطي الكود:**
- يشرح ما الذي سيتغير.
- يعطي الكود كامل.
- يذكر: "ملف جديد" أو "استبدل".

**الخطوة 2 — المالك ينسخ الملفات في GitHub:**
- **ملف جديد:** Add file → Create new file → الصق → Commit.
- **ملف موجود:** اضغط الملف → القلم ✏️ → Select All → Delete → الصق → Commit.

**الخطوة 3 — في Terminal:**
- `git pull`
- `flutter analyze` → يجب `No issues found!`.

**الخطوة 4 — اختبار:**
- `bash tool/preview.sh`
- افتح التطبيق، جرب الميزة.

**الخطوة 5 — إذا نجح، احفظ:**
- `git add .`
- `git commit -m "Feature: [اسم الميزة]"`
- `git push`

**الخطوة 6 — حدّث `PROJECT.md`:**
- أضف الميزة في "المنجز" بصيغة `- [x]`.
- احذفها من "قيد التنفيذ".
- حدّث "آخر تحديث" + "الإصدار".

**الخطوة 7 — ابدأ الميزة التالية.**

---

### كيف تُنشأ الملفات الجديدة؟

**ملف Flutter جديد:**
1. GitHub → المجلد المطلوب.
2. Add file → Create new file.
3. اكتب الاسم.
4. الصق الكود.
5. Commit → `git pull`.

**مجلد فرعي:** اكتب المسار كامل: `newfolder/newfile.dart`.

**صورة:** Add file → Upload files → المجلد الصحيح → حدّث `pubspec.yaml` → `git pull` + `flutter pub get`.

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

### حل مشكلة Codespaces (عند فشل البناء):

```bash
pkill -f flutter ; pkill -f dart
flutter clean
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8095 --web-renderer html
```

إذا فشل كل شي:
- VS Code → ☰ → Command Palette → **"Codespaces: Rebuild Container"**.

---

### القواعد الذهبية الثلاث:

1. **لا حفظ بدون اختبار:** لا `git commit` قبل `flutter analyze` = `No issues found!`.
2. **لا استبدال جزئي:** انسخ الملف كامل.
3. **لا انتقال بدون تحديث:** لا بداية ميزة جديدة قبل تحديث `PROJECT.md`.

---

### إذا حصل خطأ:

1. لا تكمل — أوقف.
2. انسخ رسالة الخطأ كاملة.
3. أرسلها للـ AI مع صورة + اسم الملف.
4. AI يصلح ويعطيك كود جديد.
5. أعد من الخطوة 2.

---

### نصائح:

- احفظ نسخة احتياطية: `git tag v0.4-stable && git push --tags`.
- للتجارب: `git checkout -b experiment`.

---

**آخر تحديث لهذا القسم:** 2026-09-28 — ثابت ولا يُحذف.
