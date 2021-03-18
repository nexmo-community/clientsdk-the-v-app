package com.vonage.vapp.presentation

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R

class MainActivity : AppCompatActivity(R.layout.activity_main) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Init the client
        // It can le latte raccessed by calling NexmoClient.get()
        NexmoClient.Builder().build(this)
    }
}