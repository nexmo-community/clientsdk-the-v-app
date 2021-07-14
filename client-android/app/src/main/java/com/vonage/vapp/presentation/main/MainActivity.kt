package com.vonage.vapp.presentation.main

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.navigateSafe

class MainActivity : AppCompatActivity(R.layout.activity_main) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initClient()
        initNavManager()
    }

    private fun initClient() {
        // Init the client
        // It can le latter accessed by calling NexmoClient.get()

        NexmoClient.Builder().build(this)
    }

    private fun initNavManager() {
        NavManager.setOnNavEvent {
            val navHostFragment = supportFragmentManager.findFragmentById(R.id.navHostFragment)
            val currentFragment = navHostFragment?.childFragmentManager?.fragments?.get(0)

            currentFragment?.navigateSafe(it)
        }
    }
}