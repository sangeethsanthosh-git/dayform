package com.dayform.app.dayform

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dayform.app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPinWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = getSystemService(AppWidgetManager::class.java)
                        val myProvider = ComponentName(this, LiveDayWidgetProvider::class.java)
                        if (appWidgetManager != null && appWidgetManager.isRequestPinAppWidgetSupported) {
                            val success = appWidgetManager.requestPinAppWidget(myProvider, null, null)
                            result.success(success)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "updateWidget" -> {
                    val appWidgetManager = AppWidgetManager.getInstance(this)
                    val thisWidget = ComponentName(this, LiveDayWidgetProvider::class.java)
                    val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                    for (widgetId in allWidgetIds) {
                        LiveDayWidgetProvider.updateWidget(this, appWidgetManager, widgetId)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        try {
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val thisWidget = ComponentName(this, LiveDayWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (widgetId in allWidgetIds) {
                LiveDayWidgetProvider.updateWidget(this, appWidgetManager, widgetId)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
