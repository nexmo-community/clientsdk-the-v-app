//
//  HomeViewModel.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 28/03/2024.
//

import Foundation
import Combine
import VonageClientSDK

final class HomeViewModel: ObservableObject {
    private let clientManager = ClientManager.shared
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var isLoading = false
    @Published var conversations: [VGConversation] = []
    
    @Published var showNewConversation = false
    @Published var showIncomingCall = false
    @Published var showIncomingChat = false
    @Published var showSettings = false
    @Published var showUsers = false
    
    @Published var shouldLogout = false
    
    @Published var callAccepted = false
    @Published var chatInviteAccepted = false
    
    @Published var errorContainer = (hasError: false, text: "")
    
    var incomingCallId: String!
    var incomingCaller: String!
    
    var incomingConversationId: String!
    var incomingInviter: String!
    
    var user: Users.User?
    var token: String?
    
    init() {
        self.user = clientManager.user
        self.token = clientManager.token
        
        clientManager.onCall
            .receive(on: DispatchQueue.main)
            .sink { [weak self] call in
                switch call {
                case .invite(let callId, let caller):
                    self?.showIncomingCall = true
                    self?.incomingCallId = callId
                    self?.incomingCaller = caller
                case .inviteCancel:
                    self?.showIncomingCall = false
                }
            }
            .store(in: &subscriptions)
        
        clientManager.onEvent
            .receive(on: DispatchQueue.main)
            .filter { $0.kind == .memberInvited }
            .filter { !($0.from is VGSystem) }
            .map { $0 as! VGMemberInvitedEvent }
            .sink { [weak self] event in
                guard event.body.user.name == self?.clientManager.user?.name else { return }
                self?.incomingConversationId = event.conversationId
                self?.incomingInviter = "Unknown"
                
                if let userInfo = event.from as? VGEmbeddedInfo {
                    self?.incomingInviter = userInfo.user.name
                }
                
                self?.showIncomingChat = true
            }.store(in: &subscriptions)
    }
    
    @MainActor
    func loadConversations() async {
        do {
            let conversationPage = try await clientManager.client.getConversations()
            conversations = conversationPage.conversations.filter { !$0.name.contains("NAM") }
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    @MainActor
    func deleteConversation(_ id: String) async {
        do {
            try await clientManager.client.deleteConversation(id)
            conversations.removeAll { $0.id == id }
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    @MainActor
    func acceptCallInvite() async {
        do {
            showIncomingCall = false
            try await clientManager.client.answer(incomingCallId)
            callAccepted = true
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    @MainActor
    func rejectCallInvite() async {
        do {
            try await clientManager.client.reject(incomingCallId)
            showIncomingCall = false
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    @MainActor
    func acceptChatInvite() async {
        do {
            showIncomingChat = false
            _ = try await clientManager.client.joinConversation(incomingConversationId)
            await loadConversations()
            chatInviteAccepted = true
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    func rejectChatInvite() async {
        await MainActor.run {
            showIncomingChat = false
        }
    }
    
    @MainActor
    func logout() async {
        do {
            showSettings = false
            try await clientManager.logout()
            shouldLogout = true
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    func updateUser(imageURL: String?) {
        guard let user = user, let imageURL = imageURL else { return }
        let newUser = Users.User(id: user.id, name: user.name, displayName: user.displayName, imageURL: imageURL)
        self.user = newUser
    }
}
