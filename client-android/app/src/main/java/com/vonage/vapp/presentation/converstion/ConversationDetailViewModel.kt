package com.vonage.vapp.presentation.converstion

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.*
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.vapp.core.ext.asLiveData
import java.io.File


class ConversationDetailViewModel : ViewModel() {

    // should be injected
    private val client = NexmoClient.get()

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    private var conversation: NexmoConversation? = null

    private val messageListener = object : NexmoMessageEventListener {
        override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}

        override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {

        }

        override fun onTextEvent(textEvent: NexmoTextEvent) {
            val line = getConversationLine(textEvent)
            addConversationLine(line)
        }

        override fun onMessageEvent(messageEvent: NexmoMessageEvent) {
        }

        override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}
        override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}
        override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
        override fun onSubmittedReceipt(submittedEvent: NexmoSubmittedEvent) {}
        override fun onRejectedReceipt(rejectedEvent: NexmoRejectedEvent) {}
        override fun onUndeliverableReceipt(undeliverableEvent: NexmoUndeliverableEvent) {}
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
            val line = when (event) {
                is NexmoMemberEvent -> {
                    getConversationLine(event)
                }
                is NexmoTextEvent -> {
                    getConversationLine(event)
                }
                else -> {
                    null
                }
            }

            line?.let { lines.add(it) }
        }

        // Production-ready application should utilise RecyclerView to provide better UX
        val linesString = if (lines.isNullOrEmpty()) {
            "Conversation has No messages"
        } else {
            lines.joinToString(separator = System.lineSeparator(), postfix = System.lineSeparator())
        }

        viewActionMutableLiveData.postValue(Action.SetConversation(linesString))
    }

    private fun getConversationLine(memberEvent: NexmoMemberEvent): String {
        // Bug in SDK 3.0.1 - embeddedInfo can be null for JOINED events
        val userName = memberEvent.embeddedInfo?.user?.name ?: "Unknown"

        return when (memberEvent.state) {
            NexmoMemberState.JOINED -> "$userName joined"
            NexmoMemberState.INVITED -> "$userName invited"
            NexmoMemberState.LEFT -> "$userName left"
            else -> "Error: Unknown member event state"
        }
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val userName = textEvent.embeddedInfo?.user?.name ?: "Unknown"
        return "$userName said: ${textEvent.text}"
    }

    private fun addConversationLine(line: String?) {
        viewActionMutableLiveData.postValue(Action.AddConversationLine(line + System.lineSeparator()))
    }

    fun sendMessage(message: NexmoMessage) {
        conversation?.sendMessage(message, object : NexmoRequestListener<Void> {
            override fun onSuccess(p0: Void?) {
            }

            override fun onError(apiError: NexmoApiError) {
                viewActionMutableLiveData.postValue(Action.Error(apiError.message))
            }
        })
    }

    fun uploadImage(file: File) {
        client.uploadAttachment(file, object : NexmoRequestListener<NexmoImage> {
            override fun onError(apiError: NexmoApiError) {
                viewActionMutableLiveData.postValue(Action.Error(apiError.message))
            }

            override fun onSuccess(result: NexmoImage?) {
                if (result != null) {
                    sendMessage(NexmoMessage.fromImage(result.original.url))
                } else {
                    viewActionMutableLiveData.postValue(Action.Error("Image wasn't returned on upload"))
                }
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
