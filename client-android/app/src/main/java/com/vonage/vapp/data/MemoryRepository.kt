package com.vonage.vapp.data

import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.LoginResponseModel
import com.vonage.vapp.data.model.SignupResponseModel
import com.vonage.vapp.data.model.User

object MemoryRepository {
    lateinit var token: String
        private set

    lateinit var user: User
        private set

    lateinit var otherUsers: List<User>
        private set

    lateinit var allUsers: List<User>
        private set

    private var _conversations: MutableList<Conversation> = mutableListOf()

    val conversations get() = _conversations.toList()

    fun update(body: SignupResponseModel) {
        token = body.token
        user = body.user
        otherUsers = body.otherUsers
        allUsers = otherUsers + user
        _conversations = body.conversations.toMutableList()
    }

    fun update(body: LoginResponseModel) {
        token = body.token
        user = body.user
        otherUsers = body.otherUsers
        allUsers = otherUsers + user
        _conversations = body.conversations.toMutableList()
    }

    fun addConversation(conversation: Conversation) {
        _conversations.add(conversation)
    }

    fun setConversations(conversations: List<Conversation>) {
        _conversations = conversations.toMutableList()
    }
}