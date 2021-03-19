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

class ConversationViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val apiRepository = ApiRepository
    private val navManager = NavManager

    private var conversations = mutableListOf<Conversation>()
    private var allUsers = listOf<User>()

    private val viewStateMutableLiveData = MutableLiveData<State>()
    val viewStateLiveData = viewStateMutableLiveData.asLiveData()

    fun initClient(navArgs: ConversationsFragmentArgs) {

        this.conversations = navArgs.conversations.toMutableList()
        this.allUsers = (navArgs.users + navArgs.user).toList()


        if (!client.isConnected) {
            viewStateMutableLiveData.postValue(State.Loading)

            client.setConnectionListener { newConnectionStatus, _ ->

                if (newConnectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                    val conversation = State.Content(navArgs.conversations.toList())
                    viewStateMutableLiveData.postValue(conversation)
                }

                return@setConnectionListener
            }
        }

        client.login(navArgs.token)
    }

    fun createConversation() {
        viewStateMutableLiveData.postValue(State.SelectUsers)
    }

    fun createConversation(users: Set<User>) {
        viewStateMutableLiveData.postValue(State.Loading)

        viewModelScope.launch {
            val userIds = users.map { it.id }.toSet()
            val result = apiRepository.createConversation(userIds)

            if (result is CreateConversationResponseModel) {
                conversations.add(result.conversation)
                viewStateMutableLiveData.postValue(State.Content(conversations))

                navigateToConversation(result.conversation)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(State.Error("${result.title} - ${result.detail}"))
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
        viewStateMutableLiveData.postValue(State.Loading)

        viewModelScope.launch {
            val result = apiRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                this@ConversationViewModel.conversations = result.conversations.toMutableList()
                val conversation = State.Content(conversations)
                viewStateMutableLiveData.postValue(conversation)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(State.Error("${result.title} - ${result.detail}"))
            }
        }
    }

    sealed class State {
        object Loading : State()
        data class Content(val conversations: List<Conversation>) : State()
        object SelectUsers : State()
        data class Error(val message: String) : State()
    }
}
