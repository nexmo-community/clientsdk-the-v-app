package com.vonage.vapp.data.model

import android.graphics.Bitmap

data class ConversationMessage(
    val id: String,
    val content: String?,
    val image: Bitmap?,
    val profileImage: Bitmap?,
)