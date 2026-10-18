package com.nooralhidayah.noor_al_hidayah

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.system.exitProcess

class MainActivity : FlutterActivity() {

    companion object {
        /// true  = تظهر شاشة تشخيص عند أي انهيار (نسخة الاختبار)
        /// false = السلوك العادي (للنسخة النهائية)
        const val SHOW_CRASH_SCREEN = true
        private const val PREFS = "crash_log"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        installCrashLogger()
        try {
            super.onCreate(savedInstanceState)
        } catch (t: Throwable) {
            val text = buildCrashText(t)
            saveCrash(text)
            showCrashScreen(text)
            finish()
            return
        }

        // انهيار سابق لم يُعرض بعد → نعرضه مرة واحدة
        if (SHOW_CRASH_SCREEN) {
            val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val saved = prefs.getString("last", "")
            if (!saved.isNullOrEmpty()) {
                showCrashScreen(saved)
                prefs.edit().remove("last").commit()
            }
        }
    }

    private fun buildCrashText(t: Throwable): String {
        val sb = StringBuilder()
        sb.append("Device: ").append(Build.MANUFACTURER).append(' ').append(Build.MODEL).append('\n')
        sb.append("Android: ").append(Build.VERSION.RELEASE)
            .append(" (API ").append(Build.VERSION.SDK_INT).append(")\n")
        sb.append("ABIs: ").append(Build.SUPPORTED_ABIS.joinToString(",")).append('\n')
        sb.append("------\n")
        sb.append(Log.getStackTraceString(t))
        val s = sb.toString()
        return if (s.length > 6000) s.substring(0, 6000) else s
    }

    private fun saveCrash(text: String) {
        try {
            applicationContext
                .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString("last", text)
                .commit()
        } catch (e: Throwable) {
            // لا شيء
        }
    }

    private fun showCrashScreen(text: String) {
        try {
            val intent = Intent(this, CrashActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.putExtra("text", text)
            startActivity(intent)
        } catch (e: Throwable) {
            // لا شيء
        }
    }

    /// يحفظ نص آخر انهيار ويعرض شاشة التشخيص (في عملية منفصلة) قبل إغلاق التطبيق
    private fun installCrashLogger() {
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        val appContext = applicationContext
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                val text = buildCrashText(throwable)
                appContext
                    .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    .edit()
                    .putString("last", text)
                    .commit()
                if (SHOW_CRASH_SCREEN) {
                    val intent = Intent(appContext, CrashActivity::class.java)
                    intent.addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    )
                    intent.putExtra("text", text)
                    appContext.startActivity(intent)
                }
            } catch (e: Throwable) {
                // لا شيء
            }
            if (SHOW_CRASH_SCREEN) {
                Process.killProcess(Process.myPid())
                exitProcess(10)
            } else {
                previous?.uncaughtException(thread, throwable)
            }
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
                        .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    result.success(prefs.getString("last", ""))
                }
                "clearCrash" -> {
                    applicationContext
                        .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                        .edit().remove("last").commit()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
