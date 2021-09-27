package com.vonage.vapp.presentation.converstion

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.data.model.User
import com.vonage.vapp.databinding.FragmentConversationsBinding
import com.vonage.vapp.presentation.converstion.ConversationsViewModel.Action
import com.vonage.vapp.presentation.converstion.ConversationsViewModel.Action.SelectUsers
import com.vonage.vapp.presentation.converstion.ConversationsViewModel.Action.ShowContent
import com.vonage.vapp.presentation.converstion.ConversationsViewModel.Action.ShowError
import com.vonage.vapp.presentation.converstion.ConversationsViewModel.Action.ShowLoading
import com.vonage.vapp.utils.viewBinding

class ConversationsFragment : Fragment(R.layout.fragment_conversations) {

    private val binding by viewBinding<FragmentConversationsBinding>()
    private val viewModel by viewModels<ConversationsViewModel>()

    private val conversationAdapter = ConversationAdapter()

    private val actionObserver = Observer<Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is ShowContent -> {
                conversationAdapter.setConversations(it.conversations)
                binding.contentContainer.visibility = View.VISIBLE
            }
            is SelectUsers -> {
                showUserSelectionDialog(it.users)
                binding.contentContainer.visibility = View.VISIBLE
            }
            is ShowLoading -> binding.progressBar.visibility = View.VISIBLE
            is ShowError -> toast { it.message }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observe(viewModel.viewActionLiveData, actionObserver)
        viewModel.init()

        binding.recyclerView.apply {
            setHasFixedSize(true)

            layoutManager = LinearLayoutManager(this.context)
            adapter = conversationAdapter
        }

        conversationAdapter.setOnClickListener {
            viewModel.navigateToConversationDetail(it)
        }

        binding.addFab.setOnClickListener {
            viewModel.createConversation()
        }

        binding.swipeRefreshLayout.setOnRefreshListener {
            binding.swipeRefreshLayout.isRefreshing = false
            viewModel.loadConversations()
        }
    }

    private fun showUserSelectionDialog(users: List<User>) {
        context?.let { context ->
            val userNames = users.map { it.displayName }.toTypedArray()
            val selectedUsers = mutableSetOf<User>()

            val builder: AlertDialog.Builder = AlertDialog.Builder(context)
            builder.setTitle("Select users")
            builder.setMultiChoiceItems(userNames, null) { _, index, checked ->
                val user = users[index]

                if (checked) {
                    selectedUsers.add(user)
                } else {
                    selectedUsers.remove(user)
                }
            }

            builder.setPositiveButton("OK") { _, _ ->
                viewModel.createConversation(selectedUsers)
            }

            builder.setNegativeButton("Cancel") { dialog, _ -> dialog.cancel() }

            builder.show()
        }
    }
}