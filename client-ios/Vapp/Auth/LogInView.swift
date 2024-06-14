//
//  LogInView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import SwiftUI

struct LogInView: View {
    @StateObject var viewModel = LogInViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        TextField("Username", text: $viewModel.username).textFieldStyle(.roundedBorder)
                        SecureField("Password", text: $viewModel.password).textFieldStyle(.roundedBorder)
                        
                        Button("Log In") {
                            Task {
                                viewModel.isLoading = true
                                await viewModel.logIn()
                                viewModel.isLoading = false
                            }
                        }.buttonStyle(.bordered)
                        
                        Button("Sign up?") {
                                viewModel.showSignUp = true
                        }.buttonStyle(.bordered)
                    }.padding()
                }
            }
            .task {
                viewModel.isLoading = true
                await viewModel.attemptStoredLogIn()
                viewModel.isLoading = false
            }
            .alert(isPresented: $viewModel.errorContainer.hasError) {
                Alert(title: Text("Error"), message: Text(viewModel.errorContainer.text))
            }
            .navigationDestination(isPresented: $viewModel.showHomeView) {
                HomeView()
            }
            .navigationDestination(isPresented: $viewModel.showSignUp) {
                SignUpView()
            }
        }
    }
}

final class LogInViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var showSignUp = false
    @Published var showHomeView = false
    @Published var errorContainer = (hasError: false, text: "")
    
    private let clientManager = ClientManager.shared
    
    @MainActor
    func logIn() async {
        do {
            try await clientManager.auth(username: username, password: password, path: Auth.loginPath)
            username = ""
            password = ""
            if clientManager.isAuthed {
                showHomeView = true
            }
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    @MainActor
    func attemptStoredLogIn() async {
        await clientManager.attemptStoredLogIn()
        if clientManager.isAuthed {
            showHomeView = true
        }
    }
}
