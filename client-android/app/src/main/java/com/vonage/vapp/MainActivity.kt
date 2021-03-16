package com.vonage.vapp

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoConnectionState
import com.nexmo.client.request_listener.NexmoConnectionListener
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    private lateinit var client: NexmoClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        client = NexmoClient.Builder().build(this)

        loginAsIgorButton.setOnClickListener {
            client.login(Config.igor.jwt)
        }

        client.setConnectionListener { newConnectionStatus, _ ->

            if (newConnectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                val intent = Intent(this, ChatActivity::class.java)
                startActivity(intent)
                return@setConnectionListener
            }

            runOnUiThread {
                connectionStatusTextView.text = newConnectionStatus.toString()
            }
        }
    }
}
