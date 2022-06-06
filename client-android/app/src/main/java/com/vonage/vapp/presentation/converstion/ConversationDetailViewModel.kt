package com.vonage.vapp.presentation.converstion

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.*
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.nexmo.clientcore.model.enums.EMessageEventType
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.model.Event
import java.io.File
import java.io.IOException
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL


class ConversationDetailViewModel : ViewModel() {
    // should be injected
    private val client = NexmoClient.get()

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    private val eventsMutableLiveData = MutableLiveData<MutableList<Event>?>()

    val viewActionLiveData = viewActionMutableLiveData.asLiveData()
    val eventsLiveData = eventsMutableLiveData.asLiveData()

    private var conversation: NexmoConversation? = null

    private val messageListener = object : NexmoMessageEventListener {

        override fun onMessageEvent(messageEvent: NexmoMessageEvent) {
            if (messageEvent.message.messageType == EMessageEventType.TEXT) {
                val newEventData = eventsLiveData.value
                newEventData?.add(getEventFromNexmoEvent(messageEvent))
                eventsMutableLiveData.postValue(newEventData)
            }
        }

        override fun onTextEvent(textEvent: NexmoTextEvent) {}
        override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}
        override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}
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

    private fun displayConversationEvents(nexmoEvents: List<NexmoEvent>) {
        val events = ArrayList<Event>()

        for (nexmoEvent in nexmoEvents) {
            var event: Event? = null

            when (nexmoEvent) {
                is NexmoMemberEvent -> {
                    event = getEventFromNexmoEvent(nexmoEvent)
                }
                is NexmoMessageEvent -> {
                    event = getEventFromNexmoEvent(nexmoEvent)
                }
            }

            if (event != null) {
                events.add(event)
            }
        }

        eventsMutableLiveData.postValue(events)
    }

    private fun getEventFromNexmoEvent(memberEvent: NexmoMemberEvent): Event {
        val userName = memberEvent.embeddedInfo?.user?.name ?: "Unknown"
        val profileImageURL = memberEvent.embeddedInfo?.user?.imageUrl ?: ""
        val profileImage = getBitmapFromURL(profileImageURL)

        val content = when (memberEvent.state) {
            NexmoMemberState.JOINED -> "$userName joined"
            NexmoMemberState.INVITED -> "$userName invited"
            NexmoMemberState.LEFT -> "$userName left"
            else -> "Error: Unknown member event state"
        }
        return Event(memberEvent.memberId,
            memberEvent.fromMemberId,
            memberEvent.eventType.name,
            content,
            null,
            profileImage,
            memberEvent.creationDate.toString() )
    }

    private fun getEventFromNexmoEvent(messageEvent: NexmoMessageEvent): Event {
        val userName = messageEvent.embeddedInfo?.user?.name ?: "Unknown"
        val profileImageURL = messageEvent.embeddedInfo?.user?.imageUrl ?: ""
        val profileImage = getBitmapFromURL(profileImageURL)
        val text = "$userName said: ${messageEvent.message.text}"

        val imageURL = messageEvent.message.imageUrl
        val image = getBitmapFromURL(imageURL)

        return Event(messageEvent.id.toString(),
            messageEvent.fromMemberId,
            messageEvent.eventType.name,
            text,
            image,
            profileImage,
            messageEvent.creationDate.toString() )
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

    //Thread blocking, shouldn't be used in a production app!!
    private fun getBitmapFromURL(src: String?): Bitmap? {
        return try {
            val url = URL(src)
            val connection: HttpURLConnection = url.openConnection() as HttpURLConnection
            connection.doInput = true
            connection.connect()
            val input: InputStream = connection.inputStream
            BitmapFactory.decodeStream(input)
        } catch (e: IOException) {
            // Log exception
            null
        }
    }

    sealed interface Action {
        object Loading : Action
        data class SetConversation(val conversation: String) : Action
        data class AddConversationLine(val line: String) : Action
        data class Error(val message: String) : Action
    }
}
