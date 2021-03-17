package com.vonage.vapp.data

import com.squareup.moshi.Moshi
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.data.model.LoginRequestModel
import com.vonage.vapp.data.model.LoginResponseModel
import com.vonage.vapp.data.model.SignupRequestModel
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory

object BackendRepository {

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val client = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .build()

    private val moshi = Moshi.Builder().build();

    private val retrofit = Retrofit.Builder()
        .baseUrl("https://v-app-companion.herokuapp.com/")
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .client(client)
        .build()

    private val service: BackendService = retrofit.create(BackendService::class.java)

    private var token: String? = null

    suspend fun signup(name: String, displayName: String, password: String): Any? {
        val requestModel = SignupRequestModel(name, displayName, password)
        val response = service.signup(requestModel)

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

        val response = service.login(requestModel)

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

        val response = service.getConversations("Bearer $token")

        return if (response.isSuccessful) {
            val conversations = response.body() ?: listOf()
            GetConversationsResponseModel(conversations)
        } else {
            getErrorResponseModel(response)
        }
    }

    private suspend fun getErrorResponseModel(response: Response<*>): ErrorResponseModel? =
        moshi.adapter(ErrorResponseModel::class.java).fromJson(response.errorBody()?.source())
}