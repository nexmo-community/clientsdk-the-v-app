package com.vonage.vapp.data

import retrofit2.http.POST

interface BackendService {

    @POST("/signup")
    suspend fun signup(name: String, password: String, displayName: String)
}