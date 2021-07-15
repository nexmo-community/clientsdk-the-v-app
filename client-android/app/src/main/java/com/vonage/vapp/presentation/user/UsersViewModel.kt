package com.vonage.vapp.presentation.user

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.vonage.vapp.core.NavManager
import com.vonage.vapp.core.ext.asLiveData
import com.vonage.vapp.data.model.User

class UsersViewModel : ViewModel() {
    private val viewActionMutableLiveData = MutableLiveData<Action>()
    val viewActionLiveData = viewActionMutableLiveData.asLiveData()

    fun init(navArgs: UsersFragmentArgs) {
        viewActionMutableLiveData.postValue(Action.ShowContent(navArgs.otherUsers.toList()))
    }

    fun navigateToUserDetail(user: User) {
        val navDirections = UsersFragmentDirections.actionUsersFragmentToUserDetailFragment(user)
        NavManager.navigate(navDirections)
    }

    sealed class Action {
        data class ShowContent(val users: List<User>) : Action()
    }
}
