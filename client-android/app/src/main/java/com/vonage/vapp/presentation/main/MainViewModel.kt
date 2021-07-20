package com.vonage.vapp.presentation.main

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus.*
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.MemoryRepository

class MainViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val navManager = NavManager

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    private val memoryRepository = MemoryRepository

    fun init() {
        if(client.isConnected) {
            viewActionMutableLiveData.postValue(Action.ShowContent)
        } else {
            viewActionMutableLiveData.postValue(Action.ShowLoading)

            client.setConnectionListener { newConnectionStatus, _ ->
                if (newConnectionStatus == CONNECTED) {
                    viewActionMutableLiveData.postValue(Action.ShowContent)
                }

                return@setConnectionListener
            }

            client.login(memoryRepository.token)
        }
    }

    fun navigateToConversations() {
        val navDirections = MainFragmentDirections.actionMainFragmentToConversationsFragment()
        NavManager.navigate(navDirections)
    }

    fun navigateToUsers() {
        val navDirections = MainFragmentDirections.actionMainFragmentToUsersFragment()
        NavManager.navigate(navDirections)
    }

    sealed interface Action {
        object ShowLoading : Action
        object ShowContent : Action
        data class ShowError(val message: String) : Action
    }

    override fun onCleared() {
        super.onCleared()
        client.logout()
    }
}
