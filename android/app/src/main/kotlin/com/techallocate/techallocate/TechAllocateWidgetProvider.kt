package com.techallocate.techallocate

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

class TechAllocateWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val PREFS = "techallocate_widget"
        private const val JO = "jo"
        private const val CF = "cf"
        private const val PM = "pm"
        private const val BM = "bm"
        private const val CL = "cl"
        private const val AD = "ad"

        fun updateAll(context: Context, jo: Int, cf: Int, pm: Int, bm: Int, cl: Int, ad: Int) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putInt(JO, jo)
                .putInt(CF, cf)
                .putInt(PM, pm)
                .putInt(BM, bm)
                .putInt(CL, cl)
                .putInt(AD, ad)
                .apply()

            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, TechAllocateWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) updateOne(context, manager, id)
        }

        private fun updateOne(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.techallocate_widget)

            // "Person Available" card
            views.setTextViewText(R.id.widget_jo, "JO - ${prefs.getInt(JO, 0)}")
            views.setTextViewText(R.id.widget_cf, "CF - ${prefs.getInt(CF, 0)}")

            // "Task Running" card
            views.setTextViewText(R.id.widget_pm, "PM - ${prefs.getInt(PM, 0)}")
            views.setTextViewText(R.id.widget_bm, "BM - ${prefs.getInt(BM, 0)}")
            views.setTextViewText(R.id.widget_cl, "CL - ${prefs.getInt(CL, 0)}")
            views.setTextViewText(R.id.widget_ad, "AD - ${prefs.getInt(AD, 0)}")

            manager.updateAppWidget(widgetId, views)
        }
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) updateOne(context, manager, id)
    }
}