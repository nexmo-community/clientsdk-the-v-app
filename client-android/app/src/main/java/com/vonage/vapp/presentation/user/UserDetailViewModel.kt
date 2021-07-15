package com.vonage.vapp.presentation.user

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.model.User

class UserDetailViewModel : ViewModel() {
    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun init(navArgs: UserDetailFragmentArgs) {
        viewActionMutableLiveData.postValue(Action.ShowContent(navArgs.user))
    }

    fun startCall() {
        TODO("not implemented")
    }

    fun startConversation() {
        TODO("not implemented")
    }

    sealed class Action {
        data class ShowContent(val user: User) : Action()
    }
}
