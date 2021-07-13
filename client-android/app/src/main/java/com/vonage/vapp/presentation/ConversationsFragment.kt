package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.data.model.User
import com.vonage.vapp.databinding.FragmentConversationsBinding
import com.vonage.vapp.presentation.ConversationsViewModel.Action

class ConversationsFragment : Fragment(R.layout.fragment_conversations) {

    private val binding by viewBinding<FragmentConversationsBinding>()
    private val navArgs by navArgs<ConversationsFragmentArgs>()
    private val viewModel by viewModels<ConversationsViewModel>()

    private val conversationAdapter = ConversationAdapter()

    private val actionObserver = Observer<Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is Action.ShowContent -> {
                conversationAdapter.setConversations(it.conversations)
                binding.contentContainer.visibility = View.VISIBLE
            }
            is Action.SelectUsers -> showUserSelectionDialog()
            Action.ShowLoading -> binding.progressBar.visibility = View.VISIBLE
            is Action.ShowError -> toast { it.message }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.recyclerView.apply {
            setHasFixedSize(true)

            layoutManager = LinearLayoutManager(this.context)
            adapter = conversationAdapter
        }

        conversationAdapter.setOnClickListener {
            viewModel.navigateToConversation(it)
        }

        binding.addFab.setOnClickListener {
            viewModel.createConversation()
        }

        binding.swipeRefreshLayout.setOnRefreshListener {
            binding.swipeRefreshLayout.isRefreshing = false
            viewModel.loadConversations()
        }

        observe(viewModel.viewStateLiveData, actionObserver)
        viewModel.initClient(navArgs)
    }

    private fun showUserSelectionDialog() {
        context?.let { context ->
            val userNames = navArgs.users.map { it.displayName }.toTypedArray()
            val selectedUsers = mutableSetOf<User>()

            val builder: AlertDialog.Builder = AlertDialog.Builder(context)
            builder.setTitle("Select users")
            builder.setMultiChoiceItems(userNames, null) { _, index, checked ->
                val user = navArgs.users[index]

                if (checked) {
                    selectedUsers.add(user)
                } else {
                    selectedUsers.remove(user)
                }
            }

            builder.setOnDismissListener {
                binding.addFab.isVisible = true
            }

            builder.setPositiveButton("OK") { _, _ ->
                viewModel.createConversation(selectedUsers)
            }

            builder.setNegativeButton("Cancel") { dialog, _ -> dialog.cancel() }

            builder.show()
        }
    }
}