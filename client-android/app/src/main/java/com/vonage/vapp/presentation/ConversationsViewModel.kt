package com.vonage.vapp.presentation

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.CreateConversationResponseModel
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.data.model.User
import kotlinx.coroutines.launch

class ConversationsViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val apiRepository = ApiRepository

    private var conversations = mutableListOf<Conversation>()
    private var allUsers = listOf<User>()

    private val viewStateMutableLiveData = MutableLiveData<Action>()
    val viewStateLiveData = viewStateMutableLiveData.asLiveData()

    fun initClient(navArgs: ConversationsFragmentArgs) {

        this.conversations = navArgs.conversations?.toMutableList()
        this.allUsers = (navArgs.users + navArgs.user).toList()


        if (!client.isConnected) {
            viewStateMutableLiveData.postValue(Action.ShowLoading)

            client.setConnectionListener { newConnectionStatus, _ ->

                if (newConnectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                    val conversation = Action.ShowContent(navArgs.conversations.toList())
                    viewStateMutableLiveData.postValue(conversation)
                }

                return@setConnectionListener
            }
        }

        client.login(navArgs.token)
    }

    fun createConversation() {
        viewStateMutableLiveData.postValue(Action.SelectUsers)
    }

    fun createConversation(users: Set<User>) {
        viewStateMutableLiveData.postValue(Action.ShowLoading)

        viewModelScope.launch {
            val userIds = users.map { it.id }.toSet()
            val result = apiRepository.createConversation(userIds)

            if (result is CreateConversationResponseModel) {
                conversations.add(result.conversation)
                viewStateMutableLiveData.postValue(Action.ShowContent(conversations))

                navigateToConversation(result.conversation)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(Action.ShowError(result.fullMessage))
            }
        }
    }

    fun navigateToConversation(conversation: Conversation) {
        val navDirections =
            ConversationsFragmentDirections.actionConversationsFragmentToConversationDetailFragment(
                conversation,
                allUsers.toTypedArray()
            )
        NavManager.navigate(navDirections)
    }

    fun loadConversations() {
        viewStateMutableLiveData.postValue(Action.ShowLoading)

        viewModelScope.launch {
            val result = apiRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                this@ConversationsViewModel.conversations = result.conversations.toMutableList()
                val conversation = Action.ShowContent(conversations)
                viewStateMutableLiveData.postValue(conversation)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(Action.ShowError(result.fullMessage))
            }
        }
    }

    sealed class Action {
        object ShowLoading : Action()
        data class ShowContent(val conversations: List<Conversation>) : Action()
        object SelectUsers : Action()
        data class ShowError(val message: String) : Action()
    }
}
