//
//  UsersView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 19/03/2024.
//

import SwiftUI
import VonageClientSDK

struct UsersView: View {
    @StateObject var viewModel = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.users) { user in
                    HStack {
                        Text(user.name)
                        Spacer()
                        Button(action: {
                            Task {
                                await viewModel.startCall(callee: user.name)
                            }
                        }) {
                            Image(systemName: "phone.circle.fill")
                        }.buttonStyle(.borderless)
                    }
                }
            }
            .alert(isPresented: $viewModel.errorContainer.hasError) {
                Alert(title: Text("Error Making Call"), message: Text(viewModel.errorContainer.text))
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.callCreated) {
                CallView(viewModel: .init(callId: viewModel.callId, callee: viewModel.callee))
            }
        }
    }
}

final class UsersViewModel: ObservableObject {
    private let clientManager = ClientManager.shared
    
    @Published var isLoading = false
    @Published var callCreated = false
    @Published var errorContainer = (hasError: false, text: "")
    
    var callId = ""
    var callee = ""
    
    var users: [Users.User] {
        clientManager.users
    }
    
    @MainActor
    func startCall(callee: String) async {
        do {
            self.callId = try await clientManager.client.serverCall(["to" : callee])
            self.callee = callee
            callCreated = true
            
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
}
