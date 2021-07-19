package com.vonage.vapp.presentation.main

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.databinding.FragmentMainBinding
import com.vonage.vapp.presentation.main.MainViewModel.Action
import com.vonage.vapp.utils.viewBinding

class MainFragment : Fragment(R.layout.fragment_main) {

    private val binding by viewBinding<FragmentMainBinding>()
    private val viewModel by viewModels<MainViewModel>()

    private val actionObserver = Observer<Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is Action.ShowContent -> binding.contentContainer.visibility = View.VISIBLE
            is Action.ShowLoading -> binding.progressBar.visibility = View.VISIBLE
            is Action.ShowError -> toast { it.message }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observe(viewModel.viewActionLiveData, actionObserver)
        viewModel.init()

        binding.usersButton.setOnClickListener { viewModel.navigateToUsers() }
        binding.conversationsButton.setOnClickListener { viewModel.navigateToConversations() }
    }
}