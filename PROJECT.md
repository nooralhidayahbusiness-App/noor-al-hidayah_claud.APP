# 🕌 نور الهداية — Noor Al-Hidayah

> **آخر تحديث:** 2026-10-06 | **الإصدار:** Beta 2.2 | **الحالة:** Premium نظام مكتمل — قيد إضافة الميزات

---

## 📖 كيف تقرأ هذا الملف (للـ AI)

هذا الملف مُصمّم **للعمل مع AI في جلسات متعددة**. كل قسم فيه معلومات كاملة تُغني عن أي ملف آخر.

**⚠️ قواعد إجبارية للـ AI عند قراءة الملف:**
1. **اقرأ كل الأقسام** قبل أول رد.
2. **اتبع نفس الأسلوب** الموثق في قسم "طريقة العمل" بالأسفل.
3. **لا تسأل عن معلومات موجودة في الملف** — استخرجها.
4. **أي ميزة جديدة** → ملف كامل → تعديل على GitHub → `git pull` → `flutter analyze` → حفظ.
5. **لا تقترح تعديلات جزئية** أبداً — المستخدم يستبدل الملفات كاملة.

---

## 🎯 نظرة عامة

### التطبيق
**Noor Al-Hidayah (نور الهداية)** — تطبيق إسلامي شامل للمسلمين حول العالم.

### الميزات الرئيسية
- 🕌 مواقيت الصلاة + الأذان (10 مؤذنين)
- 📖 القرآن الكريم + التلاوة (كل القراء)
- 🤲 الأذكار والأدعية (~120 عنصر)
- 🏆 التحديات + المتجر + النقاط
- 🎓 معلم ذكي لتصحيح التلاوة (Gemini AI)
- 💬 شبكة اجتماعية (Posts, Comments, Likes, Reposts, Follow)
- 🎬 قناة YouTube (فيديوهات 16:9 + ريلز 9:16)
- 💬 نظام محادثات (Chat) مع طلبات للمستخدمين Private
- 💎 نظام Premium (اشتراك مدفوع)
- 📬 إشعارات اجتماعية + إدارية
- 📺 إعلانات مكافئة (Rewarded Ads)

### الجمهور المستهدف
- عالمي (7 لغات)
- Android + iOS (لاحقاً)
- Web (للتطوير)

---

## 👤 المالك والحسابات

### المالك
**Abdel Rahmen Ben Romdhan**

### إيميلات المالك (Owner) — 4 إيميلات
هذه الإيميلات تحصل تلقائياً على شارة `owner.png` (ذهبية + نبض) + كل الميزات:

```
1. abdelrahmenbenromdhan11@gmail.com
2. vevocom888@gmail.com
3. nooralimanechannel@gmail.com
4. nooralhidayahbusiness@gmail.com
```

**الفرق بين المستويات:**

| الميزة | owner | premium | me | user | none |
|--------|-------|---------|-----|------|------|
| الشارة | owner.png | premium.png + true.me.png | true.me.png | true.users.png | لا شيء |
| لوحة التحكم | ✅ | ❌ | ❌ | ❌ | ❌ |
| NAH2026 لا نهائي | ✅ | ❌ | ❌ | ❌ | ❌ |
| رؤية Private | ✅ | ✅ | ❌ | ❌ | ❌ |
| تغيير صورة بلا قيود | ✅ | ❌ | ❌ | ❌ | ❌ |
| تاج متحرك | ❌ | ✅ | ❌ | ❌ | ❌ |
| Ad-free | ✅ | ✅ | ❌ | ❌ | ❌ |
| 10,000 نقطة/شهر | ✅ | ✅ | ❌ | ❌ | ❌ |

### AdMob Account
- **الإيميل:** `abdelrahmenbenromdhan11@gmail.com`
- **Android App ID:** `ca-app-pub-7354273374998913~5567231375`
- **Android Rewarded Unit:** `ca-app-pub-7354273374998913/5755827856`
- **iOS App ID:** `ca-app-pub-7354273374998913~4615890593`
- **iOS Rewarded Unit:** `ca-app-pub-7354273374998913/8080492888`

### PayPal
- **الرابط:** `https://www.paypal.me/AbdelRahmen2003`
- **المبالغ:** 5$ (شهري), 13$ (3 أشهر), 45$ (سنوي)

### Firebase
- **Project ID:** `noor-al-hidayah`
- **Number:** `762471094332`
- **Web App ID:** `1:762471094332:web:68fe063e9282d7441d8b39`
- **Location:** `nam5`
- **Google Web Client ID:** `762471094332-l8vkd8up5i13ivjt1btr0urllgvtoupm.apps.googleusercontent.com`

---

## 🎨 نظام التصميم

### الألوان الأساسية
```dart
deepGreen #041F18  // الخلفية الرئيسية
green     #0B3D2E  // ثانوي
emerald   #14664C  // زمردي
gold      #D4AF37  // الذهبي
softGold  #F1DC9A  // ذهبي فاتح
cream     #FFF8E7  // الكريمي
```

### الأسلوب البصري
- خلفية خضراء داكنة + نقشات إسلامية ذهبية
- نجوم ثمانية في الزوايا
- بطاقات زجاجية (GlassCard) بحدود ذهبية
- توهج ذهبي حول العناصر النشطة
- حلقة ذهبية دوّارة حول صور البروفايل
- الأنيميشن: `AnimatedEntry` (fade+slide)، نبض للقلب، shimmer للشارات

