# 🕌 نور الهداية — Noor Al-Hidayah

تطبيق إسلامي شامل. **آخر تحديث:** 2026-10-06 | **الإصدار:** Beta 2.1

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
- نظام اشتراكات Premium (قيد التطوير)

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
- **YouTube Data API** — الفيديوهات.
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
- **نجوم ثمانية** في الزوايا (PostCard + Empty states).
- **بطاقات زجاجية** شفافة (GlassCard) مع حدود ذهبية.
- **توهج ذهبي** حول العناصر النشطة.
- **حركات ناعمة**: AnimatedEntry, AnimatedSwitcher, pulse, shimmer.
- **حلقة ذهبية دوّارة** حول صور البروفايل.
- **نبض للقلب** عند الإعجاب.
- **نبض للـ badges** غير المقروءة.

### الأحجام المتجاوبة (`responsive.dart`)
- حاسوب ≥ 1000px → 0.88
- تابلت ≥ 700px → 0.78
- جوال ≥ 500px → 0.68
- جوال صغير → 0.62

**يُستخدم**: `R.s(context, base)` للأحجام و `R.f(context, base)` للنصوص.

### الثيمات الديناميكية (9 ثيمات)
- 6 عادية: default, night, sunset, mosque, kaaba, ramadan.
- 3 VIP: emperor, cosmic, crimson (مع animations).

---

## 🏅 نظام الشارات (5 مستويات)

| # | الشارة | اللون | من يحصل عليها | الميزات |
|---|--------|------|---------------|---------|
| **1** | `owner.png` | 🟡 ذهبي + نبض | الإيميلات الأربعة فقط | كل ميزات المطور |
| **2** | `premium.png` + `true.me.png` | 🟡 ذهبي + نبض | 5$/شهر (مع صورة) | 15 ميزة |
| **3** | `premium.png` فقط | 🟡 ذهبي + نبض | 5$/شهر (بدون صورة) | نفس ميزات Premium |
| **4** | `true.me.png` | 🟡 ذهبي + لمعان | يمنحها المالك يدوياً | فقط الشارة |
| **5** | `true.users.png` | 🟡 ذهبي | توثيق عادي | فقط الشارة |
| **6** | بدون شارة | — | الجميع | استخدام عادي |

**ملاحظة:** كل الشارات تُحوّل تلقائياً للذهبي عبر `ColorFiltered`.

---

## 💎 نظام Premium (مخطط)

### الخطط:
| الخطة | السعر |
|-------|-------|
| شهري | 5$ |
| 3 أشهر | 13$ |
| سنوي | 45$ |

### الدفع:
- **PayPal.me** — `paypal.me/AbdelRahmen2003`
- التفعيل يدوي من لوحة التحكم.

### الميزات (15):
1. 👑 تاج متحرك فوق الاسم
2. ✨ دائرة ذهبية متحركة
3. 🏷️ premium.png + true.me.png
4. 🏷️ premium.png فقط (بدون صورة)
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

### عروض:
- 3 أيام مجانية لكل مستخدم جديد.
- إحالة: صديق يجيب صديق = 3 أيام.

---

## 🔐 نظام الحسابات الخاصة (Private)

| النوع | يرى Private؟ |
|-------|-------------|
| owner | ✅ |
| premium | ✅ |
| me / user | ❌ (لازم متابعة) |
| بدون شارة | ❌ |

**الشات:** خاص → طلب رسالة، عام → يفتح مباشرة.

---

## 📸 نظام تغيير الصورة

### 3 خيارات:
- Symbol ذكر (للذكور فقط)
- Symbol انثى (للإناث فقط)
- صورة مخصصة (الجميع)

### الجنس:
- **ثابت نهائياً** — لا يتغير.
- **تحذير إجباري** في `GenderSelectScreen`.

### Cooldown:
- غير موثق: 24 ساعة.
- موثق: طلب → موافقة المالك.
- owner: بلا قيود.

---

## 🌍 اللغات المدعومة (7 لغات)

| # | اللغة | الكود | الاتجاه |
|---|-------|------|---------|
| 1 | العربية | `ar` | RTL |
| 2 | English | `en` | LTR |
| 3 | Français | `fr` | LTR |
| 4 | اردو | `ur` | RTL |
| 5 | नेपाली | `ne` | LTR |
| 6 | Bahasa Indonesia | `id` | LTR |
| 7 | Bahasa Melayu | `ms` | LTR |

