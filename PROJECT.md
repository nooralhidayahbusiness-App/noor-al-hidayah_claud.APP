# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-10-02 | **الإصدار:** Beta 1.9

---

## 📌 نظرة عامة

### الهدف
تطبيق إسلامي شامل للمسلمين حول العالم يجمع:
- مواقيت الصلاة + الأذان
- القرآن الكريم + التلاوة
- الأذكار والأدعية
- التحديات والمتجر بنظام النقاط
- معلم ذكي لتصحيح التلاوة (Gemini AI)
- شبكة اجتماعية بسيطة

### المالك
**Abdel Rahmen Ben Romdhan**

**الإيميلات الشخصية:**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (Business):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

### التقنيات
- **Flutter** — الواجهة الأمامية.
- **Firebase** — Auth + Firestore + Storage.
- **Google Gemini AI** — المعلم الذكي.
- **APIs مجانية** — أسعار الذهب/الصرف + Overpass للمساجد.
- **Codespaces + GitHub** — بيئة التطوير.

---

## 🎨 نظام التصميم

### الألوان الأساسية
- `deepGreen #041F18` — الخلفية
- `green #0B3D2E` — ثانوي
- `emerald #14664C` — زمردي
- `gold #D4AF37` — الذهبي
- `softGold #F1DC9A` — ذهبي فاتح
- `cream #FFF8E7` — الكريمي

### الزخارف والأسلوب البصري
- **خلفية خضراء داكنة** مع نقشات إسلامية ذهبية.
- **نجوم ثمانية** في الزوايا.
- **بطاقات زجاجية** شفافة (GlassCard) مع حدود ذهبية.
- **توهج ذهبي** حول العناصر النشطة.
- **حركات ناعمة**: AnimatedSwitcher, AnimatedOpacity, pulse, rotation.
- **خلفيات VIP متحركة**: نجوم + shimmer + تدرجات.
- **حلقة ذهبية دوّارة** حول صور البروفايل.

### الأحجام المتجاوبة (`responsive.dart`)
- حاسوب ≥ 1000px → 0.88
- تابلت ≥ 700px → 0.78
- جوال ≥ 500px → 0.68
- جوال صغير → 0.62

**يُستخدم**: `R.s(context, base)` للأحجام و `R.f(context, base)` للنصوص.

### الخطوط
- العناوين: Amiri / Noto Naskh.
- الآيات: `GoogleFonts.amiriQuran` (26).
- النصوص: Cairo / Noto Sans Arabic.

### الثيمات الديناميكية (9 ثيمات)
- 6 عادية: default, night, sunset, mosque, kaaba, ramadan.
- 3 VIP: emperor, cosmic, crimson (مع animations).

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

**التبديل**: `appState.setLanguage(code)` — قائمة في شاشة الإعدادات.

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
│   ├── secrets.dart           (محمي — .gitignore)
│   └── i18n/
│       ├── fr.dart, ur.dart, ne.dart, id.dart, ms.dart
├── data/
│   ├── questions, adhkar, duas, haram, makruh, currencies, store_items
│   ├── adhan_reciters, adhan_timings, ai_teacher_data
├── models/
│   ├── quran, saved_location, mosque, reciter
│   ├── post.dart              ← (جديد — Community)
│   ├── comment.dart           ← (جديد — Community)
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
│   ├── metals_service, khatm_service, qibla_service, mosques_service
│   ├── notification_service, adhan_service
│   ├── gemini_service, recitation_service
│   ├── verification_service
│   ├── community_service.dart ← (جديد — Community)
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
│   ├── ai_teacher_screen, recitation_learning_screen
│   ├── verification_request_screen
│   ├── admin/
│   │   ├── admin_panel_screen.dart
│   │   └── verification_requests_screen.dart
│   └── tabs/ (home_tab, quran_browser_tab, community_tab, more_tab, soon_tabs)
└── widgets/
    ├── app_branding, animated_vip_background, themed_background
    ├── theme_preview, asset_icon, profile_avatar, verified_badge
    ├── glass_card, star_badge, ornament_medallion
    ├── auth_widgets, glow_sparks, islamic_pattern
    ├── ai_teacher_card, prayer_widgets, daily_cards, avatar_picker
    └── reciter_picker_sheet
