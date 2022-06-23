package com.vonage.vapp.presentation.converstion

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import coil.imageLoader
import coil.load
import coil.request.ImageRequest
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R
import com.vonage.vapp.data.model.ConversationMessage

class ConversationMessageAdapter: ListAdapter<ConversationMessage, ConversationMessageAdapter.ConversationMessageViewHolder>(ConversationMessageDiffCallback) {

    class ConversationMessageViewHolder(view: View) : RecyclerView.ViewHolder(view){
        private var currentConversationMessage: ConversationMessage? = null

        private val contentTextView: TextView = itemView.findViewById(R.id.contentText)
        private val profilePictureImageView: ImageView = itemView.findViewById(R.id.profilePicture)
        private val contentImageView: ImageView = itemView.findViewById(R.id.contentImage)

        fun bind(conversationMessage: ConversationMessage) {
            currentConversationMessage = conversationMessage

            contentTextView.text = conversationMessage.content

            if (conversationMessage.profileImageUrl != null) {
                loadImageFromURL(profilePictureImageView, conversationMessage.profileImageUrl)
            }
            if (conversationMessage.imageUrl != null) {
                loadImageFromURL(contentImageView, conversationMessage.imageUrl)
                contentImageView.visibility = View.VISIBLE
                contentTextView.visibility = View.GONE
            } else {
                contentImageView.visibility = View.GONE
                contentTextView.visibility = View.VISIBLE
            }
        }

        private fun loadImageFromURL(imageView: ImageView, url: String) {
            val imageLoader = imageView.context.imageLoader
            val request = ImageRequest.Builder(imageView.context)
                .data(url)
                .addHeader("Authorization", "Bearer ${NexmoClient.get().authToken}")
                .target(imageView)
                .build()
            imageLoader.enqueue(request)
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ConversationMessageViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.event_item, parent, false)
        return ConversationMessageViewHolder(view)
    }

    override fun onBindViewHolder(holder: ConversationMessageViewHolder, position: Int) {
        val event = getItem(position)
        holder.bind(event)
    }



}

object ConversationMessageDiffCallback : DiffUtil.ItemCallback<ConversationMessage>() {
    override fun areItemsTheSame(oldItem: ConversationMessage, newItem: ConversationMessage): Boolean {
        return oldItem == newItem
    }

    override fun areContentsTheSame(oldItem: ConversationMessage, newItem: ConversationMessage): Boolean {
        return oldItem.id == newItem.id
    }
}