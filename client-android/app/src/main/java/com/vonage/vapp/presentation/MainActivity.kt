package com.vonage.vapp.presentation

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener
import com.vonage.vapp.R
import com.vonage.vapp.data.BackendRepository
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    private lateinit var client: NexmoClient
    private val backendRepository = BackendRepository()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
