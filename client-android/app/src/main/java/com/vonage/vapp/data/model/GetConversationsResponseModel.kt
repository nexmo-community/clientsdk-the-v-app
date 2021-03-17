package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class GetConversationsResponseModel(
    @field:Json(name="conversations") val conversations: List<Conversation>
)