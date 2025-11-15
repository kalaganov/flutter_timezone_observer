package com.flutter_timezone_observer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.time.ZoneId

/**
 * [FlutterPlugin] for the flutter_timezone_observer package.
 *
 * This class handles the native Android implementation for fetching the
 * current timezone and listening for timezone changes.
 */
class FlutterTimezoneObserverPlugin : FlutterPlugin, EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var applicationContext: Context? = null
    private var timezoneReceiver: BroadcastReceiver? = null

    private val METHOD_CHANNEL_NAME = "flutter_timezone_observer/methods"
    private val EVENT_CHANNEL_NAME = "flutter_timezone_observer/events"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                try {
                    val timezone = ZoneId.systemDefault().id
                    result.success(timezone)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get timezone", e.toString())
                }
            } else {
                result.notImplemented()
            }
        }

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        applicationContext = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        timezoneReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_TIMEZONE_CHANGED) {
                    val timezone = ZoneId.systemDefault().id
                    // Send the new timezone to Flutter
                    events?.success(timezone)
                }
            }
        }
        applicationContext?.registerReceiver(
            timezoneReceiver,
            IntentFilter(Intent.ACTION_TIMEZONE_CHANGED)
        )
    }

    override fun onCancel(arguments: Any?) {
        if (timezoneReceiver != null) {
            applicationContext?.unregisterReceiver(timezoneReceiver)
            timezoneReceiver = null
        }
    }
}