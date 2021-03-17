package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.vonage.vapp.R
import com.vonage.vapp.data.BackendRepository
import com.vonage.vapp.data.model.GetConversationsResponseModel
import com.vonage.vapp.databinding.FragmentConversationListBinding
import com.vonage.vapp.utils.viewBinding
import kotlinx.coroutines.launch

class ConversationListFragment : Fragment(R.layout.fragment_conversation_list) {

    private val binding: FragmentConversationListBinding by viewBinding()
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

        loadConversations()
    }

    private fun loadConversations() {
        binding.progressBar.visibility = View.VISIBLE

        lifecycleScope.launch {
            val result = BackendRepository.getConversations()

            if (result is GetConversationsResponseModel) {
                conversationAdapter.conversations = result.conversations
                binding.progressBar.visibility = View.GONE
            } else {
                    // how error
            }
        }
    }
}