package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.vonage.vapp.R
import com.vonage.vapp.data.BackendRepository
import com.vonage.vapp.databinding.FragmentSignupBinding
import com.vonage.vapp.utils.viewBinding
import kotlinx.coroutines.launch

class SignupFragment : Fragment(R.layout.fragment_signup) {

    private val binding: FragmentSignupBinding by viewBinding()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.signUpButton.setOnClickListener {
            signUp()
        }
    }

    private fun signUp() {

        updateTextView(binding.nameTextView, "Enter name")
        updateTextView(binding.displayNameTextView, "Enter display name")
        updateTextView(binding.passwordTextView, "Enter password")

        if(binding.nameTextView.error != null
            || binding.displayNameTextView.error != null
            || binding.passwordTextView.error != null
        ) {
            return
        }

        viewLifecycleOwner.lifecycleScope.launch {
            val respnse = BackendRepository.signup(
                binding.nameTextView.text.toString(),
                binding.displayNameTextView.text.toString(),
                binding.passwordTextView.text.toString()
            )

            val a  = 2
        }
    }

    private fun updateTextView(textView: TextView, errorMessage: String) {
        textView.apply {
            error = if(text.toString().isEmpty()) errorMessage else null
        }
    }
}