**الملفات:**
- `app_state.dart` → ar + en
- `i18n/fr.dart`, `i18n/ur.dart`, `i18n/ne.dart`, `i18n/id.dart`, `i18n/ms.dart`
- `i18n/community_strings.dart` → ترجمات المجتمع (كل اللغات)
- `strings_prayer.dart` → ترجمات الصلاة
- **الترجمات المحلية** في بعض الشاشات (chat, gender, change_photo)

---

## 📂 بنية الملفات

```
lib/
├── core/
│   ├── app_flow, app_state, prayer_state, profile_state
│   ├── theme, theme_palette, theme_state, themed_colors
│   ├── responsive, reciter_prefs, fonts, validators, navigation
│   ├── quran_prefs, divine_names, firebase_options, strings_prayer
│   ├── channel_config (YouTube)
│   ├── secrets.dart (محمي)
│   └── i18n/
│       ├── fr, ur, ne, id, ms
│       └── community_strings
├── data/
│   └── questions, adhkar, duas, haram, makruh, currencies, store_items,
│       adhan_reciters, adhan_timings, ai_teacher_data
├── models/
│   ├── quran, saved_location, mosque, reciter, prayer_times_data
│   ├── post.dart ✅
│   ├── comment.dart ✅
│   ├── user_brief.dart ✅
│   ├── community_notification.dart ✅
│   ├── chat_message.dart ✅
│   ├── chat.dart ✅
│   ├── message_request.dart ✅
│   └── channel_video_data.dart ✅
├── services/
│   ├── auth_service, user_service, storage_service
│   ├── location_service, quran_audio_service, tafsir_service, share_service
│   ├── metals_service, khatm_service, qibla_service, mosques_service
│   ├── notification_service, adhan_service
│   ├── gemini_service, recitation_service
│   ├── verification_service ✅
│   ├── community_service.dart ✅
│   ├── community_notification_service.dart ✅
│   ├── follow_service.dart ✅
│   ├── chat_service.dart ✅
│   ├── youtube_service.dart ✅
│   ├── link_service
│   └── premium_service.dart ⏳
├── screens/
│   ├── splash, welcome, login, register, location
│   ├── home_shell, account, edit_profile, settings_screen
│   ├── challenge, challenge_play, challenge_result
│   ├── store, my_purchases, adhkar, duas, tasbeeh, zakat, khatm, haram
│   ├── qibla, mosques, adhan
│   ├── ai_teacher, recitation_learning
│   ├── verification_request
│   ├── gender_select_screen ✅
│   ├── change_photo_screen ✅
│   ├── community_feed_screen ✅
│   ├── create_post_screen ✅
│   ├── post_detail_screen ✅
│   ├── user_profile_screen ✅
│   ├── follow_list_screen ✅
│   ├── notifications_screen ✅
│   ├── chat_screen ✅
│   ├── chats_list_screen ✅
│   ├── premium_screen ⏳
│   ├── admin/
│   │   ├── admin_panel_screen ✅
│   │   ├── verification_requests_screen ✅
│   │   ├── photo_requests_screen ✅
│   │   └── add_video_screen ✅
│   └── tabs/
│       ├── home_tab, quran_browser_tab, community_tab
│       ├── channel_view, more_tab, soon_tabs
└── widgets/
    ├── app_branding, animated_vip_background, themed_background
    ├── theme_preview, asset_icon, profile_avatar, verified_badge ✅
    ├── user_badges.dart ✅
    ├── animated_entry.dart ✅
    ├── islamic_empty_state.dart ✅
    ├── glass_card, star_badge, ornament_medallion
    ├── auth_widgets, glow_sparks, islamic_pattern
    ├── ai_teacher_card, prayer_widgets, daily_cards
    ├── reciter_picker_sheet, language_picker_sheet
```

---

## 🗄️ بنية Firestore

