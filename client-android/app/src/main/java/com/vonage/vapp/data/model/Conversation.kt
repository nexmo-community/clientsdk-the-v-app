package com.vonage.vapp.data.model

data class Conversation(
    val created_at: String,
    val id: String,
    val joined_at: String,
    val name: String,
    val state: String,
    val users: List<User>
)