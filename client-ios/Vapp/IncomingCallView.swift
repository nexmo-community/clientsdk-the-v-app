//
//  IncomingCallView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 22/03/2024.
//

import SwiftUI

struct IncomingCallView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text("Call from \(viewModel.incomingCaller)")
                .padding(16)
            HStack {
                Button("Accept") {
                    Task {
                        await viewModel.acceptCallInvite()
                    }
                }
                .tint(.green)
                .buttonStyle(.bordered)
                
                Button("Reject") {
                    Task {
                        await viewModel.rejectCallInvite()
                    }
                }
                .tint(.red)
                .buttonStyle(.bordered)
            }
        }
    }
}
