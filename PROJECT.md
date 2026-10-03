# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-10-03 | **الإصدار:** Beta 2.0

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
- نظام اشتراكات Premium

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
- **Firebase** — Auth + Firestore + Cloud Functions.
- **Google Gemini AI** — المعلم الذكي.
- **Stripe** — نظام الدفع للاشتراكات.
- **AdMob** — إعلانات المكافآت.
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

## 🏅 نظام الشارات (5 مستويات)

### الترتيب من الأعلى إلى الأدنى:

| # | الشارة | اللون | من يحصل عليها | المميزات |
|---|--------|------|---------------|----------|
| **1** | `owner.png` | 🟡 ذهبي | الإيميلات الأربعة فقط | كل ميزات المطور (لوحة التحكم، نقاط لا نهائية، رؤية Private) |
| **2** | `premium.png` + `true.me.png` | 🟡 ذهبي | 5$/شهر (مع صورة) | 15 ميزة (انظر قسم Premium) |
| **3** | `premium.png` فقط | 🟡 ذهبي | 5$/شهر (بدون صورة) | نفس ميزات Premium |
| **4** | `true.me.png` | 🟡 ذهبي | يمنحها المالك يدوياً | فقط الشارة — لا ميزات |
| **5** | `true.users.png` | 🟡 ذهبي | توثيق عادي (صورة) | فقط الشارة — لا ميزات |
| **6** | بدون شارة | — | الجميع | استخدام عادي |

### قواعد الشارات:
- `owner.png` **يحل مكان** `true.me.png` في حسابات المالك الأربعة.
- **الجنس ثابت** بعد التسجيل (يمكن طلب تغييره من لوحة التحكم).
- **الصورة**: 3 خيارات:
  - Symbol ذكر (للذكور فقط)
  - Symbol انثى (للإناث فقط)
  - صورة شخصية مخصصة (الجميع — اختيارية)
- **الشعارات في كل مكان**: PostCard, التعليقات, الإشعارات, قوائم المتابعين, البروفايل, الشاشة الرئيسية.

---

## 💎 نظام Premium

### الخطط والأسعار:

| الخطة | السعر | الخصم | الفترة |
|-------|-------|-------|--------|
| **شهري** | 5$ | — | 30 يوم |
| **3 أشهر** | 13$ | ~13% | 90 يوم |
| **سنوي** | 45$ | ~25% | 365 يوم |

### طريقة الدفع:
- **Stripe** (موصى به — رسوم أقل: 2.9% + 0.30$).
- بديل: PayPal (رسوم أعلى: 3.49% + 0.49$).

### الميزات الكاملة (15):

| # | الميزة | التفصيل |
|---|--------|---------|
| 1 | 👑 تاج متحرك | فوق الاسم/الصورة في كل مكان |
| 2 | ✨ دائرة ذهبية متحركة | حول صورة البروفايل |
| 3 | 🏷️ `premium.png` + `true.me.png` | أمام الاسم (لو رفع صورة) |
| 4 | 🏷️ `premium.png` فقط | أمام الاسم (لو بدون صورة) |
| 5 | 🚫 بدون إعلانات | إخفاء كامل |
| 6 | 🎨 كل شي VIP مجاني | خلفيات، ثيمات، قراء، خلفيات أذان |
| 7 | 💰 10,000 نقطة شهرياً | تُضاف تلقائياً |
| 8 | 📌 تثبيت 3 منشورات | بدل 1 |
| 9 | ✍️ اسم ذهبي متوهج | في التعليقات والـ Feed |
| 10 | 📝 منشور أطول | 1000 حرف بدل 500 |
| 11 | 🚀 أولوية في Feed | منشوراته أولاً |
| 12 | 🎯 ضعف نقاط التحديات | 40 بدل 20 |
| 13 | 👁️ رؤية الحسابات الخاصة | بدون متابعة |
| 14 | 📊 إحصاءات متقدمة | عدد مشاهدات منشوراته |
| 15 | 🎁 هدية شهرية | مؤذن VIP مجاناً |

