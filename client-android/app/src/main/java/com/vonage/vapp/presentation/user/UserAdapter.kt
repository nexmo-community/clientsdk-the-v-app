package com.vonage.vapp.presentation.user

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.vonage.vapp.data.model.User
import com.vonage.vapp.databinding.ItemUserListBinding

class UserAdapter : RecyclerView.Adapter<UserAdapter.ViewHolder>() {

    private var users = mutableListOf<User>()

    private var onClickListener: ((user: User) -> Unit)? = null

    fun setUsers(users: List<User>) {
        this.users = users.toMutableList()
        notifyDataSetChanged()
    }

    fun addUser(user: User) {
        users.add(user)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        val binding = ItemUserListBinding.inflate(inflater, parent, false)

        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(users[position])
    }

    override fun getItemCount(): Int = users.size

    fun setOnClickListener(listener: (user: User) -> Unit) {
        this.onClickListener = listener
    }

    inner class ViewHolder(private val binding: ItemUserListBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(user: User) {
            itemView.setOnClickListener { onClickListener?.invoke(user) }

            binding.name.text = user.name
            binding.description.text = user.displayName
        }
    }
}