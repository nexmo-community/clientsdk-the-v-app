package com.vonage.vapp.presentation

import android.os.Bundle
import androidx.fragment.app.Fragment
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
import com.vonage.vapp.Config
import com.vonage.vapp.R
import kotlinx.android.synthetic.main.fragment_conversation.*

class ConversationFragment : Fragment(R.layout.fragment_conversation) {
    private val client: NexmoClient = NexmoClient.get()

    private var conversation: NexmoConversation? = null

    private val messageListener = object : NexmoMessageEventListener {
        override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}

        override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}

        override fun onTextEvent(textEvent: NexmoTextEvent) {
            val line = getConversationLine(textEvent)
            displayConversationLine(line)
        }

        override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}

        override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}

        override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        getConversation()

        sendMessageButton.setOnClickListener {
            val message = messageEditText.text.toString()

            if(message.isNotBlank()) {
                conversation?.sendText(message, object : NexmoRequestListener<Void> {
                    override fun onSuccess(p0: Void?) {
                    }

                    override fun onError(apiError: NexmoApiError) {
                    }
                })
            }

            messageEditText.setText("")
        }
    }

    private fun getConversation() {
        client.getConversation(Config.CONVERSATION_ID, object : NexmoRequestListener<NexmoConversation> {
            override fun onSuccess(conversation: NexmoConversation?) {
                this@ConversationFragment.conversation = conversation

                conversation?.let {
                    getConversationEvents(it)
                    it.addMessageEventListener(messageListener)
                }
            }

            override fun onError(apiError: NexmoApiError) {
                this@ConversationFragment.conversation = null
            }
        })
    }

    private fun getConversationEvents(conversation: NexmoConversation) {
        conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
            object : NexmoRequestListener<NexmoEventsPage> {
                override fun onSuccess(nexmoEventsPage: NexmoEventsPage?) {
                    val events = nexmoEventsPage?.pageResponse?.data
                    displayConversationEvents(events)
                }

                override fun onError(apiError: NexmoApiError) {
                }
            })
    }

    private fun displayConversationEvents(events: MutableCollection<NexmoEvent>?) {
        events?.forEach {
            val line = when (it) {
                is NexmoMemberEvent -> getConversationLine(it)
                is NexmoTextEvent -> getConversationLine(it)
                else -> null
            }

            displayConversationLine(line)
        }
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val user = textEvent.fromMember.user.name
        return "$user said: ${textEvent.text}"
    }

    private fun getConversationLine(memberEvent: NexmoMemberEvent): String {
        val user = memberEvent.member.user.name

        return when (memberEvent.state) {
            NexmoMemberState.JOINED -> "$user joined"
            NexmoMemberState.INVITED -> "$user invited"
            NexmoMemberState.LEFT -> "$user left"
            else -> "Error: Unknown member event state"
        }
    }

    private fun displayConversationLine(line: String?) {
        line?.let { conversationEventsTextView.append(it + System.lineSeparator()) }
    }
}