### زر Premium:
- في الشريط العلوي (بجانب ⚙️ و 🌐).
- قسم "اشترك في Premium" في المتجر.
- بطاقة Premium في لوحة التحكم (للمالك).

---

## 🔐 نظام الحسابات الخاصة (Private)

| نوع الحساب | يستطيع رؤية Private؟ |
|-----------|---------------------|
| **owner** | ✅ نعم (دائماً) |
| **premium** | ✅ نعم |
| **me / user** | ❌ لا — لازم متابعة + موافقة |
| **بدون شارة** | ❌ لا — لازم متابعة + موافقة |

---

## 📸 نظام تغيير الصورة (للموثقين)

### التدفق:
```
1. المستخدم يرفع صورة جديدة
2. تُحفظ في photo_update_requests/{uid} (لا تُطبَّق فوراً)
3. الصورة القديمة تظهر + "قيد المراجعة"
4. المالك يقارن الصورتين (قديمة/جديدة)
5. القرار:
   ├─ موافقة → الصورة الجديدة + الشارة تبقى + إشعار
   └─ رفض  → الصورة القديمة تبقى + إشعار
6. قفل التغيير لمدة 72 ساعة
```

### للمستخدم غير الموثق:
- يرفع صورة مخصصة → تظهر فوراً.
- اختياري: يطلب توثيق.

---

## 🔄 نظام تغيير الجنس

- **افتراضي**: ثابت بعد التسجيل.
- **الاستثناء**: زر "طلب تغيير" في الإعدادات → يفتح شاشة فيها:
  - الجنس الحالي + الجنس المطلوب.
  - رفع صورة إلزامي (للتحقق).
  - يُحفظ في `gender_change_requests/{uid}`.
- المالك يوافق/يرفض من لوحة التحكم.

---

## ❌ نظام إلغاء التوثيق

- المالك يقدر يسحب التوثيق من أي مستخدم.
- المستخدم يقدر يطلب إلغاء التوثيق (يريد Symbol بدل صورة):
  - **تحذير**: يُزال الشعار + **قفل التوثيق 30 يوم**.
  - `verification_revoke_requests/{uid}`.
- المالك يوافق/يرفض.

---

## 📺 نظام الإعلانات (مؤجل — المرحلة 8)

### الشبكة: **AdMob Rewarded Video**

| المعيار | التفصيل |
|---------|---------|
| **النوع** | Rewarded Video (50 نقطة/إعلان) |
| **الحماية** | SSV (Server-Side Verification) |
| **الحد اليومي** | 10 إعلانات = 500 نقطة |
| **البديل** | Unity Ads (للأجهزة بدون GMS — هواوي) |
| **Cloud Function** | للتحقق من SSV + إضافة النقاط |

### المكان:
- بطاقة كبيرة في أسفل شاشة التحدي.
- زر "شاهد إعلان واربح 50 نقطة".

---

## 🏪 توزيع التطبيق

| المتجر | التكلفة | ملاحظات |
|--------|---------|---------|
| **موقعك الشخصي** | ✅ مجاني | APK مباشر |
| **Samsung Galaxy Store** | ✅ مجاني | يحتاج توقيع APK |
| **Huawei AppGallery** | ✅ مجاني | يحتاج HMS Core |
| **APKPure** | ✅ مجاني | بدون مراجعة صارمة |
| **Aptoide** | ⚠️ مجاني | خطر رفع نسخة معدّلة |

**⚠️ ملاحظة:** لا Play Store / App Store حالياً (رسوم).

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

