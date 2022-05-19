package com.vonage.vapp.presentation.converstion

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.nexmo.client.NexmoClient
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.databinding.FragmentConversationDetailBinding
import com.vonage.vapp.presentation.converstion.ConversationDetailViewModel.Action.AddConversationLine
import com.vonage.vapp.presentation.converstion.ConversationDetailViewModel.Action.Error
import com.vonage.vapp.presentation.converstion.ConversationDetailViewModel.Action.Loading
import com.vonage.vapp.presentation.converstion.ConversationDetailViewModel.Action.SetConversation
import com.vonage.vapp.utils.viewBinding

class ConversationDetailFragment : Fragment(R.layout.fragment_conversation_detail) {
    private val client: NexmoClient = NexmoClient.get()

    private val binding by viewBinding<FragmentConversationDetailBinding>()
    private val navArgs by navArgs<ConversationDetailFragmentArgs>()
    private val viewModel by viewModels<ConversationDetailViewModel>()

    private val actionObserver = Observer<ConversationDetailViewModel.Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is Error -> toast { it.message }
            is Loading -> binding.progressBar.visibility = View.VISIBLE
            is AddConversationLine -> {
                binding.contentContainer.visibility = View.VISIBLE
                binding.conversationEventsTextView.append(it.line)
            }
            is SetConversation -> {
                binding.contentContainer.visibility = View.VISIBLE
                binding.conversationEventsTextView.text = it.conversation
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observe(viewModel.viewActionLiveData, actionObserver)
        viewModel.init(navArgs)

        binding.sendMessageButton.setOnClickListener {
            val message = binding.messageEditText.text.toString()

            if (message.isNotBlank()) {
                viewModel.sendTextMessage(message)
            }

            binding.messageEditText.setText("")
        }
    }
}
