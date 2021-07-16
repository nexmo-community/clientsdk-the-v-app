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
        this.otherUsers = navArgs.otherUsers.toList().filter {
            it.name == "alamakota" || it.name == "testtest"
        }

        viewActionMutableLiveData.postValue(Action.ShowLoading)

        client.setConnectionListener { newConnectionStatus, _ ->
            when (newConnectionStatus) {
                CONNECTED -> {
                    viewActionMutableLiveData.postValue(Action.ShowContent)
                }
            }

            return@setConnectionListener
        }

        client.login(navArgs.token)
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

    override fun onCleared() {
        super.onCleared()
        client.logout()
    }
}
