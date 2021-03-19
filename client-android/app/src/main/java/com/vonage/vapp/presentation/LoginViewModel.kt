package com.vonage.vapp.presentation

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.LoginResponseModel
import kotlinx.coroutines.launch

class LoginViewModel : ViewModel() {
    // should be injected
    private val apiRepository = ApiRepository
    private val navManager = NavManager

    private val viewStateMutableLiveData = MutableLiveData<State>()
    val viewStateLiveData = viewStateMutableLiveData.asLiveData()

    fun navigateToSignup() {
        val navDirections = LoginFragmentDirections.actionLoginFragmentToSignupFragment()
        navManager.navigate(navDirections)
    }

    fun login(name: String, password: String) {
        viewModelScope.launch {
            val result = apiRepository.login(name, password)

            if (result is LoginResponseModel) {
                val navDirections = LoginFragmentDirections.actionLoginFragmentToConversationsFragment(
                    result.user,
                    result.users.toTypedArray(),
                    result.conversations.filterNotNull().toTypedArray(),
                    result.token
                )

                navManager.navigate(navDirections)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(State.Error("${result.title} - ${result.detail}"))
            }
        }
    }

    sealed class State {
        data class Error(val message: String) : State()
    }
}