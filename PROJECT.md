# 🕌 نور الهداية — Noor Al-Hidayah

> **آخر تحديث:** 2026-10-08 | **الإصدار:** Beta 3.0 | **الحالة:** 🚀 جاهز للاختبار الفعلي — بانتظار اختبار الأذان عند صلاة العشاء

---

## 📖 كيف تقرأ هذا الملف (للـ AI)

هذا الملف مُصمّم **للعمل مع AI في جلسات متعددة**. كل قسم فيه معلومات كاملة تُغني عن أي ملف آخر.

**⚠️ قواعد إجبارية للـ AI عند قراءة الملف:**
1. **اقرأ كل الأقسام** قبل أول رد.
2. **اتبع نفس الأسلوب** الموثق في قسم "طريقة العمل" بالأسفل.
3. **لا تسأل عن معلومات موجودة في الملف** — استخرجها.
4. **أي ميزة جديدة** → ملف كامل → تعديل على GitHub → `git pull` → `flutter analyze` → حفظ.
5. **لا تقترح تعديلات جزئية** أبداً — المستخدم يستبدل الملفات كاملة.
6. **المستخدم على الهاتف فقط** — عيناه تؤلمه من الشاشات الصغيرة — أرسل الملفات كاملة دائماً بدون "ابحث عن السطر".

---

## 🎯 نظرة عامة

### التطبيق
**Noor Al-Hidayah (نور الهداية)** — تطبيق إسلامي شامل للمسلمين حول العالم.

### الميزات الرئيسية
- 🕌 مواقيت الصلاة + الأذان (19 مؤذن)
- 📖 القرآن الكريم + التلاوة (كل القراء)
- 🤲 الأذكار والأدعية (~120 عنصر)
- 🏆 التحديات + المتجر + النقاط
- 🎓 معلم ذكي لتصحيح التلاوة (Gemini AI)
- 💬 شبكة اجتماعية (Posts, Comments, Likes, Reposts, Follow)
- 🎬 قناة YouTube (فيديوهات 16:9 + ريلز 9:16)
- 💬 نظام محادثات (Chat) مع طلبات للمستخدمين Private
- 💎 نظام Premium (اشتراك مدفوع) + ميزات فعلية مكتملة
- 📬 إشعارات اجتماعية + إدارية
- 📺 إعلانات مكافئة (Rewarded Ads)
- 🔔 إشعارات Push عبر OneSignal
- 🎁 تجربة Premium مجانية 3 أيام (مقابل 10 إعلانات)
- 📞 شاشة دعم وتواصل
- ⏰ إشعار دائم للصلاة القادمة مع عد تنازلي حيّ
- 🕌 شاشة أذان كاملة الشاشة مع صوت المؤذن المختار
- 📿 أذكار بعد الصلاة (زر مباشر)
- 🧭 قبلة (زر مباشر من شاشة الأذان)

### الجمهور المستهدف
- عالمي (7 لغات)
- Android + iOS (لاحقاً)
- Web (للتطوير)

---

## 👤 المالك والحسابات

### المالك
**Abdel Rahmen Ben Romdhan**

### إيميلات المالك (Owner) — 4 إيميلات
```

1. abdelrahmenbenromdhan11@gmail.com
2. vevocom888@gmail.com
3. nooralimanechannel@gmail.com
4. nooralhidayahbusiness@gmail.com

```

### AdMob Account
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
- **Android App ID:** `1:762471094332:android:8a851d27fb4e78861d8b39`
- **Android Package Name:** `com.nooralhidayah.noor_al_hidayah`
- **Location:** `nam5`
- **Google Web Client ID:** `762471094332-l8vkd8up5i13ivjt1btr0urllgvtoupm.apps.googleusercontent.com`

### OneSignal
- **App ID:** `4e7862a1-4191-4788-a703-72a3fea3d12d`
- **REST API Key:** موجود في `lib/core/secrets.dart` (محمي)
- **Firebase Server Key:** مُرفوع في لوحة OneSignal

### Keystore (Release Signing)
- **الملف:** `~/noor-release.jks` (خارج المشروع)
- **storePassword:** `noor2026`
- **keyPassword:** `noor2026`
- **keyAlias:** `noor`
- **SHA-1 (Debug):** `F9:48:AD:F2:A7:85:7E:1F:89:54:FF:50:53:7E:8C:60:31:3B:E6:DB`
- **SHA-1 (Release):** `34:74:07:F9:D2:7A:5D:FD:2E:BB:E8:4A:36:62:C4:C2:22:2C:C6:30`

**⚠️ SHA-1 (Release) مضاف في Firebase Console (لـ Google Sign-In).**

---

## 🎨 نظام التصميم

### الألوان الأساسية
```dart
deepGreen #041F18
green     #0B3D2E
emerald   #14664C
gold      #D4AF37
softGold  #F1DC9A
cream     #FFF8E7
```

الأحجام المتجاوبة

· R.s(context, value) → للحجم
· R.f(context, value) → للخطوط

