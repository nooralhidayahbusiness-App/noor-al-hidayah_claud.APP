package com.nooralhidayah.noor_al_hidayah;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * يستقبل منبّه التحديث (وإعادة تشغيل الهاتف) ويحدّث الإشعار الدائم.
 */
public class PrayerCountdownReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            PrayerCountdown.refresh(context.getApplicationContext());
        } catch (Exception ignored) {
        }
    }
}
