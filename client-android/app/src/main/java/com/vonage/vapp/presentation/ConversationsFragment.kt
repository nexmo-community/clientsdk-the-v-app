package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.data.model.User
import com.vonage.vapp.databinding.FragmentConversationsBinding
import com.vonage.vapp.presentation.ConversationViewState.*

class ConversationsFragment : Fragment(R.layout.fragment_conversations) {

    private val binding: FragmentConversationsBinding by viewBinding()
    private val navArgs: ConversationsFragmentArgs by navArgs()
    private val viewModel: ConversationViewModel by viewModels()

    private val conversationAdapter = ConversationAdapter()

    private val stateObserver = Observer<ConversationViewState> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

            when(it) {
                is Content -> {
                    conversationAdapter.setConversations(it.conversations)
                    binding.contentContainer.visibility = View.VISIBLE
                }
                is SelectUsers -> showUserSelectionDialog()
                Loading -> binding.progressBar.visibility = View.VISIBLE
                is Error -> toast { it.message }
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

        observe(viewModel.viewStateLiveData, stateObserver)
        viewModel.initClient(navArgs)
    }

    private fun showUserSelectionDialog() {
        context?.let { context ->
            val builder: AlertDialog.Builder = AlertDialog.Builder(context)
            builder.setTitle("Select users")

            val userNames = navArgs.users.map { it.name }.toTypedArray()
            val selectedUsers = mutableSetOf<User>()

            builder.setMultiChoiceItems(userNames, null) { _, index, checked ->
                val user = navArgs.users[index]

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