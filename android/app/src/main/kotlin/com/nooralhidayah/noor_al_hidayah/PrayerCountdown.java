package com.nooralhidayah.noor_al_hidayah;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.widget.RemoteViews;

import androidx.core.app.NotificationCompat;

import org.json.JSONObject;

public class PrayerCountdown {

    private static final String CHANNEL_ID = "native_prayer_countdown_v1";
    private static final String CHANNEL_NAME = "Next Prayer Countdown";
    private static final int NOTIFICATION_ID = 8888;
    private static final String PREFS = "prayer_countdown_prefs";

    // ✅ تحديث الإشعار
    public static void update(Context context, String json) {
        try {
            JSONObject obj = new JSONObject(json);

            // حفظ البيانات لاستخدامها عند إعادة التشغيل
            SharedPreferences prefs =
                context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            prefs.edit().putString("json", json).apply();

            showNotification(context, obj);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ إلغاء الإشعار
    public static void cancel(Context context) {
        try {
            NotificationManager nm =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (nm != null) nm.cancel(NOTIFICATION_ID);
        } catch (Exception ignored) {}
    }

    // ✅ عرض الإشعار
    private static void showNotification(Context context, JSONObject obj) {
        try {
            String prayerName = obj.optString("prayer", "");
            long targetTime  = obj.optLong("targetTime", 0L);
            boolean urgent   = obj.optBoolean("urgent", false);
            String hijri     = obj.optString("hijri", "");

            NotificationManager nm =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

            // إنشاء القناة (Android 8+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && nm != null) {
                NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_LOW
                );
                channel.setShowBadge(false);
                channel.setSound(null, null);
                channel.enableVibration(false);
                nm.createNotificationChannel(channel);
            }

            // RemoteViews
            RemoteViews smallView = new RemoteViews(
                context.getPackageName(),
                R.layout.notification_prayer_small
            );
            RemoteViews bigView = new RemoteViews(
                context.getPackageName(),
                R.layout.notification_prayer_big
            );

            // نصوص اسم الصلاة
            smallView.setTextViewText(R.id.notif_prayer_name, prayerName);
            bigView.setTextViewText(R.id.notif_prayer_name, prayerName);

            // التاريخ الهجري
            if (hijri != null && !hijri.isEmpty()) {
                smallView.setTextViewText(R.id.notif_hijri, hijri);
                bigView.setTextViewText(R.id.notif_hijri, hijri);
            }

            // عدّاد تنازلي حي
            if (targetTime > 0) {
                smallView.setChronometerCountDown(R.id.notif_chronometer, true);
                smallView.setChronometer(
                    R.id.notif_chronometer, targetTime, null, true
                );
                bigView.setChronometerCountDown(R.id.notif_chronometer, true);
                bigView.setChronometer(
                    R.id.notif_chronometer, targetTime, null, true
                );
            }

            // Intent لفتح التطبيق عند النقر
            Intent launchIntent = context.getPackageManager()
                .getLaunchIntentForPackage(context.getPackageName());
            PendingIntent pendingIntent = null;
            if (launchIntent != null) {
                launchIntent.setFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK |
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
                );
                int flags = PendingIntent.FLAG_UPDATE_CURRENT;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    flags |= PendingIntent.FLAG_IMMUTABLE;
                }
                pendingIntent = PendingIntent.getActivity(
                    context, 0, launchIntent, flags
                );
            }

            // بناء الإشعار
            NotificationCompat.Builder builder =
                new NotificationCompat.Builder(context, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_notification)
                    .setOngoing(true)
                    .setAutoCancel(false)
                    .setOnlyAlertOnce(true)
                    .setShowWhen(false)
                    .setContent(smallView)
                    .setCustomBigContentView(bigView)
                    .setPriority(NotificationCompat.PRIORITY_LOW)
                    .setCategory(NotificationCompat.CATEGORY_STATUS)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC);

            // لون حسب حالة الاستعجال
            if (urgent) {
                builder.setColor(Color.parseColor("#FFA000"));
            } else {
                builder.setColor(Color.parseColor("#4CAF50"));
            }

            if (pendingIntent != null) {
                builder.setContentIntent(pendingIntent);
            }

            Notification notification = builder.build();

            if (nm != null) {
                nm.notify(NOTIFICATION_ID, notification);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
