package com.vonage.vapp.data.model

import android.os.Parcelable
import com.squareup.moshi.Json
import kotlinx.parcelize.Parcelize

@Parcelize
data class Event(
    @field:Json(name = "id") val id: String,
    @field:Json(name = "from") val from: String,
    @field:Json(name = "type") val type: String,
    @field:Json(name = "content") val content: String?,
    @field:Json(name = "timestamp") val timestamp: String
) : Parcelable