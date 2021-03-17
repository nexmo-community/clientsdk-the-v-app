package com.vonage.vapp.data

import com.vonage.vapp.data.model.SignupRequestModel
import retrofit2.http.Body
import retrofit2.http.Headers
import retrofit2.http.POST

interface BackendService {

    @Headers("Content-Type: application/json")
    @POST("signup")
    suspend fun signup(@Body requestModelModel: SignupRequestModel)
}