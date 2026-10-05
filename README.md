# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-10-05 | **الإصدار:** Beta 2.1

---

## 📌 نظرة عامة

### الهدف
تطبيق إسلامي شامل للمسلمين حول العالم يجمع:
- مواقيت الصلاة + الأذان
- القرآن الكريم + التلاوة
- الأذكار والأدعية
- التحديات والمتجر بنظام النقاط
- معلم ذكي لتصحيح التلاوة (Gemini AI)
- شبكة اجتماعية (Community)
- محادثات (Chat)
- قناة YouTube (فيديوهات + ريلز)
- نظام اشتراكات Premium

### المالك
**Abdel Rahmen Ben Romdhan**

**الإيميلات الشخصية:**
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com

**إيميلات العمل (Business):**
- nooralhidayahbusiness@gmail.com
- nooralimanechannel@gmail.com

**الإيميلات الأربعة (Owner)** — تُعطى شارة `owner.png` تلقائياً:
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com
- nooralimanechannel@gmail.com
- nooralhidayahbusiness@gmail.com

### التقنيات
- **Flutter** — الواجهة الأمامية.
- **Firebase** — Auth + Firestore.
- **Google Gemini AI** — المعلم الذكي.
- **YouTube Data API** — الفيديوهات (لاحقاً).
- **PayPal.me** — الدفع (Premium يدوياً).
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
| **1** | `owner.png` | 🟡 ذهبي | الإيميلات الأربعة فقط | كل ميزات المطور |
| **2** | `premium.png` + `true.me.png` | 🟡 ذهبي | 5$/شهر (مع صورة) | 15 ميزة |
| **3** | `premium.png` فقط | 🟡 ذهبي | 5$/شهر (بدون صورة) | نفس ميزات Premium |
| **4** | `true.me.png` | 🟡 ذهبي | يمنحها المالك يدوياً | فقط الشارة |
| **5** | `true.users.png` | 🟡 ذهبي | توثيق عادي | فقط الشارة |
| **6** | بدون شارة | — | الجميع | استخدام عادي |

### قواعد الشارات:
- `owner.png` **يحل مكان** `true.me.png` في حسابات المالك الأربعة.
- **الشعارات في كل مكان**: PostCard, التعليقات, الإشعارات, قوائم المتابعين, البروفايل, الرئيسية.
- كل الشارات **ذهبية** (تحويل تلقائي بـ `ColorFiltered`).

---

## 💎 نظام Premium (مخطط)

### الخطط والأسعار:

| الخطة | السعر | الفترة |
|-------|-------|--------|
| **شهري** | 5$ | 30 يوم |
| **3 أشهر** | 13$ | 90 يوم |
| **سنوي** | 45$ | 365 يوم |

### طريقة الدفع:
- **PayPal.me** — `paypal.me/AbdelRahmen2003`
- التفعيل **يدوي** من لوحة التحكم (مؤقتاً).
- Stripe مؤجل.

### الميزات (15):
1. 👑 تاج متحرك فوق الاسم
2. ✨ دائرة ذهبية متحركة حول الصورة
3. 🏷️ `premium.png` + `true.me.png`
4. 🏷️ `premium.png` فقط (بدون صورة)
5. 🚫 بدون إعلانات
6. 🎨 كل شي VIP مجاني
7. 💰 10,000 نقطة شهرياً
8. 📌 تثبيت 3 منشورات
9. ✍️ اسم ذهبي متوهج
10. 📝 منشور أطول (1000 حرف)
11. 🚀 أولوية في Feed
12. 🎯 ضعف نقاط التحديات
13. 👁️ رؤية الحسابات الخاصة
14. 📊 إحصاءات متقدمة
15. 🎁 هدية شهرية

### مميزات إضافية:
- **3 أيام مجانية** لكل مستخدم جديد.
- **إحالة**: صديق يجيب صديق = 3 أيام مجانية.

---

## 🔐 نظام الحسابات الخاصة (Private)

