package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class ErrorResponseModel(
    @field:Json(name = "type") val type: String,
    @field:Json(name = "title") val title: String,
    @field:Json(name = "detail") val detail: String,
) {
    val fullMessage = "$title - $detail"
}