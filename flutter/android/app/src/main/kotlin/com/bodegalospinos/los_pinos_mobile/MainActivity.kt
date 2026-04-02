package com.bodegalospinos.los_pinos_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val EVENT_CHANNEL = "com.bodegalospinos.los_pinos_mobile/scanner_events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var receiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    receiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context?, intent: Intent?) {
                            if (intent == null || events == null) return
                            val data = HashMap<String, String>()
                            
                            // Map all extras to a hashmap
                            val extras = intent.extras
                            if (extras != null) {
                                for (key in extras.keySet()) {
                                    val value = extras.get(key)
                                    if (value != null) {
                                        data[key] = value.toString()
                                    }
                                }
                            }
                            events.success(data)
                        }
                    }

                    val filter = IntentFilter()
                    filter.addCategory(Intent.CATEGORY_DEFAULT)
                    
                    // Add common scanner actions
                    filter.addAction("com.android.scanner.ACTION_DECODE") // Intermec/Honeywell
                    filter.addAction("com.symbol.datawedge.api.ACTION") // Zebra Default
                    filter.addAction("com.bodegalospinos.SCAN") // Our custom action for Zebra
                    filter.addAction("com.symbol.datawedge.api.RESULT_ACTION") // Zebra Results
                    filter.addAction("android.intent.ACTION_DECODE_DATA") // Generic
                    filter.addAction("device.scanner.emit") // Sunmi sometimes
                    filter.addAction("unitech.scanservice.data") // Unitech
                    filter.addAction("com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED") // Sunmi

                    context.registerReceiver(receiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    if (receiver != null) {
                        context.unregisterReceiver(receiver)
                        receiver = null
                    }
                }
            }
        )
    }
}