| نوع الحساب | يستطيع رؤية Private؟ |
|-----------|---------------------|
| **owner** | ✅ نعم |
| **premium** | ✅ نعم |
| **me / user** | ❌ لا — لازم متابعة |
| **بدون شارة** | ❌ لا |

**المحادثات:**
- خاص → يرسل **طلب رسالة** → العضو يوافق → يُفتح الشات.
- عام → يفتح الشات مباشرة.

---

## 📸 نظام تغيير الصورة

### 3 خيارات للصورة:
- **Symbol ذكر** (للذكور فقط)
- **Symbol انثى** (للإناث فقط)
- **صورة مخصصة** (الجميع — اختيارية)

### الجنس:
- **ثابت نهائياً** — لا يتغير أبداً.
- يُختار في شاشة `GenderSelectScreen` عند التسجيل الأول.
- **تحذير إجباري**: "بعد اختيار الجنس، لن يمكنك تغييره أبداً".

### التدفق:
```
مستخدم غير موثق:
  - يرفع صورة → تظهر فوراً
  - قفل 24 ساعة بين التغييرات

مستخدم موثق:
  - يرفع صورة → photo_update_requests (pending)
  - الصورة القديمة تظل معروضة
  - المالك يقارن الصورتين في لوحة التحكم
  - موافقة → الصورة الجديدة + الشارة تبقى
  - رفض  → الصورة القديمة تبقى

المالك (Owner):
  - بلا قيود — تغيير فوري دائماً
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

**التبديل**: `appState.setLanguage(code)` — قائمة كاملة في شاشة المزيد + أيقونة 🌐 في HomeShell.

---

## 📂 بنية الملفات

```
lib/
├── core/
│   ├── app_flow, app_state, prayer_state, profile_state
│   ├── theme, theme_palette, theme_state, themed_colors
│   ├── responsive, reciter_prefs, fonts, validators, navigation
│   ├── quran_prefs, divine_names, firebase_options, strings_prayer
│   ├── channel_config  ← (YouTube)
│   ├── secrets.dart    (محمي — .gitignore)
│   └── i18n/
│       ├── fr, ur, ne, id, ms
│       └── community_strings
├── data/
│   └── questions, adhkar, duas, haram, makruh, currencies, store_items,
│       adhan_reciters, adhan_timings, ai_teacher_data
├── models/
│   ├── quran, saved_location, mosque, reciter, prayer_times_data
│   ├── post.dart              ✅
│   ├── comment.dart           ✅
│   ├── user_brief.dart        ✅
│   ├── community_notification.dart ✅
│   ├── chat_message.dart      ✅
│   ├── chat.dart              ✅
│   ├── message_request.dart   ✅
│   └── channel_video_data.dart ✅
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
│   ├── metals_service, khatm_service, qibla_service, mosques_service
│   ├── notification_service, adhan_service
│   ├── gemini_service, recitation_service
│   ├── verification_service   ✅
│   ├── community_service.dart ✅
│   ├── community_notification_service.dart ✅
│   ├── follow_service.dart    ✅
│   ├── chat_service.dart      ✅
│   ├── youtube_service.dart   ✅
│   ├── link_service
│   └── premium_service.dart   ⏳ (قادم)
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
│   ├── gender_select_screen.dart     ✅
│   ├── change_photo_screen.dart      ✅
│   ├── community_feed_screen.dart    ✅
│   ├── create_post_screen.dart       ✅
│   ├── post_detail_screen.dart       ✅
│   ├── user_profile_screen.dart      ✅
│   ├── follow_list_screen.dart       ✅
│   ├── notifications_screen.dart     ✅
│   ├── chat_screen.dart              ✅
│   ├── chats_list_screen.dart        ✅
│   ├── premium_screen.dart           ⏳
│   ├── admin/
│   │   ├── admin_panel_screen.dart
│   │   ├── verification_requests_screen.dart
│   │   ├── photo_requests_screen.dart ✅
│   │   └── add_video_screen.dart      ✅
│   └── tabs/
│       ├── home_tab, quran_browser_tab, community_tab
│       ├── channel_view, more_tab, soon_tabs
└── widgets/
    ├── app_branding, animated_vip_background, themed_background
    ├── theme_preview, asset_icon, profile_avatar, verified_badge
    ├── user_badges.dart       ✅
    ├── glass_card, star_badge, ornament_medallion
    ├── auth_widgets, glow_sparks, islamic_pattern
    ├── ai_teacher_card, prayer_widgets, daily_cards, avatar_picker (محذوف)
    ├── reciter_picker_sheet
    └── language_picker_sheet.dart ✅
