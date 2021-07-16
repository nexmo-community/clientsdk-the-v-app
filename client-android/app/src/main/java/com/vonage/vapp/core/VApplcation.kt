package com.vonage.vapp.core

import android.app.Application
import com.nexmo.client.NexmoClient

class VApplcation : Application() {

    override fun onCreate() {
        super.onCreate()

        initClient()
    }

    private fun initClient() {
        // Init the client, so it can le latter accessed by calling NexmoClient.get()
        NexmoClient.Builder().build(this)
    }
}