### الأحجام المتجاوبة (`lib/core/responsive.dart`)
- حاسوب ≥ 1000px → factor 0.88
- تابلت ≥ 700px → factor 0.78
- جوال ≥ 500px → factor 0.68
- جوال صغير → factor 0.62

**الاستخدام:**
- `R.s(context, value)` → للحجم
- `R.f(context, value)` → للخطوط

### الثيمات (9)
6 عادية: default, night, sunset, mosque, kaaba, ramadan  
3 VIP: emperor, cosmic, crimson (مع animations)

---

## 🌍 اللغات (7 لغات)

| # | اللغة | Code | الاتجاه | مكان الترجمة |
|---|-------|------|---------|--------------|
| 1 | العربية | ar | RTL | `app_state.dart` (_ar) |
| 2 | English | en | LTR | `app_state.dart` (_en) |
| 3 | Français | fr | LTR | `i18n/fr.dart` |
| 4 | اردو | ur | RTL | `i18n/ur.dart` |
| 5 | नेपाली | ne | LTR | `i18n/ne.dart` |
| 6 | Bahasa Indonesia | id | LTR | `i18n/id.dart` |
| 7 | Bahasa Melayu | ms | LTR | `i18n/ms.dart` |

**ملفات ترجمة إضافية:**
- `strings_prayer.dart` → ترجمات الصلاة
- `i18n/community_strings.dart` → ترجمات المجتمع (كل اللغات)
- **ترجمات محلية** في بعض الشاشات: `chat_screen`, `chats_list_screen`, `change_photo_screen`, `gender_select_screen`, `premium_screen`, `premium_checkout_screen`, `add_video_screen`, `photo_requests_screen`, `admin_panel_screen`, `notifications_screen`, `premium_promo_dialog`

**الاستخدام:**
```dart
appState.tr('key')  // ترجمة عادية
appState.trn('keyWith{n}', n)  // ترجمة مع {n}
```

---

## 📂 بنية المشروع الكاملة

```
lib/
├── core/
│   ├── app_flow.dart              // التنقل بعد auth
│   ├── app_state.dart             // اللغة + الترجمة (ar/en + 5 ملفات)
│   ├── prayer_state.dart          // مواقيت الصلاة
│   ├── profile_state.dart         // البروفايل (reset عند signOut)
│   ├── reciter_prefs.dart         // القارئ المفضل
│   ├── theme_state.dart           // الخلفيات والثيمات
│   ├── theme.dart                 // AppColors
│   ├── theme_palette.dart         // كل الثيمات
│   ├── themed_colors.dart         // ألوان theme-aware
│   ├── responsive.dart            // R.s / R.f
│   ├── fonts.dart                 // brandStyle
│   ├── validators.dart            // email/password
│   ├── navigation.dart            // fadeRoute
│   ├── quran_prefs.dart
│   ├── divine_names.dart
│   ├── firebase_options.dart
│   ├── strings_prayer.dart
│   ├── channel_config.dart        // إعدادات YouTube
│   ├── secrets.dart               // 🔴 محمي (.gitignore)
│   └── i18n/
│       ├── fr.dart, ur.dart, ne.dart, id.dart, ms.dart
│       └── community_strings.dart
│
├── data/
│   ├── questions.dart             // أسئلة التحدي
│   ├── adhkar.dart, duas.dart
│   ├── haram.dart, makruh.dart
│   ├── currencies.dart
│   ├── store_items.dart
│   ├── adhan_reciters.dart, adhan_timings.dart
│   └── ai_teacher_data.dart
│
├── models/
│   ├── quran.dart, saved_location.dart, mosque.dart
│   ├── reciter.dart, prayer_times_data.dart
│   ├── post.dart                  // ✅
│   ├── comment.dart               // ✅
│   ├── user_brief.dart            // ✅
│   ├── community_notification.dart // ✅
│   ├── chat_message.dart          // ✅
│   ├── chat.dart                  // ✅
│   ├── message_request.dart       // ✅
│   ├── channel_video_data.dart    // ✅
│   └── premium_request.dart       // ✅
│
├── services/
│   ├── auth_service.dart          // ✅ login/register/signOut + handlers
│   ├── user_service.dart          // ✅ stats/profile/inventory/progress
│   ├── storage_service.dart
│   ├── location_service.dart
│   ├── quran_audio_service.dart, tafsir_service.dart, share_service.dart
│   ├── metals_service.dart, khatm_service.dart
│   ├── qibla_service.dart, mosques_service.dart
│   ├── notification_service.dart  // إشعارات محلية (صلوات)
│   ├── adhan_service.dart
│   ├── gemini_service.dart, recitation_service.dart
│   ├── verification_service.dart  // ✅ (توثيق + صور + جنس)
│   ├── community_service.dart     // ✅ (posts/comments/likes)
│   ├── community_notification_service.dart // ✅
│   ├── follow_service.dart        // ✅
│   ├── chat_service.dart          // ✅
│   ├── youtube_service.dart       // ✅
│   ├── link_service.dart
│   ├── ads_service.dart           // ✅ AdMob
│   └── premium_service.dart       // ✅
│
├── screens/
│   ├── splash_screen.dart         // ✅ يفحص setupComplete
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── location_screen.dart
│   ├── home_shell.dart            // ✅
│   ├── account_screen.dart        // ✅ (Premium badge)
│   ├── edit_profile_screen.dart
│   ├── settings_screen.dart
│   ├── challenge_screen.dart      // ✅ (RewardedAdCard)
│   ├── challenge_play_screen.dart
│   ├── challenge_result_screen.dart
│   ├── store_screen.dart          // ✅ (Premium banner)
│   ├── my_purchases_screen.dart
│   ├── adhkar_screen.dart, adhkar_detail_screen.dart
│   ├── duas_screen.dart, duas_detail_screen.dart
│   ├── tasbeeh_screen.dart, zakat_screen.dart, khatm_plan_screen.dart
│   ├── haram_screen.dart, prohibition_detail_screen.dart
│   ├── qibla_screen.dart, mosques_screen.dart
│   ├── adhan_screen.dart
│   ├── ai_teacher_screen.dart, recitation_learning_screen.dart
│   ├── verification_request_screen.dart
│   ├── gender_select_screen.dart  // ✅ (تحذير إجباري)
│   ├── change_photo_screen.dart   // ✅ (24h cooldown + owner bypass)
│   ├── community_feed_screen.dart // ✅
│   ├── create_post_screen.dart    // ✅
│   ├── post_detail_screen.dart    // ✅
│   ├── user_profile_screen.dart   // ✅
│   ├── follow_list_screen.dart    // ✅
│   ├── notifications_screen.dart  // ✅
│   ├── chat_screen.dart           // ✅
│   ├── chats_list_screen.dart     // ✅
│   ├── premium_screen.dart        // ✅ (4 حالات)
│   ├── premium_checkout_screen.dart // ✅
│   ├── admin/
│   │   ├── admin_panel_screen.dart          // ✅ (4 بطاقات)
│   │   ├── verification_requests_screen.dart // ✅
│   │   ├── photo_requests_screen.dart       // ✅
│   │   ├── premium_requests_screen.dart     // ✅
│   │   └── add_video_screen.dart            // ✅
│   └── tabs/
│       ├── home_tab.dart, quran_browser_tab.dart
│       ├── community_tab.dart     // ✅
│       ├── channel_view.dart      // ✅ (تابات + NestedScrollView)
│       ├── more_tab.dart, soon_tabs.dart
│
└── widgets/
    ├── app_branding.dart, animated_vip_background.dart
    ├── themed_background.dart
    ├── theme_preview.dart, asset_icon.dart
    ├── profile_avatar.dart        // ✅ (3 أنواع + crown)
    ├── verified_badge.dart        // ✅ (owner/premium/me/user)
    ├── user_badges.dart           // ✅
    ├── animated_entry.dart        // ✅
    ├── islamic_empty_state.dart   // ✅
    ├── rewarded_ad_card.dart      // ✅
    ├── premium_promo_dialog.dart  // ✅
    ├── glass_card.dart
    ├── star_badge.dart, ornament_medallion.dart
    ├── auth_widgets.dart          // ✅ (زر لغة موحّد)
    ├── glow_sparks.dart, islamic_pattern.dart
    ├── ai_teacher_card.dart
    ├── prayer_widgets.dart, daily_cards.dart
    ├── reciter_picker_sheet.dart
    └── language_picker_sheet.dart // ✅
```