```

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt, avatar ("man"|"woman")
├── location_label, location_lat, location_lng, location_address
├── profile: {
│     name, bio, isPublic, country,
│     gender: "man" | "woman",           ← ثابت
│     photoMode: "symbol" | "custom",
│     customPhotoBase64: string,
│     verified: bool,
│     verifiedType: "owner"|"me"|"user"|"none",
│     verifiedAt, verifiedBy,
│     photoBase64: string,
│     lastPhotoChangeAt: timestamp,
│     setupComplete: bool,                ← بعد شاشة الجنس
│     premium: { active, plan, startedAt, expiresAt, stripeCustomerId }
│   }
├── stats: { points, level, streak, ... }
├── inventory: { backgrounds, adhans, adhanBackgrounds, themes, active* }
├── settings: { language, theme, notifications{...} }
└── progress: { challenges, tasbeeh, quran, aiTeacher }

verification_requests/{uid}/
├── uid, email, name, gender
├── photoBase64
├── requestedAt, status, reviewedAt, reviewedBy

photo_update_requests/{uid}/
├── uid, email, name
├── oldPhotoBase64, newPhotoBase64
├── requestedAt, status, reviewedAt, reviewedBy

gender_change_requests/{uid}/         (مؤجل — الجنس ثابت حالياً)
verification_revoke_requests/{uid}/   (مؤجل)
premium_subscriptions/{uid}/          (مؤجل — تفعيل يدوي)
referrals/{newUserId}/                (مؤجل)

follows/{followerUid}_{followingUid}/
├── followerUid, followingUid, createdAt

posts/{postId}/
├── uid, userName, userAvatar, userPhotoBase64
├── userVerified, userVerifiedType, userBadges
├── text (max 1000), createdAt, editedAt
├── likes, likesCount, commentsCount, repostsCount
├── repostOf, originalAuthorUid/Name/Avatar
├── isPinned, isGlobalPin, isDeleted
├── mentions, hashtags
└── comments/{commentId}/
    ├── uid, userName, userAvatar, userPhotoBase64
    ├── userVerified, userVerifiedType, userBadges
    ├── text (max 300), createdAt, editedAt
    ├── likes, likesCount, isDeleted

notifications/{uid}/items/{notifId}/
├── type: "follow"|"like"|"comment"|"repost"
│        |"photo_approved"|"photo_rejected"
│        |"verified_me"|"verified_user"|"verify_rejected"
├── fromUid, fromName, fromAvatar
├── fromVerified, fromVerifiedType
├── targetId, createdAt, isRead

chats/{chatId}/     (chatId = sorted uids joined with _)
├── participants: [uid1, uid2]
├── lastMessage, lastMessageAt, lastMessageSenderUid
├── unread: {uid1: int, uid2: int}
├── createdAt
└── messages/{msgId}/
    ├── senderUid, text (max 2000)
    ├── createdAt, readBy, isDeleted

message_requests/{chatId}/
├── fromUid, toUid
├── status: "pending" | "accepted" | "rejected"
└── createdAt

channel_videos/{videoId}/
├── title, url, thumbnailUrl, videoId
├── isReel: bool (16:9 أو 9:16)
├── createdAt, addedBy
```

