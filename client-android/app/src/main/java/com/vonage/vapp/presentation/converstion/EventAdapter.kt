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
import com.vonage.vapp.data.model.Event

class EventAdapter: ListAdapter<Event, EventAdapter.EventViewHolder>(EventDiffCallback) {

    class EventViewHolder(view: View) : RecyclerView.ViewHolder(view){
        private var currentEvent: Event? = null

        private val contentTextView: TextView = itemView.findViewById(R.id.contentText)
        private val profilePictureImageView: ImageView = itemView.findViewById(R.id.profilePicture)
        private val contentImageView: ImageView = itemView.findViewById(R.id.contentImage)

        fun bind(event: Event) {
            currentEvent = event

            contentTextView.text = event.content
            if (event.profileImage != null) {
                profilePictureImageView.setImageBitmap(event.profileImage)
            }
            if (event.image != null) {
                contentImageView.setImageBitmap(event.image)
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): EventViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.event_item, parent, false)
        return EventViewHolder(view)
    }

    override fun onBindViewHolder(holder: EventViewHolder, position: Int) {
        val event = getItem(position)
        holder.bind(event)
    }

}

object EventDiffCallback : DiffUtil.ItemCallback<Event>() {
    override fun areItemsTheSame(oldItem: Event, newItem: Event): Boolean {
        return oldItem == newItem
    }

    override fun areContentsTheSame(oldItem: Event, newItem: Event): Boolean {
        return oldItem.id == newItem.id
    }
}