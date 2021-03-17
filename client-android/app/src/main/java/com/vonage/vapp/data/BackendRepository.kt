package com.vonage.vapp.data

import com.vonage.vapp.data.model.SignupRequestModel
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory

object BackendRepository {

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val client = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .build()

    private val retofit = Retrofit.Builder()
        .baseUrl("https://v-app-companion.herokuapp.com/")
        .addConverterFactory(MoshiConverterFactory.create())
        .client(client)
        .build()

    private val service: BackendService = retofit.create(BackendService::class.java)

    suspend fun signup(name: String, displayName: String, password: String) {
        val requestModel = SignupRequestModel(name, displayName, password)
        service.signup(requestModel)
    }
}