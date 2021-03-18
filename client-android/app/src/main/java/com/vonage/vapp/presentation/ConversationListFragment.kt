package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.vonage.vapp.R
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.CreateConversationResponseModel
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.data.model.User
import com.vonage.vapp.databinding.FragmentConversationListBinding
import com.vonage.vapp.utils.viewBinding
import kotlinx.coroutines.launch

class ConversationListFragment : Fragment(R.layout.fragment_conversation_list) {

    private val binding: FragmentConversationListBinding by viewBinding()
    private val navArgs: ConversationListFragmentArgs by navArgs()
    private val conversationAdapter = ConversationAdapter()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.recyclerView.apply {
            setHasFixedSize(true)

            layoutManager = LinearLayoutManager(this.context)
            adapter = conversationAdapter
        }

        conversationAdapter.setOnClickListener {
            findNavController().navigate(R.id.action_conversationListFragment_to_conversationFragment)
        }

        binding.addFab.setOnClickListener {
            showUserSelectionDialog()
        }

        loadConversations()
    }

    private fun showUserSelectionDialog() {
        context?.let { context ->
            val builder: AlertDialog.Builder = AlertDialog.Builder(context)
            builder.setTitle("Select users")

            val userNames = navArgs.users.map { it.name }.toTypedArray()
            val selectedUsers = mutableSetOf(navArgs.user)

            builder.setMultiChoiceItems(userNames, null) { _, index, checked ->
                val user = navArgs.users[index]

                if (checked) {
                    selectedUsers.add(user)
                } else {
                    selectedUsers.remove(user)
                }
            }

            builder.setPositiveButton("OK") { dialog, _ ->
                createConversation(selectedUsers)
            }

            builder.setNegativeButton("Cancel") { dialog, _ -> dialog.cancel() }

            builder.show()
        }
    }

    private fun createConversation(users: Set<User>) {

        lifecycleScope.launch {
            val userIds = users.map { it.id }.toSet()
            val result = ApiRepository.createConversation(userIds)

            if (result is CreateConversationResponseModel) {
                conversationAdapter.addConversation(result.conversation)

                // navigate
            } else if (result is ErrorResponseModel) {
                // Error
            }
        }
    }

    private fun loadConversations() {
        binding.progressBar.visibility = View.VISIBLE

        lifecycleScope.launch {
            val result = ApiRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                conversationAdapter.setConversations(result.conversations)
                binding.progressBar.visibility = View.GONE
            } else if (result is ErrorResponseModel) {
                // how error
            }
        }
    }
}