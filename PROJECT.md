# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-09-28 | **الإصدار:** Beta 0.6

---

## 📌 نظرة عامة

### التقنيات
- **Flutter** + **Firebase Auth** + **Firestore** + **SharedPreferences**.
- **Codespaces + GitHub** للتطوير، **GitHub Pages** للنشر.

### المالك
**Abdel Rahmen Ben Romdhan**

**الإيميلات الشخصية:**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (Business):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

---

## 🎨 نظام التصميم

### الألوان الافتراضية
`deepGreen #041F18` | `green #0B3D2E` | `emerald #14664C` | `gold #D4AF37` | `softGold #F1DC9A` | `cream #FFF8E7`

### الثيمات الديناميكية
- **9 ثيمات** (`lib/core/theme_palette.dart`): 6 عادية + 3 VIP.
- **themeState** يحفظ المختار (محلي + Firestore).
- **ThemedColors** ألوان ديناميكية — تُستخدم بدل `AppColors` في العناصر القابلة للتغيير.
- **VIP animations**: نجوم متحركة + shimmer + تدرجات + توهج نابض.

### الأحجام المتجاوبة (`lib/core/responsive.dart`)
- حاسوب ≥ 1000px → 0.88 | تابلت ≥ 700px → 0.78 | جوال ≥ 500px → 0.68 | جوال صغير → 0.62.
- استخدم **`R.s(context, base)`** للأحجام، **`R.f(context, base)`** للنصوص.

### الخطوط
- العناوين: Amiri / Noto Naskh | الآيات: amiriQuran (26) | النصوص: Cairo / Noto Sans Arabic.

### الأسلوب البصري
- خلفية خضراء داكنة مع نقشات إسلامية ذهبية.
- تدرجات ذهبية على الأزرار.
- توهج حول العناصر النشطة.
- بطاقات زجاجية (GlassCard) شفافة theme-aware.
- زخارف نجمية في الزوايا.

---

## 📂 بنية الملفات

