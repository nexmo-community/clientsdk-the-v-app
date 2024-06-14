//
//  IncomingChatView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 25/03/2024.
//

import SwiftUI

struct IncomingChatView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text("Chat Invite from \(viewModel.incomingInviter)")
                .padding(16)
            HStack {
                Button("Accept") {
                    Task {
                        await viewModel.acceptChatInvite()
                    }
                }
                .tint(.green)
                .buttonStyle(.bordered)
                
                Button("Reject") {
                    Task {
                        await viewModel.rejectChatInvite()
                    }
                }
                .tint(.red)
                .buttonStyle(.bordered)
            }
        }
    }
}