```

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt, avatar ("man" | "woman")
├── location_label, location_lat, location_lng, location_address
├── profile: {
│     name, bio, isPublic, country,
│     verified: bool,
│     verifiedType: "owner" | "me" | "user" | "none",
│     verifiedAt, verifiedBy,
│     photoBase64: string (صورة التوثيق)
│   }
├── stats: { points, level, streak, lastActiveDate,
│            challengesCompleted, totalCorrectAnswers,
│            quranKhatmas, aiTeacherScore, redeemedCoupons }
├── inventory: { backgrounds, adhans, adhanBackgrounds, themes,
│                activeBackground, activeAdhan,
│                activeAdhanBackground, activeTheme }
├── settings: { language, theme, notifications{...} }
└── progress: {
      challenges: { lastPlayedDate, todayPoints, todayCorrect, totalCompleted }
      tasbeeh:    { totalCount, todayCount, lastDate, target, lastDhikr }
      quran:      { khatmActive, startDate, endDate, totalPages, pagesPerDay,
                    pagesRead, lastReadDate, lastReadPage, streak, history,
                    completedKhatmas }
      aiTeacher:  { lastRecitationSurah, lastRecitationAyah,
                    recitationSessions, lastRecitationTime }
    }

verification_requests/{uid}/
├── uid, email, name, gender
├── photoBase64: string
├── requestedAt: timestamp
├── status: "pending" | "approved_user" | "approved_me" | "rejected"
├── reviewedAt, reviewedBy

posts/{postId}/
├── uid, userName, userAvatar, userVerified
├── text: string (max 500)
├── createdAt: timestamp
├── editedAt: timestamp?
├── likes: [uid1, uid2, ...]
├── likesCount: int
├── commentsCount: int
├── repostsCount: int
├── repostOf: string? (postId الأصلي)
├── originalAuthorUid, originalAuthorName, originalAuthorAvatar
├── isPinned: bool
├── isDeleted: bool (soft delete)
├── mentions: [userName1, ...]
├── hashtags: [tag1, ...]
└── comments/{commentId}/
    ├── uid, userName, userAvatar, userVerified
    ├── text: string (max 300)
    ├── createdAt: timestamp
    ├── editedAt: timestamp?
    ├── likes: [uid1, uid2, ...]
    ├── likesCount: int
    └── isDeleted: bool
```