```
lib/
├── core/
│   ├── app_flow, app_state, prayer_state, profile_state
│   ├── theme, theme_palette, theme_state, themed_colors
│   ├── responsive               (R.s / R.f)
│   ├── reciter_prefs, fonts, validators, navigation
│   ├── quran_prefs, divine_names, firebase_options, strings_prayer
├── data/
│   ├── questions                (~55 سؤال)
│   ├── adhkar                   (7 أقسام، ~60 ذكر)
│   └── store_items              (10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات)
├── models/
│   ├── quran, saved_location
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
├── screens/
│   ├── splash, welcome, login, register, location
│   ├── home_shell               (شريط سفلي مخصص + SafeArea)
│   ├── account, edit_profile
│   ├── challenge, challenge_play, challenge_result
│   ├── store, my_purchases
│   ├── adhkar_screen, adhkar_detail_screen
│   └── tabs/
│       ├── home_tab, quran_browser_tab, community_tab, more_tab
│       └── soon_tabs            (ComingSoonView + AdhkarTab)
└── widgets/
    ├── app_branding, animated_vip_background, themed_background
    ├── theme_preview, asset_icon, profile_avatar, verified_badge
    ├── glass_card, star_badge, ornament_medallion
    ├── auth_widgets, glow_sparks, islamic_pattern
    ├── ai_teacher_card, prayer_widgets, daily_cards, avatar_picker
```

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt, avatar ("man" | "woman")
├── location_label, location_lat, location_lng, location_address
├── profile: { name, bio, isPublic, country, verified, verifiedType, faceScanDone }
├── stats: { points, level, streak, lastActiveDate, challengesCompleted,
│            totalCorrectAnswers, quranKhatmas, aiTeacherScore, redeemedCoupons }
├── inventory: { backgrounds, voices, adhans, themes,
│                activeBackground, activeVoice, activeAdhan, activeTheme }
├── settings: { language, theme, notifications{...} }
└── progress: { challenges{}, quran{}, aiTeacher{} }
```

### Firestore Rules
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

## ✅ المنجز

### 1) الحسابات
- [x] تسجيل/دخول/خروج Firebase
- [x] `authService.isOwner`
- [x] مزامنة كاملة (صورة/موقع/بيانات)

### 2) الملف الشخصي
- [x] شاشة "حسابي" + تعديل
- [x] حلقة ذهبية دوّارة + توهج
- [x] شعار التوثيق (true.me / true.users)
- [x] صور مخصصة لحسابات المالك
- [x] الاسم الطويل لا يخرج من البطاقة

### 3) النقاط والمستويات
- [x] addPoints / incrementStats / setStats
- [x] مستوى تلقائي (100 نقطة/مستوى)
- [x] كود `NAH2026` = 1000 نقطة (غير محدود للمالك)

### 4) التحديات
- [x] 5 أسئلة عشوائية يومياً، 30 ثانية لكل سؤال
- [x] 20 نقطة/إجابة، منع الإعادة اليومية، Streak تلقائي

### 5) المتجر
- [x] 4 تبويبات: خلفيات/قراء/مؤذنون/ثيمات
- [x] 10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات
- [x] VIP animations + شارات VIP/ANIMATION
- [x] "مشترياتي" + تبديل فوري

### 6) الخلفيات والثيمات
- [x] AppBackground + AnimatedVipBackground + ThemedBackground
- [x] GlassCard/StarBadge/OrnamentMedallion/SymbolImage theme-aware

### 7) الأحجام المتجاوبة
- [x] welcome / home_tab / home_shell / account / AI card / prayer card

### 8) الشريط السفلي
- [x] SafeArea (لا يلمس أزرار الهاتف)
- [x] شريط مخصص: الكتابة مباشرة تحت الأيقونة
- [x] أيقونات: challenge.png + community.png + more.png

### 9) تصميم الصفحة الرئيسية
- [x] بطاقة AI Teacher — "QURAN TEACHER" على سطر واحد
- [x] بطاقة الصلاة — أيقونة `adhan.png` ذهبية + أكبر (118) + لمعان متحرك

### 10) القرآن
- [x] القرآن كامل + تلاوة + تفسير + نسخ/مشاركة
- [x] الأحاديث + مواقيت الصلاة

### 11) الأذكار (كامل)
- [x] بنك أذكار (`lib/data/adhkar.dart`) — 7 أقسام (~60 ذكر).
- [x] شاشة أذكار رئيسية (`adhkar_screen.dart`) — عرض الأقسام ببطاقات.
- [x] شاشة تفاصيل (`adhkar_detail_screen.dart`) — عداد لكل ذكر + إعادة + فضل + مرجع.
- [x] أقسام: الصباح، المساء، بعد الصلاة، النوم، الاستيقاظ، متفرقة.
- [x] الضغط على البطاقة = زيادة العداد. الضغط المطول = إعادة.
- [x] تتبع: `X / N` ثم "تم ✓".
- [x] ربط تبويب "الأذكار" في الشريط السفلي بالشاشة الجديدة.

### 12) الإسناد
- [x] قسم Flaticon في تبويب المزيد

---

## ⏳ قيد التنفيذ

### 🔥 الأولوية القادمة (شاشات الوصول السريع — من السهل للصعب)
- [ ] **التسبيح (Tasbeeh)** ← التالي
- [ ] حساب الزكاة (Zakat)
- [ ] الأدعية (Duas)
- [ ] خطة ختم القرآن (Khatm Plan)
- [ ] المحرمات + المكروهات
- [ ] القبلة (Qibla)
- [ ] المساجد القريبة (Nearby Mosques)

### ب) شاشة الإعدادات
- [ ] زر Setting.png
- [ ] إشعارات لكل صلاة + تشغيل الأذان + تذكير قبل الأذان

### ج) الوضع النهاري/الليلي

### د) زر "وثّق حسابي" للمستخدم العادي

### هـ) الإشعارات + شاشة الأذان (10 مؤذنين)

### و) اللغات: الفرنسية، الأوردو، النيبالية، الإندونيسية، المليزية

### ز) المعلم الذكي (AI) كامل

### ح) شاشة المجتمع (نشر + تفاعل)

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah` | Number: `762471094332`
- Web App: `1:762471094332:web:68fe063e9282d7441d8b39` | Location: `nam5`