```
users/{uid}/
├── email, createdAt, avatar ("man"|"woman")
├── location_*
├── profile: {
│     name, bio, isPublic, country,
│     gender, photoMode, customPhotoBase64,
│     verified, verifiedType,
│     verifiedAt, verifiedBy,
│     photoBase64, lastPhotoChangeAt,
│     setupComplete, premium:{...}
│   }
├── stats, inventory, settings, progress

verification_requests/{uid}/
photo_update_requests/{uid}/
gender_change_requests/{uid}/ (مؤجل)
verification_revoke_requests/{uid}/ (مؤجل)
premium_subscriptions/{uid}/ (مؤجل)
referrals/{newUserId}/ (مؤجل)
follows/{followerUid}_{followingUid}/

posts/{postId}/
├── uid, userName, userAvatar, userPhotoBase64
├── userVerified, userVerifiedType, userBadges
├── text (max 1000), createdAt, editedAt
├── likes, likesCount, commentsCount, repostsCount
├── repostOf, originalAuthor*
├── isPinned, isGlobalPin, isDeleted
├── mentions, hashtags
└── comments/{commentId}/
    ├── uid, userName, userAvatar, userPhotoBase64
    ├── userVerified, userVerifiedType, userBadges
    ├── text (max 300), createdAt, editedAt
    ├── likes, likesCount, isDeleted

notifications/{uid}/items/{notifId}/
├── type: follow|like|comment|repost
│        |photo_approved|photo_rejected
│        |verified_me|verified_user|verify_rejected
│        |new_video|new_reel
├── fromUid, fromName, fromAvatar
├── fromVerified, fromVerifiedType
├── targetId, createdAt, isRead

chats/{chatId}/
├── participants, lastMessage, lastMessageAt
├── lastMessageSenderUid, unread, createdAt
└── messages/{msgId}/
    ├── senderUid, text (max 2000)
    ├── createdAt, readBy, isDeleted

message_requests/{chatId}/
├── fromUid, toUid, status (pending/accepted/rejected)
└── createdAt

channel_videos/{videoId}/
├── title, url, thumbnailUrl, videoId
├── isReel (16:9 أو 9:16)
└── createdAt, addedBy
```

### Firestore Rules
**النسخة الكاملة منشورة على Firebase Console.**

تشمل:
- `isOwnerEmail()` — الإيميلات الأربعة
- `users` — read للجميع، write للمستخدم
- `posts` — create بـ uid، update للمالك (`isGlobalPin`)
- `chats` — read لأي مسجل، create/update لأصحاب المحادثة
- `channel_videos` — read للجميع، write للمالك
- + collections مؤجلة

---

## ✅ المراحل المكتملة

### 1-24) المراحل الأساسية:
الحسابات، البروفايل، النقاط، التحديات، المتجر، الثيمات، الشريط السفلي، الرئيسية، الأذكار، التسبيح، الزكاة، الأدعية، ختم القرآن، المحرمات، القبلة، المساجد، الإعدادات، الإشعارات، الأذان، اللغات، المعلم الذكي، التوثيق، الإسناد.

### 25) ✅ المجتمع (Community Feed)
- نشر منشورات نصية (حتى 1000 حرف)
- إعجاب ❤️ + تعليقات 💬 + إعادة نشر 🔄
- تعديل/حذف (soft delete)
- Pin شخصي
- **منشور الترحيب العالمي** (المالك فقط)
- الشارات في كل مكان
- زر "حسابي" في الأعلى

### 26) ✅ نظام المتابعة (Follow)
- زر متابعة/متابَع
- قوائم المتابعين/المتابَعين
- بروفايل كامل

### 27) ✅ الإشعارات الاجتماعية
- متابعة، إعجاب، تعليق، إعادة نشر
- إشعارات إدارية (توثيق + صورة)
- إشعار "فيديو جديد" لكل المتابعين
- شاشة إشعارات + badge

### 28) ✅ VerifiedBadge في كل مكان
- owner.png / premium.png / true.me.png / true.users.png
- كلها ذهبية + لمعان + نبض

### 29) ✅ إصلاح تسرب البيانات
- reset عند signOut
- Auto-login بعد الإغلاق

### 30) ✅ نظام الصور المتقدم
- 3 خيارات صور
- الجنس ثابت
- cooldown 24 ساعة
- طلب إعادة توثيق
- المالك بلا قيود
- الصورة في كل مكان

### 31) ✅ إشعارات الموافقة/الرفض
- photo_approved / photo_rejected
- verified_me / verified_user / verify_rejected
- درع ذهبي "الإدارة"

### 32) ✅ قناة YouTube
- تابين: الفيديوهات (16:9) + الريلز (9:16)
- Firestore-driven
- تصميم YouTube-style قابل للانزلاق

### 33) ✅ الشات (Chat)
- زر 💬 في HomeShell (chat.png + badge)
- زر 💬 في البروفايل
- Private: طلب رسالة → موافقة → شات
- Public: يفتح مباشرة
- قائمة محادثات + شاشة شات

### 34) ✅ الترجمات الشاملة
- كل الشاشات مترجمة بالـ7 لغات
- chat + channel + admin + community

