package com.nooralhidayah.noor_al_hidayah

import android.content.Context
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        installCrashLogger()
        super.onCreate(savedInstanceState)
    }

    /// يحفظ نص آخر انهيار في SharedPreferences ليعرضه التطبيق في التشغيل التالي
    private fun installCrashLogger() {
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                val text = Log.getStackTraceString(throwable)
                applicationContext
                    .getSharedPreferences("crash_log", Context.MODE_PRIVATE)
                    .edit()
                    .putString("last", text)
                    .commit()
            } catch (e: Throwable) {
                // لا شيء
            }
            previous?.uncaughtException(thread, throwable)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // قناة الإشعار الدائم المخصّص للصلاة القادمة + سجل الانهيار
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "noor/prayer_countdown"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    val json = call.argument<String>("json") ?: ""
                    PrayerCountdown.update(applicationContext, json)
                    result.success(true)
                }
                "cancel" -> {
                    PrayerCountdown.cancel(applicationContext)
                    result.success(true)
                }
                "lastCrash" -> {
                    val prefs = applicationContext
                        .getSharedPreferences("crash_log", Context.MODE_PRIVATE)
                    result.success(prefs.getString("last", ""))
                }
                "clearCrash" -> {
                    applicationContext
                        .getSharedPreferences("crash_log", Context.MODE_PRIVATE)
                        .edit().remove("last").commit()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
