package com.vonage.vapp.presentation.converstion

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexmo.client.NexmoClient
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

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun init(navArgs: ConversationsFragmentArgs) {
        this.conversations = navArgs.conversaions.toMutableList()
        this.allUsers = navArgs.allUsers.toList()

        viewActionMutableLiveData.postValue(Action.ShowContent(conversations))
    }

    fun createConversation() {
        viewActionMutableLiveData.postValue(Action.SelectUsers)
    }

    fun createConversation(users: Set<User>) {
        viewActionMutableLiveData.postValue(Action.ShowLoading)

        viewModelScope.launch {
            val userIds = users.map { it.id }.toSet()
            val result = apiRepository.createConversation(userIds)

            if (result is CreateConversationResponseModel) {
                conversations.add(result.conversation)
                viewActionMutableLiveData.postValue(Action.ShowContent(conversations))

                navigateToConversationDetail(result.conversation)
            } else if (result is ErrorResponseModel) {
                viewActionMutableLiveData.postValue(Action.ShowError(result.fullMessage))
            }
        }
    }

    fun navigateToConversationDetail(conversation: Conversation) {
//        val navDirections =
//            ConversationsFragmentDirections.actionConversationsFragmentToConversationDetailFragment(
//                conversation,
//                allUsers.toTypedArray()
//            )
//        NavManager.navigate(navDirections)
    }

    fun loadConversations() {
        viewActionMutableLiveData.postValue(Action.ShowLoading)

        viewModelScope.launch {
            val result = apiRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                this@ConversationsViewModel.conversations = result.conversations.toMutableList()
                val conversation = Action.ShowContent(conversations)
                viewActionMutableLiveData.postValue(conversation)
            } else if (result is ErrorResponseModel) {
                viewActionMutableLiveData.postValue(Action.ShowError(result.fullMessage))
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
