package com.vonage.vapp.presentation

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.SignupResponseModel
import kotlinx.coroutines.launch

class SignupViewModel : ViewModel() {
    // should be injected
    private val apiRepository = ApiRepository
    private val navManager = NavManager

    private val viewStateMutableLiveData = MutableLiveData<Action>()
    val viewStateLiveData = viewStateMutableLiveData.asLiveData()

    fun signUp(name: String, displayName: String, password: String) {
        viewModelScope.launch {
            val result = apiRepository.signup(name, displayName, password)

            if (result is SignupResponseModel) {
                val navDirections = SignupFragmentDirections.actionSignupFragmentToConversationsFragment(
                    result.user,
                    result.users.toTypedArray(),
                    result.conversations.toTypedArray(),
                    result.token
                )

                navManager.navigate(navDirections)
            } else if (result is ErrorResponseModel) {
                viewStateMutableLiveData.postValue(Action.Error(result.fullMessage))
            }
        }
    }

    sealed class Action {
        data class Error(val message: String) : Action()
    }
}