package com.dayform.app.dayform

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

class LiveDayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        if (action == Intent.ACTION_DATE_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED ||
            action == Intent.ACTION_TIME_TICK ||
            action == Intent.ACTION_BOOT_COMPLETED ||
            action == AppWidgetManager.ACTION_APPWIDGET_UPDATE
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, LiveDayWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (widgetId in allWidgetIds) {
                updateWidget(context, appWidgetManager, widgetId)
            }
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int) {
            try {
                // 1. Decode base 3D card bitmap
                val base = BitmapFactory.decodeResource(context.resources, R.drawable.widget_card_base)
                    ?: return
                val bitmap = base.copy(Bitmap.Config.ARGB_8888, true)
                val canvas = Canvas(bitmap)
                val w = bitmap.width.toFloat()
                val h = bitmap.height.toFloat()

                // 2. Fetch real current day and date
                val cal = Calendar.getInstance()
                val weekdayStr = SimpleDateFormat("EEE", Locale.getDefault()).format(cal.time)
                val dayStr = SimpleDateFormat("d", Locale.getDefault()).format(cal.time)

                // 3. Card inner coordinates
                val padX = w * 0.085f
                val padTop = h * 0.065f
                val padBot = h * 0.14f
                val cardW = w - 2 * padX
                val cardH = h - padTop - padBot
                val creaseY = padTop + cardH * 0.505f

                // 4. Paint setup for Weekday
                val weekdayPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = Color.argb(235, 240, 246, 255)
                    textSize = cardW * 0.22f
                    typeface = Typeface.create("sans-serif-light", Typeface.NORMAL)
                    textAlign = Paint.Align.CENTER
                }

                val weekdayBounds = Rect()
                weekdayPaint.getTextBounds(weekdayStr, 0, weekdayStr.length, weekdayBounds)
                val weekdayY = padTop + (creaseY - padTop) * 0.55f

                canvas.drawText(weekdayStr, w / 2f, weekdayY, weekdayPaint)

                // 5. Paint setup for Date (10, 23, etc.)
                val datePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = Color.WHITE
                    textSize = cardW * 0.54f
                    typeface = Typeface.create("sans-serif-light", Typeface.NORMAL)
                    textAlign = Paint.Align.CENTER
                }

                val dateBounds = Rect()
                datePaint.getTextBounds(dayStr, 0, dayStr.length, dateBounds)
                val dateY = creaseY + (dateBounds.height() * 0.45f)

                canvas.drawText(dayStr, w / 2f, dateY, datePaint)

                // 6. Crease cast shadow on top of the text
                val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = Color.argb(130, 2, 22, 90)
                }
                val shadowRect = RectF(padX, creaseY, padX + cardW, creaseY + 30f)
                canvas.drawRect(shadowRect, shadowPaint)

                // 7. RemoteViews setup
                val views = RemoteViews(context.packageName, R.layout.widget_live_day)
                views.setImageViewBitmap(R.id.widget_image, bitmap)

                // 8. Tapping launches the app
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
