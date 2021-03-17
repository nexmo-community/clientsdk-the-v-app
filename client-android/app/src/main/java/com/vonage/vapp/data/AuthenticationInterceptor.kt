package com.vonage.vapp.data

import okhttp3.Interceptor
import okhttp3.Response
import retrofit2.http.Header

class AuthenticationInterceptor(private val apiKey: String) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response = chain.request().let {
        val url = it.url.newBuilder()
            .build()

        val newRequest = it.newBuilder()
            .url(url)
            .build()

        chain.proceed(newRequest)
    }
}
