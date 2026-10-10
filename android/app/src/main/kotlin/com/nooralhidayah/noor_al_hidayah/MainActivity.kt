package com.nooralhidayah.noor_al_hidayah

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // قناة الإشعار الدائم المخصّص للصلاة القادمة
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
