//
//  ChatInviteView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 19/03/2024.
//

import SwiftUI
import VonageClientSDK

struct ChatInviteView: View {
    @StateObject var viewModel: ChatInviteViewModel
    @State private var selectedUsers = Set<String>()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        List(viewModel.users, selection: $selectedUsers) { user in
                            Text(user.name)
                        }.environment(\.editMode, .constant(EditMode.active))
                        
                        Spacer()
                        
                        Button("Invite") {
                            Task {
                                viewModel.isLoading = true
                                await viewModel.invite(selectedUsers)
                                viewModel.isLoading = false
                            }
                        }.buttonStyle(.bordered)
                    }
                }
            }
            .onChange(of: viewModel.membersInvited, initial: false) { oldValue, newValue in
                if newValue { dismiss() }
            }
            .navigationTitle("Invite to Conversation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

final class ChatInviteViewModel: ObservableObject {
    private let conversationId: String
    private let clientManager = ClientManager.shared
    
    var users: [Users.User] {
        clientManager.users
    }
    
    @Published var isLoading = false
    @Published var membersInvited = false
    
    init(conversationId: String) {
        self.conversationId = conversationId
    }
    
    public func invite(_ invitedUsers: Set<String>) async {
        let usernames = invitedUsers.map { uId in
            let user = users.first { $0.id == uId }
            return user?.name
        }.compactMap { $0 }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for username in usernames {
                group.addTask {
                    let memberId = try await self.clientManager.client.inviteToConversation(self.conversationId, username: username)
                }
            }
        }
        
        await MainActor.run {
            membersInvited = true
        }
    }
}