---

## 🗄️ بنية Firestore الكاملة

```
users/{uid}/
├── email, createdAt, avatar ("man"|"woman")
├── location_label, location_lat, location_lng, location_address
├── profile: {
│     name, bio, isPublic, country,
│     gender: "man"|"woman",              // ثابت نهائياً
│     photoMode: "symbol"|"custom",
│     customPhotoBase64: string,
│     verified: bool,
│     verifiedType: "owner"|"me"|"user"|"none",
│     verifiedAt, verifiedBy,
│     photoBase64: string,
│     lastPhotoChangeAt: timestamp,
│     setupComplete: bool,                // true بعد شاشة الجنس
│     premium: {
│       active: bool,
│       plan: "monthly"|"quarterly"|"yearly"|"trial",
│       amount: number,
│       startedAt: timestamp,
│       expiresAt: timestamp,
│       approvedBy: string
│     }
│   }
├── stats: {
│     points, level, streak, lastActiveDate,
│     challengesCompleted, totalCorrectAnswers,
│     quranKhatmas, aiTeacherScore, redeemedCoupons,
│     adsWatchedToday: int,               // ✅ عداد الإعلانات
│     lastAdDate: string (YYYY-MM-DD),    // ✅
│     totalAdsWatched: int,               // ✅
│     premiumTrialUsed: bool              // ✅
│   }
├── inventory: { backgrounds, adhans, adhanBackgrounds, themes, active* }
├── settings: { language, theme, notifications{...} }
└── progress: { challenges, tasbeeh, quran, aiTeacher }

verification_requests/{uid}/
├── uid, email, name, gender
├── photoBase64
├── requestedAt: int (ms)
├── status: "pending"|"approved_user"|"approved_me"|"rejected"
└── reviewedAt, reviewedBy

photo_update_requests/{uid}/
├── uid, email, name
├── oldPhotoBase64, newPhotoBase64
├── requestedAt: int
└── status: "pending"|"approved"|"rejected"

premium_subscriptions/{uid}/
├── uid, name, email, paypalAccount
├── plan: "monthly"|"quarterly"|"yearly"
├── amount: double
├── status: "pending"|"approved"|"rejected"
├── requestedAt: timestamp
├── reviewedAt: timestamp?
└── reviewedBy: string?

follows/{followerUid}_{followingUid}/
├── followerUid, followingUid
└── createdAt

posts/{postId}/
├── uid, userName, userAvatar, userPhotoBase64
├── userVerified, userVerifiedType, userBadges: []
├── text (max 1000)
├── createdAt, editedAt
├── likes: [], likesCount, commentsCount, repostsCount
├── repostOf, originalAuthorUid/Name/Avatar
├── isPinned, isGlobalPin, isDeleted
├── mentions: [], hashtags: []
└── comments/{commentId}/
    ├── uid, userName, userAvatar, userPhotoBase64
    ├── userVerified, userVerifiedType, userBadges: []
    ├── text (max 300), createdAt, editedAt
    ├── likes: [], likesCount
    └── isDeleted

notifications/{uid}/items/{notifId}/
├── type: "follow"|"like"|"comment"|"repost"
│        |"photo_approved"|"photo_rejected"
│        |"verified_me"|"verified_user"|"verify_rejected"
│        |"new_video"|"new_reel"
│        |"premium_approved"|"premium_rejected"
├── fromUid, fromName, fromAvatar
├── fromVerified, fromVerifiedType
├── targetId, createdAt, isRead
└── customTitle?: string

chats/{chatId}/                        // chatId = sorted uids joined by _
├── participants: [uid1, uid2]
├── lastMessage, lastMessageAt, lastMessageSenderUid
├── unread: {uid1: int, uid2: int}
├── createdAt
└── messages/{msgId}/
    ├── senderUid, text (max 2000)
    ├── createdAt, readBy: [], isDeleted
    └── 

message_requests/{chatId}/
├── fromUid, toUid
├── status: "pending"|"accepted"|"rejected"
└── createdAt

channel_videos/{videoId}/
├── title, url, thumbnailUrl, videoId
├── isReel: bool (16:9 or 9:16)
├── createdAt: int (ms)
└── addedBy: string
```

