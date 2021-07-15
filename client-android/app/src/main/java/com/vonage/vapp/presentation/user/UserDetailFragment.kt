package com.vonage.vapp.presentation.user

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.databinding.FragmentUserDetailBinding
import com.vonage.vapp.databinding.FragmentUsersBinding
import com.vonage.vapp.presentation.converstion.ConversationAdapter

class UserDetailFragment : Fragment(R.layout.fragment_users) {

    private val binding by viewBinding<FragmentUserDetailBinding>()
//    private val navArgs by navArgs<UserDetailFragmentArgs>()
    private val viewModel by viewModels<UserDetailViewModel>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

//        viewModel.initClient(navArgs)
    }
}