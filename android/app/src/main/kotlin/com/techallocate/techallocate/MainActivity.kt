package com.techallocate.techallocate

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "techallocate/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method == "updateStatus") {
                val jo = call.argument<Int>("jo") ?: 0
                val cf = call.argument<Int>("cf") ?: 0
                val pm = call.argument<Int>("pm") ?: 0
                val bm = call.argument<Int>("bm") ?: 0
                val cl = call.argument<Int>("cl") ?: 0
                val ad = call.argument<Int>("ad") ?: 0
                TechAllocateWidgetProvider.updateAll(this, jo, cf, pm, bm, cl, ad)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}