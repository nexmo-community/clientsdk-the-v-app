//
//  CreateConversationView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 18/03/2024.
//

import SwiftUI
import VonageClientSDK

struct CreateConversationView: View {
    @StateObject var viewModel = NewConversationViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Form {
                        Section(header: Text("Conversation Details")) {
                            TextField("Display Name", text: $viewModel.displayName)
                        }
                        
                        Button("Create") {
                            Task {
                                viewModel.isLoading = true
                                await viewModel.createConversation()
                                viewModel.isLoading = false
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.conversationCreated, initial: false) { oldValue, newValue in
                if newValue { dismiss() }
            }
            .alert(isPresented: $viewModel.errorContainer.hasError) {
                Alert(title: Text("Error creating conversation"), message: Text(viewModel.errorContainer.text))
            }
            .navigationTitle("Create a New Conversation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

final class NewConversationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var conversationCreated = false
    
    @Published var displayName = ""
    
    @Published var errorContainer = (hasError: false, text: "")
    
    private let clientManager = ClientManager.shared
    
    @MainActor
    func createConversation() async {
        if (displayName.isEmpty) {
            errorContainer = (true, "Please provide a conversation name and display name.")
            return
        }
        
        let params = VGCreateConversationParameters(displayName: displayName)
        
        do {
            let convId = try await clientManager.client.createConversation(params)
            _ = try await clientManager.client.joinConversation(convId)
            conversationCreated = true
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
}