### Firestore Rules (النسخة الكاملة الحالية)

**⚠️ منشورة على Firebase Console** — الرابط: Firebase → Firestore → Rules

(النسخة الكاملة متوفرة في قسم آخر — انسخها كما هي في Firebase Console)

المميزات:
- `isOwnerEmail()` — قائمة الإيميلات الأربعة.
- `users` — كل مستخدم يقرأ/يكتب بياناته، المالك يقرأ الكل.
- `posts` — إنشاء بـ uid، تحديث من المالك (`isGlobalPin`) + like counters.
- `chats` — قراءة لأي مستخدم مسجل، create/update لأصحاب المحادثة.
- `channel_videos` — قراءة للجميع، كتابة للمالك فقط.

---

## ✅ المراحل المكتملة

### 1) الحسابات + Auto-login ✅
### 2) الملف الشخصي ✅
### 3) النقاط والمستويات ✅
### 4) التحديات ✅
### 5) المتجر ✅
### 6) الخلفيات والثيمات ✅
### 7) الأحجام المتجاوبة ✅
### 8) الشريط السفلي ✅
### 9) الصفحة الرئيسية ✅
### 10) الأذكار ✅
### 11) التسبيح ✅
### 12) حساب الزكاة ✅
### 13) الأدعية ✅
### 14) خطة ختم القرآن ✅
### 15) المحرمات + المكروهات ✅
### 16) القبلة ✅
### 17) المساجد القريبة ✅
### 18) شاشة الإعدادات ✅
### 19) الإشعارات (محلية) ✅
### 20) شاشة الأذان ✅
### 21) اللغات (7 لغات) ✅
### 22) المعلم الذكي (Gemini) ✅
### 23) نظام التوثيق ✅
### 24) الإسناد (Flaticon) ✅
### 25) ✅ المجتمع (Community Feed)
- نشر منشورات نصية (حتى 1000 حرف)
- إعجاب ❤️ + تعليقات 💬 + إعادة نشر 🔄
- تعديل/حذف (soft delete)
- Pin شخصي (منشور واحد)
- **منشور الترحيب العالمي** (المالك فقط — يظهر في الأعلى)
- الشارات في كل مكان
- زر "حسابي" في الأعلى
### 26) ✅ نظام المتابعة (Follow)
- زر متابعة/متابَع
- قوائم المتابعين/المتابَعين
- بروفايل كامل
### 27) ✅ الإشعارات الاجتماعية
- متابعة، إعجاب، تعليق، إعادة نشر
- شاشة إشعارات + badge
### 28) ✅ VerifiedBadge في كل مكان
- owner.png / premium.png / true.me.png / true.users.png
- كلها ذهبية عبر ColorFiltered
### 29) ✅ إصلاح تسرب البيانات بين الحسابات
- reset عند signOut
- Auto-login بعد الإغلاق
### 30) ✅ نظام الصور المتقدم
- 3 خيارات (symbol ذكر/انثى + صورة مخصصة)
- الجنس ثابت (تحذير إجباري)
- cooldown 24 ساعة (غير موثق)
- طلب إعادة توثيق (موثق)
- المالك بلا قيود
- الصورة في كل مكان (Feed + Profile + Comments + Notifications + Home)
### 31) ✅ إشعارات الموافقة/الرفض
- photo_approved / photo_rejected
- verified_me / verified_user / verify_rejected
- درع ذهبي "الإدارة" في شاشة الإشعارات
### 32) ✅ قناة YouTube
- تابين: الفيديوهات (16:9) + الريلز (9:16)
- Firestore-driven (channel_videos)
- ترتيب: الجديدة أولاً → فاصل → القديمة تحت
- تصميم YouTube-style قابل للانزلاق
### 33) ✅ الشات (Backend + UI)
- زر 💬 في HomeShell (chat.png + badge)
- زر 💬 في البروفايل (ذهبي/رمادي)
- Private: طلب رسالة → موافقة → شات
- Public: يفتح مباشرة
- قائمة محادثات + شاشة شات + bubble + date labels