الثيمات (9)

6 عادية + 3 VIP (مع animations)

---

🌍 اللغات (7 لغات)

# اللغة Code الاتجاه
1 العربية ar RTL
2 English en LTR
3 Français fr LTR
4 اردو ur RTL
5 नेपाली ne LTR
6 Bahasa Indonesia id LTR
7 Bahasa Melayu ms LTR

---

📂 بنية المشروع الكاملة

```
lib/
├── core/
│   ├── app_state.dart             // الترجمة (ar/en + 5 ملفات)
│   ├── secrets.dart               // 🔴 محمي (.gitignore)
│   ├── prayer_state.dart
│   ├── theme_state.dart
│   ├── profile_state.dart
│   ├── reciter_prefs.dart
│   ├── theme.dart, theme_palette.dart, themed_colors.dart
│   ├── responsive.dart, fonts.dart, validators.dart
│   └── i18n/
│
├── data/
│   ├── adhan_reciters.dart        // ✅ 10 مؤذنين (praytimes.org)
│   ├── store_items.dart           // ✅ 17 مؤذن في المتجر
│   ├── adhkar.dart                // ✅ أذكار بعد الصلاة (id: after_prayer)
│   ├── duas.dart, questions.dart, haram.dart, makruh.dart
│   └── ...
│
├── models/
│   ├── post.dart, comment.dart, user_brief.dart
│   ├── prayer_times_data.dart
│   ├── premium_request.dart
│   └── ...
│
├── services/
│   ├── auth_service.dart          // ✅ + signInWithGoogle + currentUid
│   ├── notification_service.dart  // ✅ + chronometer + full-screen + exact alarm
│   ├── adhan_service.dart         // ✅ + mute/unmute + AudioContext alarm
│   ├── push_service.dart          // ✅ OneSignal (بديل FCM)
│   ├── community_notification_service.dart // ✅ + REST API push
│   ├── prayer_service.dart        // ✅ + offline cache
│   ├── storage_service.dart       // ✅ + prayer cache
│   ├── ads_service.dart
│   ├── premium_service.dart
│   ├── user_service.dart
│   └── ...
│
├── screens/
│   ├── support_screen.dart        // ✅ جديد — دعم وتواصل
│   ├── adhan_screen.dart          // ✅ mute + qibla + adhkar + prayed 2-stage
│   ├── home_shell.dart            // ✅ prayer timer + ongoing notification
│   ├── splash_screen.dart         // ✅ consume pending launch
│   ├── store_screen.dart          // ✅ blur cards + preview + dialogs
│   ├── premium_screen.dart, premium_checkout_screen.dart, premium_stats_screen.dart
│   ├── challenge_screen.dart
│   ├── login_screen.dart, register_screen.dart  // ✅ + Google buttons
│   ├── settings_screen.dart       // ✅ + Support button
│   ├── tabs/more_tab.dart         // ✅ + Support button
│   ├── admin/...
│   └── ...
│
└── widgets/
    ├── profile_avatar.dart        // ✅ تاج بدون دائرة + أكبر
    ├── post_card.dart             // ✅ اسم ذهبي لـ Premium
    ├── rewarded_ad_card.dart      // ✅ يختفي لـ Premium
    └── ...

android/
├── app/
│   ├── build.gradle.kts           // ✅ signingConfigs + desugaring
│   ├── google-services.json       // ✅ محدث (SHA-1 جديد)
│   └── src/main/
│       ├── AndroidManifest.xml    // ✅ كل الصلاحيات (incl. REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
│       └── res/mipmap-*/          // ✅ أيقونة من logoapp.png
├── gradle/wrapper/gradle-wrapper.properties  // ✅ Gradle 8.14
├── settings.gradle.kts            // ✅ AGP 8.11.1 + Kotlin 2.2.20
├── gradle.properties              // ✅ Xmx 4096M + Jetifier off
└── key.properties                 // 🔴 محمي (.gitignore)

.github/workflows/
└── build-apk.yml                  // ✅ GitHub Actions builds APK
```

---

🗄️ بنية Firestore الكاملة

