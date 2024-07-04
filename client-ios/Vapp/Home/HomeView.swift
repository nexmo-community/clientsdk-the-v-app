//
//  HomeView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import SwiftUI
import VonageClientSDK

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var selectedConversation: VGConversation?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    if viewModel.conversations.isEmpty {
                        Button("Start a Conversation") {
                            viewModel.showNewConversation = true
                        }.buttonStyle(.bordered)
                    } else {
                        List {
                            Section(header: Text("Conversations")) {
                                ForEach(viewModel.conversations[.joined] ?? []) { conversation in
                                    HStack {
                                        Text(conversation.displayName ?? "")
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedConversation = conversation
                                    }
                                    .swipeActions {
                                        Button("Delete") {
                                            Task {
                                                await viewModel.deleteConversation(conversation.id)
                                            }
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                            
                            Section(header: Text("Invites")) {
                                ForEach(viewModel.conversations[.invited] ?? []) { conversation in
                                    HStack {
                                        Text(conversation.displayName ?? "")
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedConversation = conversation
                                    }
                                    .swipeActions {
                                        Button("Decline") {
                                            Task {
                                                await viewModel.declineInvite(conversation.id)
                                            }
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                        .refreshable {
                            await triggerConversationLoad()
                        }
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.errorContainer.hasError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorContainer.text))
        }
        .navigationTitle("V App")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.showNewConversation = true
                }) {
                    Image(systemName: "plus")
                }
                
                Button(action: {
                    viewModel.showUsers = true
                }) {
                    Image(systemName: "person.circle")
                }
                
                Button(action: {
                    viewModel.showSettings = true
                }) {
                    Image(systemName: "gear")
                }
            }
        }
        .navigationDestination(item: $selectedConversation) { conversation in
            ChatView(viewModel: .init(conversationId: conversation.id, conversationDisplayName: conversation.displayName))
        }
        .navigationDestination(isPresented: $viewModel.callAccepted) {
            CallView(viewModel: .init(callId: viewModel.incomingCallId, callee: viewModel.incomingCaller))
        }
        .sheet(isPresented: $viewModel.showUsers) {
            UsersView()
        }
        .sheet(isPresented: $viewModel.showSettings, onDismiss: {
            if viewModel.shouldLogout {
                dismiss()
            }
        }) {
            SettingsView(homeViewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showIncomingCall) {
            IncomingCallView(viewModel: viewModel)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showIncomingChat) {
            IncomingChatView(viewModel: viewModel)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showNewConversation, onDismiss: {
            Task {
                await triggerConversationLoad()
            }
        }, content: {
            CreateConversationView()
        })
        .task {
            await triggerConversationLoad()
        }
    }
    
    func triggerConversationLoad() async {
        viewModel.isLoading = true
        await viewModel.loadConversations()
        viewModel.isLoading = false
    }
}
