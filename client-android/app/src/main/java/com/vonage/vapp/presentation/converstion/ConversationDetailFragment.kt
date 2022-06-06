package com.vonage.vapp.presentation.converstion

import android.content.ContentResolver
import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.ConcatAdapter
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoMessage
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.data.model.Event
import com.vonage.vapp.databinding.FragmentConversationDetailBinding
import com.vonage.vapp.presentation.converstion.ConversationDetailViewModel.Action.*
import com.vonage.vapp.utils.viewBinding
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream


class ConversationDetailFragment : Fragment(R.layout.fragment_conversation_detail) {
    private val client: NexmoClient = NexmoClient.get()

    private val binding by viewBinding<FragmentConversationDetailBinding>()
    private val navArgs by navArgs<ConversationDetailFragmentArgs>()
    private val viewModel by viewModels<ConversationDetailViewModel>()

    private val getImageContent = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        if (uri != null) {
            fileFromURI(uri)?.let { viewModel.uploadImage(it) }
        }
    }

    private val actionObserver = Observer<ConversationDetailViewModel.Action> {
        binding.progressBar.visibility = View.INVISIBLE
        binding.contentContainer.visibility = View.INVISIBLE

        when (it) {
            is Error -> toast { it.message }
            is Loading -> binding.progressBar.visibility = View.VISIBLE
            is AddConversationLine -> {
                binding.contentContainer.visibility = View.VISIBLE
            }
            is SetConversation -> {
                binding.contentContainer.visibility = View.VISIBLE
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val eventAdapter = EventAdapter()

        observe(viewModel.viewActionLiveData, actionObserver)
        viewModel.init(navArgs)

        binding.conversationEventsRecyclerView.adapter = eventAdapter

        viewModel.eventsLiveData.observe(viewLifecycleOwner) {
            it?.let {
                eventAdapter.submitList(it)
            }
        }

        binding.sendMessageButton.setOnClickListener {
            val message = binding.messageEditText.text.toString()

            if (message.isNotBlank()) {
                viewModel.sendMessage(NexmoMessage.fromText(message))
            }

            binding.messageEditText.setText("")
        }

        binding.sendImageButton.setOnClickListener{
            getImageContent.launch("image/*")
        }
    }

    private fun fileFromURI(uri: Uri): File? {
        val contentResolver: ContentResolver = context?.contentResolver ?: return null

        val filePath: String = (context?.applicationInfo?.dataDir.toString() + File.separator
                + System.currentTimeMillis())
        val file = File(filePath)
        try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val outputStream: OutputStream = FileOutputStream(file)
            val buf = ByteArray(1024)
            var len: Int
            while (inputStream.read(buf).also { len = it } > 0) outputStream.write(buf, 0, len)
            outputStream.close()
            inputStream.close()
        } catch (ignore: IOException) {
            return null
        }
        return file
    }
}