**التبديل**: `appState.setLanguage(code)` — قائمة في شاشة الإعدادات + شاشة المزيد + أيقونة 🌐 في HomeShell.

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
│       └── community_strings.dart  ← (جديد)
├── data/
│   ├── questions, adhkar, duas, haram, makruh, currencies, store_items
│   ├── adhan_reciters, adhan_timings, ai_teacher_data
├── models/
│   ├── quran, saved_location, mosque, reciter, prayer_times_data
│   ├── post.dart              ✅ (Community)
│   ├── comment.dart           ✅ (Community)
│   ├── user_brief.dart        ✅ (Community)
│   └── community_notification.dart ✅ (Notifications)
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
│   ├── metals_service, khatm_service, qibla_service, mosques_service
│   ├── notification_service, adhan_service
│   ├── gemini_service, recitation_service
│   ├── verification_service
│   ├── community_service.dart ✅ (Community)
│   ├── community_notification_service.dart ✅ (Notifications)
│   ├── follow_service.dart    ✅ (Follow)
│   └── premium_service.dart   ⏳ (Premium — قادم)
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
│   ├── community_feed_screen.dart ✅
│   ├── create_post_screen.dart    ✅
│   ├── post_detail_screen.dart    ✅
│   ├── user_profile_screen.dart   ✅
│   ├── follow_list_screen.dart    ✅
│   ├── notifications_screen.dart  ✅
│   ├── gender_select_screen.dart  ⏳ (قادم)
│   ├── change_photo_screen.dart   ⏳ (قادم)
│   ├── premium_screen.dart        ⏳ (قادم)
│   ├── admin/
│   │   ├── admin_panel_screen.dart
│   │   ├── verification_requests_screen.dart
│   │   ├── photo_requests_screen.dart    ⏳ (قادم)
│   │   ├── gender_requests_screen.dart   ⏳ (قادم)
│   │   ├── revoke_requests_screen.dart   ⏳ (قادم)
│   │   └── premium_screen.dart           ⏳ (قادم)
│   └── tabs/ (home_tab, quran_browser_tab, community_tab, more_tab, soon_tabs)
└── widgets/
    ├── app_branding, animated_vip_background, themed_background
    ├── theme_preview, asset_icon, profile_avatar, verified_badge
    ├── glass_card, star_badge, ornament_medallion
    ├── auth_widgets, glow_sparks, islamic_pattern
    ├── ai_teacher_card, prayer_widgets, daily_cards, avatar_picker
    ├── reciter_picker_sheet
    ├── language_picker_sheet.dart ✅
    └── user_badges.dart        ⏳ (قادم — يعرض owner/premium/me/user)
```

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt
├── avatar ("man" | "woman")
├── location_label, location_lat, location_lng, location_address
├── profile: {
│     name, bio, isPublic, country,
│     gender: "man" | "woman",
│     photoMode: "symbol" | "custom",
│     customPhotoBase64: string,
│     verified: bool,
│     verifiedType: "owner" | "me" | "user" | "premium" | "none",
│     verifiedAt, verifiedBy,
│     photoBase64: string (صورة التوثيق),
│     lastPhotoChangeAt: timestamp,
│     premium: {
│       active: bool,
│       plan: "monthly" | "quarterly" | "yearly",
│       startedAt: timestamp,
│       expiresAt: timestamp,
│       stripeCustomerId: string
│     }
│   }
├── stats: { points, level, streak, lastActiveDate,
│            challengesCompleted, totalCorrectAnswers,
│            quranKhatmas, aiTeacherScore, redeemedCoupons }
├── inventory: { backgrounds, adhans, adhanBackgrounds, themes,
│                activeBackground, activeAdhan,
│                activeAdhanBackground, activeTheme }
├── settings: { language, theme, notifications{...} }
└── progress: {
      challenges, tasbeeh, quran, aiTeacher
    }

verification_requests/{uid}/
├── uid, email, name, gender
├── photoBase64: string
├── requestedAt: timestamp
├── status: "pending" | "approved_user" | "approved_me" | "rejected"
├── reviewedAt, reviewedBy

photo_update_requests/{uid}/
├── uid, email, name
├── oldPhotoBase64, newPhotoBase64
├── requestedAt: timestamp
└── status: "pending" | "approved" | "rejected"

gender_change_requests/{uid}/
├── uid, email, name
├── oldGender, newGender
├── photoBase64: string (للتحقق)
├── requestedAt: timestamp
└── status: "pending" | "approved" | "rejected"

verification_revoke_requests/{uid}/
├── uid, email, name
├── requestedAt: timestamp
└── status: "pending" | "approved" | "rejected"

premium_subscriptions/{uid}/
├── uid, email
├── plan: "monthly" | "quarterly" | "yearly"
├── amount: number
├── currency: "USD"
├── stripeSessionId: string
├── stripeCustomerId: string
├── startedAt: timestamp
├── expiresAt: timestamp
├── status: "active" | "expired" | "cancelled"
└── autoRenew: bool

follows/{followerUid}_{followingUid}/
├── followerUid: string
├── followingUid: string
└── createdAt: timestamp

posts/{postId}/
├── uid, userName, userAvatar
├── userVerified: bool
├── userVerifiedType: "owner" | "me" | "user" | "premium" | "none"
├── userBadges: [string]  ← (قائمة الشارات للعرض السريع)
├── text: string (max 1000)
├── createdAt, editedAt
├── likes: [uid], likesCount, commentsCount, repostsCount
├── repostOf, originalAuthorUid, originalAuthorName, originalAuthorAvatar
├── isPinned, isDeleted
├── mentions, hashtags
└── comments/{commentId}/
    ├── uid, userName, userAvatar
    ├── userVerified: bool
    ├── userVerifiedType: string
    ├── userBadges: [string]
    ├── text: string (max 300)
    ├── createdAt, editedAt
    ├── likes: [uid], likesCount
    └── isDeleted: bool

notifications/{uid}/items/{notifId}/
├── type: "follow" | "like" | "comment" | "repost"
├── fromUid, fromName, fromAvatar
├── fromVerified: bool
├── fromVerifiedType: string
├── fromBadges: [string]
├── targetId: string?
├── createdAt: timestamp
└── isRead: bool
```

