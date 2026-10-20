package com.example.fittrack

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class LiveWorkoutService : Service() {

    companion object {
        const val CHANNEL_ID = "live_workout"
        const val CHANNEL_NAME = "Live Workout"
        const val NOTIFICATION_ID = 1001

        const val ACTION_START = "com.example.fittrack.START_LIVE"
        const val ACTION_UPDATE = "com.example.fittrack.UPDATE_LIVE"
        const val ACTION_STOP = "com.example.fittrack.STOP_LIVE"

        fun start(context: Context, data: Map<String, Any>) {
            val intent = Intent(context, LiveWorkoutService::class.java).apply {
                action = ACTION_START
                putExtras(data)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun update(context: Context, data: Map<String, Any>) {
            val intent = Intent(context, LiveWorkoutService::class.java).apply {
                action = ACTION_UPDATE
                putExtras(data)
            }
            context.startService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, LiveWorkoutService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        private fun Intent.putExtras(data: Map<String, Any>) {
            for ((key, value) in data) {
                when (value) {
                    is String -> putExtra(key, value)
                    is Int -> putExtra(key, value)
                    is Long -> putExtra(key, value)
                    is Double -> putExtra(key, value)
                    is Boolean -> putExtra(key, value)
                }
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private var isForeground = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null || intent.action == ACTION_STOP) {
            stopForegroundService()
            return START_NOT_STICKY
        }

        when (intent.action) {
            ACTION_START, ACTION_UPDATE -> {
                val notification = buildNotification(intent)
                if (!isForeground) {
                    startForegroundWithProperType(notification)
                    isForeground = true
                } else {
                    val manager = getSystemService(NotificationManager::class.java)
                    manager?.notify(NOTIFICATION_ID, notification)
                }
            }
        }

        return START_NOT_STICKY
    }

    private fun startForegroundWithProperType(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            try {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH or ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } catch (_: Exception) {
                try {
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                    )
                } catch (_: Exception) {
                    startForeground(NOTIFICATION_ID, notification)
                }
            }
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun stopForegroundService() {
        isForeground = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val existing = manager?.getNotificationChannel(CHANNEL_ID)
            if (existing != null && existing.importance < NotificationManager.IMPORTANCE_HIGH) {
                manager.deleteNotificationChannel(CHANNEL_ID)
            }
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Ongoing live workout progress notification"
                setShowBadge(false)
                setSound(null, null)
                enableVibration(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(intent: Intent): Notification {
        val scheduleName = intent.getStringExtra("scheduleName") ?: "Workout"
        val scheduleId = intent.getStringExtra("scheduleId") ?: ""
        val mode = intent.getStringExtra("mode") ?: "workout" // "workout" or "rest"
        val title = intent.getStringExtra("title") ?: "Workout"
        val subtitle = intent.getStringExtra("subtitle") ?: ""
        val workoutProgress = intent.getIntExtra("workoutProgress", 0)
        val restRemainingSeconds = intent.getIntExtra("restRemainingSeconds", 0)
        val restTotalSeconds = intent.getIntExtra("restTotalSeconds", 45).coerceAtLeast(1)
        val chronometerBase = intent.getLongExtra("chronometerBase", 0L)
        val isCountDown = intent.getBooleanExtra("isCountDown", false)
        val isPaused = intent.getBooleanExtra("isPaused", false)

        val isRest = mode == "rest"

        // Build RemoteViews: compact view fits inside 64dp collapsed container; expanded view contains full controls
        val viewsCompact = RemoteViews(packageName, R.layout.notification_live_workout)
        val viewsExpanded = RemoteViews(packageName, R.layout.notification_live_workout_expanded)

        val viewsList = listOf(viewsCompact, viewsExpanded)
        for (views in viewsList) {
            views.setTextViewText(R.id.notif_schedule_name, scheduleName)
            views.setTextViewText(R.id.notif_title, title)
            views.setTextViewText(R.id.notif_subtitle, subtitle)
            views.setProgressBar(R.id.notif_progress_workout, 100, workoutProgress.coerceIn(0, 100), false)

            if (chronometerBase > 0) {
                if (isCountDown) {
                    val remainingMs = chronometerBase - System.currentTimeMillis()
                    val baseTime = SystemClock.elapsedRealtime() + remainingMs
                    views.setChronometer(R.id.notif_chronometer, baseTime, null, true)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        views.setChronometerCountDown(R.id.notif_chronometer, true)
                    }
                } else {
                    val elapsedMs = System.currentTimeMillis() - chronometerBase
                    val baseTime = SystemClock.elapsedRealtime() - elapsedMs
                    views.setChronometer(R.id.notif_chronometer, baseTime, null, !isPaused)
                }
            } else {
                views.setChronometer(R.id.notif_chronometer, SystemClock.elapsedRealtime(), null, false)
            }
        }

        // Expanded specific views
        if (isRest) {
            viewsExpanded.setViewVisibility(R.id.notif_progress_rest, View.VISIBLE)
            viewsExpanded.setProgressBar(
                R.id.notif_progress_rest,
                restTotalSeconds,
                restRemainingSeconds.coerceIn(0, restTotalSeconds),
                false
            )
            viewsExpanded.setViewVisibility(R.id.layout_workout_actions, View.GONE)
            viewsExpanded.setViewVisibility(R.id.layout_rest_actions, View.VISIBLE)
        } else {
            viewsExpanded.setViewVisibility(R.id.notif_progress_rest, View.GONE)
            viewsExpanded.setViewVisibility(R.id.layout_workout_actions, View.VISIBLE)
            viewsExpanded.setViewVisibility(R.id.layout_rest_actions, View.GONE)
            viewsExpanded.setTextViewText(R.id.btn_pause_resume, if (isPaused) "Resume" else "Pause")
        }

        // Open App PendingIntent
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("route", if (scheduleId.isNotEmpty()) "/workouts/active/$scheduleId" else "/workouts")
        }
        val pendingOpen = PendingIntent.getActivity(
            this,
            1001,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        viewsCompact.setOnClickPendingIntent(R.id.notif_root, pendingOpen)
        viewsExpanded.setOnClickPendingIntent(R.id.notif_root, pendingOpen)
        viewsExpanded.setOnClickPendingIntent(R.id.btn_open, pendingOpen)

        // Action Buttons PendingIntents
        viewsExpanded.setOnClickPendingIntent(
            R.id.btn_pause_resume,
            createActionPendingIntent(if (isPaused) "resume" else "pause", 1002)
        )
        viewsExpanded.setOnClickPendingIntent(
            R.id.btn_minus_15,
            createActionPendingIntent("rest_minus_15", 1003)
        )
        viewsExpanded.setOnClickPendingIntent(
            R.id.btn_skip_rest,
            createActionPendingIntent("skip_rest", 1004)
        )
        viewsExpanded.setOnClickPendingIntent(
            R.id.btn_plus_15,
            createActionPendingIntent("rest_plus_15", 1005)
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_fittrack)
            .setColor(0xFF5F3BDC.toInt())
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setSortKey("1")
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCustomContentView(viewsCompact)
            .setCustomBigContentView(viewsExpanded)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setContentIntent(pendingOpen)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setTicker(title)

        // Title and Subtitle in extras for accessibility / system parsing without DecoratedCustomViewStyle injecting duplicate title TextView
        builder.extras.putString(NotificationCompat.EXTRA_TITLE, title)
        builder.extras.putString(NotificationCompat.EXTRA_TEXT, subtitle)

        // Ongoing Live Updates
        builder.extras.putBoolean("android.requestPromotedOngoing", true)
        builder.extras.putBoolean("android.liveUpdates", true)
        builder.extras.putBoolean("show_when_locked", true)

        // Xiaomi HyperOS Dynamic Island / Super Island (Focus Notification)
        builder.extras.putBoolean("miui.focus.enable", true)
        builder.extras.putString("miui.focus.type", "sport")

        // Attach icon bitmap for HyperOS small island capsule
        try {
            val drawable = androidx.core.content.ContextCompat.getDrawable(this, R.drawable.ic_stat_fittrack)
            if (drawable != null) {
                val bitmap = if (drawable is android.graphics.drawable.BitmapDrawable) {
                    drawable.bitmap
                } else {
                    val bmp = android.graphics.Bitmap.createBitmap(
                        drawable.intrinsicWidth.coerceAtLeast(48),
                        drawable.intrinsicHeight.coerceAtLeast(48),
                        android.graphics.Bitmap.Config.ARGB_8888
                    )
                    val canvas = android.graphics.Canvas(bmp)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bmp
                }
                builder.extras.putParcelable("miui.focus.pic_icon", bitmap)
            }
        } catch (_: Exception) {}

        try {
            val islandJson = org.json.JSONObject().apply {
                val paramV2 = org.json.JSONObject().apply {
                    put("protocol", 1)
                    put("business", "sport")
                    put("enableFloat", true)
                    put("updatable", true)
                    put("smallWindowTarget", "com.example.fittrack.MainActivity")
                    val paramIsland = org.json.JSONObject().apply {
                        put("islandProperty", 1)
                        val bigArea = org.json.JSONObject().apply {
                            val picInfo = org.json.JSONObject().apply {
                                put("type", 1)
                                put("pic", "miui.focus.pic_icon")
                            }
                            put("picInfo", picInfo)
                            val textInfo = org.json.JSONObject().apply {
                                put("title", title)
                                put("content", subtitle)
                                put("frontTitle", scheduleName)
                            }
                            put("textInfo", textInfo)
                        }
                        put("bigIslandArea", bigArea)
                        val smallArea = org.json.JSONObject().apply {
                            val picInfo = org.json.JSONObject().apply {
                                put("type", 1)
                                put("pic", "miui.focus.pic_icon")
                            }
                            put("picInfo", picInfo)
                            val textInfo = org.json.JSONObject().apply {
                                put("title", "FitTrack")
                                put("content", title)
                            }
                            put("textInfo", textInfo)
                        }
                        put("smallIslandArea", smallArea)
                    }
                    put("param_island", paramIsland)
                    val baseInfo = org.json.JSONObject().apply {
                        put("title", title)
                        put("content", subtitle)
                        put("colorTitle", "#5F3BDC")
                        put("pictureKey", "miui.focus.pic_icon")
                        put("type", 2)
                    }
                    put("baseInfo", baseInfo)
                }
                put("param_v2", paramV2)
            }
            builder.extras.putString("miui.focus.param", islandJson.toString())
        } catch (_: Exception) {}

        return builder.build()
    }

    private fun createActionPendingIntent(action: String, requestCode: Int): PendingIntent {
        val intent = Intent(this, LiveWorkoutActionReceiver::class.java).apply {
            this.action = LiveWorkoutActionReceiver.ACTION_PREFIX + action
            putExtra(LiveWorkoutActionReceiver.EXTRA_ACTION, action)
        }
        return PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
