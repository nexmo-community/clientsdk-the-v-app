package com.vonage.vapp.presentation.user

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.databinding.FragmentUserDetailBinding
import com.vonage.vapp.presentation.user.UserDetailViewModel.Action
import com.vonage.vapp.presentation.user.UserDetailViewModel.Action.ShowContent
import com.vonage.vapp.presentation.user.UserDetailViewModel.Action.ShowError
import com.vonage.vapp.presentation.user.UserDetailViewModel.Action.ShowLoading

class UserDetailFragment : Fragment(R.layout.fragment_user_detail) {

    private val binding by viewBinding<FragmentUserDetailBinding>()
    private val navArgs by navArgs<UserDetailFragmentArgs>()
    private val viewModel by viewModels<UserDetailViewModel>()

    private val actionObserver = Observer<Action> {

        binding.progressBar.visibility = View.INVISIBLE
        binding.userNameTextView.visibility = View.INVISIBLE

        when (it) {
            is ShowContent -> {
                binding.userNameTextView.visibility = View.VISIBLE
                binding.userNameTextView.text = it.user.displayName
            }
            is ShowLoading -> {
                binding.progressBar.visibility = View.VISIBLE
            }
            is ShowError -> {
                toast { it.message }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.init(navArgs)
        observe(viewModel.viewActionLiveData, actionObserver)

        binding.startConversationButton.setOnClickListener {
            viewModel.startConversation()
        }

        binding.startCallButton.setOnClickListener {
            viewModel.startCall()
        }
    }
}