### Firestore Rules (الكاملة — تم نشرها)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isOwner() {
      return request.auth != null &&
             request.auth.token.email in [
               'abdelrahmenbenromdhan11@gmail.com',
               'vevocom888@gmail.com',
               'nooralimanechannel@gmail.com',
               'nooralhidayahbusiness@gmail.com'
             ];
    }

    // المستخدمون
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read, update: if isOwner();
    }

    // طلبات التوثيق
    match /verification_requests/{userId} {
      allow read, create: if request.auth != null && request.auth.uid == userId;
      allow read, update, delete: if isOwner();
    }

    // المجتمع: المنشورات
    match /posts/{postId} {
      allow read: if request.auth != null;

      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid
        && request.resource.data.text is string
        && request.resource.data.text.size() > 0
        && request.resource.data.text.size() <= 500;

      allow update: if request.auth != null && (
        (
          resource.data.uid == request.auth.uid
          && request.resource.data.uid == resource.data.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() <= 500
        )
        ||
        (
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['likes', 'likesCount', 'commentsCount'])
        )
      );

      allow delete: if request.auth != null
        && resource.data.uid == request.auth.uid;

      // التعليقات
      match /comments/{commentId} {
        allow read: if request.auth != null;

        allow create: if request.auth != null
          && request.resource.data.uid == request.auth.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() > 0
          && request.resource.data.text.size() <= 300;

        allow update: if request.auth != null && (
          resource.data.uid == request.auth.uid
          ||
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['likes', 'likesCount'])
        );

        allow delete: if request.auth != null
          && resource.data.uid == request.auth.uid;
      }
    }
  }
}
```

---

## ✅ المراحل المكتملة

### 1) الحسابات + Auto-login ✅
- تسجيل/دخول/خروج Firebase.
- `authService.isOwner`.
- Auto-login (يتخطى Welcome و Login).
- مزامنة كاملة بين الأجهزة.

### 2) الملف الشخصي ✅
- شاشة حسابي + تعديل.
- حلقة ذهبية دوّارة + توهج نابض.
- شعار التوثيق (true.me + true.users).
- صور مخصصة لحسابات المالك (Me.png / logo.png).
- الاسم الطويل لا يخرج من البطاقة.

### 3) النقاط والمستويات ✅
- addPoints / incrementStats / setStats.
- مستوى تلقائي (100 نقطة/مستوى).
- كود `NAH2026` = 1000 نقطة (غير محدود للمالك).

### 4) التحديات ✅
- 5 أسئلة عشوائية يومياً.
- 30 ثانية/سؤال، 20 نقطة/إجابة.
- Streak تلقائي.
- منع الإعادة اليومية.

### 5) المتجر ✅
- 4 تبويبات: خلفيات، مؤذنون، خلفيات أذان، ثيمات.
- 10 خلفيات + 7 مؤذنين + 9 ثيمات + 8 خلفيات أذان.
- **كل القراء مجانيون** (أُزيلوا من المتجر).
- شارات VIP + ANIMATION.
- "مشترياتي".

### 6) الخلفيات والثيمات ✅
- AppBackground + AnimatedVipBackground + ThemedBackground.
- كل العناصر theme-aware.

### 7) الأحجام المتجاوبة ✅
- كل الشاشات responsive.

### 8) الشريط السفلي ✅
- SafeArea (لا يلمس أزرار الهاتف).
- 6 أيقونات: الرئيسية، القرآن، الأذكار، التحديات، المجتمع، المزيد.
- أيقونات مخصصة (challenge.png, community.png, more.png).

### 9) الصفحة الرئيسية ✅
- بطاقة AI (سطر واحد).
- بطاقة الصلاة (adhan.png ذهبية + لمعان متحرك).

### 10) الأذكار ✅
- 7 أقسام (~60 ذكر) + عدّاد + إعادة.

### 11) التسبيح ✅
- عدّاد دائري + نبض + haptic + Wakelock.
- 7 أذكار + هدف (33/100/مفتوح).

### 12) حساب الزكاة ✅
- 5 أنواع (مال/ذهب/فضة/زروع/أنعام) + 160+ عملة.
- أسعار حية + cache 30 دقيقة.

### 13) الأدعية ✅
- 7 أقسام (~60 دعاء) + نسخ + مشاركة.

### 14) خطة ختم القرآن ✅
- 30/60/90/180 يوم + ورد يومي + سجل + streak.

### 15) المحرمات + المكروهات ✅
- ~50 بند بأدلة شرعية.

### 16) القبلة ✅
- بوصلة + مسافة إلى مكة.

### 17) المساجد القريبة ✅
- خريطة OpenStreetMap + Overpass API.
- 60% خريطة + 40% قائمة.
- فلترة (1/3/5/10 كم).
- يعمل على APK — الويب فيه CORS.

### 18) شاشة الإعدادات ✅
- قسم الحساب.
- إشعارات الصلاة (5 مفاتيح).
- الأذان (تفعيل + تذكير قبل الأذان).
- التذكيرات اليومية (تحدي، ورد، آية).
- المظهر (اللغة + الثيمات).
- القرآن (القارئ + التقدم التلقائي).
- حول التطبيق.
- **لوحة التحكم (للمالك فقط).**
- تسجيل الخروج.

### 19) الإشعارات ✅
- `flutter_local_notifications` + `timezone`.
- إشعارات 5 صلوات + 3 تذكيرات يومية.
- payload → يفتح شاشة الأذان.

### 20) شاشة الأذان ✅
- 10 مؤذنين بروابط MP3.
- نص متحرك يتبع الصوت (VIP).
- زر القبلة + إيقاف/تشغيل + تأجيل + "صليت".
- 8 خلفيات أذان.

### 21) اللغات (7 لغات) ✅

### 22) المعلم الذكي (Gemini) ✅
- محادثة نصية + شارة BETA.
- 6 أقسام تعليمية.
- **شاشة تعلّم التلاوة التفاعلية**:
  - 114 سورة + بحث.
  - اختيار قارئ (كل القراء مجاناً).
  - تسجيل + تحليل Gemini.
  - نسبة دقة + نجوم + نصائح.
  - حفظ التقدم.

### 23) نظام التوثيق ✅
- شاشة طلب التوثيق (رفع صورة).
- 3 أنواع شعار: owner / me / user.
- **لوحة تحكم للمالك**:
  - عرض الطلبات المعلقة.
  - "توثيق عادي" → true.users.png.
  - "توثيق مميز" → true.me.png.
  - "رفض".
- الصورة تُعرض في البروفايل بعد الموافقة.
- Firestore Rules محدّثة.

### 24) الإسناد ✅
- قسم Flaticon في "المزيد" + الإعدادات.

---

## 🚧 المراحل الجارية

### 🌱 المرحلة 1: المنشورات (Community Feed) — قيد التنفيذ
**الحالة:** تم إنجاز **الأساس** (Models + Service + Rules)، والباقي شاشات و widgets.

**الفكرة:**
- المستخدم ينشر منشورات **نصية فقط** (بدون صور/فيديو).
- عرض المنشورات من الأحدث للأقدم.
- إعجاب ❤️ + تعليقات 💬 + إعادة نشر 🔄.
- تعديل/حذف منشورك.
- Pin 📌 (تثبيت منشور واحد في أعلى ملفك).
- **منشور المطور الترحيبي** (يظهر لكل مستخدم أول مرة).

**ما تم إنجازه:**
- ✅ `lib/models/post.dart` — نموذج المنشور (with likes/mentions/hashtags/repost/pin/softDelete).
- ✅ `lib/models/comment.dart` — نموذج التعليق.
- ✅ `lib/services/community_service.dart` — خدمة Firestore كاملة:
  - Streams: `postsStream`, `userPostsStream`, `postStream`, `commentsStream`.
  - إنشاء/تعديل/حذف: `createPost`, `editPost`, `deletePost` (soft).
  - تفاعلات: `toggleLike` (transaction), `togglePin` (منشور واحد/مستخدم), `repost`.
  - تعليقات: `addComment`, `deleteComment` (مع تحديث `commentsCount`).
- ✅ Firestore Rules جديدة لـ `posts` و `comments` (تم نشرها).

**ما تبقّى:**
- ⏳ `lib/widgets/post_card.dart` — بطاقة عرض منشور.
- ⏳ `lib/screens/community_feed_screen.dart` — الشاشة الرئيسية.
- ⏳ `lib/screens/create_post_screen.dart` — إنشاء منشور.
- ⏳ `lib/screens/post_detail_screen.dart` — تفاصيل + تعليقات.
- ⏳ ربط `community_tab.dart` بالشاشة الجديدة.
- ⏳ منشور المطور الترحيبي.

**بنية Firestore:** (انظر قسم بنية Firestore أعلاه — `posts/{postId}` + `comments`).

---

## ⏳ المراحل التالية

### 🌱 المرحلة 2: صفحة البروفايل الكاملة
- عرض بيانات المستخدم + منشوراته.
- زر Pin (إذا هو بروفايلك).
- عرض التوثيق + شعاره.
- Private Mode للموثّقين.

### 🌱 المرحلة 3: المحادثات (Chat)
**الفكرة:**
- إضافة صديق.
- شات بين مستخدمين.
- زر Chat في الزاوية.
- إشعارات للمحادثات الجديدة.

**بنية Firestore:**
```
chats/{chatId}/
├── participants: [uid1, uid2]
├── lastMessage, lastMessageTime
└── messages/{msgId}/ {uid, text, createdAt}
```

### 🌱 المرحلة 4: إحصائيات المعلم
- عدد الجلسات.
- متوسط الدقة.
- التقدم الأسبوعي.
- نقاط على كل جلسة تلاوة.

### 🌱 المرحلة 5: إضافات مستقبلية
- **الوضع النهاري/الليلي** (نهاري: أبيض + ذهبي).
- **تطبيق إدارة منفصل** (لاحقاً، للمالك).
- **إشعارات فورية للتوثيق** (Cloud Functions).
- **إعادة محاولة CORS proxy للمساجد على الويب**.
- **صور في المنشورات** (يتطلب Firebase Storage).

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah` | Number: `762471094332`
- Web App: `1:762471094332:web:68fe063e9282d7441d8b39` | Location: `nam5`

