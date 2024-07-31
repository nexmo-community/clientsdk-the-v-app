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
                        if let url = user.imageURL {
                            AsyncImage(url: URL(string: url)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(8)
                                } else {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(8)
                        }
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