### 35) ✅ التزيينات النهائية
- `AnimatedEntry` — fade+slide للـ widgets
- `IslamicEmptyState` — نجمة ثمانية دوّارة
- PostCard: نجمتان + معين متوهج + نبض قلب
- VerifiedBadge: لمعان + نبض
- Chat: فقاعات أنيقة + AnimatedEntry
- ChatsList: Avatar rings + Badge نابض
- Profile: staggered AnimatedEntry

### 36) ✅ `tool/preview.sh` (Release + Static)
- Build مرة + serve static → **فائق السرعة**
- يحل مشكلة بطء debug mode

---

## ⏳ المراحل التالية (بالترتيب)

### 🌱 المرحلة 37: FCM + Push Notifications
**المتطلبات:**
- ترقية Firebase لـ Blaze (مجاني عملياً + 300$ رصيد)
- تفعيل `firebase_messaging`
- SHA-1 في Firebase Console
- Cloud Function (Node.js) لمراقبة `notifications/{uid}/items/`
- Service Account

**النتيجة:** كل إشعار يصل **حتى لو التطبيق مغلق**.

**يغطي:** Community, Admin, New Video, Chat, Premium.

### 🌱 المرحلة 38: نظام Premium (تفعيل يدوي)
- شاشة Premium (`premium_screen.dart`)
- بطاقة Premium في لوحة التحكم
- تفعيل يدوي بعد استلام الدفع (PayPal.me)
- تطبيق الـ 15 ميزة
- زر Premium في HomeShell

### 🌱 المرحلة 39: إعلانات AdMob
- ترقية Blaze
- تفعيل AdMob Rewarded Video
- Cloud Function للـ SSV
- بطاقة "شاهد إعلان واربح 50 نقطة" في التحدي
- حد أقصى 10 إعلانات/يوم

### 🌱 المرحلة 40: Stripe (اختياري لاحقاً)
- تكامل Stripe Billing
- Webhook + Cloud Functions
- تفعيل تلقائي

### 🌱 المرحلة 41: طلب تغيير الجنس
- `gender_change_requests`
- بطاقة في لوحة التحكم

### 🌱 المرحلة 42: صور في المنشورات
- Firebase Storage
- صور في الـ Feed

### 🌱 المرحلة 43: تحسينات APK + النشر
- `flutter build apk --release`
- توقيع APK (keystore)
- SHA-1 للـ Google Sign-In
- رفع على: Samsung Store, AppGallery, APKPure, موقعك

### 🌱 المرحلة 44: تطبيق إدارة منفصل (لاحقاً)

---

## 📌 معلومات تقنية

### Firebase
- Project ID: `noor-al-hidayah`
- Number: `762471094332`
- Web App ID: `1:762471094332:web:68fe063e9282d7441d8b39`
- Location: `nam5`
- **Google Web Client ID:** `762471094332-l8vkd8up5i13ivjt1btr0urllgvtoupm.apps.googleusercontent.com`

### PayPal
- الرابط: `paypal.me/AbdelRahmen2003`
- المبالغ: 5 / 13 / 45 USD

### APIs
- **الذهب/الفضة:** `data-asg.goldprice.org/dbXRates/USD`
- **الصرف:** `open.er-api.com/v6/USD`
- **المساجد:** Overpass API
- **الأذان:** `islamcan.com/audio/adhan/azanN.mp3`
- **Gemini AI:** `generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent`
- **YouTube Thumbs:** `img.youtube.com/vi/{videoId}/maxresdefault.jpg`

