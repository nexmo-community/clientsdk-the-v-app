package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class LoginRequestModel(
    @field:Json(name="name") val name: String,
    @field:Json(name="password") val password: String
)
