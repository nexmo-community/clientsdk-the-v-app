package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.vonage.vapp.R
import com.vonage.vapp.data.BackendRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.LoginResponseModel
import com.vonage.vapp.databinding.FragmentLoginBinding
import com.vonage.vapp.utils.viewBinding
import kotlinx.coroutines.launch

class LoginFragment : Fragment(R.layout.fragment_login) {
    private val binding: FragmentLoginBinding by viewBinding()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.loginButton.setOnClickListener {
            login()
        }
    }

    private fun login() {
        updateTextView(binding.nameTextView, "Enter name")
        updateTextView(binding.passwordTextView, "Enter password")

        if (binding.nameTextView.error != null || binding.passwordTextView.error != null) {
            return
        }

        lifecycleScope.launch {
            val result = BackendRepository.login(
                binding.nameTextView.text.toString(),
                binding.passwordTextView.text.toString()
            )

            if (result is LoginResponseModel) {
                findNavController().navigate(R.id.action_loginFragment_to_conversationListFragment)
            } else if (result is ErrorResponseModel) {
                binding.messageTextView.text = result.detail
            }
        }
    }

    private fun updateTextView(textView: TextView, errorMessage: String) {
        textView.apply {
            error = if (text.toString().isEmpty()) errorMessage else null
        }
    }
}