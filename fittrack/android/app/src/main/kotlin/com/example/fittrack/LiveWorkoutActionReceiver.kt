package com.example.fittrack

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class LiveWorkoutActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_PREFIX = "com.example.fittrack.action."
        const val EXTRA_ACTION = "action"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.getStringExtra(EXTRA_ACTION) ?: return
        MainActivity.sendNotificationAction(action)
    }
}
