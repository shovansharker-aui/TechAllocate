package com.techallocate.techallocate

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

class TechAllocateWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val PREFS = "techallocate_widget"
        private const val MAINTENANCE = "maintenanceOngoing"
        private const val ENGAGED = "personEngaged"
        private const val FREE = "personFree"

        fun updateAll(context: Context, maintenance: Int, engaged: Int, free: Int) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putInt(MAINTENANCE, maintenance)
                .putInt(ENGAGED, engaged)
                .putInt(FREE, free)
                .apply()

            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, TechAllocateWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) updateOne(context, manager, id)
        }

        private fun updateOne(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.techallocate_widget)
            views.setTextViewText(R.id.widget_maintenance, "Maintenance Ongoing: ${prefs.getInt(MAINTENANCE, 0)}")
            views.setTextViewText(R.id.widget_engaged, "Person Engaged: ${prefs.getInt(ENGAGED, 0)}")
            views.setTextViewText(R.id.widget_free, "Person Free: ${prefs.getInt(FREE, 0)}")
            manager.updateAppWidget(widgetId, views)
        }
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) updateOne(context, manager, id)
    }
}