### أصول الصور
**assets/icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, **adhan**  
**assets/images/**: Me, logo, avatar_man, avatar_woman  
**assets/images/backgrounds/**: backgroundv2 (default), _blue, _orange, _brown, _dark, _purple, _olive, vip1, vip2, vip3

### pubspec.yaml
```
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/
    - assets/images/backgrounds/
```

### Git Workflow
```
flutter analyze           # No issues found!
bash tool/preview.sh      # اختبار
git add . && git commit -m "..." && git push
```

### كودات وأصحاب (Owner)
- **NAH2026** → 1000 نقطة (غير محدود لحسابات المالك، مرة واحدة لكل مستخدم آخر).

**الإيميلات الشخصية (تستخدم Me.png + true.me.png):**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (تستخدم logo.png + true.me.png):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

---

## 🙏 شكر وتقدير

بعض الأيقونات من [Flaticon](https://www.flaticon.com/) — Icon made by Flaticon from www.flaticon.com. الإسناد معروض في تبويب "المزيد".

---

## 🎯 قواعد للمطور الجديد

1. `flutter analyze` = "No issues found" قبل أي تعديل.
2. **استبدال كامل** — لا تعديل بالقطع.
3. ألوان قابلة للتغيير → `ThemedColors` (لا `AppColors`).
4. أحجام → `R.s()` / `R.f()`.
5. كل بيانات في Firestore تحت `users/{uid}`.
6. `UserService` + `AuthService` للـ Firestore.
7. الترجمات في `app_state.dart` (`_ar` + `_en`).
8. الصور في `assets/` → تحديث `pubspec.yaml`.
9. اختبار: `flutter analyze` + `bash tool/preview.sh`.

### القاعدة الذهبية:
بعد كل ميزة ناجحة: `git add . && git commit && git push` + تحديث `PROJECT.md`.

---

## 📞 التواصل

**المالك:** Abdel Rahmen Ben Romdhan

**الإيميلات الشخصية:**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (Business):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

**الشعار:** By Abdel Rahmen Ben Romdhan

---

## 🛠️ طريقة العمل بين المالك و AI (Workflow)

> ⚠️ قسم دائم — لا يُحذف أبداً عند تحديث `PROJECT.md`.

### المبادئ
1. ملف واحد لكل ميزة.
2. **استبدال كامل** — انسخ الملف كامل واستبدل القديم.
3. لا حفظ قبل `flutter analyze` = `No issues found!` + اختبار.
4. `PROJECT.md` يُحدّث بعد كل ميزة.
5. خطوات صغيرة — كل رد فيه خطوة واحدة.

### دورة العمل
**1.** AI يشرح + يعطي الكود (كامل، مع تحديد "ملف جديد" أو "استبدل").  
**2.** المالك ينسخ في GitHub:
   - ملف جديد: Add file → Create new file → الصق → Commit.
   - ملف موجود: افتحه → القلم ✏️ → Select All → Delete → الصق → Commit.  
**3.** Terminal: `git pull` → `flutter analyze` (يجب "No issues found!").  
**4.** اختبار: `bash tool/preview.sh`.  
**5.** حفظ: `git add . && git commit -m "Feature: ..." && git push`.  
**6.** تحديث `PROJECT.md` (لا تحذف قسم طريقة العمل).  
**7.** الميزة التالية.

### إنشاء ملفات جديدة
- **ملف Flutter:** GitHub → المجلد → Add file → Create new file → اكتب الاسم (أو `folder/file.dart`) → الصق → Commit.
- **صورة:** Add file → Upload files → المجلد الصحيح → حدّث `pubspec.yaml`.

### تحديث `PROJECT.md`
1. أضف `- [x]` في "المنجز".
2. احذف البند من "قيد التنفيذ".
3. حدّث "آخر تحديث" + "الإصدار".
4. ⚠️ لا تحذف قسم Workflow.

### حل مشكلة Codespaces
```
pkill -f flutter ; pkill -f dart
flutter clean
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8095 --web-renderer html
```
إذا فشل: Command Palette → **"Codespaces: Rebuild Container"**.

### القواعد الذهبية
1. لا حفظ بدون اختبار.
2. لا استبدال جزئي.
3. لا انتقال بدون تحديث `PROJECT.md`.

### إذا حصل خطأ
أوقف → انسخ الخطأ كامل + صورة + اسم الملف → أرسل للـ AI → أعد من الخطوة 2.

**آخر تحديث لهذا القسم:** 2026-09-28 — ثابت ولا يُحذف.