---

## 🔒 Firestore Rules (الحالية)

**⚠️ منشورة على Firebase Console.** النسخة الكاملة:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isOwnerEmail() {
      return request.auth != null &&
             request.auth.token.email in [
               'abdelrahmenbenromdhan11@gmail.com',
               'vevocom888@gmail.com',
               'nooralimanechannel@gmail.com',
               'nooralhidayahbusiness@gmail.com'
             ];
    }
    
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read, update: if isOwnerEmail();
      allow read: if request.auth != null;
    }
    
    match /verification_requests/{userId} {
      allow read, create: if request.auth != null && request.auth.uid == userId;
      allow read, update, delete: if isOwnerEmail();
    }
    
    match /photo_update_requests/{userId} {
      allow read, create: if request.auth != null && request.auth.uid == userId;
      allow read, update, delete: if isOwnerEmail();
    }
    
    match /gender_change_requests/{userId} {
      allow read, create: if request.auth != null && request.auth.uid == userId;
      allow read, update, delete: if isOwnerEmail();
    }
    
    match /verification_revoke_requests/{userId} {
      allow read, create: if request.auth != null && request.auth.uid == userId;
      allow read, update, delete: if isOwnerEmail();
    }
    
    match /premium_subscriptions/{userId} {
      allow read: if request.auth != null
        && (request.auth.uid == userId || isOwnerEmail());
      allow create: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.uid == request.auth.uid
        && request.resource.data.status == 'pending';
      allow update, delete: if isOwnerEmail();
    }
    
    match /referrals/{newUserId} {
      allow read: if request.auth != null
        && (request.auth.uid == newUserId || isOwnerEmail());
      allow create: if request.auth != null
        && request.resource.data.newUserId == request.auth.uid;
      allow update, delete: if isOwnerEmail();
    }
    
    match /channel_videos/{videoId} {
      allow read: if request.auth != null;
      allow create: if isOwnerEmail()
        && request.resource.data.title is string
        && request.resource.data.title.size() > 0
        && request.resource.data.url is string
        && request.resource.data.url.size() > 0;
      allow update, delete: if isOwnerEmail();
    }
    
    match /follows/{followId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.followerUid == request.auth.uid
        && request.resource.data.followingUid != request.auth.uid
        && request.resource.data.followingUid is string
        && request.resource.data.followerUid is string;
      allow delete: if request.auth != null
        && resource.data.followerUid == request.auth.uid;
      allow update: if false;
    }
    
    match /chats/{chatId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.participants.size() == 2
        && request.auth.uid in request.resource.data.participants;
      allow update: if request.auth != null
        && request.auth.uid in resource.data.participants;
      allow delete: if false;
      
      match /messages/{msgId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null
          && request.resource.data.senderUid == request.auth.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() > 0
          && request.resource.data.text.size() <= 2000;
        allow update: if request.auth != null
          && request.resource.data.diff(resource.data).affectedKeys()
              .hasOnly(['readBy', 'isDeleted']);
        allow delete: if false;
      }
    }
    
    match /message_requests/{chatId} {
      allow read: if request.auth != null
        && (resource.data.fromUid == request.auth.uid
            || resource.data.toUid == request.auth.uid);
      allow create: if request.auth != null
        && request.resource.data.fromUid == request.auth.uid
        && request.resource.data.toUid != request.auth.uid
        && request.resource.data.status == 'pending';
      allow update, delete: if request.auth != null
        && resource.data.toUid == request.auth.uid;
    }
    
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid
        && request.resource.data.text is string
        && request.resource.data.text.size() > 0
        && request.resource.data.text.size() <= 1000;
      allow update: if request.auth != null && (
        (
          resource.data.uid == request.auth.uid
          && request.resource.data.uid == resource.data.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() <= 1000
        )
        ||
        (
          isOwnerEmail()
          && request.resource.data.diff(resource.data).affectedKeys()
              .hasOnly(['isGlobalPin'])
        )
        ||
        (
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['likes', 'likesCount', 'commentsCount', 'repostsCount'])
        )
      );
      allow delete: if request.auth != null
        && (resource.data.uid == request.auth.uid || isOwnerEmail());
      
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
    
    match /notifications/{uid}/items/{notifId} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow create: if request.auth != null
        && request.resource.data.fromUid == request.auth.uid
        && request.resource.data.type is string;
      allow update: if request.auth != null
        && request.auth.uid == uid
        && request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['isRead']);
      allow delete: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

