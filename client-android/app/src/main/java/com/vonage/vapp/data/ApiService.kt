package com.vonage.vapp.data

import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.CreateConversationRequestModel
import com.vonage.vapp.data.model.LoginRequestModel
import com.vonage.vapp.data.model.LoginResponseModel
import com.vonage.vapp.data.model.SignupRequestModel
import com.vonage.vapp.data.model.SignupResponseModel
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Headers
import retrofit2.http.POST
import retrofit2.http.Path

interface ApiService {

    @Headers("Content-Type: application/json")
    @POST("signup")
    suspend fun signup(@Body requestModel: SignupRequestModel): Response<SignupResponseModel>

    @Headers("Content-Type: application/json")
    @POST("login")
    suspend fun login(@Body requestModel: LoginRequestModel): Response<LoginResponseModel>

    @Headers("Content-Type: application/json")
    @GET("conversations")
    suspend fun getConversations(@Header("Authorization") token: String?): Response<List<Conversation>>

    @Headers("Content-Type: application/json")
    @GET("conversations/{conversationId}")
    suspend fun getConversation(
        @Header("Authorization") token: String?,
        @Path("conversationId") conversationId: String
    ): Response<Conversation>

    @Headers("Content-Type: application/json")
    @POST("conversations")
    suspend fun createConversation(
        @Header("Authorization") token: String?,
        @Body requestMode: CreateConversationRequestModel
    ): Response<Conversation>
}