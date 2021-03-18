package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener
import com.vonage.vapp.R
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.Conversation
import com.vonage.vapp.data.model.CreateConversationResponseModel
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.data.model.User
import com.vonage.vapp.databinding.FragmentConversationsBinding
import com.vonage.vapp.utils.viewBinding
import kotlinx.coroutines.launch

class ConversationsFragment : Fragment(R.layout.fragment_conversations) {

    private val binding: FragmentConversationsBinding by viewBinding()
    private val navArgs: ConversationsFragmentArgs by navArgs()
    private val conversationAdapter = ConversationAdapter()
    private val client get() = NexmoClient.get()
    private val conversations by lazy { navArgs.conversations.toMutableList() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.recyclerView.apply {
            setHasFixedSize(true)

            layoutManager = LinearLayoutManager(this.context)
            adapter = conversationAdapter
        }

        conversationAdapter.setOnClickListener {
            navigateToConversation(it)
        }

        binding.addFab.setOnClickListener {
            showUserSelectionDialog()
        }

        binding.swipeRefreshLayout.setOnRefreshListener {
            binding.swipeRefreshLayout.isRefreshing = false
            loadConversations()
        }

        initClient()
    }

    private fun initClient() {
        if (!client.isConnected) {
            binding.progressBar.visibility = View.VISIBLE

            client.setConnectionListener { newConnectionStatus, _ ->

                if (newConnectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                    activity?.runOnUiThread {
                        conversationAdapter.setConversations(conversations)
                        binding.progressBar.visibility = View.GONE
                    }

                    return@setConnectionListener
                }
            }

            client.login(navArgs.token)
        }
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
                createConversation(selectedUsers)
            }

            builder.setNegativeButton("Cancel") { dialog, _ -> dialog.cancel() }

            builder.show()
        }
    }

    private fun navigateToConversation(conversation: Conversation) {
        val navDirections =
            ConversationsFragmentDirections.actionConversationsFragmentToConversationDetailFragment(
                conversation,
                navArgs.users + navArgs.user
            )
        findNavController().navigate(navDirections)
    }

    private fun createConversation(users: Set<User>) {
        lifecycleScope.launch {
            val userIds = users.map { it.id }.toSet()
            val result = ApiRepository.createConversation(userIds)

            if (result is CreateConversationResponseModel) {
                conversationAdapter.addConversation(result.conversation)
                navigateToConversation(result.conversation)
            } else if (result is ErrorResponseModel) {
                // Error
            }
        }
    }

    private fun loadConversations() {
        binding.progressBar.visibility = View.VISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        lifecycleScope.launch {
            val result = ApiRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                conversationAdapter.setConversations(result.conversations)
                binding.progressBar.visibility = View.GONE
                binding.contentContainer.visibility = View.VISIBLE
            } else if (result is ErrorResponseModel) {
                // error
            }
        }
    }
}