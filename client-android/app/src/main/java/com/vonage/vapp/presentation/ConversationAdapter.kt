package com.vonage.vapp.presentation

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.databinding.ItemConversationListBinding
import kotlin.properties.Delegates

class ConversationAdapter : RecyclerView.Adapter<ConversationAdapter.ViewHolder>() {

    var conversations: List<Conversation> by Delegates.observable(listOf()) { _, _, _ ->
        notifyDataSetChanged()
    }

    private var onClickListener: ((conversation: Conversation) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        val binding = ItemConversationListBinding.inflate(inflater, parent, false)

        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(conversations[position])
    }

    override fun getItemCount(): Int = conversations.size

    fun setOnClickListener(listener: (conversation: Conversation) -> Unit) {
        this.onClickListener = listener
    }

    inner class ViewHolder(private val binding: ItemConversationListBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(conversation: Conversation) {
            itemView.setOnClickListener { onClickListener?.invoke(conversation) }

            binding.name.text = conversation.name
            binding.description.text = "Created: ${conversation.createdAt}, Users: ${conversation.users.size}"
        }
    }
}