---

## ✅ المراحل المكتملة (1-40)

### المراحل الأساسية (1-24)
1. ✅ الحسابات + Auto-login
2. ✅ الملف الشخصي
3. ✅ النقاط والمستويات
4. ✅ التحديات
5. ✅ المتجر (4 تبويبات)
6. ✅ الخلفيات والثيمات (9 ثيمات)
7. ✅ الأحجام المتجاوبة
8. ✅ الشريط السفلي (6 أيقونات)
9. ✅ الصفحة الرئيسية
10. ✅ الأذكار (7 أقسام، ~60 ذكر)
11. ✅ التسبيح
12. ✅ حساب الزكاة (5 أنواع، 160+ عملة)
13. ✅ الأدعية (7 أقسام، ~60 دعاء)
14. ✅ خطة ختم القرآن (30/60/90/180)
15. ✅ المحرمات + المكروهات (~50 بند)
16. ✅ القبلة
17. ✅ المساجد القريبة (OpenStreetMap + Overpass)
18. ✅ شاشة الإعدادات
19. ✅ الإشعارات المحلية (5 صلوات + 3 يومية)
20. ✅ شاشة الأذان
21. ✅ اللغات (7 لغات كاملة)
22. ✅ المعلم الذكي (Gemini + تعلّم التلاوة)
23. ✅ نظام التوثيق (owner/me/user)
24. ✅ الإسناد (Flaticon)

### المراحل المتقدمة (25-40)

**25) ✅ المجتمع (Community Feed)**
- Posts نصية (حتى 1000 حرف)
- Likes + Comments + Reposts
- Pin شخصي
- **منشور الترحيب العالمي** (isGlobalPin للمالك)
- Soft delete
- PostCard مع أنيميشن + نجوم زخرفية

**26) ✅ نظام المتابعة (Follow)**
- زر متابعة/متابَع
- قوائم المتابعين/المتابَعين
- User profile screen

**27) ✅ الإشعارات الاجتماعية + الإدارية**
- 4 أنواع اجتماعية: follow, like, comment, repost
- 7 أنواع إدارية: photo_approved, photo_rejected, verified_me, verified_user, verify_rejected, new_video, new_reel
- 2 Premium: premium_approved, premium_rejected
- درع "الإدارة" + شارات

**28) ✅ VerifiedBadge موحّد**
- owner.png + premium.png + true.me.png + true.users.png
- كلها ذهبية عبر ColorFiltered
- لمعان + نبض

**29) ✅ إصلاح تسرب البيانات بين الحسابات**
- reset عند signOut
- Auto-login

**30) ✅ نظام الصور المتقدم**
- 3 خيارات: symbol ذكر/انثى + صورة مخصصة
- الجنس ثابت (تحذير إجباري)
- Cooldown 24 ساعة (غير موثق)
- طلب إعادة توثيق (موثق)
- Owner بلا قيود
- الصورة في كل مكان

**31) ✅ تحذير الجنس + إشعارات الموافقة/الرفض**

**32) ✅ قناة YouTube**
- تابين: الفيديوهات (16:9) + الريلز (9:16)
- Firestore-driven
- NestedScrollView + Tabs تستقر عند السكرول
- إشعار "فيديو جديد" لكل متابع

**33) ✅ الشات (Chat)**
- زر 💬 في HomeShell (chat.png + badge)
- زر 💬 في UserProfile (ذهبي/رمادي)
- Private: طلب رسالة، Public: مباشر
- chatId = sorted uids joined by _
- قائمة محادثات + شاشة شات + date labels

**34) ✅ الترجمات الشاملة**
- كل الشاشات بالـ7 لغات

**35) ✅ التزيينات النهائية**
- `AnimatedEntry` (fade+slide مع delay)
- `IslamicEmptyState` (نجمة ثمانية دوّارة)
- PostCard: نجمتان + معين متوهج + نبض قلب
- VerifiedBadge: لمعان + نبض
- Chat: فقاعات مع glow + tail
- ChatsList: Avatar rings + Badge نابض

**36) ✅ `tool/preview.sh` (Release + Static)**
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

**37) ✅ AdMob Rewarded Ads**
- 20 إعلان/يوم
- 50 نقطة لكل إعلان
- 10 إعلانات → 3 أيام Premium Trial (مرة واحدة)
- Firestore counters: adsWatchedToday, lastAdDate, totalAdsWatched, premiumTrialUsed
- `AdsService` + `RewardedAdCard`
- رسالة دعم أسفل البطاقة

