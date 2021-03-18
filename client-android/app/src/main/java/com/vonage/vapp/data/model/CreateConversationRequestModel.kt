package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class CreateConversationRequestModel(
    @field:Json(name = "users") val userIds: List<String>
)
