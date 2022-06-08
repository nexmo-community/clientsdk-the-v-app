package com.vonage.vapp.presentation.converstion

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
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

            if (conversationMessage.profileImage != null) {
                profilePictureImageView.setImageBitmap(conversationMessage.profileImage)
            }
            if (conversationMessage.image != null) {
                contentImageView.setImageBitmap(conversationMessage.image)
                contentImageView.visibility = View.VISIBLE
            } else {
                contentImageView.visibility = View.GONE
            }
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