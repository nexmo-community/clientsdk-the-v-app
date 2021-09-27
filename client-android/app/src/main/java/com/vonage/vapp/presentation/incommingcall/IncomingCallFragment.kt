package com.vonage.vapp.presentation.incommingcall

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import by.kirich1409.viewbindingdelegate.viewBinding
import com.vonage.vapp.R
import com.vonage.vapp.core.BackPressHandler
import com.vonage.vapp.databinding.FragmentIncomingCallBinding

class IncomingCallFragment : Fragment(R.layout.fragment_incoming_call), BackPressHandler {

    private val viewModel by viewModels<IncomingCallViewModel>()
    private val bindings by viewBinding<FragmentIncomingCallBinding>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.toast.observe(
            viewLifecycleOwner,
            { Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show() })

        bindings.hangupButton.setOnClickListener {
            viewModel.hangup()
        }

        bindings.answerButton.setOnClickListener {
            viewModel.answer()
        }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}