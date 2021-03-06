package com.vonage.vapp.data

import com.squareup.moshi.Moshi
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.CreateConversationRequestModel
import com.vonage.vapp.data.model.CreateConversationResponseModel
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.GetConversationResponseModel
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.data.model.LoginRequestModel
import com.vonage.vapp.data.model.SignupRequestModel
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import java.util.concurrent.TimeUnit.SECONDS

object ApiRepository {

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val client = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .readTimeout(60, SECONDS)
        .writeTimeout(60, SECONDS)
        .connectTimeout(60, SECONDS)
        .build()

    private val moshi = Moshi.Builder().build();

    private val retrofit = Retrofit.Builder()
        .baseUrl("https://v-app-companion.herokuapp.com/")
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .client(client)
        .build()

    private val apiService: ApiService = retrofit.create(ApiService::class.java)

    private var token: String? = null

    suspend fun signup(name: String, displayName: String, password: String): Any? {
        val requestModel = SignupRequestModel(name, displayName, password)
        val response = apiService.signup(requestModel)

        return if (response.isSuccessful) {
            val body = response.body()
            token = body?.token
            body
        } else {
            getErrorResponseModel(response)
        }
    }

    suspend fun login(name: String, password: String): Any? {
        val requestModel = LoginRequestModel(name, password)

        val response = apiService.login(requestModel)

        return if (response.isSuccessful) {
            val body = response.body()
            token = body?.token
            body
        } else {
            getErrorResponseModel(response)
        }
    }

    suspend fun getConversations(): Any? {
        checkNotNull(token)

        val response = apiService.getConversations("Bearer $token")

        return if (response.isSuccessful) {
            val conversations = response.body() ?: listOf()
            GetConversationsResponseModel(conversations)
        } else {
            getErrorResponseModel(response)
        }
    }

    suspend fun getConversation(conversationId: String): Any? {
        checkNotNull(token)

        val response = apiService.getConversation("Bearer $token", conversationId)

        return if (response.isSuccessful) {
            val conversations = response.body()
            GetConversationResponseModel(conversations)
        } else {
            getErrorResponseModel(response)
        }
    }

    suspend fun createConversation(userIds: Set<String>): Any? {
        checkNotNull(token)

        val requestModel = CreateConversationRequestModel(userIds)
        val response = apiService.createConversation("Bearer $token", requestModel)

        return if (response.isSuccessful) {
            val conversations = response.body() as Conversation
            CreateConversationResponseModel(conversations)
        } else {
            getErrorResponseModel(response)
        }
    }

    private suspend fun getErrorResponseModel(response: Response<*>): ErrorResponseModel? =
        moshi.adapter(ErrorResponseModel::class.java).fromJson(response.errorBody()?.source())
}