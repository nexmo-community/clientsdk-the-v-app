package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class CreateConversationResponseModel(
    @field:Json(name = "conversations") val conversation: Conversation
)