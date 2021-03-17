package com.vonage.vapp.data.model

data class ErrorResponseModel(
    val type: String,
    val title: String,
    val detail: String,
)