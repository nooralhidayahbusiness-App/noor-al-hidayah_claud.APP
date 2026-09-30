# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-09-30 | **الإصدار:** Beta 1.5

---

## 📌 نظرة عامة

### التقنيات
- **Flutter** + **Firebase Auth** + **Firestore** + **SharedPreferences** + **HTTP API** + **flutter_compass** + **flutter_map** + **flutter_local_notifications** + **audioplayers**.
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

### الألوان
`deepGreen #041F18` | `green #0B3D2E` | `emerald #14664C` | `gold #D4AF37` | `softGold #F1DC9A` | `cream #FFF8E7`

### الثيمات الديناميكية
- **9 ثيمات**: 6 عادية + 3 VIP.
- **themeState** يحفظ المختار (محلي + Firestore).
- **ThemedColors** ألوان ديناميكية.
- **VIP animations**: نجوم + shimmer + تدرجات + توهج نابض.

### الأحجام المتجاوبة (`responsive.dart`)
- حاسوب ≥ 1000px → 0.88 | تابلت ≥ 700px → 0.78 | جوال ≥ 500px → 0.68 | جوال صغير → 0.62.
- استخدم **`R.s(context, base)`** و **`R.f(context, base)`**.

### الخطوط
- العناوين: Amiri / Noto Naskh | الآيات: amiriQuran (26) | النصوص: Cairo.

---

## 📂 بنية الملفات

```
lib/
├── core/
│   ├── app_flow, app_state, prayer_state, profile_state
│   ├── theme, theme_palette, theme_state, themed_colors
│   ├── responsive
│   ├── reciter_prefs, fonts, validators, navigation
│   ├── quran_prefs, divine_names, firebase_options, strings_prayer
│   └── i18n/
│       ├── fr.dart, ur.dart, ne.dart, id.dart, ms.dart
├── data/
│   ├── questions, adhkar, duas, haram, makruh, currencies, store_items
│   ├── adhan_reciters, adhan_timings
├── models/
│   ├── quran, saved_location, mosque
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
│   ├── metals_service, khatm_service, qibla_service, mosques_service
│   ├── notification_service, adhan_service
├── screens/
│   ├── splash, welcome, login, register, location
│   ├── home_shell
│   ├── account, edit_profile, settings_screen
│   ├── challenge, challenge_play, challenge_result
│   ├── store, my_purchases
│   ├── adhkar_screen, adhkar_detail_screen
│   ├── duas_screen, duas_detail_screen
│   ├── tasbeeh_screen, zakat_screen, khatm_plan_screen
│   ├── haram_screen, prohibition_detail_screen
│   ├── qibla_screen, mosques_screen
│   ├── adhan_screen
│   └── tabs/ (home_tab, quran_browser_tab, community_tab, more_tab, soon_tabs)
└── widgets/
    ├── app_branding, animated_vip_background, themed_background
    ├── theme_preview, asset_icon, profile_avatar, verified_badge
    ├── glass_card, star_badge, ornament_medallion
    ├── auth_widgets, glow_sparks, islamic_pattern
    ├── ai_teacher_card, prayer_widgets, daily_cards, avatar_picker
```

---

## 🌍 اللغات المدعومة (7 لغات)

| # | اللغة | الكود | الاتجاه | الملف |
|---|-------|------|---------|-------|
| 1 | العربية | `ar` | RTL | `app_state.dart` |
| 2 | English | `en` | LTR | `app_state.dart` |
| 3 | Français | `fr` | LTR | `i18n/fr.dart` |
| 4 | اردو | `ur` | RTL | `i18n/ur.dart` |
| 5 | नेपाली | `ne` | LTR | `i18n/ne.dart` |
| 6 | Bahasa Indonesia | `id` | LTR | `i18n/id.dart` |
| 7 | Bahasa Melayu | `ms` | LTR | `i18n/ms.dart` |

- **دالة `appState.setLanguage(code)`** للتبديل.
- **قائمة اختيار في شاشة الإعدادات** (7 لغات + علامة ✓ على المختارة).

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt, avatar ("man" | "woman")
├── location_label, location_lat, location_lng, location_address
├── profile: { name, bio, isPublic, country, verified, verifiedType, faceScanDone }
├── stats: { points, level, streak, lastActiveDate, challengesCompleted,
│            totalCorrectAnswers, quranKhatmas, aiTeacherScore, redeemedCoupons }
├── inventory: { backgrounds, voices, adhans, adhanBackgrounds, themes,
│                activeBackground, activeVoice, activeAdhan,
│                activeAdhanBackground, activeTheme }
├── settings: { language, theme, notifications{...} }
└── progress: {
      challenges: { lastPlayedDate, todayPoints, todayCorrect, totalCompleted }
      tasbeeh:    { totalCount, todayCount, lastDate, target, lastDhikr }
      quran:      { khatmActive, startDate, endDate, totalPages, pagesPerDay,
                    pagesRead, lastReadDate, lastReadPage, streak, history,
                    completedKhatmas }
      aiTeacher:  {}
    }
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