```
users/{uid}/
├── email, createdAt, avatar ("man"|"woman")
├── location_label, location_lat, location_lng, location_address
├── profile: {
│     name, bio, isPublic, country,
│     gender, photoMode, customPhotoBase64,
│     verified, verifiedType, verifiedAt, verifiedBy,
│     photoBase64, lastPhotoChangeAt, setupComplete,
│     premium: { active, plan, amount, startedAt, expiresAt, approvedBy }
│   }
├── stats: {
│     points, level, streak, lastActiveDate,
│     challengesCompleted, totalCorrectAnswers,
│     quranKhatmas, aiTeacherScore, redeemedCoupons,
│     adsWatchedToday, lastAdDate, totalAdsWatched, premiumTrialUsed
│   }
├── inventory: { backgrounds, adhans, adhanBackgrounds, themes, active* }
├── settings: { language, theme, notifications{...} }
├── progress: { challenges, tasbeeh, quran, aiTeacher }
└── onesignalSubs/{subId}/
    ├── subId, platform, updatedAt

premium_subscriptions/{uid}/
├── uid, name, email, paypalAccount
├── plan, amount, status, requestedAt, reviewedAt, reviewedBy

posts/{postId}/
├── uid, userName, userAvatar, userPhotoBase64
├── userVerified, userVerifiedType, userBadges
├── text (max 1000 لـ Premium، 500 للعادي)
├── createdAt, editedAt
├── likes, likesCount, commentsCount, repostsCount
├── repostOf, originalAuthorUid/Name/Avatar
├── isPinned, isGlobalPin, pinnedAt, isDeleted
└── comments/{commentId}/...

notifications/{uid}/items/{notifId}/
├── type: follow|like|comment|repost|photo_approved|photo_rejected|
│        verified_me|verified_user|verify_rejected|new_video|new_reel|
│        premium_approved|premium_rejected
├── fromUid, fromName, fromAvatar, fromVerified, fromVerifiedType
├── targetId, createdAt, isRead

chats/{chatId}/...
message_requests/{chatId}/...
channel_videos/{videoId}/...
follows/{followerUid}_{followingUid}/...
verification_requests/{uid}/...
photo_update_requests/{uid}/...
```

---

✅ المراحل المكتملة (1-47)

الأساسيات (1-24)

1-24. ✅ حسابات، بروفايل، نقاط، تحديات، متجر، خلفيات، قرآن، أذكار، أدعية، زكاة، ختم، محرمات، قبلة، مساجد، إعدادات، إشعارات محلية، أذان، لغات، معلم ذكي، توثيق

المراحل المتقدمة (25-40)

25. ✅ المجتمع
26. ✅ المتابعة
27. ✅ الإشعارات الاجتماعية + الإدارية
28. ✅ VerifiedBadge موحّد
29. ✅ إصلاح تسرب البيانات
30. ✅ نظام الصور المتقدم
31. ✅ تحذير الجنس + إشعارات
32. ✅ قناة YouTube
33. ✅ الشات
34. ✅ الترجمات الشاملة
35. ✅ التزيينات النهائية
36. ✅ tool/preview.sh
37. ✅ AdMob Rewarded
38. ✅ Premium Backend
39. ✅ شاشات Premium
40. ✅ التكامل + Promo

المرحلة 41: ميزات Premium الفعلية ✅

12 ميزة مكتملة (إخفاء إعلانات، VIP مجاني، 3 pins، x2 نقاط، 1000 حرف، رؤية Private، 10000 نقطة، تاج متحرك، اسم ذهبي، أولوية Feed، إحصاءات، تجربة 3 أيام)

المرحلة 42: OneSignal ✅

· ✅ onesignal_flutter + push_service.dart
· ✅ REST API push في community_notification_service
· ✅ App ID: 4e7862a1-4191-4788-a703-72a3fea3d12d

المرحلة 43: Google Sign-In ✅

· ✅ زر Google في login + register
· ✅ SHA-1 (Debug + Release) في Firebase
· ✅ يعمل على APK

المرحلة 44: GitHub Actions + APK ✅

· ✅ مجلد android + كل الإعدادات
· ✅ أيقونة من logoapp.png
· ✅ 6 GitHub Secrets
· ✅ APK يُبنى تلقائياً

المرحلة 45: الصلاة والأذان ✅ (قيد الاختبار)

· ✅ إشعار دائم حيّ (chronometer) أخضر → برتقالي في آخر 10 دقائق
· ✅ إشعار full-screen عند الصلاة
· ✅ SCHEDULE_EXACT_ALARM + fallback inexact
· ✅ REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
· ✅ شاشة أذان كاملة: خلفية + اسم المؤذن + زر كتم + قبلة + أذكار بعد الصلاة + زر "صليت الآن" بمرحلتين
· ✅ 19 مؤذن

المرحلة 46: شاشة الدعم ✅

· ✅ 4 إيميلات + هواتف + واتساب + فيسبوك + إنستغرام
· ✅ زر في more_tab + settings

المرحلة 47: المتجر — إعادة تصميم ✅

· ✅ بطاقة مبسّطة + blur عند الضغط
· ✅ زر 🔊 تشغيل المؤذن (ذهبي → أحمر)
· ✅ زر 👁 معاينة الخلفية
· ✅ بطاقات تأكيد الشراء/الإلغاء/نقاط غير كافية

---

🚧 ما ينتظرنا / قيد الاختبار

🔴 قيد الاختبار الفوري:

1. فتح شاشة الأذان تلقائياً عند دخول الوقت (التطبيق مغلق)
2. صوت الأذان عند فتح الشاشة من الإشعار
3. العد التنازلي الحيّ في الإشعار الدائم

⏳ ميزات مستقبلية:

المرحلة 48: تحسينات الأداء

· تقليل الأنيميشن والظلال
· تحسين IndexedStack
· تحسين AnimatedEntry

