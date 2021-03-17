package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class SignupRequestModel(
    @field:Json(name="name") val name: String,
    @field:Json(name="display_name") val displayName: String,
    @field:Json(name="password") val password: String
)