### 1) الحسابات + Auto-login
- [x] تسجيل/دخول/خروج Firebase
- [x] `authService.isOwner`
- [x] مزامنة كاملة
- [x] Auto-login

### 2) الملف الشخصي
- [x] شاشة حسابي + تعديل
- [x] حلقة ذهبية دوّارة + توهج
- [x] شعار التوثيق + صور مخصصة

### 3) النقاط والمستويات
- [x] addPoints / incrementStats / setStats
- [x] مستوى تلقائي (100 نقطة/مستوى)
- [x] كود `NAH2026` = 1000 نقطة

### 4) التحديات
- [x] 5 أسئلة عشوائية يومياً، 30 ثانية/سؤال
- [x] 20 نقطة/إجابة، Streak تلقائي

### 5) المتجر
- [x] 5 تبويبات: خلفيات/قراء/مؤذنون/خلفيات أذان/ثيمات
- [x] 10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات + 8 خلفيات أذان
- [x] VIP animations + شارات
- [x] "مشترياتي"

### 6) الخلفيات والثيمات
- [x] AppBackground + AnimatedVipBackground + ThemedBackground
- [x] كل العناصر theme-aware

### 7) الأحجام المتجاوبة — كل الشاشات

### 8) الشريط السفلي — SafeArea + مخصص + أيقونات

### 9) الصفحة الرئيسية — بطاقة AI + بطاقة الصلاة

### 10) الأذكار — 7 أقسام (~60 ذكر) + عدّاد

### 11) التسبيح — عدّاد دائري + Wakelock + 7 أذكار + هدف

### 12) حساب الزكاة — 5 أنواع + 160+ عملة + أسعار حية

### 13) الأدعية — 7 أقسام (~60 دعاء) + نسخ + مشاركة

### 14) خطة ختم القرآن — 30/60/90/180 يوم + ورد يومي + سجل

### 15) المحرمات + المكروهات — ~50 بند بأدلة

### 16) القبلة — بوصلة + مسافة إلى مكة

### 17) المساجد القريبة
- [x] خريطة OpenStreetMap + Overpass API.
- [x] 60% خريطة + 40% قائمة قابلة للتمرير.
- [x] فلترة النطاق (1/3/5/10 كم).
- [x] زر التوجيه (Google/Apple Maps).
- [x] يعمل على APK/iOS — على الويب قد يفشل بسبب CORS.

### 18) شاشة الإعدادات (كامل)
- [x] قسم الحساب
- [x] إشعارات الصلاة (5 مفاتيح + الأذان + التذكيرات اليومية)
- [x] تذكير قبل الأذان (0/5/10/15/20 دقيقة)
- [x] المظهر (اللغة + الثيمات)
- [x] القرآن (القارئ + التقدم التلقائي)
- [x] حول التطبيق
- [x] زر تسجيل الخروج
- [x] حفظ الإعدادات في Firestore

### 19) الإشعارات (كامل)
- [x] `flutter_local_notifications` + `timezone` + `flutter_timezone`.
- [x] إشعارات 5 صلوات (قابلة للتفعيل/الإيقاف).
- [x] تذكير قبل الأذان.
- [x] 3 تذكيرات يومية: التحدي (9ص)، الورد (6ص)، آية اليوم (7ص).
- [x] طلب الصلاحيات تلقائياً.
- [x] إعادة الجدولة عند التغيير.
- [x] payload → يفتح شاشة الأذان عند الضغط.

### 20) شاشة الأذان (كامل)
- [x] 10 مؤذنين بروابط MP3 مباشرة (`adhan_reciters.dart`).
- [x] تشغيل تلقائي عند فتح الشاشة (`adhan_service.dart`).
- [x] نص متحرك يتبع الصوت (توقيتات في `adhan_timings.dart`).
- [x] سطرين بحد أقصى: السابق باهت + الحالي بارز بتوهج.
- [x] زر القبلة + إيقاف/تشغيل + تأجيل + "صليت".
- [x] خلفية من المتجر (8 خلفيات).
- [x] تظهر تلقائياً عند الضغط على الإشعار.
- [x] fallback للويب (بدون صوت/إشعار).

### 21) خلفيات الأذان (8 في المتجر)
- [x] 5 عادية (400-700 نقطة).
- [x] 3 VIP (2000 نقطة) مع animations + نص متحرك.
- [x] تبويب جديد في المتجر: "خلفيات الأذان".
- [x] شارة `VIP` + `ANIMATION`.

### 22) اللغات (7 لغات كاملة)
- [x] العربية + English + Français + اردو + नेपाली + Bahasa Indonesia + Bahasa Melayu.
- [x] ملفات `i18n/*.dart` للغات الجديدة.
- [x] `appState.setLanguage(code)` + دعم RTL للأوردو.
- [x] قائمة اختيار اللغة في الإعدادات (7 لغات).

### 23) الإسناد
- [x] قسم Flaticon في تبويب المزيد + شاشة الإعدادات.

