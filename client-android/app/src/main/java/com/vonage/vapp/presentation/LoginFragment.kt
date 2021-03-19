package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.data.ApiRepository
import com.vonage.vapp.data.model.ErrorResponseModel
import com.vonage.vapp.data.model.LoginResponseModel
import com.vonage.vapp.databinding.FragmentLoginBinding
import kotlinx.coroutines.launch

class LoginFragment : Fragment(R.layout.fragment_login) {
    private val binding: FragmentLoginBinding by viewBinding()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.loginButton.setOnClickListener {
            login()
        }

        binding.signupButton.setOnClickListener {
            findNavController().navigate(R.id.action_loginFragment_to_SignupFragment)
        }

        login()
    }

    private fun login() {
        updateTextView(binding.nameTextView, "Enter name")
        updateTextView(binding.passwordTextView, "Enter password")

        if (binding.nameTextView.error != null || binding.passwordTextView.error != null) {
            return
        }

        lifecycleScope.launch {
            val result = ApiRepository.login(
                binding.nameTextView.text.toString(),
                binding.passwordTextView.text.toString()
            )

            if (result is LoginResponseModel) {
                val navDirections = LoginFragmentDirections.actionLoginFragmentToConversationsFragment(
                    result.user,
                    result.users.toTypedArray(),
                    result.conversations.filterNotNull().toTypedArray(),
                    result.token
                )

                findNavController().navigate(navDirections)
            } else if (result is ErrorResponseModel) {
                toast { "${result.title} - ${result.detail}" }
            }
        }
    }

    private fun updateTextView(textView: TextView, errorMessage: String) {
        textView.apply {
            error = if (text.toString().isEmpty()) errorMessage else null
        }
    }
}