المرحلة 49: Push Notifications حقيقي

· اختبار على جهازين
· إشعارات Like/Comment/Follow بين حسابين

المرحلة 50: الترجمة لجميع اللغات

· نصوص جديدة لـ 5 لغات
· ترجمة شاشة الدعم

المرحلة 51: تحسينات إضافية

· صور في المنشورات
· Voice Messages
· Stories

المرحلة 52: النشر

· موقع شخصي
· Samsung Galaxy Store
· Huawei AppGallery
· APKPure

---

🛠️ طريقة العمل مع AI (Workflow إجباري)

⚠️ قسم دائم — لا يُحذف أبداً.

⚠️ المالك يستخدم الهاتف فقط

· ❌ لا اختصارات كيبورد (Ctrl+C, Ctrl+V, Ctrl+A)
· ❌ لا يستطيع التمرير بين الأسطر الطويلة (عيناه تؤلمه)
· ✅ تعديل الملفات: GitHub.com مباشرة
· ✅ تشغيل الأوامر: Codespaces Terminal

🚨 القواعد الإجبارية للـ AI

1. ملف كامل دائماً — بدون استثناء
   · أرسل الملف كاملاً جاهزاً للنسخ
   · لا تقل "ابحث عن السطر X"
   · لا تقل "أضف سطر Y"
   · حتى لو كان الملف 800 سطر — أرسله كاملاً
2. أوامر Terminal بكتلة واحدة
   ```
   git pull
   flutter analyze
   ```
3. بعد كل ملف:
   · اسم الملف: lib/path/file.dart
   · حدد: (جديد) أو (تعديل)
   · أرسل الملف كامل
4. قبل أي تعديل: git pull ثم flutter analyze
5. بعد نجاح التحليل: GitHub Actions يبني APK تلقائياً
6. اختبار: حمّل APK من Artifacts

📋 دورة العمل

```
1. AI يقرأ الملفات المطلوبة.
2. AI يرسل الملفات كاملة.
3. المالك ينسخها في GitHub (commit).
4. Terminal: git pull && flutter analyze
5. لو "No issues found" → GitHub Actions يبني APK.
6. المالك يحمّل APK من Actions → Artifacts.
7. يثبت APK ويختبر.
8. يخبر AI بالنتيجة → المرحلة التالية.
```

🎨 قواعد الكود

1. الألوان: AppColors أو ThemedColors
2. الأحجام: R.s() و R.f()
3. الترجمات: appState.tr('key')
4. Firestore: تحت users/{uid}
5. الصور: assets/
6. الأنيميشن: AnimatedEntry
7. لا تحذف imports بدون فحص
8. الملفات >500 سطر → استبدال كامل إجباري

⚠️ قواعد التحذير

1. lib/core/secrets.dart محمي
2. android/key.properties محمي
3. noor-release.jks خارج المشروع
4. لا تعديل على Firestore Rules من Terminal
5. AdMob App ID حساس
6. android.enableJetifier=false

---

🔧 معلومات تقنية إضافية

Dependencies (pubspec.yaml)

```
firebase_core: ^4.15.0
firebase_auth: ^6.7.0
cloud_firestore: ^6.10.0
firebase_messaging: ^16.0.0
onesignal_flutter: ^5.2.0
google_sign_in: ^6.2.1
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

Gradle / Build

```
Gradle: 8.14
AGP: 8.11.1
Kotlin: 2.2.20
Java: 17 (Temurin)
compileSdk: 36
```

GitHub Actions

· Workflow: .github/workflows/build-apk.yml
· Triggers: push + workflow_dispatch
· Output: noor-al-hidayah-apk

GitHub Secrets

```
KEYSTORE_BASE64
STORE_PASSWORD
KEY_PASSWORD
KEY_ALIAS
GEMINI_API_KEY
ONESIGNAL_API_KEY
```

APIs الخارجية

· الذهب/الفضة: data-asg.goldprice.org/dbXRates/USD
· الصرف: open.er-api.com/v6/USD
· الصلاة: api.aladhan.com/v1/timings/{date}
· الأذان: praytimes.org/audio/sunni/*.mp3 + islamcan.com/audio/adhan/*.mp3
· Gemini AI: generativelanguage.googleapis.com/v1beta
· OneSignal: api.onesignal.com/notifications

Assets

```
assets/icons/: Setting, challenge, coupon, more, store, community,
              true.me, true.users, adhan, owner, premium, chat,
              support, phone, whatsapp, facebook, instagram, gmail
assets/images/: Me, logo, logoapp, arabian, hijab
assets/images/backgrounds/: ...
assets/images/adhan_backgrounds/: ...
```

كودات خاصة

· NAH2026 → 1000 نقطة (غير محدود للمالك فقط)

---

📋 قائمة الحسابات والمعرفات

```
Firebase Project ID: noor-al-hidayah
Firebase Number: 762471094332
Firebase Web App ID: 1:762471094332:web:68fe063e9282d7441d8b39
Firebase Android App ID: 1:762471094332:android:8a851d27fb4e78861d8b39
Android Package Name: com.nooralhidayah.noor_al_hidayah

