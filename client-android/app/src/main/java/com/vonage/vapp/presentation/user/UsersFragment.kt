package com.vonage.vapp.presentation.user

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.databinding.FragmentUsersBinding
import com.vonage.vapp.presentation.converstion.ConversationAdapter

class UsersFragment : Fragment(R.layout.fragment_users) {

    private val binding by viewBinding<FragmentUsersBinding>()
//    private val navArgs by navArgs<UsersFragmentArgs>()
    private val viewModel by viewModels<UsersViewModel>()

    private val conversationAdapter = ConversationAdapter()

//    private val actionObserver = Observer<Action> {
//        binding.progressBar.visibility = View.INVISIBLE
//        binding.contentContainer.visibility = View.INVISIBLE
//
//        when (it) {
//            is Action.ShowContent -> {
//                conversationAdapter.setConversations(it.conversations)
//                binding.contentContainer.visibility = View.VISIBLE
//            }
//            is Action.SelectUsers -> showUserSelectionDialog()
//            Action.ShowLoading -> binding.progressBar.visibility = View.VISIBLE
//            is Action.ShowError -> toast { it.message }
//        }
//    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

//        binding.recyclerView.apply {
//            setHasFixedSize(true)
//
//            layoutManager = LinearLayoutManager(this.context)
//            adapter = conversationAdapter
//        }
//
//        conversationAdapter.setOnClickListener {
//            viewModel.navigateToConversation(it)
//        }
//
//        binding.addFab.setOnClickListener {
//            viewModel.createConversation()
//        }
//
//        binding.swipeRefreshLayout.setOnRefreshListener {
//            binding.swipeRefreshLayout.isRefreshing = false
//            viewModel.loadConversations()
//        }
//
//        observe(viewModel.viewActionLiveData, actionObserver)
//        viewModel.initClient(navArgs)
    }
}