### APIs خارجية (مجانية)
- **الذهب/الفضة:** `https://data-asg.goldprice.org/dbXRates/USD`
- **الصرف:** `https://open.er-api.com/v6/USD`
- **المساجد:** Overpass API.
- **الأذان:** `islamcan.com/audio/adhan/azanN.mp3`.
- **Gemini AI:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent`.

### أصول الصور
**assets/icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, adhan  
**assets/images/**: Me, logo, arabian, hijab  
**assets/images/backgrounds/**: backgroundv2, _blue, _orange, _brown, _dark, _purple, _olive, vip1, vip2, vip3  
**assets/images/adhan_backgrounds/**: adhan_bg_1..5, adhan_bg_vip_1..3

### pubspec.yaml — Dependencies المهمة
`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_fonts`, `shared_preferences`, `geolocator`, `http`, `wakelock_plus`, `flutter_compass`, `flutter_map`, `latlong2`, `url_launcher`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `audioplayers`, `record`, `path_provider`, `permission_handler`, `image_picker`, `image`.

### Git Workflow
```
flutter analyze           # No issues found!
bash tool/preview.sh      # اختبار
git add . && git commit -m "..." && git push
```

### كودات وأصحاب (Owner)
- **NAH2026** → 1000 نقطة (غير محدود للمالك فقط).

**الإيميلات الشخصية (Me.png + true.me.png):**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (logo.png + true.me.png):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

**الفرق بين owner و me:**
| الميزة | owner | me |
|--------|-------|-----|
| الشعار | true.me.png + لمعان | true.me.png + لمعان |
| لوحة التحكم | ✅ | ❌ |
| NAH2026 غير محدود | ✅ | ❌ |
| صلاحيات المطور | ✅ | ❌ |

---

## 🙏 شكر وتقدير

بعض الأيقونات من [Flaticon](https://www.flaticon.com/) — Icon made by Flaticon.

---

## 🎯 قواعد للمطور الجديد

1. `flutter analyze` = "No issues found" قبل أي تعديل.
2. **استبدال كامل — لا تعديل بالقطع** (الملفات كبيرة).
3. ألوان → `ThemedColors` (لا `AppColors`).
4. أحجام → `R.s()` / `R.f()`.
5. Firestore تحت `users/{uid}`.
6. `UserService` + `AuthService`.
7. الترجمات: `app_state.dart` (ar/en) + `i18n/*.dart` (fr/ur/ne/id/ms).
8. الصور في `assets/`.
9. ⚠️ تجنّب تكرار الأحرف العربية في `currencies.dart`.
10. ⚠️ **`lib/core/secrets.dart` محمي** — لا يرفع على GitHub.
11. اختبار: `flutter analyze` + `bash tool/preview.sh`.

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

### ⚠️ ملاحظة مهمة: المالك يستخدم **الهاتف** فقط — لا كمبيوتر ولا كيبورد:
- ❌ **لا يُستخدم** `Ctrl+C`, `Ctrl+V`, `Ctrl+O`, `Ctrl+X` أبداً.
- ✅ **لحفظ ملفات Terminal** → يُستخدم:
  ```bash
  cat > path/to/file.dart << 'EOF'
  // محتوى الملف
  EOF
  ```
- ✅ **لإيقاف التطبيق** → أيقونة 🗑️ في VS Code أو `Ctrl+C` غير متاح → يُستخدم `pkill -f flutter`.
- ✅ **للتعديل على GitHub** → نستخدم واجهة الويب (Add file / قلم ✏️ / Select All / Delete / Paste).
- ✅ **لتلوين الصور** → أمر Python مباشر.

### المبادئ
1. **ملف واحد لكل ميزة**.
2. **استبدال كامل** — لا تعديل بالقطع.
3. **لا حفظ قبل** `flutter analyze` = `No issues found!` + اختبار.
4. `PROJECT.md` يُحدّث بعد كل ميزة.
5. **خطوات صغيرة** — كل رد فيه خطوة واحدة.

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

**آخر تحديث لهذا القسم:** 2026-10-02 — ثابت ولا يُحذف.
