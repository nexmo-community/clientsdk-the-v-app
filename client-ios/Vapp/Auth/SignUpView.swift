//
//  SignUpView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @StateObject var clientManager = ClientManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        TextField("Display Name", text: $viewModel.displayName).textFieldStyle(.roundedBorder)
                        TextField("Username", text: $viewModel.username).textFieldStyle(.roundedBorder)
                        SecureField("Password", text: $viewModel.password).textFieldStyle(.roundedBorder)
                        
                        Button("Sign Up") {
                            Task {
                                viewModel.isLoading = true
                                await viewModel.signUp()
                                viewModel.isLoading = false
                            }
                        }.buttonStyle(.bordered)
                    }.padding()
                }
            }
            .alert(isPresented: $viewModel.errorContainer.hasError) {
                Alert(title: Text("Error"), message: Text(viewModel.errorContainer.text))
            }
            .navigationDestination(isPresented: $clientManager.isAuthed) {
                HomeView()
            }
        }
    }
}

final class SignUpViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var username = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorContainer = (hasError: false, text: "")
    
    @MainActor
    func signUp() async {
        do {
            try await ClientManager.shared.auth(username: username, password: password, displayName: displayName, path: Auth.signupPath)
            username = ""
            password = ""
            displayName = ""
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
}
