package com.vonage.vapp.core

import androidx.annotation.IdRes
import androidx.navigation.NavDirections

object NavManager {

    private var navEventListener: ((navDirections: NavDirections) -> Unit)? = null
    private var popBackListener: ((destinationId: Int, inclusive: Boolean) -> Unit)? = null

    fun navigate(navDirections: NavDirections) {
        navEventListener?.invoke(navDirections)
    }

    fun setOnNavEvent(listener: (navDirections: NavDirections) -> Unit) {
        this.navEventListener = listener
    }

    fun setOnPopBack(listener: (destinationId: Int, inclusive: Boolean) -> Unit) {
        this.popBackListener = listener
    }

    fun popBackStack(@IdRes destinationId: Int, inclusive: Boolean) {
        popBackListener?.invoke(destinationId, inclusive)
    }
}