**38) ✅ نظام Premium Backend**
- `PremiumRequest` model + `PremiumService`
- Firestore rules لـ `premium_subscriptions`
- PayPal.me: paypal.me/AbdelRahmen2003/5, /13, /45

**39) ✅ شاشات Premium**
- `PremiumScreen` (4 حالات: main, pending, approved, rejected)
- `PremiumCheckoutScreen` (PayPal + Checkbox يدوي للتأكيد)
- 15 ميزة مع عرض صور فعلية لـ premium.png + true.me.png

**40) ✅ التكامل + Promo**
- `PremiumRequestsScreen` في admin
- بطاقة "طلبات Premium" في `AdminPanelScreen`
- `StoreScreen`: Premium banner نابض في الأعلى
- `HomeShell`: زر Promo (يظهر في المرة 2 و 5)
- `AccountScreen`: عرض Premium badge
- `notifications_screen`: عرض premium_approved/rejected

---

## 🚧 ما ينتظرنا — المراحل التالية (بالترتيب المقترح)

### 🌱 المرحلة 41: إكمال ميزات Premium الفعلية

**الوضع الحالي:** بعد موافقة المالك، `profile.premium.active = true`، لكن **الميزات لم تُفعّل تلقائياً**.

**الميزات التي يجب تفعيلها:**

| # | الميزة | الطريقة |
|---|--------|---------|
| 1 | 🚫 إخفاء الإعلانات | `RewardedAdCard` يفحص `isPremium` |
| 2 | 🎨 VIP مجاني في المتجر | `StoreScreen` يفحص `isPremium` → كل شي مجاني |
| 3 | 📌 تثبيت 3 منشورات | `togglePin` يفحص `isPremium` |
| 4 | 🎯 ضعف نقاط التحديات | `challenge_screen` → 40 بدل 20 |
| 5 | 📝 منشور أطول | `create_post_screen` → 1000 بدل 500 (متوفر أصلاً) |
| 6 | 👁️ رؤية Private | `UserProfileScreen` → فحص `isPremium` |
| 7 | 💰 10,000 نقطة شهرياً | عند approve → add points فوراً + تتبع شهري |
| 8 | 👑 تاج متحرك | `ProfileAvatar` يدعمه لكن يحتاج تفعيل |
| 9 | ✍️ اسم ذهبي | في `PostCard` + `UserProfileScreen` |
| 10 | 🚀 أولوية في Feed | `postsStream` ترتيب حسب `isPremium` |
| 11 | 📊 إحصاءات | شاشة إحصائيات جديدة |
| 12 | 🎁 هدية شهرية | يدوي |

**الملفات المطلوبة:**
- `lib/services/premium_service.dart` → دالة `isUserPremium(uid)` static
- `lib/services/community_service.dart` → ترتيب Feed
- `lib/screens/challenge_screen.dart` → ضعف النقاط
- `lib/screens/store_screen.dart` → VIP مجاني
- `lib/widgets/rewarded_ad_card.dart` → إخفاء لـ Premium
- `lib/widgets/post_card.dart` → اسم ذهبي + ترتيب
- `lib/screens/user_profile_screen.dart` → رؤية Private

---

### 🌱 المرحلة 42: FCM + Push Notifications

**⚠️ يتطلب:**
- ترقية Firebase إلى **Blaze** (يتطلب بطاقة بنكية)
- تفعيل `firebase_messaging`
- Cloud Functions (Node.js)
- SHA-1 في Firebase Console

**الفائدة:** إشعارات تصل حتى لو التطبيق مغلق.

**الملفات المطلوبة:**
- `functions/index.js` (Cloud Function)
- `lib/services/push_service.dart` (Flutter)
- تعديل `main.dart` أو `HomeShell` لتهيئة FCM
- `android/app/build.gradle` → google-services.json
- `ios/Runner/Info.plist` → Capabilities

**⚠️ ملاحظة:** يحتاج إعادة توليد مجلد `ios/` (غير موجود حالياً).

---

### 🌱 المرحلة 43: إصلاح Google Sign-In

**⚠️ مشكلة معروفة:** Google Sign-In جُرّب وفشل سابقاً (People API + origin_mismatch + minified errors). تم تأجيله.

**المطلوب لتفعيله:**
1. تفعيل People API في Google Cloud Console
2. إضافة `github.dev` في Authorized Domains
3. إضافة `humble-yodel-w5vqw65rrqhqp-8095.app.github.dev` في OAuth Origins
4. إعادة تفعيل زر Google في `register_screen.dart`
5. إضافة `google_sign_in: ^6.2.1` في pubspec

**الملفات:**
- `lib/services/auth_service.dart` → إضافة `signInWithGoogle()`
- `lib/screens/register_screen.dart` → زر Google
- `lib/screens/login_screen.dart` → زر Google
- `pubspec.yaml` → google_sign_in

**⚠️ ملاحظة:** على APK حقيقي، Google Sign-In أسهل بكثير (SHA-1 فقط، بدون origin mismatch).

---

### 🌱 المرحلة 44: الفحص النهائي والتنظيف

- مراجعة كل التحذيرات (`flutter analyze`)
- توحيد الكود
- إزالة الاستيرادات غير المستخدمة
- توحيد الترجمات
- حذف الملفات غير المستخدمة (`avatar_picker` مثلاً)

---

### 🌱 المرحلة 45: بناء APK