---

## ⏳ قيد التنفيذ

### 🔥 الأولوية القادمة (بالترتيب)
1. [ ] **المعلم الذكي (AI) كامل** — مع خطة مجانية + شارة Beta ← التالي
2. [ ] **شاشة المجتمع** (نشر + تفاعل) — **⚠️ تذكير: جعل `community.png` ذهبي**

### لاحقاً
- [ ] الوضع النهاري/الليلي
- [ ] زر "وثّق حسابي" للمستخدم العادي
- [ ] شاشة "الصدقة" منفصلة
- [ ] إعادة محاولة CORS proxy للمساجد على الويب

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah` | Number: `762471094332`
- Web App: `1:762471094332:web:68fe063e9282d7441d8b39` | Location: `nam5`

### APIs خارجية (مجانية)
- **أسعار الذهب/الفضة:** `https://data-asg.goldprice.org/dbXRates/USD`
- **أسعار الصرف:** `https://open.er-api.com/v6/USD`
- **المساجد:** Overpass API.
- **الأذان:** `islamcan.com/audio/adhan/azanN.mp3` (10 ملفات).
- **AI Teacher:** (قيد البحث — خطة مجانية).

### أصول الصور
**assets/icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, adhan  
**assets/images/**: Me, logo, avatar_man, avatar_woman  
**assets/images/backgrounds/**: backgroundv2 (default), _blue, _orange, _brown, _dark, _purple, _olive, vip1, vip2, vip3  
**assets/images/adhan_backgrounds/**: adhan_bg_1..5, adhan_bg_vip_1..3

### pubspec.yaml — Dependencies المهمة
`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_fonts`, `shared_preferences`, `geolocator`, `http`, `wakelock_plus`, `flutter_compass`, `flutter_map`, `latlong2`, `url_launcher`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `audioplayers`.

### Git Workflow
```
flutter analyze           # No issues found!
bash tool/preview.sh      # اختبار
git add . && git commit -m "..." && git push
```

### كودات وأصحاب (Owner)
- **NAH2026** → 1000 نقطة (غير محدود للمالك).

**الإيميلات الشخصية (Me.png + true.me.png):**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (logo.png + true.me.png):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

---

## 🙏 شكر وتقدير

بعض الأيقونات من [Flaticon](https://www.flaticon.com/) — Icon made by Flaticon.

---

## 🎯 قواعد للمطور الجديد

1. `flutter analyze` = "No issues found" قبل أي تعديل.
2. **استبدال كامل** — لا تعديل بالقطع.
3. ألوان → `ThemedColors` (لا `AppColors`).
4. أحجام → `R.s()` / `R.f()`.
5. Firestore تحت `users/{uid}`.
6. `UserService` + `AuthService`.
7. الترجمات: `app_state.dart` (ar/en) + `i18n/*.dart` (fr/ur/ne/id/ms).
8. الصور في `assets/`.
9. ⚠️ تجنّب تكرار الأحرف العربية في `currencies.dart`.
10. اختبار: `flutter analyze` + `bash tool/preview.sh`.

### القاعدة الذهبية:
بعد كل ميزة: `git add . && git commit && git push` + تحديث `PROJECT.md`.

---

## 📞 التواصل

**المالك:** Abdel Rahmen Ben Romdhan

**الإيميلات الشخصية:**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل:**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

**الشعار:** By Abdel Rahmen Ben Romdhan

---

## 🛠️ طريقة العمل بين المالك و AI (Workflow)

> ⚠️ قسم دائم — لا يُحذف أبداً.

### المبادئ
1. ملف واحد لكل ميزة.
2. **استبدال كامل**.
3. لا حفظ قبل `flutter analyze` = `No issues found!` + اختبار.
4. `PROJECT.md` يُحدّث بعد كل ميزة.
5. خطوات صغيرة.

### دورة العمل
**1.** AI يشرح + يعطي الكود كامل.  
**2.** المالك ينسخ في GitHub → Commit.  
**3.** Terminal: `git pull` → `flutter analyze`.  
**4.** اختبار: `bash tool/preview.sh`.  
**5.** حفظ: `git add . && git commit && git push`.  
**6.** تحديث `PROJECT.md`.  
**7.** الميزة التالية.

### إنشاء ملفات جديدة
- **ملف Flutter:** Add file → Create new file → الصق → Commit.
- **صورة:** Add file → Upload files → المجلد → حدّث `pubspec.yaml`.

### حل مشكلة Codespaces (نفاد الذاكرة)
```
pkill -f flutter ; pkill -f dart
flutter clean
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8095 --web-renderer html
```
إذا فشل: **Stop Codespace** → **Open in browser**.

### القواعد الذهبية
1. لا حفظ بدون اختبار.
2. لا استبدال جزئي.
3. لا انتقال بدون تحديث `PROJECT.md`.

**آخر تحديث لهذا القسم:** 2026-09-30 — ثابت ولا يُحذف.
