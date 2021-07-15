package com.vonage.tutorial.voice

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.vonage.vapp.R
import com.vonage.vapp.core.BackPressHandler
import com.vonage.vapp.databinding.FragmentOnCallBinding
import com.vonage.vapp.utils.viewBinding

class OnCallFragment : Fragment(R.layout.fragment_on_call), BackPressHandler {

    private val binding by viewBinding<FragmentOnCallBinding>()
    private val viewModel by viewModels<OnCallViewModel>()

    private val toastObserver = Observer<String> {
        Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show();
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.toast.observe(viewLifecycleOwner, toastObserver)

        binding.endCall.setOnClickListener {
            viewModel.hangup()
        }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}
