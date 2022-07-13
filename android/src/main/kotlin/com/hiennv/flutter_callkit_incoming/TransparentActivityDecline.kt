package com.hiennv.flutter_callkit_incoming

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log

class TransparentActivityDecline : Activity() {

    companion object {
        fun getIntentDecline(context: Context, data: Bundle?): Intent {
            val declineIntent = Intent(context, TransparentActivityDecline::class.java)
            declineIntent.putExtra("data", data)
            declineIntent.putExtra("type", "DECLINE")
            declineIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            declineIntent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            return declineIntent
        }

    }


    override fun onStart() {
        super.onStart()
        setVisible(true)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.getStringExtra("type")) {
            "DECLINE" -> {
                val data = intent.getBundleExtra("data")
                val declineIntent = CallkitIncomingBroadcastReceiver.getIntentDecline(this@TransparentActivityDecline, data)
                sendBroadcast(declineIntent)
            }
            else -> { // Note the block
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallkitIncomingBroadcastReceiver.getIntentAccept(this@TransparentActivityDecline, data)
                sendBroadcast(acceptIntent)
            }
        }
        finish()
        overridePendingTransition(0, 0)
    }
}