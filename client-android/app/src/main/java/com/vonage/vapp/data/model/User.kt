package com.vonage.vapp.data.model

import android.os.Parcelable
import com.squareup.moshi.Json
import kotlinx.parcelize.Parcelize

@Parcelize
data class User(
    @field:Json(name = "display_name") val displayName: String,
    @field:Json(name = "id") val id: String,
    @field:Json(name = "name") val name: String
) : Parcelable