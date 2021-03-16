package com.vonage.vapp.data

import retrofit2.http.Field
import retrofit2.http.FormUrlEncoded
import retrofit2.http.Headers
import retrofit2.http.POST

interface BackendService {

    @Headers("Content-Type: application/json")
    @FormUrlEncoded
    @POST("/signup")
    suspend fun signup(
        @Field("name") name: String,
        @Field("display_name") displayName: String,
        @Field("password") password: String
    )
}