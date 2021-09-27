package com.vonage.vapp.presentation.signup

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.vonage.vapp.R
import com.vonage.vapp.core.ext.observe
import com.vonage.vapp.core.ext.toast
import com.vonage.vapp.databinding.FragmentSignupBinding
import com.vonage.vapp.presentation.signup.SignupViewModel.Action
import com.vonage.vapp.utils.viewBinding

class SignupFragment : Fragment(R.layout.fragment_signup) {

    private val binding by viewBinding<FragmentSignupBinding>()
    private val viewModel by viewModels<SignupViewModel>()

    private val actionObserver = Observer<Action> {
        when (it) {
            is Action.Error -> toast { it.message }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.signUpButton.setOnClickListener {
            signUp()
        }

        observe(viewModel.viewActionLiveData, actionObserver)
    }

    private fun signUp() {

        updateTextView(binding.nameTextView, "Enter name")
        updateTextView(binding.displayNameTextView, "Enter display name")
        updateTextView(binding.passwordTextView, "Enter password")

        if (binding.nameTextView.error != null
            || binding.displayNameTextView.error != null
            || binding.passwordTextView.error != null
        ) {
            return
        }

        viewModel.signUp(
            binding.nameTextView.text.toString(),
            binding.displayNameTextView.text.toString(),
            binding.passwordTextView.text.toString()
        )
    }

    private fun updateTextView(textView: TextView, errorMessage: String) {
        textView.apply {
            error = if (text.toString().isEmpty()) errorMessage else null
        }
    }
}
