package com.vonage.vapp.presentation

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.vonage.vapp.R

class MainFragment : Fragment(R.layout.fragment_main) {
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_main, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        view.findViewById<Button>(R.id.loginButton).setOnClickListener {
            findNavController().navigate(R.id.action_MainFragment_to_loginFragment)
        }

        view.findViewById<Button>(R.id.signUpButton).setOnClickListener {
            findNavController().navigate(R.id.action_MainFragment_to_SignupFragment)
        }
    }
}