package com.vonage.vapp.core

import android.os.Handler
import android.os.Looper
import androidx.annotation.IdRes
import androidx.navigation.NavDirections

object NavManager {

    private var navEventListener: ((navDirections: NavDirections) -> Unit)? = null
    private var popBackListener: ((destinationId: Int?, inclusive: Boolean?) -> Unit)? = null

    fun navigate(navDirections: NavDirections) {
        navEventListener?.invoke(navDirections)
}
    fun popBackStack(@IdRes destinationId: Int? = null, inclusive: Boolean? = null) {
        popBackListener?.invoke(destinationId, inclusive);
    }

    fun setOnNavEvent(listener: (navDirections: NavDirections) -> Unit) {
        this.navEventListener = listener
    }

    fun setOnPopBack(listener: (destinationId: Int?, inclusive: Boolean?) -> Unit) {
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
