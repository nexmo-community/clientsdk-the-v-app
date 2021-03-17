package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class User(
    @field:Json(name="display_name") val displayName: String,
    @field:Json(name="id") val id: String,
    @field:Json(name="name") val name: String
)