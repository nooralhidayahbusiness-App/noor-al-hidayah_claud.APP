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

import androidx.core.app.NotificationCompat;

import org.json.JSONArray;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class PrayerCountdown {

    private static final String CHANNEL_ID = "native_prayer_countdown_v1";
    private static final String CHANNEL_NAME = "Next Prayer Countdown";
    private static final int NOTIFICATION_ID = 8888;
    private static final String PREFS = "prayer_countdown_prefs";
    private static final String KEY_JSON = "json";

    private static final int RC_SOON = 1;
    private static final int RC_TIME = 2;
    private static final int RC_AFTER = 3;

    // ============ Public API ============

    public static void update(Context context, String json) {
        try {
            JSONObject obj = new JSONObject(json);
            saveJson(context, json);
            render(context, obj);
            scheduleNextAlarm(context, obj);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void cancel(Context context) {
        try {
            cancelAlarms(context);
            NotificationManager nm = (NotificationManager)
                context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (nm != null) nm.cancel(NOTIFICATION_ID);
        } catch (Exception ignored) {}
    }

    /// ✅ يُستدعى من PrayerCountdownReceiver
    public static void refresh(Context context) {
        try {
            String json = loadJson(context);
            if (json == null) return;
            JSONObject obj = new JSONObject(json);
            render(context, obj);
            scheduleNextAlarm(context, obj);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ============ Storage ============

    private static void saveJson(Context context, String json) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        prefs.edit().putString(KEY_JSON, json).apply();
    }

    private static String loadJson(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        return prefs.getString(KEY_JSON, null);
    }

    // ============ Render ============

    private static void render(Context context, JSONObject obj) {
        try {
            String appName = obj.optString("appName", "Noor Al-Hidayah");
            String labelNext = obj.optString("labelNext", "Next prayer");
            String labelNow = obj.optString("labelNow", "Prayer time");
            String hijri = obj.optString("hijri", "");
            int soonMinutes = obj.optInt("soonMinutes", 10);
            int afterMinutes = obj.optInt("afterMinutes", 30);

            JSONArray prayers = obj.optJSONArray("prayers");
            if (prayers == null || prayers.length() == 0) return;

            long now = System.currentTimeMillis();

            JSONObject next = null;
            for (int i = 0; i < prayers.length(); i++) {
                JSONObject p = prayers.getJSONObject(i);
                long t = p.getLong("t");
                if (t + afterMinutes * 60_000L > now) {
                    next = p;
                    break;
                }
            }
            if (next == null) return;

            long targetTime = next.getLong("t");
            String nameAr = next.optString("ar", "");
            String nameEn = next.optString("en", "");

            boolean isNow = now >= targetTime;
            boolean isSoon = !isNow && (targetTime - now) <= soonMinutes * 60_000L;

            String label = isNow ? labelNow : labelNext;

            int color;
            if (isNow) {
                color = Color.parseColor("#E53935");
            } else if (isSoon) {
                color = Color.parseColor("#FFA000");
            } else {
                color = Color.parseColor("#4CAF50");
            }

            long targetElapsed = SystemClock.elapsedRealtime() + (targetTime - now);

            NotificationManager nm = (NotificationManager)
                context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && nm != null) {
                NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_LOW);
                channel.setShowBadge(false);
                channel.setSound(null, null);
                channel.enableVibration(false);
                nm.createNotificationChannel(channel);
            }

            RemoteViews smallView = new RemoteViews(
                context.getPackageName(), R.layout.notification_prayer_small);
            RemoteViews bigView = new RemoteViews(
                context.getPackageName(), R.layout.notification_prayer_big);

            smallView.setTextViewText(R.id.pc_app_name, appName);
            smallView.setTextViewText(R.id.pc_label, label);
            smallView.setTextViewText(R.id.pc_name_ar, nameAr);
            smallView.setTextViewText(R.id.pc_name_en, nameEn);

            bigView.setTextViewText(R.id.pc_app_name, appName);
            bigView.setTextViewText(R.id.pc_label, label);
            bigView.setTextViewText(R.id.pc_name_ar, nameAr);
            bigView.setTextViewText(R.id.pc_name_en, nameEn);
            if (hijri != null && !hijri.isEmpty()) {
                bigView.setTextViewText(R.id.pc_hijri, hijri);
            }

            bigView.setTextViewText(R.id.pc_date, formatDate(now));

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                if (isNow) {
                    smallView.setChronometerCountDown(R.id.pc_counter, false);
                    bigView.setChronometerCountDown(R.id.pc_counter, false);
                } else {
                    smallView.setChronometerCountDown(R.id.pc_counter, true);
                    bigView.setChronometerCountDown(R.id.pc_counter, true);
                }
            }
            smallView.setChronometer(R.id.pc_counter, targetElapsed, null, true);
            bigView.setChronometer(R.id.pc_counter, targetElapsed, null, true);

            Intent launchIntent = context.getPackageManager()
                .getLaunchIntentForPackage(context.getPackageName());
            PendingIntent pendingIntent = null;
            if (launchIntent != null) {
                launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                int flags = PendingIntent.FLAG_UPDATE_CURRENT;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    flags |= PendingIntent.FLAG_IMMUTABLE;
                }
                pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, flags);
            }

            NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_notification)
                .setOngoing(true)
                .setAutoCancel(false)
                .setOnlyAlertOnce(true)
                .setShowWhen(false)
                .setContent(smallView)
                .setCustomBigContentView(bigView)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_STATUS)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setColor(color);

            if (pendingIntent != null) {
                builder.setContentIntent(pendingIntent);
            }

            if (nm != null) {
                nm.notify(NOTIFICATION_ID, builder.build());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String formatDate(long timeMs) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("EEEE, d MMM", Locale.getDefault());
            return sdf.format(new Date(timeMs));
        } catch (Exception e) {
            return "";
        }
    }

    // ============ Alarm scheduling ============

    private static void scheduleNextAlarm(Context context, JSONObject obj) {
        try {
            JSONArray prayers = obj.optJSONArray("prayers");
            if (prayers == null || prayers.length() == 0) return;

            int soonMinutes = obj.optInt("soonMinutes", 10);
            int afterMinutes = obj.optInt("afterMinutes", 30);

            long now = System.currentTimeMillis();

            JSONObject next = null;
            for (int i = 0; i < prayers.length(); i++) {
                JSONObject p = prayers.getJSONObject(i);
                long t = p.getLong("t");
                if (t + afterMinutes * 60_000L > now) {
                    next = p;
                    break;
                }
            }
            if (next == null) return;

            long targetTime = next.getLong("t");
            long soonTime = targetTime - soonMinutes * 60_000L;
            long afterTime = targetTime + afterMinutes * 60_000L;

            long triggerAt;
            int requestCode;

            if (now < soonTime) {
                triggerAt = soonTime;
                requestCode = RC_SOON;
            } else if (now < targetTime) {
                triggerAt = targetTime;
                requestCode = RC_TIME;
            } else {
                triggerAt = afterTime;
                requestCode = RC_AFTER;
            }

            cancelAlarms(context);

            AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (am == null) return;

            Intent intent = new Intent(context, PrayerCountdownReceiver.class);
            int flags = PendingIntent.FLAG_UPDATE_CURRENT;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                flags |= PendingIntent.FLAG_IMMUTABLE;
            }
            PendingIntent pi = PendingIntent.getBroadcast(context, requestCode, intent, flags);

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pi);
                } else {
                    am.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pi);
                }
            } catch (SecurityException se) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pi);
                } else {
                    am.set(AlarmManager.RTC_WAKEUP, triggerAt, pi);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void cancelAlarms(Context context) {
        try {
            AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (am == null) return;
            Intent intent = new Intent(context, PrayerCountdownReceiver.class);
            int flags = PendingIntent.FLAG_UPDATE_CURRENT;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                flags |= PendingIntent.FLAG_IMMUTABLE;
            }
            for (int rc : new int[]{RC_SOON, RC_TIME, RC_AFTER}) {
                PendingIntent pi = PendingIntent.getBroadcast(context, rc, intent, flags);
                am.cancel(pi);
            }
        } catch (Exception ignored) {}
    }
}
