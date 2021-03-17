package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.vonage.vapp.R
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

        if(binding.nameTextView.error != null || binding.passwordTextView.error != null) {
            return
        }

        viewLifecycleOwner.lifecycleScope.launch {
            // do login
        }
    }

    private fun updateTextView(textView: TextView, errorMessage: String) {
        textView.apply {
            error = if(text.toString().isEmpty()) errorMessage else null
        }
    }
}