```bash
# 1. توليد keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. إنشاء android/key.properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=...

# 3. تحديث android/app/build.gradle

# 4. البناء
flutter build apk --release
flutter build appbundle --release
```

**الملفات المطلوبة:**
- `android/app/build.gradle` (تعديل signing)
- `android/key.properties` (جديد، محمي)
- `~/upload-keystore.jks` (خارج المشروع)

**⚠️ SHA-1:** يُضاف في Firebase Console → Project Settings → SHA certificate fingerprints.

---

### 🌱 المرحلة 46: النشر على المنصات

**المنصات المجانية:**

| المنصة | الرابط | ملاحظات |
|--------|--------|---------|
| موقعك الشخصي | — | APK مباشر |
| Samsung Galaxy Store | seller.samsungapps.com | مجاني، يحتاج توقيع |
| Huawei AppGallery | developer.huawei.com | مجاني، HMS Core |
| APKPure | apkpure.com | مجاني |
| Aptoide | aptoide.com | ⚠️ خطر نسخ معدّلة |

**مؤجل (يحتاج رسوم):**
- Google Play ($25 مرة واحدة)
- Apple App Store ($99/سنة)

---

### 🌱 المرحلة 47: ميزات إضافية

- صور في المنشورات (Firebase Storage)
- طلب تغيير الجنس (بطاقة في admin)
- طلب إلغاء التوثيق
- إحصائيات المعلم (نقاط لكل جلسة تلاوة)
- تطبيق إدارة منفصل للمالك
- Cloud Functions للتنبيهات
- CORS proxy للمساجد على الويب

---

## 🛠️ طريقة العمل مع AI (Workflow إجباري)

> ⚠️ **قسم دائم** — لا يُحذف أبداً. يقرأه كل AI جديد.

### ⚠️ المالك يستخدم **الهاتف فقط**
- ❌ **لا اختصارات كيبورد**: `Ctrl+C`, `Ctrl+V`, `Ctrl+X`, `Ctrl+O`, `Ctrl+A`
- ✅ تعديل الملفات: على **GitHub.com مباشرة** (Add file أو قلم ✏️ → Select All → Delete → Paste → Commit)
- ✅ تشغيل الأوامر: **Codespaces Terminal** على المتصفح
- ✅ حفظ ملفات من Terminal: أمر واحد بـ heredoc:
  ```bash
  cat > path/to/file.dart << 'EOF'
  // محتوى
  EOF
  ```
- ✅ إيقاف التطبيق: `pkill -f flutter` (لا `Ctrl+C`)

### 🚨 القواعد الإجبارية للـ AI

1. **ملف كامل دائماً** — لا تعديلات جزئية
   - عند تعديل أي ملف → **أرسل الملف كامل من جديد**
   - المستخدم يحذف القديم ويلصق الجديد
   - **لا تقل "ابحث عن السطر..."** أبداً

2. **أوامر Terminal بكتلة واحدة**
   - أي أوامر متسلسلة → اكتبها في **كتلة واحدة** بدون شرح بينها
   - مثال:
     ```
     git pull
     flutter analyze
     ```
   - لا تكتب "ثم اكتب..." — فقط الكود

3. **لا خطوات وسيطة** — لا تقل "بعدين نضيف"

4. **بعد كل ملف:**
   - ✅ اذكر اسم الملف بوضوح: `lib/path/file.dart`
   - ✅ حدد: **(ملف جديد)** أو **(تعديل/تغيير)**
   - ✅ اكتب الملف كامل

5. **قبل أي تعديل جديد:**
   - `git pull` أولاً
   - `flutter analyze` بعده
   - لا حفظ قبل `No issues found`

6. **بعد ما ينجح:** احفظ بالأوامر:
   ```
   git add .
   git commit -m "..."
   git push
   ```

7. **اختبار (بعد التحليل النظيف):**
   ```
   bash tool/preview.sh
   ```
   ⚠️ **ملاحظة:** Flutter Web **لا يشغل إعلانات AdMob** — تحتاج APK حقيقي.

8. **تحديث `PROJECT.md`** — بعد كل مرحلة رئيسية.

### 📋 خطوات دورة العمل (لا تتغير)

```
1. AI يشرح + يعطي الملفات كاملة.
2. المالك ينسخها في GitHub → Commit لكل ملف.
3. Terminal:
   git pull
   flutter analyze
4. لو "No issues found" → اختبار:
   bash tool/preview.sh
5. لو التطبيق شغال → حفظ:
   git add .
   git commit -m "..."
   git push
6. تحديث PROJECT.md → Commit → git pull
7. المرحلة التالية.
```

### 🎨 قواعد الكود

1. **الألوان:** `AppColors` أو `ThemedColors` (theme-aware)
2. **الأحجام:** `R.s()` و `R.f()`
3. **الترجمات:** `appState.tr('key')` و `appState.trn('key{n}', n)`
4. **Firestore:** تحت `users/{uid}`
5. **الصور:** `assets/` (icons, images, backgrounds, adhan_backgrounds)
6. **الأنيميشن:** `AnimatedEntry` للظهور، نبض للقلب، shimmer للشارات
7. **الأيقونات الجديدة:** تُلوَّن ذهبي عبر `ColorFiltered`
8. **لا تحذف imports بدون فحص** — تأكد إنها غير مستخدمة
9. **الملفات الكبيرة:** `>500` سطر، استبدال كامل إجباري

### ⚠️ قواعد التحذير