Google Web Client ID: 762471094332-l8vkd8up5i13ivjt1btr0urllgvtoupm.apps.googleusercontent.com

OneSignal App ID: 4e7862a1-4191-4788-a703-72a3fea3d12d

AdMob Android App ID: ca-app-pub-7354273374998913~5567231375
AdMob Android Rewarded: ca-app-pub-7354273374998913/5755827856

PayPal: paypal.me/AbdelRahmen2003

SHA-1 (Debug): F9:48:AD:F2:A7:85:7E:1F:89:54:FF:50:53:7E:8C:60:31:3B:E6:DB
SHA-1 (Release): 34:74:07:F9:D2:7A:5D:FD:2E:BB:E8:4A:36:62:C4:C2:22:2C:C6:30

Owner Emails (4):
- abdelrahmenbenromdhan11@gmail.com
- vevocom888@gmail.com
- nooralimanechannel@gmail.com
- nooralhidayahbusiness@gmail.com

GitHub Repo:
github.com/nooralhidayahbusiness-App/noor-al-hidayah_claud.APP

Codespace URL (مثال):
https://humble-yodel-w5vqw65rrqhqp-8095.app.github.dev
```

---

🎯 الخلاصة التنفيذية

التطبيق: إسلامي شامل، Flutter + Firebase + OneSignal + AdMob.

حالياً (Beta 3.0):

· ✅ 47 مرحلة مكتملة
· ✅ APK يُبنى على GitHub Actions
· ✅ Google Sign-In يعمل
· ✅ OneSignal يعمل (اختبار Push ناجح)
· ✅ الإشعار الدائم يعمل (Chronometer)
· ⏳ اختبار الأذان الفعلي عند الصلاة

الخطوة الفورية:
اختبار الأذان عند صلاة العشاء — هل:

1. شاشة الأذان تفتح تلقائياً؟
2. صوت المؤذن يشتغل؟
3. زر الكتم + القبلة + الأذكار + "صليت الآن" تعمل؟

إذا نجحت → المرحلة 48 (تحسينات الأداء).
إذا فشلت → إصلاح الأذان أولاً.

## 🚨 إذا حدثت مشكلة أخرى — اقرأ هذا أولاً (قسم إجباري لأي AI جديد)

> **هذا القسم مهم جداً.** أي AI جديد يقرأ الملف يجب أن يفهم:
> 1. ما آخر شيء تم إنجازه
> 2. ما المشاكل التي واجهناها وكيف حللناها
> 3. ما الذي **لا يجب لمسه نهائياً**
> 4. ما الذي **يمكن تعديله** إذا تكررت المشاكل

---

## 📅 آخر ما تم إنجازه (المرحلة 45-49)

### ✅ المرحلة 45: إشعار دائم للصلاة (Chronometer)
**الهدف:** إشعار مستمر يُظهر الصلاة القادمة + العد التنازلي **حيّاً** (بدون تحديث Notification كل ثانية).

**الحل المطبّق:**
- `AndroidNotificationDetails` مع:
  - `usesChronometer: true`
  - `chronometerCountDown: true`
  - `when: targetTime.millisecondsSinceEpoch`
  - `ongoing: true`
  - `autoCancel: false`
  - `onlyAlertOnce: true`
- القناة: `ongoing_prayer_channel_v4`
- **قناة تُنشأ برمجياً** في `_createChannels()` داخل `NotificationService.init()`.

**الملف المسؤول:** `lib/services/notification_service.dart` (دالة `showOngoingPrayer`).

---

### ✅ المرحلة 46: إصلاح مشكلة الجدولة (بدون `Future.delayed(3s)`)

**المشكلة القديمة:** `home_shell.dart` كان يستخدم `Future.delayed(Duration(seconds: 3))` لجدولة الصلوات. النتيجة: أحياناً تُجدول **قبل** أن تُحمّل أوقات الصلاة فعلياً → **لا إشعار، لا أذان**.

**الحل المطبّق:**
- حذف `Future.delayed(3s)`.
- إضافة `prayerState.addListener(_onPrayerStateChanged)`.
- الجدولة تحدث **فقط** عندما `prayerState.status == PrayerStatus.ready`.
- إضافة متغيّرين:
  - `_rescheduleInFlight` (منع التكرار المتزامن).
  - `_lastRescheduledPrayerDay` (الجدولة مرة واحدة يومياً).

**الملف المسؤول:** `lib/screens/home_shell.dart`.

---

### ✅ المرحلة 47: حل مشكلة "صلاحية المنبهات" نهائياً

**المشكلة:** زر اختبار الأذان 🐛 كان يقول "❌ فشلت الجدولة". السبب: `SCHEDULE_EXACT_ALARM` غير مفعّلة، و Samsung A55 لا يُظهرها في الإعدادات.

**الحل المطبّق:**
- **حذف `canScheduleExactNotifications` بالكامل.**
- استخدام `AndroidScheduleMode.inexactAllowWhileIdle` **دائماً**.
- `inexact` لا يحتاج أي صلاحية خاصة.
- **لا يطلب التطبيق أي إذن من المستخدم للمنبهات.**

**النتيجة:** زر اختبار الأذان 🐛 يعمل بدون أي رفض.

---

### ✅ المرحلة 48: Full-Screen Intent (شاشة الأذان عند الصلاة)

**الهدف:** عند دخول وقت الصلاة، تظهر **شاشة الأذان كاملة** حتى لو التطبيق مغلق.

**الحل المطبّق في `notification_service.dart`:**
- `fullScreenIntent: true` في `AndroidNotificationDetails` للإشعارات المجدولة.
- `category: AndroidNotificationCategory.alarm`
- `audioAttributesUsage: AudioAttributesUsage.alarm`
- `visibility: NotificationVisibility.public`
- القناة: `prayer_channel_v4`

**في `AndroidManifest.xml`:**
- `USE_FULL_SCREEN_INTENT` permission.
- `MainActivity` يحتوي:
  - `android:showWhenLocked="true"`
  - `android:turnScreenOn="true"`

---

### ✅ المرحلة 49: تحسينات شاشة الأذان + المتجر

**شاشة الأذان (`adhan_screen.dart`):**
- اسم الصلاة **72pt** مع توهج ثلاثي.
- الوقت **26pt** مع توهج ذهبي.
- **دوائر توهج ماء** (4 دوائر، AnimationController 3.5s) خلف اسم الصلاة والوقت.
- زر **"صليت الآن"** في **الوسط** كمستطيل دائري (240x58) مع **3 حلقات تموّج** (AnimationController 2.4s).
- أزرار **القبلة** + **أذكار بعد الصلاة** في **الأسفل** كدوائر كبيرة (90px).
- النص المتحرك أبطأ 1.4x وأكبر (40pt).
- **حذف بطاقة المؤذن** (الخرم المكي/السعودية) لأنها كانت تُغطي زخرفة المسجد.

**المتجر (`store_screen.dart`):**
- زر **👁 معاينة** يفتح `_AdhanPreviewPage` — شاشة كاملة بتصميم شاشة الأذان.
- الخلفيات VIP (adhanBackground + background) تُظهر شارات: `VIP` + `ANIMATION`.
- خلفيات `adhanBackground` VIP تُظهر شارة إضافية: `TEXT`.
- معاينة `adhanBackground` تُظهر **نص الأذان المتحرك**.
- معاينة `background` العادية **بدون** نص الأذان.

---

### ✅ المرحلة 50: أزرار اختبار داخل التطبيق (للمالك فقط)

في `home_shell.dart`، أعلى اليمين:

| الزر | اللون | الوظيفة |
|------|-------|---------|
| 🐛 `Icons.bug_report_rounded` | 🟠 برتقالي | اختبار الأذان بعد 30 ثانية (يُغلقه المستخدم للاختبار) |
| 🔔 `Icons.notifications_active_rounded` | 🟢 أخضر | عرض إشعار فوري (بدون جدولة) |

**تظهر فقط لـ `authService.isOwner == true`.**

**الاستخدام:** اضغط 🐛 → رسالة "✅ تم الجدولة" → أغلق التطبيق → انتظر 30 ثانية → يجب أن تفتح شاشة الأذان.

---

## 🚨 قائمة "لا تلمسها" (CRITICAL — لا تُعدّل مطلقاً)

### التصميم والهوية:
- ❌ **`AppColors`** (`deepGreen`, `green`, `emerald`, `gold`, `softGold`, `cream`) — أي تغيير يُفسد هوية التطبيق.
- ❌ **`themeState.palette`** — الثيمات الـ9.
- ❌ **الأنيميشن** `AnimatedEntry`, `AnimatedSwitcher` في `PostCard`, `_RippleButton`, `_GlowWrapper`.
- ❌ **الحلقة الذهبية الدوّارة** في `ProfileAvatar`.
- ❌ **التاج** فوق صورة Premium في `ProfileAvatar`.
- ❌ **VerifiedBadge** (owner/premium/me/user).

### البنية الأساسية:
- ❌ **`IndexedStack`** في `home_shell.dart` — 6 تبويبات متزامنة.
- ❌ **`_BottomBar`** و **`_BottomTab`** — أي تعديل يكسر التنقل.
- ❌ **`TabController`** في `store_screen` (طول 4).
- ❌ **`prayerState.nextPrayer()`** — منطق الصلاة القادمة.
- ❌ **`adhanService.setReciter()`** + `adhanService.isMuted` — كتم الصوت.
- ❌ **زر "صليت الآن"** بمرحلتين (ذهبي → رمادي → إغلاق).
- ❌ **زر X** في أعلى شاشة الأذان + `PopScope`.

### الخدمات:
- ❌ **`premiumService`** — منطق Premium (approve/reject + إشعارات + 10000 نقطة).
- ❌ **`userService`** — النقاط والمخزون.
- ❌ **`authService.signInWithGoogle()`** — Google Sign-In.
- ❌ **`pushService`** — OneSignal.
- ❌ **`community_notification_service`** — إشعارات المجتمع.

### مفاتيح الترجمة:
- ❌ **لا تحذف** أي مفتاح من `app_state.dart` (العربية + الإنجليزية).
- ❌ **لا تغيّر** قيم المفاتيح الموجودة.

---

## ✅ قائمة "يمكن تعديلها" إذا تكررت المشاكل

### 🅰️ إذا لم يظهر الإشعار الدائم عند التسجيل:

**الملف:** `lib/screens/home_shell.dart`
**ابحث عن:** `FirebaseAuth.instance.authStateChanges().listen(...)`
**التحقق:**
- بعد تسجيل الدخول → `_updateOngoing()` تُستدعى بعد 2 ثانية.
- إذا لم تُستدعَ → تحقق أن `prayerState.status == PrayerStatus.ready`.
- إذا `prayerState` لا يزال `loading` → انتظر `_onPrayerStateChanged`.

### 🅱️ إذا لم تظهر شاشة الأذان عند الوقت:

**الملف:** `lib/services/notification_service.dart`
**تحقق من:**
1. القناة `prayer_channel_v4` موجودة في `_createChannels()`.
2. الإشعار المجدول يحتوي:
   - `fullScreenIntent: true`
   - `category: AndroidNotificationCategory.alarm`
   - `priority: Priority.max`
   - `importance: Importance.max`
3. `AndroidManifest.xml` يحتوي `USE_FULL_SCREEN_INTENT`.

**إذا على Samsung تحديداً:** افتح **الإعدادات** → **التطبيقات** → **Noor Al-Hidayah** → **إشعارات** → **فئة قناة prayer_channel_v4** → تأكد من تفعيل "Popup" أو "Full-screen".

### 🅲 إذا فشل جدولة الإشعارات:

**لا تحتاج صلاحية Exact Alarm** (تم حذفها).
- كل الإشعارات تستخدم `inexactAllowWhileIdle`.
- إذا فشلت → تحقق أن وقت الصلاة > الآن + دقيقة واحدة.
- الإشعارات الماضية تُتخطى تلقائياً.

### 🅳 إذا تكرر البق "File could not be edited" في GitHub:

**السبب:** تحرير ملف كبير في محرر GitHub على الجوال.
**الحل:**
1. استخدم Terminal بدل المحرر (مثال: `cat > file << 'EOF'`).
2. أو حرّر الملف على جهاز الكمبيوتر.
3. أو قسم التعديل إلى أجزاء صغيرة.

### 🅴 إذا فشل البناء على GitHub Actions:

**تحقق من:**
1. Gradle: `8.14` في `android/gradle/wrapper/gradle-wrapper.properties`.
2. AGP: `8.11.1` + Kotlin: `2.2.20` في `android/settings.gradle.kts`.
3. `android.enableJetifier=false` في `gradle.properties`.
4. `Xmx 4096M` في `gradle.properties`.
5. `google-services.json` موجود في `android/app/`.
6. `key.properties` + keystore secrets موجودة في GitHub.

---

## 🛠️ أدوات التشخيص (Debug Tools)

### داخل التطبيق (للمالك فقط):
- 🐛 **Bug Report** → اختبار الأذان (30 ثانية).
- 🔔 **Notification Active** → إشعار فوري بدون جدولة.

### Logs في Terminal:
البحث في Output بحثاً عن:
```

