package com.vonage.vapp.presentation.main

import android.Manifest
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.navigation.Navigation
import androidx.navigation.fragment.findNavController
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R
import com.vonage.vapp.core.BackPressHandler
import com.vonage.vapp.core.CallManager
import com.vonage.vapp.core.NavManager

class MainActivity : AppCompatActivity(R.layout.activity_main) {

    private val navController by lazy { Navigation.findNavController(this, R.id.navHostFragment) }
    private val callManager: CallManager = CallManager

    // Client initialized in the VApplication class
    private val client = NexmoClient.get()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestPermissions()
        initNavManager()
        iniClientListeners()
    }

    private fun requestPermissions() {
        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)
    }

    private fun initNavManager() {
        NavManager.setOnNavEvent {
            val navHostFragment = supportFragmentManager.findFragmentById(R.id.navHostFragment)
            val currentFragment = navHostFragment?.childFragmentManager?.fragments?.get(0)
            currentFragment?.findNavController()?.navigate(it)
        }

        NavManager.setOnPopBack { destinationId , inclusive ->
            if(destinationId != null && inclusive != null) {
                navController.popBackStack(destinationId, inclusive)
            } else {
                navController.popBackStack()
            }
        }

        navController.addOnDestinationChangedListener { controller, destination, arguments ->
            Log.d("MainActivity", "NavDestination us ${destination.label}")
        }

        runOnUiThread { }
    }

    private fun iniClientListeners() {
        client.addIncomingCallListener {
            callManager.onGoingCall = it
            navController.navigate(R.id.action_global_incomingCallFragment)
        }
    }

    override fun onBackPressed() {
        val childFragmentManager = supportFragmentManager.primaryNavigationFragment?.childFragmentManager
        val currentNavigationFragment = childFragmentManager?.fragments?.first()

        if (currentNavigationFragment is BackPressHandler) {
            currentNavigationFragment.onBackPressed()
        }

        super.onBackPressed()
    }
}