package com.vonage.vapp.core

import com.nexmo.client.NexmoCall

// Used to store reference of ongoing call
object CallManager {
    var onGoingCall: NexmoCall? = null
}
