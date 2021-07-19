package com.vonage.vapp.presentation.user

import android.annotation.SuppressLint
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.core.CallManager
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.CreateConversationResponseModel
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.User
import com.vonage.vapp.presentation.user.UserDetailViewModel.Action.ShowError
import kotlinx.coroutines.launch

class UserDetailViewModel : ViewModel() {
    private lateinit var user: User

    // Should be injected
    private val client = NexmoClient.get()
    private val callManager = CallManager
    private val navManager = NavManager

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    private val apiRepository = ApiRepository

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
            viewActionMutableLiveData.postValue(ShowError(apiError.message))
        }
    }

    private fun createConversation(user: User) {
        viewActionMutableLiveData.postValue(Action.ShowLoading)

        viewModelScope.launch {
            val userIds = setOf(user.id)
            val result = apiRepository.createConversation(userIds)

            if (result is CreateConversationResponseModel) {
                val navDirections = UserDetailFragmentDirections.actionUserDetailFragmentToConversationDetailFragment(result.conversation)
                NavManager.navigate(navDirections)
            } else if (result is ErrorResponseModel) {
                viewActionMutableLiveData.postValue(ShowError(result.fullMessage))
            }
        }
    }

    @SuppressLint("MissingPermission")
    fun startCall() {
        viewActionMutableLiveData.postValue(Action.ShowLoading)
        client.call(user.name, NexmoCallHandler.IN_APP, callListener)
    }

    fun startConversation() {
        createConversation(user)
    }

    sealed class Action {
        data class ShowContent(val user: User) : Action()
        object ShowLoading : Action()
        data class ShowError(val message: String) : Action()
    }
}