---

## 🚧 المرحلة الجارية

### 🌱 المرحلة 34: ترجمة الشاشات الجديدة + إشعار "فيديو جديد"
**قيد التنفيذ.**

**ما يحتاج ترجمة:**
- `chat_screen` + `chats_list_screen` (مترجمة داخلياً — تحتاج مراجعة)
- `gender_select_screen` (مترجمة داخلياً)
- `change_photo_screen` (مترجمة داخلياً)
- `photo_requests_screen` (مترجمة عربي فقط — تحتاج 6 لغات)
- `add_video_screen` (مترجمة عربي فقط — تحتاج 6 لغات)
- `admin_panel_screen` (يحتاج ترجمة)
- رسائل SnackBar موحدة

**ما يحتاج إضافة:**
- إشعار للمتابعين عند رفع فيديو جديد
- إشعار للمستخدمين عند إضافة منشور ترحيب

---

## ⏳ المراحل التالية (بالترتيب)

### 🌱 المرحلة 35: الإعلانات (AdMob + SSV)
- ترقية Firebase لـ Blaze
- تفعيل AdMob Rewarded Video
- Cloud Function للتحقق من SSV
- بطاقة "شاهد إعلان واربح 50 نقطة"

### 🌱 المرحلة 36: FCM (Push Notifications)
- ترقية Firebase لـ Blaze
- تفعيل `firebase_messaging`
- Cloud Function: كل إشعار جديد → Push تلقائي
- يغطي: Community, Admin, New Video, Chat, Premium

### 🌱 المرحلة 37: نظام Premium (تفعيل يدوي)
- شاشة Premium (3 خطط + ميزات)
- بطاقة Premium في لوحة التحكم
- تفعيل يدوي بعد استلام الدفع (PayPal.me)
- شارة + ميزات

### 🌱 المرحلة 38: Stripe (لاحقاً)
- تكامل Stripe Billing
- Webhook + Cloud Functions
- تفعيل تلقائي

### 🌱 المرحلة 39: إشعارات فورية للتوثيق
- Cloud Function تراقب verification_requests
- Push للمالك مباشرة

### 🌱 المرحلة 40: صفحة البروفايل الكاملة (تحديث)
- Private Mode مع override للمالك/Premium
- إحصاءات متقدمة (Premium)
- زر إلغاء التوثيق

### 🌱 المرحلة 41: طلب تغيير الجنس
- `gender_change_requests`
- بطاقة في لوحة التحكم

### 🌱 المرحلة 42: إعلانات + صور للمنشورات
- صور في المنشورات (Firebase Storage)
- إعلانات حقيقية

### 🌱 المرحلة 43: تطبيق إدارة منفصل (لاحقاً)

### 🌱 المرحلة 44: تحسينات APK + النشر
- `flutter build apk --release`
- توقيع APK (keystore)
- SHA-1 في Firebase Console (Google Sign-In)
- رفع على: موقعك، Samsung Store، AppGallery، APKPure

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah` | Number: `762471094332`
- Web App ID: `1:762471094332:web:68fe063e9282d7441d8b39`
- Location: `nam5`
- **Google Web Client ID:** `762471094332-l8vkd8up5i13ivjt1btr0urllgvtoupm.apps.googleusercontent.com`

### PayPal
- الرابط: `paypal.me/AbdelRahmen2003`
- المبالغ: 5 / 13 / 45 USD

### APIs خارجية (مجانية)
- **الذهب/الفضة:** `https://data-asg.goldprice.org/dbXRates/USD`
- **الصرف:** `https://open.er-api.com/v6/USD`
- **المساجد:** Overpass API
- **الأذان:** `islamcan.com/audio/adhan/azanN.mp3`
- **Gemini AI:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent`
- **YouTube Thumbnails:** `https://img.youtube.com/vi/{videoId}/maxresdefault.jpg`

