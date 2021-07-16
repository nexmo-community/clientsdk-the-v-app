package com.vonage.vapp.presentation.main

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus.*
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.User

class MainViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val navManager = NavManager

    private var conversations = mutableListOf<Conversation>()
    private var allUsers = listOf<User>()
    private var otherUsers = listOf<User>()

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun initClient(navArgs: MainFragmentArgs) {

        this.conversations = navArgs.conversations.toMutableList()
        this.otherUsers = navArgs.otherUsers.toList()

        if (client.isConnected) {
            viewActionMutableLiveData.postValue(Action.ShowContent)
        } else {
            viewActionMutableLiveData.postValue(Action.ShowLoading)
            client.login(navArgs.token)
        }

        client.setConnectionListener { newConnectionStatus, _ ->
            when (newConnectionStatus) {
                CONNECTED -> {
                    viewActionMutableLiveData.postValue(Action.ShowContent)
                }
                DISCONNECTED -> {
                    navManager.popBackStack()
                }
            }

            return@setConnectionListener
        }
    }

    fun navigateToConversations() {
        val navDirections = MainFragmentDirections.actionMainFragmentToConversationsFragment(
            conversations.toTypedArray(),
            otherUsers.toTypedArray(),
            allUsers.toTypedArray()
        )
        NavManager.navigate(navDirections)
    }

    fun navigateToUsers() {
        val navDirections = MainFragmentDirections.actionMainFragmentToUsersFragment(otherUsers.toTypedArray())
        NavManager.navigate(navDirections)
    }

    sealed class Action {
        object ShowLoading : Action()
        object ShowContent : Action()
        data class ShowError(val message: String) : Action()
    }

    fun onBackPressed() {
//        dispose()
    }

    override fun onCleared() {
        super.onCleared()
        dispose()
    }

    private fun dispose() {
        client.logout()
    }
}