### Firestore Rules (الكاملة — منشورة على Firebase Console)
انظر قسم "Firestore Rules" في ملف الـ rules المحفوظ في Firebase Console — النسخة المحدّثة.

---

## ✅ المراحل المكتملة

### 1) الحسابات + Auto-login ✅
- تسجيل/دخول/خروج Firebase.
- `authService.isOwner`.
- Auto-login (يتخطى Welcome و Login).
- مزامنة كاملة بين الأجهزة.
- **Reset كامل للـ State عند signOut** (لا تسرب بيانات بين الحسابات).

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
- **كل القراء مجانيون**.
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

### 18) شاشة الإعدادات ✅
- قسم الحساب.
- إشعارات الصلاة (5 مفاتيح).
- الأذان (تفعيل + تذكير قبل الأذان).
- التذكيرات اليومية.
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
- ar/en في `app_state.dart`.
- fr/ur/ne/id/ms في `i18n/*.dart`.
- `community_strings.dart` لترجمات المجتمع.
- **قائمة لغات كاملة في شاشة المزيد + أيقونة 🌐 في HomeShell**.

### 22) المعلم الذكي (Gemini) ✅
- محادثة نصية + شارة BETA.
- 6 أقسام تعليمية.
- **شاشة تعلّم التلاوة التفاعلية**:
  - 114 سورة + بحث.
  - اختيار قارئ.
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

### 25) ✅ المجتمع (Community Feed) — مكتمل
**الميزات:**
- ✅ نشر منشورات نصية (حتى 500 حرف، مع خطة 1000 لـ Premium).
- ✅ عرض من الأحدث للأقدم.
- ✅ إعجاب ❤️ + تعليقات 💬 + إعادة نشر 🔄.
- ✅ تعديل/حذف منشورك (soft delete).
- ✅ Pin 📌 (منشور واحد — 3 لـ Premium).
- ✅ شارة التوثيق (owner/me/user/premium) في كل مكان.
- ✅ ربط `community_tab` بالشاشة الجديدة.
- ✅ زر "حسابي" في الأعلى (يفتح بروفايلك).
- ✅ **منشور المطور الترحيبي** (قادم).

