# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-09-29 | **الإصدار:** Beta 0.9

---

## 📌 نظرة عامة

### التقنيات
- **Flutter** + **Firebase Auth** + **Firestore** + **SharedPreferences** + **HTTP API**.
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
- **9 ثيمات** (`theme_palette.dart`): 6 عادية + 3 VIP.
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
│   ├── responsive               (R.s / R.f)
│   ├── reciter_prefs, fonts, validators, navigation
│   ├── quran_prefs, divine_names, firebase_options, strings_prayer
├── data/
│   ├── questions                (~55 سؤال)
│   ├── adhkar                   (7 أقسام، ~60 ذكر)
│   ├── duas                     (7 أقسام، ~60 دعاء)
│   ├── currencies               (160+ عملة)
│   └── store_items              (10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات)
├── models/
│   ├── quran, saved_location
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
│   ├── metals_service          (أسعار الذهب/الفضة/الصرف + cache)
│   └── khatm_service           (خطة ختم القرآن)
├── screens/
│   ├── splash (Auto-login), welcome, login, register, location
│   ├── home_shell               (شريط سفلي مخصص + SafeArea)
│   ├── account, edit_profile
│   ├── challenge, challenge_play, challenge_result
│   ├── store, my_purchases
│   ├── adhkar_screen, adhkar_detail_screen
│   ├── duas_screen, duas_detail_screen
│   ├── tasbeeh_screen
│   ├── zakat_screen
│   ├── khatm_plan_screen
│   └── tabs/
│       ├── home_tab, quran_browser_tab, community_tab, more_tab
│       └── soon_tabs
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
- [x] Auto-login: يحفظ الجلسة، يتخطى Welcome و Login.

### 2) الملف الشخصي
- [x] شاشة حسابي + تعديل
- [x] حلقة ذهبية دوّارة + توهج
- [x] شعار التوثيق
- [x] صور مخصصة (Me.png / logo.png)
- [x] الاسم الطويل لا يخرج من البطاقة

### 3) النقاط والمستويات
- [x] addPoints / incrementStats / setStats
- [x] مستوى تلقائي (100 نقطة/مستوى)
- [x] كود `NAH2026` = 1000 نقطة

### 4) التحديات
- [x] 5 أسئلة عشوائية يومياً، 30 ثانية/سؤال
- [x] 20 نقطة/إجابة، Streak تلقائي

### 5) المتجر
- [x] 4 تبويبات
- [x] 10 خلفيات + 7 قراء + 7 مؤذنين + 9 ثيمات
- [x] VIP animations + شارات VIP/ANIMATION
- [x] "مشترياتي"

### 6) الخلفيات والثيمات
- [x] AppBackground + AnimatedVipBackground + ThemedBackground
- [x] كل العناصر theme-aware

### 7) الأحجام المتجاوبة
- [x] كل الشاشات

### 8) الشريط السفلي
- [x] SafeArea، مخصص، الكتابة تحت الأيقونة
- [x] أيقونات challenge/community/more

### 9) الصفحة الرئيسية
- [x] بطاقة AI — سطر واحد
- [x] بطاقة الصلاة — adhan.png ذهبية + لمعان متحرك

### 10) الأذكار
- [x] 7 أقسام (~60 ذكر) + عدّاد + إعادة

### 11) التسبيح
- [x] عدّاد دائري + نبض + haptic + Wakelock
- [x] 7 أذكار + هدف (33/100/مفتوح)

### 12) حساب الزكاة
- [x] 5 أنواع + 160+ عملة + كشف تلقائي
- [x] أسعار حية (ذهب/فضة/صرف) + cache 30 دقيقة

### 13) الأدعية
- [x] 7 أقسام (~60 دعاء) + نسخ + مشاركة

### 14) خطة ختم القرآن
- [x] 30/60/90/180 يوم مع حساب تلقائي للورد اليومي
- [x] تتبع الصفحة الحالية (1-604)
- [x] ورد اليوم + Streak + إحصائيات
- [x] سجل آخر 30 يوم
- [x] شاشة احتفال عند إتمام الختمة
- [x] حفظ في `progress.quran`

### 15) الإسناد
- [x] قسم Flaticon في تبويب المزيد

---

## ⏳ قيد التنفيذ

### 🔥 الأولوية القادمة
1. [ ] **المحرمات + المكروهات** ← التالي
2. [ ] **القبلة (Qibla)** — بوصلة
3. [ ] **المساجد القريبة (Nearby Mosques)**

### لاحقاً
- [ ] شاشة الإعدادات الكاملة
- [ ] إشعارات لكل صلاة + الأذان + تذكير
- [ ] الوضع النهاري/الليلي
- [ ] زر "وثّق حسابي" للمستخدم العادي
- [ ] شاشة الأذان (10 مؤذنين)
- [ ] اللغات الإضافية
- [ ] المعلم الذكي (AI) كامل
- [ ] شاشة المجتمع
- [ ] شاشة "الصدقة" منفصلة

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah` | Number: `762471094332`
- Web App: `1:762471094332:web:68fe063e9282d7441d8b39` | Location: `nam5`

### APIs خارجية (مجانية، بدون مفتاح)
- **أسعار الذهب/الفضة:** `https://data-asg.goldprice.org/dbXRates/USD`
- **أسعار الصرف:** `https://open.er-api.com/v6/USD`

### أصول الصور
**assets/icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, adhan  
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
2. **استبدال كامل**.
3. ألوان → `ThemedColors`.
4. أحجام → `R.s()` / `R.f()`.
5. Firestore تحت `users/{uid}`.
6. `UserService` + `AuthService`.
7. الترجمات في `app_state.dart`.
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

**آخر تحديث لهذا القسم:** 2026-09-29 — ثابت ولا يُحذف.
