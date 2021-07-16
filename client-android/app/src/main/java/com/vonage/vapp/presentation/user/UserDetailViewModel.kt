package com.vonage.vapp.presentation.user

import android.annotation.SuppressLint
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.core.CallManager
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.model.User

class UserDetailViewModel : ViewModel() {
    private lateinit var user: User

    // Should be injected
    private val client = NexmoClient.get()
    private val callManager = CallManager
    private val navManager = NavManager

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun init(navArgs: UserDetailFragmentArgs) {
        user = navArgs.user
        viewActionMutableLiveData.postValue(Action.ShowContent(navArgs.user))
    }

    private val callListener = object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            callManager.onGoingCall = call

            viewActionMutableLiveData.postValue(Action.ShowContent(user))

            val navDirections = UserDetailFragmentDirections.actionUserDetailFragmentToOnCallFragment()
            navManager.navigate(navDirections)
        }

        override fun onError(apiError: NexmoApiError) {
            viewActionMutableLiveData.postValue(Action.ShowError(apiError.message))
        }
    }

    @SuppressLint("MissingPermission")
    fun startCall() {
        viewActionMutableLiveData.postValue(Action.ShowLoading)
        client.call(user.name, NexmoCallHandler.IN_APP, callListener)
    }

    fun startConversation() {
        TODO("not implemented")
    }

    sealed class Action {
        data class ShowContent(val user: User) : Action()
        object ShowLoading : Action()
        data class ShowError(val message: String) : Action()
    }
}
