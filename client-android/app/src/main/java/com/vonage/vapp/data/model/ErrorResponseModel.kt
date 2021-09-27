package com.vonage.vapp.data.model

import com.squareup.moshi.Json

data class ErrorResponseModel(
    @field:Json(name = "type") val type: String,
    @field:Json(name = "title") val title: String,
    @field:Json(name = "detail") val detail: String,
    @field:Json(name = "invalid_parameters") val invalidParameters: List<InvalidParameter>?,
) {
    val fullMessage get() = "$title $detail $invalidParameters"
}

data class InvalidParameter(
    @field:Json(name = "name") val name: String,
    @field:Json(name = "reason") val reason: String
)