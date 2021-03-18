package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
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
import com.vonage.vapp.R
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.Event
import com.vonage.vapp.data.model.GetConversationResponseModel
import com.vonage.vapp.databinding.FragmentConversationBinding
import com.vonage.vapp.utils.viewBinding
import kotlinx.coroutines.launch

class ConversationFragment : Fragment(R.layout.fragment_conversation) {
    private val client: NexmoClient = NexmoClient.get()

    private var nexmoConversation: NexmoConversation? = null

    private val binding: FragmentConversationBinding by viewBinding()
    private val navArgs: ConversationFragmentArgs by navArgs()

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

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        getConversation()
        getNexmoConversation()

        binding.sendMessageButton.setOnClickListener {
            val message = binding.messageEditText.text.toString()

            if (message.isNotBlank()) {
                nexmoConversation?.sendText(message, object : NexmoRequestListener<Void> {
                    override fun onSuccess(p0: Void?) {
                    }

                    override fun onError(apiError: NexmoApiError) {
                    }
                })
            }

            binding.messageEditText.setText("")
        }
    }

    private fun getNexmoConversation() {
        binding.progressBar.visibility = View.VISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        client.getConversation(navArgs.conversaion.id, object : NexmoRequestListener<NexmoConversation> {
            override fun onSuccess(conversation: NexmoConversation?) {
                conversation?.addMessageEventListener(messageListener)

                this@ConversationFragment.nexmoConversation = conversation
            }

            override fun onError(apiError: NexmoApiError) {
                this@ConversationFragment.nexmoConversation = null
            }
        })
    }

    private fun getConversation() {
        binding.progressBar.visibility = View.VISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        lifecycleScope.launch {
            val result = ApiRepository.getConversation(navArgs.conversaion.id)

            if (result is GetConversationResponseModel) {
                val events = result.conversation?.events ?: listOf<Event>()

                displayConversationEvents(events)
                binding.progressBar.visibility = View.INVISIBLE
                binding.contentContainer.visibility = View.VISIBLE
            } else if (result is ErrorResponseModel) {

            }
        }
    }

    private fun displayConversationEvents(events: List<Event>?) {

        events
            ?.distinctBy { it.id } // Remove duplicated events
            ?.sortedBy { it.timestamp } // Sort events
            ?.forEach {
                val userDisplayName = getUserDisplayName(it.from)

                val line = when (it.type) {
                    "text" -> "$userDisplayName: ${it.content}"
                    "member:joined" -> "$userDisplayName joined"
                    else -> "${it.type} ${it.content}"
                }

                displayConversationLine(line)
            }
    }

    private fun getUserDisplayName(userId: String): String {
        return navArgs.users.firstOrNull { it.id == userId }?.displayName ?: "Unknown"
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val user = textEvent.fromMember.user.name
        return "$user said: ${textEvent.text}"
    }

    private fun displayConversationLine(line: String?) {
        line?.let { binding.conversationEventsTextView.append(it + System.lineSeparator()) }
    }
}