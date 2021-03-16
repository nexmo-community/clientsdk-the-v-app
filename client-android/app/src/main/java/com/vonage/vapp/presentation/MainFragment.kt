package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.vonage.vapp.R
import com.vonage.vapp.databinding.FragmentMainBinding
import com.vonage.vapp.utils.viewBinding

class MainFragment : Fragment(R.layout.fragment_main) {

    private val binding: FragmentMainBinding by viewBinding()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.loginButton.setOnClickListener {
            findNavController().navigate(R.id.action_MainFragment_to_loginFragment)
        }

        binding.signUpButton.setOnClickListener {
            findNavController().navigate(R.id.action_MainFragment_to_SignupFragment)
        }
    }
}