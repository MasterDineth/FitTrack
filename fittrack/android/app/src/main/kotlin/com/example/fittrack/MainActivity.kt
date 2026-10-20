package com.example.fittrack

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL_LIVE = "com.example.fittrack/live_notification"
        private var liveChannel: MethodChannel? = null
        private var pendingAction: String? = null

        fun sendNotificationAction(action: String) {
            val channel = liveChannel
            if (channel != null) {
                channel.invokeMethod("onAction", mapOf("action" to action))
            } else {
                pendingAction = action
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_LIVE)
        liveChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startLive" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any> ?: emptyMap()
                    LiveWorkoutService.start(this, args)
                    result.success(true)
                }
                "updateLive" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any> ?: emptyMap()
                    LiveWorkoutService.update(this, args)
                    result.success(true)
                }
                "stopLive" -> {
                    LiveWorkoutService.stop(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        pendingAction?.let {
            channel.invokeMethod("onAction", mapOf("action" to it))
            pendingAction = null
        }

        // Handle initial intent route if any
        handleIntentRoute(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentRoute(intent)
    }

    private fun handleIntentRoute(intent: Intent?) {
        val route = intent?.getStringExtra("route") ?: return
        liveChannel?.invokeMethod("onNavigate", mapOf("route" to route))
    }

    override fun onDestroy() {
        liveChannel = null
        super.onDestroy()
    }
}