### أصول الصور
**assets/icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, adhan, owner, premium, **chat**  
**assets/images/**: Me, logo, arabian, hijab  
**assets/images/backgrounds/**: backgroundv2, _blue, _orange, _brown, _dark, _purple, _olive, vip1, vip2, vip3  
**assets/images/adhan_backgrounds/**: adhan_bg_1..5, adhan_bg_vip_1..3

### pubspec.yaml — Dependencies المهمة
`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_fonts`, `shared_preferences`, `geolocator`, `http`, `wakelock_plus`, `flutter_compass`, `flutter_map`, `latlong2`, `url_launcher`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `audioplayers`, `record`, `path_provider`, `permission_handler`, `image_picker`, `image`.

**قادم:** `google_mobile_ads`, `firebase_messaging`, `cloud_functions`.

### Git Workflow
```
git pull                              # اسحب التحديثات
flutter analyze                       # No issues found!
bash tool/preview.sh                  # اختبار
git add .                             # جهّز
git commit -m "..."                   # احفظ
git push                              # ارفع
```

### كودات خاصة (Owner)
- **NAH2026** → 1000 نقطة (غير محدود للمالك).

### الفرق بين المستويات
| الميزة | owner | premium | me | user |
|--------|-------|---------|-----|------|
| الشارة | owner.png | premium.png + true.me.png | true.me.png | true.users.png |
| لوحة التحكم | ✅ | ❌ | ❌ | ❌ |
| NAH2026 لا نهائي | ✅ | ❌ | ❌ | ❌ |
| رؤية Private | ✅ | ✅ | ❌ | ❌ |
| تاج متحرك | ❌ | ✅ | ❌ | ❌ |
| تغيير صورة بلا قيود | ✅ | ❌ | ❌ | ❌ |

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

### ⚠️ المالك يستخدم **الهاتف** فقط:
- ❌ **لا يُستخدم** `Ctrl+C`, `Ctrl+V`, `Ctrl+X`, `Ctrl+O`.
- ✅ **لتعديل ملف** → يُستخدم واجهة GitHub (قلم ✏️ → Select All → Delete → Paste).
- ✅ **لإيقاف التطبيق** → `pkill -f flutter`.
- ✅ **لتلوين الصور** → `ColorFiltered` في Dart.
- ✅ **للأوامر الطويلة** → أمر واحد، بدون كتابات إضافية.

### المبادئ
1. **ملف واحد لكل ميزة**.
2. **استبدال كامل — لا تعديل بالقطع**.
3. **لا حفظ قبل** `flutter analyze` = `No issues found!` + اختبار.
4. `PROJECT.md` يُحدّث بعد كل ميزة.
5. **خطوات صغيرة** — كل رد فيه خطوة واحدة.
6. **الأوامر مجمّعة** في نسخة واحدة بدون كتابات إضافية.

### دورة العمل (المُتبعة)
```
1. AI يعطي الملف(ات) كاملة.
2. المالك ينسخ في GitHub → Commit.
3. Terminal: git pull → flutter analyze.
4. لو نظيف → commit + push.
5. اختبار بـ bash tool/preview.sh.
6. لو نجح → AI يعطي الخطوة التالية.
```

### حل مشكلة Codespaces (نفاد الذاكرة)
```
pkill -f flutter ; pkill -f dart
flutter clean
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8095 --web-renderer html
```
إذا فشل: **Stop Codespace** → **Open in browser**.

### القواعد الذهبية
1. **لا حفظ بدون اختبار**.
2. **لا استبدال جزئي**.
3. **لا انتقال بدون تحديث `PROJECT.md`**.
4. **لا حذف `import` بدون التأكد من أنه غير مستخدم**.
5. **أيقونات جديدة تُلوَّن بـ `ColorFiltered` ذهبي**.

**آخر تحديث لهذا القسم:** 2026-10-05 — ثابت ولا يُحذف.