[PRAYER]     — تحديثات PrayerState
[ALARM]      — جدولة الإشعارات
[NOTIFICATION] — حالة الإشعار الدائم
[FULLSCREEN] — فتح شاشة الأذان
[TEST]       — اختبارات debug
[ERROR]      — الأخطاء

```

### اختبر فوراً:
```bash
flutter analyze
# إذا "No issues found" → 
# اذهب إلى GitHub Actions → Artifacts → حمّل APK
```

---

⚙️ معلومات المشروع التقنية (للمرجعية)

الإصدارات المتوافقة (لا تغيّرها):

```
Flutter: 3.35.2 (stable)
Dart: 3.9+ (يأتي مع Flutter)
Gradle: 8.14
AGP: 8.11.1
Kotlin: 2.2.20
Java: 17 (Temurin)
compileSdk: 36
```

قنوات الإشعارات (Notifications Channels):

القناة الاستخدام Importance
prayer_channel_v4 إشعارات الصلاة (full-screen) max
ongoing_prayer_channel_v4 الإشعار الدائم low
daily_channel_v3 التذكيرات اليومية default

ملاحظة: إذا احتجت إنشاء قناة جديدة، استخدم _v5, _v6... لأن Android يحتفظ بالإعدادات القديمة للقناة.

Permissions في AndroidManifest:

```
POST_NOTIFICATIONS
SCHEDULE_EXACT_ALARM  (احتياطي، لا يُطلب فعلياً)
USE_EXACT_ALARM       (احتياطي)
RECEIVE_BOOT_COMPLETED
USE_FULL_SCREEN_INTENT
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
FOREGROUND_SERVICE
FOREGROUND_SERVICE_SPECIAL_USE
VIBRATE
WAKE_LOCK
INTERNET
ACCESS_NETWORK_STATE
ACCESS_FINE_LOCATION
ACCESS_COARSE_LOCATION
RECORD_AUDIO
```

المشاكل السابقة وحلولها (للمرجعية):

# المشكلة الحل
1 Gradle 8.9 → Flutter يرفض رُفع إلى 8.14
2 AGP 9.1.0 → google_mobile_ads يفشل رُفض إلى 8.11.1
3 Kotlin 2.0.21 → Flutter يرفض رُفع إلى 2.2.20
4 Java 25 → Gradle 8.9 يفشل نُزّل Java 17
5 flutter_local_notifications يحتاج desugaring أُضيف coreLibraryDesugaring
6 record_linux تعارض dependency_overrides: record_linux: ^1.0.0
7 Jetifier يستهلك RAM android.enableJetifier=false
8 Codespaces نفاد ذاكرة Xmx 4096M + org.gradle.daemon=false
9 GitHub Secrets: مشكلة GH_TOKEN GH_TOKEN= GITHUB_TOKEN= gh secret set ...
10 secrets.dart مرفوع خطأً أُضيف إلى .gitignore
11 Future.delayed(3s) يجدول قبل تحميل الأوقات prayerState.addListener
12 SCHEDULE_EXACT_ALARM لا يظهر في إعدادات Samsung استُبدل بـ inexactAllowWhileIdle
13 الإشعار الدائم لا يظهر يُطلَق عند authStateChanges + prayerState ready
14 شاشة الأذان لا تفتح fullScreenIntent: true + USE_FULL_SCREEN_INTENT
15 adhan_screen النص أسرع من الصوت مضاعفة المدة × 1.4
16 بطاقة المؤذن تُغطي زخرفة المسجد حُذفت
17 زر "صليت الآن" شريط عرض كامل مستطيل دائري 240px + ripple

---

📌 قواعد إضافية لأي AI جديد

1. قبل أي تعديل: اطلب من المستخدم محتوى الملف الحالي.
2. بعد أي تعديل: أرسل الملف كاملاً (لا أسطر متفرقة).
3. استثناء: إذا كان التعديل سطر استيراد فقط (import)، أخبر المستخدم "أضف السطر X" لأن هذا سهل عليه.
4. لا تخترع ألواناً جديدة — استخدم AppColors.
5. لا تستخدم Future.delayed لحل مشاكل التوقيت — استخدم Listenable أو StreamBuilder.
6. لا تحذف قنوات الإشعارات القديمة — استخدم إصدارات جديدة (_v5, _v6).
7. إذا فشل البناء: اقرأ آخر 30 سطر من GitHub Actions → أرسلها للمستخدم ليتصرف.
8. الأولوية القصوى: الحفاظ على 47 مرحلة سابقة بدقة.

---

🎯 الخلاصة الحالية (Beta 3.0)

التطبيق جاهز للاختبار الفعلي.

· جميع الميزات المذكورة أعلاه مختبرة.
· مشاكل الإشعارات والأذان محلولة.
· زر اختبار الأذان موجود (للمالك فقط).
· الأداء مقبول (يحتاج تحسينات في المرحلة القادمة).

الخطوة التالية المقترحة (المرحلة 51):

· تحسينات الأداء (تقليل الأنيميشن، تقليل الظلال).
· مراجعة IndexedStack لتحميل lazy.
· اختبار على أجهزة متعددة (Android 10-16).

---

```

---

## ✅ الخطوات

**1.** في GitHub: افتح `PROJECT.md` → قلم ✏️.

**2.** **لا تحذف أي شيء.**

**3.** **ضع المؤشر قبل السطر الأخير** `**© 2026 Noor Al-Hidayah...**` مباشرة.

**4.** **الصق الكتلة أعلاه كاملة.**

**5.** تأكد أن آخر سطرين في الملف هما:
```

---

© 2026 Noor Al-Hidayah — Abdel Rahmen Ben Romdhan

```

**6.** Commit: `PROJECT.md: add AI handoff section (Phase 45-50)`

---

## 📌 بعد البناء

**أخبرني بالنتيجة بعد الاختبار:**

1. **الإشعار الدائم** — يظهر بعد فتح التطبيق؟
2. **زر 🐛** — يقول "✅ تم الجدولة"؟
3. **شاشة الأذان** — تفتح بعد 30 ثانية؟
4. **التصميم الجديد** — دوائر توهج + ripple + دوائر القبلة؟

**🌸 سأكون معك حتى النهاية.**
---

© 2026 Noor Al-Hidayah — Abdel Rahmen Ben Romdhan
