package com.vonage.vapp.data.model

data class SignupResponse(
    val conversations: List<Conversation>,
    val token: String,
    val user: User,
    val users: List<User>
)