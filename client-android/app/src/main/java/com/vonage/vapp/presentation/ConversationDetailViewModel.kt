package com.vonage.vapp.presentation

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexmo.client.NexmoAttachmentEvent
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoConversation
import com.nexmo.client.NexmoDeletedEvent
import com.nexmo.client.NexmoDeliveredEvent
import com.nexmo.client.NexmoMessageEventListener
import com.nexmo.client.NexmoSeenEvent
import com.nexmo.client.NexmoTextEvent
import com.nexmo.client.NexmoTypingEvent
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.Event
import com.vonage.vapp.data.model.GetConversationResponseModel
import com.vonage.vapp.data.model.User
import kotlinx.coroutines.launch

class ConversationDetailViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val apiRepository = ApiRepository
    private val navManager = NavManager

    private var conversations = mutableListOf<Conversation>()
    private var allUsers = listOf<User>()

    private val viewStateMutableLiveData = MutableLiveData<State>()
    val viewStateLiveData = viewStateMutableLiveData.asLiveData()

    private var nexmoConversation: NexmoConversation? = null
    private var users = listOf<User>()

    private val messageListener = object : NexmoMessageEventListener {
        override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}

        override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}

        override fun onTextEvent(textEvent: NexmoTextEvent) {
            val line = getConversationLine(textEvent)
            addConversationLine(line)
        }

        override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}

        override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}

        override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
    }

    fun initClient(navArgs: ConversationDetailFragmentArgs) {
        this.users = navArgs.users.toList()

        getConversation(navArgs.conversaion.id)
        getNexmoConversation(navArgs.conversaion.id)
    }

    private fun getNexmoConversation(conversationId: String) {
        viewStateMutableLiveData.postValue(State.Loading)

        client.getConversation(conversationId, object : NexmoRequestListener<NexmoConversation> {
            override fun onSuccess(conversation: NexmoConversation?) {
                conversation?.addMessageEventListener(messageListener)

                this@ConversationDetailViewModel.nexmoConversation = conversation
            }

            override fun onError(apiError: NexmoApiError) {
                this@ConversationDetailViewModel.nexmoConversation = null
                viewStateMutableLiveData.postValue(State.Error("NexmoConversation load error"))
            }
        })
    }

    private fun getConversation(conversationId: String) {
        viewStateMutableLiveData.postValue(State.Loading)

        viewModelScope.launch {
            val result = ApiRepository.getConversation(conversationId)

            if (result is GetConversationResponseModel) {
                val events = result.conversation?.events ?: listOf()
                displayConversationEvents(events)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(State.Error("${result.title} - ${result.detail}"))
            }
        }
    }

    private fun displayConversationEvents(events: List<Event>?) {

        val lines = events
            ?.distinctBy { it.id } // Remove duplicated events
            ?.sortedBy { it.timestamp } // Sort events
            ?.map {
                val userDisplayName = getUserDisplayName(it.from)

                val line = when (it.type) {
                    "text" -> "$userDisplayName: ${it.content}"
                    "member:joined" -> "$userDisplayName joined"
                    else -> "${it.type} ${it.content}"
                }

                line
            } ?: listOf()

        viewStateMutableLiveData.postValue(State.SetConversation(lines.joinToString(separator = System.lineSeparator())))
    }

    private fun getUserDisplayName(userId: String): String {
        return users.firstOrNull { it.id == userId }?.displayName ?: "Unknown"
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val user = textEvent.fromMember.user.name
        return "$user said: ${textEvent.text}"
    }

    private fun addConversationLine(line: String?) {
        viewStateMutableLiveData.postValue(State.AddConversationLine(line + System.lineSeparator()))
    }

    fun sendMessage(message: String) {
        nexmoConversation?.sendText(message, object : NexmoRequestListener<Void> {
            override fun onSuccess(p0: Void?) {
            }

            override fun onError(apiError: NexmoApiError) {
                viewStateMutableLiveData.postValue(State.Error(apiError.message))
            }
        })
    }

    sealed class State {
        object Loading : State()
        data class SetConversation(val conversation: String) : State()
        data class AddConversationLine(val line: String) : State()
        data class Error(val message: String) : State()
    }
}