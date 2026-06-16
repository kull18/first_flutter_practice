package com.example.untitled1

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "security/adb"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isAdbEnabled") {
                    val adbEnabled = Settings.Global.getInt(
                        contentResolver,
                        Settings.Global.ADB_ENABLED,
                        0
                    ) == 1
                    result.success(adbEnabled)
                } else {
                    result.notImplemented()
                }
            }
    }
}