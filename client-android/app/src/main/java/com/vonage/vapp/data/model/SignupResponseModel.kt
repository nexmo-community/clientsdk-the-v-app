package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class SignupResponseModel(
    @field:Json(name="token") val token: String,
    @field:Json(name="user") val user: User,
    @field:Json(name="users") val users: List<User>,
    @field:Json(name="conversations") val conversations: List<Conversation>
)