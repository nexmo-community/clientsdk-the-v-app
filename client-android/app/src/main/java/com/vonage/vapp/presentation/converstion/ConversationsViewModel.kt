package com.vonage.vapp.presentation.converstion

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.MemoryRepository
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.CreateConversationResponseModel
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.data.model.User
import kotlinx.coroutines.launch

class ConversationsViewModel : ViewModel() {

    // should be injected
    private val apiRepository = ApiRepository
    private val memoryRepository = MemoryRepository

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun init() {
        viewActionMutableLiveData.postValue(Action.ShowContent(memoryRepository.conversations))
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
                viewActionMutableLiveData.postValue(Action.ShowContent(memoryRepository.conversations))
                navigateToConversationDetail(result.conversation)
            } else if (result is ErrorResponseModel) {
                viewActionMutableLiveData.postValue(Action.ShowError(result.fullMessage))
            }
        }
    }

    fun navigateToConversationDetail(conversation: Conversation) {
        val navDirections = ConversationsFragmentDirections.actionConversationsFragmentToConversationDetailFragment(conversation)
        NavManager.navigate(navDirections)
    }

    fun loadConversations() {
        viewActionMutableLiveData.postValue(Action.ShowLoading)

        viewModelScope.launch {
            val result = apiRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                val conversation = Action.ShowContent(result.conversations)
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
