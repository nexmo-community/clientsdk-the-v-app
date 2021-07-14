package com.vonage.vapp.presentation.signup

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

    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun signUp(name: String, displayName: String, password: String) {
        viewModelScope.launch {
            val result = apiRepository.signup(name, displayName, password)

            if (result is SignupResponseModel) {
                val navDirections = SignupFragmentDirections.actionSignupFragmentToMainFragment(
                    result.user,
                    result.users.toTypedArray(),
                    result.conversations.toTypedArray(),
                    result.token
                )

                navManager.navigate(navDirections)
            } else if (result is ErrorResponseModel) {
                viewActionMutableLiveData.postValue(Action.Error(result.fullMessage))
            }
        }
    }

    sealed class Action {
        data class Error(val message: String) : Action()
    }
}