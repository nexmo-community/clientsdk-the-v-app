package com.vonage.vapp.data

import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory

class BackendRepository {

    private val client = OkHttpClient.Builder()
        .addInterceptor(HttpLoggingInterceptor())
        .build()

    private val retofit = Retrofit.Builder()
        .baseUrl("https://v-app-companion.herokuapp.com/")
        .addConverterFactory(MoshiConverterFactory.create())
        .client(client)
        .build()

    private val service: BackendService = retofit.create(BackendService::class.java)


}