**الملفات:**
- ✅ `lib/models/post.dart`
- ✅ `lib/models/comment.dart`
- ✅ `lib/services/community_service.dart`
- ✅ `lib/widgets/post_card.dart`
- ✅ `lib/screens/community_feed_screen.dart`
- ✅ `lib/screens/create_post_screen.dart`
- ✅ `lib/screens/post_detail_screen.dart`
- ✅ `lib/screens/tabs/community_tab.dart`

### 26) ✅ نظام المتابعة (Follow System) — مكتمل
**الميزات:**
- ✅ زر متابعة / متابَع.
- ✅ Streams لعدد المتابعين / المتابَعين.
- ✅ قائمة المتابعين / المتابَعين.
- ✅ بروفايل كامل (`user_profile_screen`).
- ✅ ربط التنقل من الـ Feed + التعليقات + الإشعارات.
- ✅ Firestore Rules جديدة لـ `follows`.

**الملفات:**
- ✅ `lib/models/user_brief.dart`
- ✅ `lib/services/follow_service.dart`
- ✅ `lib/screens/user_profile_screen.dart`
- ✅ `lib/screens/follow_list_screen.dart`

### 27) ✅ الإشعارات الاجتماعية — مكتمل
**الميزات:**
- ✅ إشعارات فورية عند: متابعة جديدة، إعجاب، تعليق، إعادة نشر.
- ✅ شاشة إشعارات كاملة (mark all read, clear all).
- ✅ Badge أحمر في HomeShell.
- ✅ اتجاه RTL/LTR تلقائي حسب اللغة.
- ✅ Firestore Rules جديدة لـ `notifications/{uid}/items`.

**الملفات:**
- ✅ `lib/models/community_notification.dart`
- ✅ `lib/services/community_notification_service.dart`
- ✅ `lib/screens/notifications_screen.dart`
- ✅ `lib/screens/home_shell.dart` (محدّث)

### 28) ✅ VerifiedBadge في كل مكان — مكتمل
**الميزات:**
- ✅ `userVerifiedType` في Post/Comment/Notification/UserBrief.
- ✅ عرض `true.me.png` (المميز/المالك) أو `true.users.png` (العادي) في:
  - PostCard
  - التعليقات
  - الإشعارات
  - قوائم المتابعين
  - البروفايل
  - شاشة الحساب
- ✅ الإيميلات الأربعة تُفرض `owner` قسرياً من الـ Frontend.

### 29) ✅ إصلاح تسرب البيانات بين الحسابات — مكتمل
- ✅ `ThemeState.reset()` + `ProfileState.reset()`.
- ✅ SignOut handler chain في `auth_service`.
- ✅ تسجيل الخروج من الحساب أو الإعدادات → شاشة "ابدأ الآن".
- ✅ Auto-login بعد إغلاق التطبيق.

---

## 🚧 المراحل الجارية

### 🌱 المرحلة 30: نظام الشارات المتقدم + Premium (قيد التنفيذ)
**الحالة:** التخطيط مكتمل — نبدأ التنفيذ.

**الفكرة:**
- 5 مستويات شارات (owner/premium/me/user/none).
- صور جديدة: `owner.png` + `premium.png` (ذهبية).
- تغيير الصورة مع إعادة التوثيق للموثقين.
- تغيير الجنس (بطلب).
- إلغاء التوثيق (بطلب + قفل 30 يوم).
- Premium: 3 خطط (5$/13$/45$) + 15 ميزة.
- Stripe للدفع.
- الحسابات الخاصة + override لـ owner/premium.

**الدفعات (10):**
- [ ] A: Firestore Rules + Collections جديدة ✅ (منشورة)
- [ ] B: Models (UserBrief + Post + Comment + Notification)
- [ ] C: Widgets (UserBadges + ProfileAvatar 3 أنواع)
- [ ] D: شاشة اختيار الجنس
- [ ] E: شاشة تغيير الصورة + إعادة توثيق
- [ ] F: لوحة التحكم — 5 بطاقات
- [ ] G: نظام Premium (Stripe)
- [ ] H: الحسابات الخاصة
- [ ] I: الإعلانات (AdMob + SSV)
- [ ] J: PROJECT.md

