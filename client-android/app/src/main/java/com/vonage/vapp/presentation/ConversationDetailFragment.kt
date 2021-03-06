package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.databinding.FragmentConversationDetailBinding

class ConversationDetailFragment : Fragment(R.layout.fragment_conversation_detail) {
    private val client: NexmoClient = NexmoClient.get()

    private val binding by viewBinding<FragmentConversationDetailBinding>()
    private val navArgs by navArgs<ConversationDetailFragmentArgs>()
    private val viewModel by viewModels<ConversationDetailViewModel>()

    private val actionObserver = Observer<ConversationDetailViewModel.Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is ConversationDetailViewModel.Action.Error -> toast { it.message }
            is ConversationDetailViewModel.Action.Loading -> binding.progressBar.visibility = View.VISIBLE
            is ConversationDetailViewModel.Action.AddConversationLine -> {
                binding.contentContainer.visibility = View.VISIBLE
                binding.conversationEventsTextView.append(it.line)
            }
            is ConversationDetailViewModel.Action.SetConversation -> {
                binding.contentContainer.visibility = View.VISIBLE
                binding.conversationEventsTextView.text = it.conversation
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observe(viewModel.viewStateLiveData, actionObserver)
        viewModel.initClient(navArgs)

        binding.sendMessageButton.setOnClickListener {
            val message = binding.messageEditText.text.toString()

            if (message.isNotBlank()) {
                viewModel.sendMessage(message)
            }

            binding.messageEditText.setText("")
        }
    }
}
