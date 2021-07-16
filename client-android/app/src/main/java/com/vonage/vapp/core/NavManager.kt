package com.vonage.vapp.core

import android.os.Handler
import android.os.Looper
import androidx.navigation.NavDirections

object NavManager {

    private var navEventListener: ((navDirections: NavDirections) -> Unit)? = null
    private var popBackListener: (() -> Unit)? = null

    fun navigate(navDirections: NavDirections) {
        runOnUiThread { navEventListener?.invoke(navDirections) }
    }

    fun popBackStack() {
        runOnUiThread { popBackListener?.invoke() }
    }

    fun setOnNavEvent(listener: (navDirections: NavDirections) -> Unit) {
        this.navEventListener = listener
    }

    fun setOnPopBack(listener: () -> Unit) {
        this.popBackListener = listener
    }

    // Nexmo SDK may fire callbacks on other thread, so it's safe to always use UI Thread
    private fun runOnUiThread(action: Runnable) {
        val mainHandler: Handler = Handler(Looper.getMainLooper())

        val runnable = Runnable {
            action.run()
        }

        mainHandler.post(runnable)
    }
}