---

## ⏳ المراحل التالية

### 🌱 المرحلة 31: المحادثات (Chat)
- إضافة صديق.
- شات بين مستخدمين.
- إشعارات للمحادثات.

### 🌱 المرحلة 32: إحصائيات المعلم
- عدد الجلسات + متوسط الدقة + التقدم الأسبوعي.

### 🌱 المرحلة 33: نشر التطبيق
- APK موقّع.
- رفع على: موقعك، Samsung Store، AppGallery، APKPure.

### 🌱 المرحلة 34: الإعلانات (AdMob + SSV)
- Cloud Functions للتحقق.
- بطاقة "شاهد إعلان واربح" في التحدي.

### 🌱 المرحلة 35: إضافات مستقبلية
- الوضع النهاري/الليلي.
- تطبيق إدارة منفصل.
- صور في المنشورات (Firebase Storage).
- إشعارات فورية للتوثيق (Cloud Functions).

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah` | Number: `762471094332`
- Web App: `1:762471094332:web:68fe063e9282d7441d8b39` | Location: `nam5`

### خدمات خارجية
- **Stripe** (الدفع) — قادم.
- **AdMob** (الإعلانات) — قادم.
- **Gemini AI** (المعلم الذكي).

### APIs خارجية (مجانية)
- **الذهب/الفضة:** `https://data-asg.goldprice.org/dbXRates/USD`
- **الصرف:** `https://open.er-api.com/v6/USD`
- **المساجد:** Overpass API.
- **الأذان:** `islamcan.com/audio/adhan/azanN.mp3`.
- **Gemini AI:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent`.

### أصول الصور
**assets/icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, adhan, **owner**, **premium**  
**assets/images/**: Me, logo, arabian, hijab  
**assets/images/backgrounds/**: backgroundv2, _blue, _orange, _brown, _dark, _purple, _olive, vip1, vip2, vip3  
**assets/images/adhan_backgrounds/**: adhan_bg_1..5, adhan_bg_vip_1..3

### pubspec.yaml — Dependencies المهمة
`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_fonts`, `shared_preferences`, `geolocator`, `http`, `wakelock_plus`, `flutter_compass`, `flutter_map`, `latlong2`, `url_launcher`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `audioplayers`, `record`, `path_provider`, `permission_handler`, `image_picker`, `image`.
**قادم:** `flutter_stripe`, `google_mobile_ads`, `cloud_functions`.

### Git Workflow
```
flutter analyze           # No issues found!
bash tool/preview.sh      # اختبار
git add . && git commit -m "..." && git push
```

### كودات وأصحاب (Owner)
- **NAH2026** → 1000 نقطة (غير محدود للمالك فقط).

**الإيميلات الأربعة (Owner):**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

**الفرق بين المستويات:**
| الميزة | owner | premium | me | user |
|--------|-------|---------|-----|------|
| الشعار | owner.png | premium.png + true.me.png | true.me.png | true.users.png |
| لوحة التحكم | ✅ | ❌ | ❌ | ❌ |
| نقاط لانهائية | ✅ | ❌ | ❌ | ❌ |
| رؤية Private | ✅ | ✅ | ❌ | ❌ |
| تاج متحرك | ❌ | ✅ | ❌ | ❌ |
| بدون إعلانات | ✅ | ✅ | ❌ | ❌ |
| VIP مجاني | ✅ | ✅ | ❌ | ❌ |
| 10,000 نقطة/شهر | ✅ | ✅ | ❌ | ❌ |
| تثبيت 3 منشورات | ✅ | ✅ | ❌ | ❌ |

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
7. الترجمات: `app_state.dart` (ar/en) + `i18n/*.dart` (fr/ur/ne/id/ms) + `community_strings.dart`.
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

**آخر تحديث لهذا القسم:** 2026-10-03 — ثابت ولا يُحذف.