1. **`lib/core/secrets.dart` محمي** — لا يُرفع على GitHub (.gitignore)
2. **لا تعديل على Firestore Rules من Terminal** — فقط من Firebase Console
3. **AdMob App ID في `AndroidManifest.xml`** — حساس، لا تغييره
4. **PayPal.me ID في `premium_service.dart`** — `AbdelRahmen2003`

---

## 🔧 معلومات تقنية إضافية

### APIs الخارجية (مجانية)
- **الذهب/الفضة:** `https://data-asg.goldprice.org/dbXRates/USD`
- **الصرف:** `https://open.er-api.com/v6/USD`
- **المساجد:** Overpass API
- **الأذان:** `islamcan.com/audio/adhan/azanN.mp3`
- **Gemini AI:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent`
- **YouTube Thumbnails:** `https://img.youtube.com/vi/{videoId}/maxresdefault.jpg`

### Dependencies (pubspec.yaml)
```
firebase_core: ^4.15.0
firebase_auth: ^6.7.0
cloud_firestore: ^6.10.0
google_fonts: ^8.2.1
shared_preferences: ^2.5.5
geolocator: ^14.0.3
http: ^1.6.0
wakelock_plus: ^1.2.8
flutter_compass: ^0.8.1
flutter_map: ^7.0.2
latlong2: ^0.9.1
url_launcher: ^6.3.2
flutter_local_notifications: ^17.2.4
timezone: ^0.9.4
flutter_timezone: ^3.0.1
audioplayers: ^6.1.0
record: ^5.1.2
path_provider: ^2.1.6
permission_handler: ^11.3.1
image_picker: ^1.1.2
image: ^4.2.0
google_mobile_ads: ^5.2.0
```

**قادم:**
- `firebase_messaging` (FCM)
- `google_sign_in` (لما نصلحه)

### Assets
```
assets/icons/: Setting, challenge, coupon, more, store, community, 
              true.me, true.users, adhan, owner, premium, chat
assets/images/: Me, logo, arabian, hijab
assets/images/backgrounds/: backgroundv2, _blue, _orange, _brown, 
                             _dark, _purple, _olive, vip1, vip2, vip3
assets/images/adhan_backgrounds/: adhan_bg_1..5, adhan_bg_vip_1..3
```

### كودات خاصة
- **NAH2026** → 1000 نقطة (غير محدود للمالك فقط)

---

## 🚀 كيف يستخدم AI الجديد هذا الملف

**الرسالة الأولى للمالك إلى AI الجديد:**

> اقرأ ملف PROJECT.md كامل من:
> `https://raw.githubusercontent.com/nooralhidayahbusiness-App/noor-al-hidayah_claud.APP/main/PROJECT.md`
>
> هذا التوثيق الكامل لتطبيقي. آخر ما أنجزناه: **[اذكر آخر شي]**.
> التالي: **[اذكر المهمة الجاية من قسم "ما ينتظرنا"]**.
> اتبع نفس الأسلوب الموثق في قسم "طريقة العمل" بالحرف.

**AI الجديد يجب أن:**
1. يقرأ الملف كامل
2. يفهم بنية Firestore + Rules
3. يفهم الملفات المكتملة
4. يبدأ من المرحلة الحالية
5. يتبع نفس الـ Workflow

---

## 📋 قائمة الحسابات والمعرفات (نسخ سريع للـ AI)

```
Firebase Project ID: noor-al-hidayah
Firebase Number: 762471094332
Firebase Web App ID: 1:762471094332:web:68fe063e9282d7441d8b39

Google Web Client ID: 762471094332-l8vkd8up5i13ivjt1btr0urllgvtoupm.apps.googleusercontent.com

AdMob Android App ID: ca-app-pub-7354273374998913~5567231375
AdMob Android Rewarded: ca-app-pub-7354273374998913/5755827856
AdMob iOS App ID: ca-app-pub-7354273374998913~4615890593
AdMob iOS Rewarded: ca-app-pub-7354273374998913/8080492888

PayPal: paypal.me/AbdelRahmen2003

Owner Emails (4):
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com
- nooralimanechannel@gmail.com
- nooralhidayahbusiness@gmail.com

Codespace URL (مثال):
https://humble-yodel-w5vqw65rrqhqp-8095.app.github.dev

GitHub Repo:
github.com/nooralhidayahbusiness-App/noor-al-hidayah_claud.APP
```

---

## 🎯 الخلاصة التنفيذية (للـ AI الجديد)

**التطبيق:** إسلامي شامل، Flutter + Firebase، 7 لغات، Web+Android+iOS (لاحقاً).

**حالياً:**
- ✅ Community + Chat + Channel مكتملة
- ✅ Notifications (10 أنواع) مكتملة
- ✅ Premium Backend + UI + Payment مكتملة
- ✅ AdMob Rewarded مكتمل
- ⏳ Premium Features الفعلية (إخفاء إعلانات، VIP مجاني، إلخ)
- ⏳ FCM (يحتاج Blaze)
- ⏳ Google Sign-In Fix
- ⏳ APK + النشر

**الخطوة الفورية المقترحة:**
**المرحلة 41** — إكمال ميزات Premium الفعلية.

**الملف الأول:**
`lib/services/premium_service.dart` — إضافة دالة `static bool isUserPremium(Map profile)` لاستخدامها في كل الشاشات.

---

**© 2026 Noor Al-Hidayah — Abdel Rahmen Ben Romdhan**
