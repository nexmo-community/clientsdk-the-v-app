package com.vonage.vapp.utils

import android.widget.Toast
import androidx.fragment.app.Fragment

inline fun Fragment.toast(message: () -> String) {
    Toast.makeText(this.context, message(), Toast.LENGTH_LONG).show()
}