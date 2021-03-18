package com.vonage.vapp.data.model

import android.os.Parcelable
import com.squareup.moshi.Json
import kotlinx.parcelize.Parcelize

@Parcelize
data class Conversation(
    @field:Json(name = "created_at") val createdAt: String,
    @field:Json(name = "id") val id: String,
    @field:Json(name = "joined_at") val joinedAt: String,
    @field:Json(name = "name") val name: String,
    @field:Json(name = "state") val state: String,
    @field:Json(name = "users") val users: List<User>
) : Parcelable