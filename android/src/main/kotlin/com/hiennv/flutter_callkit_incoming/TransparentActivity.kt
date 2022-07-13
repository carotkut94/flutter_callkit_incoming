package com.hiennv.flutter_callkit_incoming

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log

class TransparentActivity : Activity() {

    companion object {

        fun getIntentAccept(context: Context, data: Bundle?): Intent {
            val intent = Intent(context, TransparentActivity::class.java)
            intent.putExtra("data", data)
            intent.putExtra("type", "ACCEPT")
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            return intent
        }

        fun getIntentCallback(context: Context, data: Bundle?): Intent {
            val intent = Intent(context, TransparentActivity::class.java)
            intent.putExtra("data", data)
            intent.putExtra("type", "CALLBACK")
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            return intent
        }

        fun getIntentDecline(context: Context, data: Bundle?): Intent {
            val declineIntent = Intent(context, TransparentActivity::class.java)
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
            "ACCEPT" -> {
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallkitIncomingBroadcastReceiver.getIntentAccept(this@TransparentActivity, data)
                sendBroadcast(acceptIntent)
            }
            "CALLBACK" -> {
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallkitIncomingBroadcastReceiver.getIntentCallback(this@TransparentActivity, data)
                sendBroadcast(acceptIntent)
            }
            "DECLINE" -> {
                val data = intent.getBundleExtra("data")
                val declineIntent = CallkitIncomingBroadcastReceiver.getIntentDecline(this@TransparentActivity, data)
                sendBroadcast(declineIntent)
            }
            else -> { // Note the block
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallkitIncomingBroadcastReceiver.getIntentAccept(this@TransparentActivity, data)
                sendBroadcast(acceptIntent)
            }
        }
        finish()
        overridePendingTransition(0, 0)
    }
}