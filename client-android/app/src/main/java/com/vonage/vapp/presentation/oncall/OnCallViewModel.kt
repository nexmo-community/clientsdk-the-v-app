package com.vonage.tutorial.voice

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.*
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.core.CallManager

class OnCallViewModel : ViewModel() {
    private val callManager = CallManager

    private val _toast = MutableLiveData<String>()
    val toast = _toast as LiveData<String>

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(nexmoCallStatus: NexmoCallMemberStatus, callMember: NexmoMember) {
            if (nexmoCallStatus == NexmoCallMemberStatus.COMPLETED || nexmoCallStatus == NexmoCallMemberStatus.CANCELLED) {
                callManager.onGoingCall = null
            }
        }

        override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}

        override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}

        override fun onDTMF(dtmf: String, callMember: NexmoMember) {}
        override fun onLegTransfer(event: NexmoLegTransferEvent?, member: NexmoMember?) {}
    }

    init {
        val onGoingCall = checkNotNull(callManager.onGoingCall) { "Call is null" }
        onGoingCall.addCallEventListener(callEventListener)
    }

    override fun onCleared() {
        super.onCleared()

        callManager.onGoingCall?.removeCallEventListener(callEventListener)
    }

    fun onBackPressed() {
        hangupInternal()
    }

    fun hangup() {
        hangupInternal()
    }

    private fun hangupInternal() {
        callManager.onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                callManager.onGoingCall = null
            }

            override fun onError(apiError: NexmoApiError) {
                _toast.postValue(apiError.message)
            }
        })
    }
}
