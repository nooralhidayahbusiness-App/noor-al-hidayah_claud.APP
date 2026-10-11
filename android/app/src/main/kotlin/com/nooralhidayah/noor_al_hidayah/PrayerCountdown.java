package com.nooralhidayah.noor_al_hidayah;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.os.SystemClock;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * الإشعار الدائم المخصّص للصلاة القادمة.
 *
 * الحالات:
 *  - NORMAL : أكثر من 10 دقائق للأذان  → عدّاد أخضر
 *  - SOON   : أقل من 10 دقائق للأذان   → عدّاد برتقالي فاتح
 *  - PASSED : بعد دخول الوقت          → عدّاد أحمر سالب (الوقت المنقضي)
 */
public class PrayerCountdown {

    static final String CHANNEL_ID = "prayer_countdown_v2";
    static final int NOTIFICATION_ID = 400;
    static final String ACTION_TICK =
            "com.nooralhidayah.noor_al_hidayah.PRAYER_COUNTDOWN_TICK";

    private static final String PREFS = "prayer_countdown_prefs";
    private static final String KEY_JSON = "payload";
    private static final int ALARM_REQUEST_CODE = 4001;

    private static final int PHASE_NORMAL = 0;
    private static final int PHASE_SOON = 1;
    private static final int PHASE_PASSED = 2;

    private static final int COLOR_NORMAL = Color.parseColor("#43A047"); // أخضر
    private static final int COLOR_SOON = Color.parseColor("#FFB74D");   // برتقالي فاتح
    private static final int COLOR_PASSED = Color.parseColor("#E53935"); // أحمر

    private PrayerCountdown() {}

    // ============================================================
    // واجهة عامة
    // ============================================================

    /** يُستدعى من Flutter: يحفظ الجدول ويحدّث الإشعار. */
    public static void update(Context context, String json) {
        try {
            SharedPreferences prefs =
                    context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            prefs.edit().putString(KEY_JSON, json).apply();
            refresh(context);
        } catch (Throwable ignored) {
        }
    }

    /** يلغي الإشعار والمنبّه. */
    public static void cancel(Context context) {
        try {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    .edit().remove(KEY_JSON).apply();
            NotificationManager nm = (NotificationManager)
                    context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (nm != null) nm.cancel(NOTIFICATION_ID);
            cancelAlarm(context);
        } catch (Throwable ignored) {
        }
    }

    /** يعيد حساب الحالة ويعرض الإشعار ويجدول المنبّه التالي. */
    public static void refresh(Context context) {
        try {
            SharedPreferences prefs =
                    context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            String text = prefs.getString(KEY_JSON, null);
            if (text == null || text.isEmpty()) return;

            JSONObject root = new JSONObject(text);
            JSONArray prayers = root.getJSONArray("prayers");
            int soonMin = root.optInt("soonMinutes", 10);
            int afterMin = root.optInt("afterMinutes", 30);
            long soonMs = soonMin * 60000L;
            long afterMs = afterMin * 60000L;
            long now = System.currentTimeMillis();

            JSONObject shown = null;
            int phase = PHASE_NORMAL;
            JSONObject next = null;

            for (int i = 0; i < prayers.length(); i++) {
                JSONObject p = prayers.getJSONObject(i);
                long t = p.getLong("t");
                if (t <= now && now < t + afterMs) {
                    shown = p;
                    phase = PHASE_PASSED;
                }
                if (t > now && next == null) {
                    next = p;
                }
            }

            if (shown == null && next != null) {
                shown = next;
                long left = next.getLong("t") - now;
                phase = (left <= soonMs) ? PHASE_SOON : PHASE_NORMAL;
            }

            NotificationManager nm = (NotificationManager)
                    context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (nm == null) return;

            if (shown == null) {
                // انتهى الجدول (لم يُفتح التطبيق منذ أيام)
                nm.cancel(NOTIFICATION_ID);
                return;
            }

            ensureChannel(context, nm);
            Notification notification = buildNotification(context, root, shown, phase);
            nm.notify(NOTIFICATION_ID, notification);

            // المنبّه التالي: عند أقرب حدّ تغيير (قبل الأذان بـ10د / الأذان / نهاية الفترة)
            long nextAlarm = Long.MAX_VALUE;
            for (int i = 0; i < prayers.length(); i++) {
                long t = prayers.getJSONObject(i).getLong("t");
                long[] candidates = new long[]{
                        t - soonMs + 1000L,
                        t + 1000L,
                        t + afterMs + 1000L
                };
                for (long c : candidates) {
                    if (c > now && c < nextAlarm) nextAlarm = c;
                }
            }
            if (nextAlarm != Long.MAX_VALUE) {
                scheduleAlarm(context, nextAlarm);
            }
        } catch (Throwable ignored) {
        }
    }

    // ============================================================
    // بناء الإشعار
    // ============================================================

