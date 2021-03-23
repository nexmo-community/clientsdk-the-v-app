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
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.Event
import com.vonage.vapp.data.model.GetConversationResponseModel
import com.vonage.vapp.data.model.User
import kotlinx.coroutines.launch

class ConversationDetailViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val adiRepository = ApiRepository

    private val viewStateMutableLiveData = MutableLiveData<Action>()
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
        viewStateMutableLiveData.postValue(Action.Loading)

        client.getConversation(conversationId, object : NexmoRequestListener<NexmoConversation> {
            override fun onSuccess(conversation: NexmoConversation?) {
                conversation?.addMessageEventListener(messageListener)

                this@ConversationDetailViewModel.nexmoConversation = conversation
            }

            override fun onError(apiError: NexmoApiError) {
                this@ConversationDetailViewModel.nexmoConversation = null
                viewStateMutableLiveData.postValue(Action.Error("NexmoConversation load error"))
            }
        })
    }

    private fun getConversation(conversationId: String) {
        viewStateMutableLiveData.postValue(Action.Loading)

        viewModelScope.launch {
            val result = adiRepository.getConversation(conversationId)

            if (result is GetConversationResponseModel) {
                val events = result.conversation?.events ?: listOf()
                displayConversationEvents(events)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(Action.Error(result.fullMessage))
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

        val linesString = lines.joinToString(separator = System.lineSeparator(), postfix = System.lineSeparator())
        viewStateMutableLiveData.postValue(Action.SetConversation(linesString))
    }

    private fun getUserDisplayName(userId: String): String {
        return users.firstOrNull { it.id == userId }?.displayName ?: "Unknown"
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val user = textEvent.fromMember.user.displayName
        return "$user said: ${textEvent.text}"
    }

    private fun addConversationLine(line: String?) {
        viewStateMutableLiveData.postValue(Action.AddConversationLine(line + System.lineSeparator()))
    }

    fun sendMessage(message: String) {
        nexmoConversation?.sendText(message, object : NexmoRequestListener<Void> {
            override fun onSuccess(p0: Void?) {
            }

            override fun onError(apiError: NexmoApiError) {
                viewStateMutableLiveData.postValue(Action.Error(apiError.message))
            }
        })
    }

    sealed class Action {
        object Loading : Action()
        data class SetConversation(val conversation: String) : Action()
        data class AddConversationLine(val line: String) : Action()
        data class Error(val message: String) : Action()
    }
}