### الأصول
**icons/**: Setting, challenge, coupon, more, store, community, true.me, true.users, adhan, owner, premium, **chat**

**images/**: Me, logo, arabian, hijab

**backgrounds/**: backgroundv2, _blue, _orange, _brown, _dark, _purple, _olive, vip1, vip2, vip3

**adhan_backgrounds/**: adhan_bg_1..5, adhan_bg_vip_1..3

### pubspec.yaml
`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_fonts`, `shared_preferences`, `geolocator`, `http`, `wakelock_plus`, `flutter_compass`, `flutter_map`, `latlong2`, `url_launcher`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `audioplayers`, `record`, `path_provider`, `permission_handler`, `image_picker`, `image`.

**قادم:** `firebase_messaging`, `google_mobile_ads`, `cloud_functions`.

---

## 🚀 Git Workflow

### العمل اليومي (مع preview سريع):
```
git pull                              # اسحب التحديثات
flutter analyze                       # No issues found!
bash tool/preview.sh                  # build + serve (release)
# اختبار التطبيق
git add . && git commit -m "..." && git push
```

### `tool/preview.sh` — النسخة الحالية:
```bash
#!/bin/bash
pkill -f "http.server" 2>/dev/null
pkill -f flutter 2>/dev/null
pkill -f dart 2>/dev/null
sleep 2

flutter build web --release

cd build/web
python3 -m http.server 8095 --bind 0.0.0.0
```

**⏱️ أول build: 1-3 دقائق | بعدها: ~30 ثانية.**

### للاختبار السريع (debug):
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8095
```
**⚠️ بطيء — لكن يعكس التعديلات فوراً.**

### إذا صار خطأ Build:
```bash
flutter clean
flutter pub get
bash tool/preview.sh
```

---

## 🔑 كودات خاصة

- **NAH2026** → 1000 نقطة (غير محدود للمالك).

## 📊 الفرق بين المستويات

| الميزة | owner | premium | me | user |
|--------|-------|---------|-----|------|
| الشارة | owner.png | premium.png + true.me.png | true.me.png | true.users.png |
| لوحة التحكم | ✅ | ❌ | ❌ | ❌ |
| NAH2026 لا نهائي | ✅ | ❌ | ❌ | ❌ |
| رؤية Private | ✅ | ✅ | ❌ | ❌ |
| تغيير صورة بلا قيود | ✅ | ❌ | ❌ | ❌ |
| تاج متحرك | ❌ | ✅ | ❌ | ❌ |

---

## 🎯 قواعد للمطور الجديد

1. `flutter analyze` = "No issues found" قبل أي تعديل.
2. **استبدال كامل — لا تعديل بالقطع**.
3. ألوان → `ThemedColors` (لا `AppColors` إلا في الثيم الأساسي).
4. أحجام → `R.s()` / `R.f()`.
5. Firestore تحت `users/{uid}`.
6. `UserService` + `AuthService`.
7. الترجمات: `app_state.dart` (ar/en) + `i18n/*.dart` + `community_strings.dart` + محلي في بعض الشاشات.
8. الصور في `assets/`.
9. ⚠️ **`lib/core/secrets.dart` محمي** — لا يرفع على GitHub.
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

### المالك يستخدم **الهاتف** فقط:
- ❌ **لا يُستخدم** `Ctrl+C`, `Ctrl+V`, `Ctrl+X`, `Ctrl+O`.
- ✅ **لتعديل ملف** → واجهة GitHub (قلم ✏️ → Select All → Delete → Paste).
- ✅ **لإيقاف التطبيق** → `pkill -f flutter`.
- ✅ **لتلوين الصور** → `ColorFiltered` في Dart.
- ✅ **للأوامر الطويلة** → نسخة واحدة بدون كتابات إضافية.

### المبادئ:
1. **ملف واحد لكل ميزة**.
2. **استبدال كامل — لا تعديل بالقطع**.
3. **لا حفظ قبل** `flutter analyze` = `No issues found!` + اختبار.
4. `PROJECT.md` يُحدّث بعد كل ميزة.
5. **خطوات صغيرة** — كل رد فيه خطوة واحدة.
6. **الأوامر مجمّعة** في نسخة واحدة.
7. **حماية الذاكرة**: `preview.sh` في release mode.

### دورة العمل:
```
1. AI يعطي الملف(ات) كاملة.
2. المالك ينسخ في GitHub → Commit.
3. Terminal: git pull → flutter analyze.
4. لو نظيف → bash tool/preview.sh.
5. اختبار التطبيق.
6. لو نجح → حفظ (commit + push).
7. AI يعطي الخطوة التالية.
```

### حل مشكلة Codespaces (نفاد الذاكرة):
```
pkill -f flutter ; pkill -f dart
flutter clean
flutter pub get
bash tool/preview.sh
```

إذا فشل: **Stop Codespace** → **Open in browser**.

### القواعد الذهبية:
1. **لا حفظ بدون اختبار**.
2. **لا استبدال جزئي**.
3. **لا انتقال بدون تحديث `PROJECT.md`**.
4. **لا حذف `import` بدون التأكد**.
5. **الأيقونات الجديدة تُلوَّن ذهبي**.
6. **الأنيميشن بسيط وأنيق** — لا مبالغة.

**آخر تحديث لهذا القسم:** 2026-10-06 — ثابت ولا يُحذف.