    private static Notification buildNotification(
            Context context, JSONObject root, JSONObject prayer, int phase)
            throws Exception {

        String appName = root.optString("appName", "Noor Al-Hidayah");
        String lang = root.optString("lang", "ar");
        String hijri = root.optString("hijri", "");
        boolean passed = (phase == PHASE_PASSED);
        String label = passed
                ? root.optString("labelNow", "Prayer time")
                : root.optString("labelNext", "Next prayer");

        String nameAr = prayer.optString("ar", "");
        String nameEn = prayer.optString("en", "");
        long target = prayer.getLong("t");

        int color = (phase == PHASE_PASSED) ? COLOR_PASSED
                : (phase == PHASE_SOON ? COLOR_SOON : COLOR_NORMAL);

        String gregorian = formatGregorian(lang);

        String pkg = context.getPackageName();
        RemoteViews small = new RemoteViews(pkg, R.layout.notification_prayer_small);
        RemoteViews big = new RemoteViews(pkg, R.layout.notification_prayer_big);

        bindCommon(small, appName, label, nameAr, nameEn, target, color);
        bindCommon(big, appName, label, nameAr, nameEn, target, color);
        big.setTextViewText(R.id.pc_date, gregorian);
        big.setTextViewText(R.id.pc_hijri, hijri);

        Notification.Builder b;
        if (Build.VERSION.SDK_INT >= 26) {
            b = new Notification.Builder(context, CHANNEL_ID);
        } else {
            b = new Notification.Builder(context);
            b.setPriority(Notification.PRIORITY_LOW);
        }

        b.setSmallIcon(R.drawable.ic_stat_prayer);
        b.setOngoing(true);
        b.setAutoCancel(false);
        b.setOnlyAlertOnce(true);
        b.setShowWhen(false);
        b.setContentIntent(launchIntent(context));

        if (Build.VERSION.SDK_INT >= 21) {
            b.setCategory(Notification.CATEGORY_STATUS);
            b.setVisibility(Notification.VISIBILITY_PUBLIC);
        }

        if (Build.VERSION.SDK_INT >= 24) {
            b.setStyle(new Notification.DecoratedCustomViewStyle());
            b.setCustomContentView(small);
            b.setCustomBigContentView(big);
        } else {
            b.setContent(small);
        }

        return b.build();
    }

    private static void bindCommon(
            RemoteViews rv, String appName, String label,
            String nameAr, String nameEn, long target, int color) {

        rv.setTextViewText(R.id.pc_app_name, appName);
        rv.setTextViewText(R.id.pc_label, label);
        rv.setTextViewText(R.id.pc_name_ar, nameAr);
        rv.setTextViewText(R.id.pc_name_en, nameEn);

        // العدّاد الحيّ: base = لحظة الأذان على ساعة النظام
        long base = SystemClock.elapsedRealtime()
                + (target - System.currentTimeMillis());
        rv.setChronometer(R.id.pc_counter, base, null, true);
        if (Build.VERSION.SDK_INT >= 24) {
            rv.setChronometerCountDown(R.id.pc_counter, true);
        }
        rv.setTextColor(R.id.pc_counter, color);
    }

    private static String formatGregorian(String lang) {
        try {
            boolean ar = "ar".equals(lang);
            Locale locale = ar
                    ? Locale.forLanguageTag("ar-u-nu-latn")
                    : Locale.ENGLISH;
            SimpleDateFormat f = new SimpleDateFormat(
                    ar ? "EEEE، d MMMM yyyy" : "EEE, d MMM yyyy", locale);
            return f.format(new Date());
        } catch (Exception e) {
            return "";
        }
    }

    private static PendingIntent launchIntent(Context context) {
        Intent intent = context.getPackageManager()
                .getLaunchIntentForPackage(context.getPackageName());
        if (intent == null) intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= 23) flags |= PendingIntent.FLAG_IMMUTABLE;
        return PendingIntent.getActivity(context, 0, intent, flags);
    }

    private static void ensureChannel(Context context, NotificationManager nm) {
        if (Build.VERSION.SDK_INT < 26) return;
        NotificationChannel ch = new NotificationChannel(
                CHANNEL_ID,
                "Next Prayer Countdown",
                NotificationManager.IMPORTANCE_LOW);
        ch.setDescription("Persistent next prayer countdown");
        ch.setShowBadge(false);
        ch.setSound(null, null);
        ch.enableVibration(false);
        nm.createNotificationChannel(ch);
    }

    // ============================================================
    // المنبّهات
    // ============================================================

    private static PendingIntent alarmIntent(Context context) {
        Intent intent = new Intent(context, PrayerCountdownReceiver.class);
        intent.setAction(ACTION_TICK);
        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= 23) flags |= PendingIntent.FLAG_IMMUTABLE;
        return PendingIntent.getBroadcast(context, ALARM_REQUEST_CODE, intent, flags);
    }

    private static void scheduleAlarm(Context context, long at) {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (am == null) return;
        PendingIntent pi = alarmIntent(context);
        try {
            if (Build.VERSION.SDK_INT >= 23) {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi);
            } else {
                am.setExact(AlarmManager.RTC_WAKEUP, at, pi);
            }
        } catch (SecurityException e) {
            // لا توجد صلاحية المنبّه الدقيق → منبّه تقريبي
            if (Build.VERSION.SDK_INT >= 23) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi);
            } else {
                am.set(AlarmManager.RTC_WAKEUP, at, pi);
            }
        }
    }

    private static void cancelAlarm(Context context) {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (am == null) return;
        am.cancel(alarmIntent(context));
    }
}
