package com.vonage.vapp.presentation

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R

class MainActivity : AppCompatActivity() {

    private lateinit var client: NexmoClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
