package com.vonage.vapp

data class User(
    val name: String,
    val jwt: String
)

object Config {

    const val CONVERSATION_ID = "CONVERSATION_ID"

    val igor = User(
        "Alice",
        ""
    )
}