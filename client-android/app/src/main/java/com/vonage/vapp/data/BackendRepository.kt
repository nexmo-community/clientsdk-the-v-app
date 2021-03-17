package com.vonage.vapp.data

import com.squareup.moshi.Moshi
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.LoginRequestModel
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

    private val moshi = Moshi.Builder().build();

    private val retrofit = Retrofit.Builder()
        .baseUrl("https://v-app-companion.herokuapp.com/")
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .client(client)
        .build()

    private val service: BackendService = retrofit.create(BackendService::class.java)

    suspend fun signup(name: String, displayName: String, password: String): RepositoryResponse {
        val requestModel = SignupRequestModel(name, displayName, password)
        val response = service.signup(requestModel)

        if (response.isSuccessful) {
            return RepositoryResponse.Success(response)
        } else {
            val errorResponseModel =
                moshi.adapter(ErrorResponseModel::class.java).fromJson(response.errorBody()?.source())
            return RepositoryResponse.Error(errorResponseModel)
        }
    }

    suspend fun login(name: String, password: String): RepositoryResponse {
        val requestModel = LoginRequestModel(name, password)
        val response = service.login(requestModel)

        if (response.isSuccessful) {
            return RepositoryResponse.Success(response)
        } else {
            val errorResponseModel =
                moshi.adapter(ErrorResponseModel::class.java).fromJson(response.errorBody()?.source())
            return RepositoryResponse.Error(errorResponseModel)
        }
    }
}

sealed class RepositoryResponse {
    data class Success<T>(val data: T) : RepositoryResponse()
    data class Error(val data: ErrorResponseModel? = null) : RepositoryResponse()
}