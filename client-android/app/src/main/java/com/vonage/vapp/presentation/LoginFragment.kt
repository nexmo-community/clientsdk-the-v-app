package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.vonage.vapp.R
import com.vonage.vapp.core.delegate.viewBinding
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.databinding.FragmentLoginBinding
import com.vonage.vapp.presentation.LoginViewModel.State

class LoginFragment : Fragment(R.layout.fragment_login) {
    private val binding by viewBinding<FragmentLoginBinding>()
    private val viewModel by viewModels<LoginViewModel>()

    private val stateObserver = Observer<State> {
        when (it) {
            is State.Error -> toast { it.message }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.loginButton.setOnClickListener {
            login()
        }

        binding.signupButton.setOnClickListener {
            viewModel.navigateToSignup()
        }

        observe(viewModel.viewStateLiveData, stateObserver)

//        login()
    }

    private fun login() {
        updateTextView(binding.nameTextView, "Enter name")
        updateTextView(binding.passwordTextView, "Enter password")

        if (binding.nameTextView.error != null || binding.passwordTextView.error != null) {
            return
        }

        viewModel.login(binding.nameTextView.text.toString(), binding.passwordTextView.text.toString())
    }

    private fun updateTextView(textView: TextView, errorMessage: String) {
        textView.apply {
            error = if (text.toString().isEmpty()) errorMessage else null
        }
    }
}