package com.vonage.vapp.presentation.converstion

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoAttachmentEvent
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoConversation
import com.nexmo.client.NexmoDeletedEvent
import com.nexmo.client.NexmoDeliveredEvent
import com.nexmo.client.NexmoEvent
import com.nexmo.client.NexmoEventsPage
import com.nexmo.client.NexmoMemberEvent
import com.nexmo.client.NexmoMemberState
import com.nexmo.client.NexmoMessageEventListener
import com.nexmo.client.NexmoPageOrder
import com.nexmo.client.NexmoSeenEvent
import com.nexmo.client.NexmoTextEvent
import com.nexmo.client.NexmoTypingEvent
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.MemoryRepository

class ConversationDetailViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()
    private val adiRepository = ApiRepository

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    private val memoryRepository = MemoryRepository
    private var conversation: NexmoConversation? = null

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

    fun init(navArgs: ConversationDetailFragmentArgs) {
        getConversation(navArgs.conversaion.id)
    }

    private fun getConversation(conversationId: String) {
        viewActionMutableLiveData.postValue(Action.Loading)

        client.getConversation(conversationId, object : NexmoRequestListener<NexmoConversation> {
            override fun onSuccess(conversation: NexmoConversation?) {
                conversation?.addMessageEventListener(messageListener)
                this@ConversationDetailViewModel.conversation = conversation
                conversation?.let { getConversationEvents(it) }
            }

            override fun onError(apiError: NexmoApiError) {
                this@ConversationDetailViewModel.conversation = null
                viewActionMutableLiveData.postValue(Action.Error("NexmoConversation load error"))
            }
        })
    }

    private fun getConversationEvents(conversation: NexmoConversation) {
        conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
            object : NexmoRequestListener<NexmoEventsPage> {
                override fun onSuccess(nexmoEventsPage: NexmoEventsPage?) {
                    nexmoEventsPage?.pageResponse?.data?.let {
                        displayConversationEvents(it.toList())
                    }
                }

                override fun onError(apiError: NexmoApiError) {
                    viewActionMutableLiveData.postValue(
                        Action.Error("Error: Unable to load conversation events ${apiError.message}")
                    )
                }
            })
    }

    private fun displayConversationEvents(events: List<NexmoEvent>) {
        val lines = ArrayList<String>()

        for (event in events) {
            var line = ""

            when (event) {
                is NexmoMemberEvent -> {
                    val userName = event.embeddedInfo.user.name

                    line = when (event.state) {
                        NexmoMemberState.JOINED -> "$userName joined"
                        NexmoMemberState.INVITED -> "$userName invited"
                        NexmoMemberState.LEFT -> "$userName left"
                        NexmoMemberState.UNKNOWN -> "Error: Unknown member event state"
                    }
                }
                is NexmoTextEvent -> {
                    line = "${event.embeddedInfo.user.name} said: ${event.text}"
                }
            }
            lines.add(line)
        }

        // Production application should utilise RecyclerView to provide better UX
        val linesString = if (lines.isNullOrEmpty()) {
            "Conversation has No messages"
        } else {
            lines.joinToString(separator = System.lineSeparator(), postfix = System.lineSeparator())
        }

        viewActionMutableLiveData.postValue(Action.SetConversation(linesString))
    }

    private fun getUserDisplayName(userId: String): String {
        return memoryRepository.allUsers.firstOrNull { it.id == userId }?.displayName ?: "Unknown"
    }

    private fun getConversationLine(memberEvent: NexmoMemberEvent): String {
        val user = memberEvent.embeddedInfo.user.name

        return when (memberEvent.state) {
            NexmoMemberState.JOINED -> "$user joined"
            NexmoMemberState.INVITED -> "$user invited"
            NexmoMemberState.LEFT -> "$user left"
            else -> "Error: Unknown member event state"
        }
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val user = textEvent.embeddedInfo.user.name
        return "$user said: ${textEvent.text}"
    }

    private fun addConversationLine(line: String?) {
        viewActionMutableLiveData.postValue(Action.AddConversationLine(line + System.lineSeparator()))
    }

    fun sendMessage(message: String) {
        conversation?.sendText(message, object : NexmoRequestListener<Void> {
            override fun onSuccess(p0: Void?) {
            }

            override fun onError(apiError: NexmoApiError) {
                viewActionMutableLiveData.postValue(Action.Error(apiError.message))
            }
        })
    }

    sealed interface Action {
        object Loading : Action
        data class SetConversation(val conversation: String) : Action
        data class AddConversationLine(val line: String) : Action
        data class Error(val message: String) : Action
    }
}
