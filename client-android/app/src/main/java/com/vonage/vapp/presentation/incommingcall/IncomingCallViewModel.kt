package com.vonage.vapp.presentation.incommingcall

import android.annotation.SuppressLint
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.R
import com.vonage.vapp.core.CallManager
import com.vonage.vapp.core.NavManager

class IncomingCallViewModel : ViewModel() {
    private val navManager: NavManager = NavManager
    private val callManager: CallManager = CallManager

    private val _toast = MutableLiveData<String>()
    var toast: LiveData<String> = _toast

    fun hangup() {
        hangupInternal()
    }

    @SuppressLint("MissingPermission")
    fun answer() {
        callManager.onGoingCall?.answer(object : NexmoRequestListener<NexmoCall?> {
            override fun onSuccess(call: NexmoCall?) {
                val navDirections = IncomingCallFragmentDirections.actionIncomingCallFragmentToOnCallFragment()
                navManager.navigate(navDirections)
            }

            override fun onError(apiError: NexmoApiError) {
                _toast.postValue(apiError.message)
            }
        })
    }

    fun onBackPressed() {
        hangupInternal()
    }

    private fun hangupInternal() {
        callManager.onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                callManager.onGoingCall = null
                navManager.popBackStack()
            }

            override fun onError(apiError: NexmoApiError) {
                _toast.postValue(apiError.message)
            }
        })
    }
}