package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import com.vonage.vapp.R
import com.vonage.vapp.databinding.FragmentSignupBinding
import com.vonage.vapp.utils.viewBinding

class SignupFragment : Fragment(R.layout.fragment_signup) {

    private val binding: FragmentSignupBinding by viewBinding()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
    }
}