package com.vonage.vapp.presentation.user

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.databinding.FragmentUsersBinding
import com.vonage.vapp.presentation.user.UsersViewModel.Action
import com.vonage.vapp.presentation.user.UsersViewModel.Action.ShowContent
import com.vonage.vapp.utils.viewBinding

class UsersFragment : Fragment(R.layout.fragment_users) {

    private val binding by viewBinding<FragmentUsersBinding>()
    private val viewModel by viewModels<UsersViewModel>()

    private val userAdapter = UserAdapter()

    private val actionObserver = Observer<Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is ShowContent -> {
                userAdapter.setUsers(it.users)
                binding.contentContainer.visibility = View.VISIBLE
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observe(viewModel.viewActionLiveData, actionObserver)
        viewModel.init()

        binding.recyclerView.apply {
            setHasFixedSize(true)

            layoutManager = LinearLayoutManager(this.context)
            adapter = userAdapter
        }

        userAdapter.setOnClickListener {
            viewModel.navigateToUserDetail(it)
        }
    }
}