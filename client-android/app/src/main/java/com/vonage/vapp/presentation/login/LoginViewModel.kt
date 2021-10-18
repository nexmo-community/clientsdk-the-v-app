package com.vonage.vapp.presentation.login

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus.*
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.MemoryRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.LoginResponseModel
import kotlinx.coroutines.launch

class LoginViewModel : ViewModel() {
    // should be injected
    private val apiRepository = ApiRepository
    private val navManager = NavManager
    private val client = NexmoClient.get()

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun navigateToSignup() {
        val navDirections = LoginFragmentDirections.actionLoginFragmentToSignupFragment()
        navManager.navigate(navDirections)
    }

    fun login(name: String, password: String) {
        viewModelScope.launch {
            val result = apiRepository.login(name, password)

            if (result is LoginResponseModel) {
                client.setConnectionListener { newConnectionStatus, _ ->
                    if (newConnectionStatus == CONNECTED) {
                        viewActionMutableLiveData.postValue(Action.ShowContent)
                    }
                    return@setConnectionListener
                }
                client.login(MemoryRepository.token)
            } else if (result is ErrorResponseModel) {
                viewActionMutableLiveData.postValue(Action.Error(result.fullMessage))
            }
        }
    }

    fun navigate() {
        val navDirections = LoginFragmentDirections.actionLoginFragmentToConversationsFragment()
        navManager.navigate(navDirections)
    }

    sealed interface Action {
        object ShowContent : Action
        data class Error(val message: String) : Action
    }
}