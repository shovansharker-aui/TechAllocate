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
                val maintenance = call.argument<Int>("maintenanceOngoing") ?: 0
                val engaged = call.argument<Int>("personEngaged") ?: 0
                val free = call.argument<Int>("personFree") ?: 0
                TechAllocateWidgetProvider.updateAll(this, maintenance, engaged, free)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
