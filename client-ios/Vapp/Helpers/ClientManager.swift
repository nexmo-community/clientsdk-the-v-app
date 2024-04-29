//
//  ClientManager.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import Combine
import Foundation
import VonageClientSDK

final class ClientManager: NSObject, ObservableObject {
    static let shared = ClientManager()
    
    public var user: Users.User? = nil
    public var token: String? = nil
    public var client: VGVonageClient!
    
    @Published var isAuthed = false
    var users: [Users.User] = []
    
    // Chat Publisher
    private var handledEventKinds: Set<VGEventKind> = [.memberInvited, .memberJoined, .memberLeft, .messageText]
    private let messageSubject = PassthroughSubject<VGConversationEvent, Never>()
    public var onEvent: AnyPublisher<VGConversationEvent, Never> {
        messageSubject
            .filter { self.handledEventKinds.contains($0.kind) }
            .eraseToAnyPublisher()
    }
    
    // Call Event Publisher
    enum CallEvent {
        case hangup(callId: String, reason: VGHangupReason)
        case update(callId: String, legId: String, status: VGLegStatus)
    }
    private let callEventSubject = PassthroughSubject<CallEvent, Never>()
    public var onCallEvent: AnyPublisher<CallEvent, Never> {
        callEventSubject.eraseToAnyPublisher()
    }
    
    // Call Publisher
    enum IncomingCallEvent {
        case invite(callId: String, caller: String)
        case inviteCancel(callId: String, reason: VGVoiceInviteCancelReason)
    }
    private let incomingCallSubject = PassthroughSubject<IncomingCallEvent, Never>()
    public var onCall: AnyPublisher<IncomingCallEvent, Never> {
        incomingCallSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        initializeClient()
    }
    
    // MARK: - Public
    
    public func auth(username: String, password: String, displayName: String? = nil, path: String, shouldStoreCredentials: Bool = true) async throws {
        let body = Auth.Body(name: username, password: password, displayName: displayName)
        
        let authResponse: Auth.Response = try await RemoteLoader.post(path: path, body: body)
        self.token = authResponse.token
        self.user = authResponse.user
        try await client?.createSession(authResponse.token)
        
        if shouldStoreCredentials {
            storeCredentials(username: username, password: password)
        }
        
        await MainActor.run {
            isAuthed = true
            users = authResponse.users
        }
    }
    
    public func attemptStoredLogIn() async {
        if let credentials = getCredentials() {
            try? await auth(username: credentials.0, password: credentials.1, path: Auth.loginPath, shouldStoreCredentials: false)
        }
    }
    
    public func logout() async throws {
        if let username = user?.name {
            try await client.deleteSession()
            deleteCredentials(username: username)
        } else {
            // TODO: throw error
        }
    }
    
    // MARK: - Private
    
    private func initializeClient() {
        VGVonageClient.isUsingCallKit = false
        let config = VGClientInitConfig(loggingLevel: .error, region: .EU, enableWebSocketInvites: true, rtcStatsTelemetry: false)
        self.client = VGVonageClient(config)
        client.delegate = self
    }
    
    private func refreshToken() async {
        if let credentials = getCredentials() {
            let body = Auth.Body(name: credentials.0, password: credentials.1, displayName: nil)
            do {
                let authResponse: Auth.RefreshResponse = try await RemoteLoader.post(path: Auth.refreshPath, body: body)
                self.token = authResponse.token
                try await self.client.refreshSession(authResponse.token)
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - VGClientDelegate

extension ClientManager: VGClientDelegate {
    func voiceClient(_ client: VGVoiceClient, didReceiveInviteForCall callId: VGCallId, from caller: String, with type: VGVoiceChannelType) {
        incomingCallSubject.send(.invite(callId: callId, caller: caller))
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveInviteCancelForCall callId: VGCallId, with reason: VGVoiceInviteCancelReason) {
        incomingCallSubject.send(.inviteCancel(callId: callId, reason: reason))
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveHangupForCall callId: VGCallId, withQuality callQuality: VGRTCQuality, reason: VGHangupReason) {
        callEventSubject.send(.hangup(callId: callId, reason: reason))
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveLegStatusUpdateForCall callId: VGCallId, withLegId legId: String, andStatus status: VGLegStatus) {
        callEventSubject.send(.update(callId: callId, legId: legId, status: status))
    }
    
    func chatClient(_ client: VGChatClient, didReceiveConversationEvent event: VGConversationEvent) {
        messageSubject.send(event)
    }
    
    func client(_ client: VGBaseClient, didReceiveSessionErrorWith reason: VGSessionErrorReason) {
        Task {
            await refreshToken()
        }
    }
}

// MARK: - Keychain Storage

extension ClientManager {
    private func storeCredentials(username: String, password: String) {
        if let passwordData = password.data(using: .utf8) {
            let keychainItem = [
                kSecClass: kSecClassInternetPassword,
                kSecAttrServer: Constants.keychainServer,
                kSecReturnData: true,
                kSecReturnAttributes: true,
                kSecAttrAccount: username,
                kSecValueData: passwordData
            ] as CFDictionary
            
            let status = SecItemAdd(keychainItem, nil)
            print("Keychain storing finished with status: \(status)")
        }
    }
    
    func getCredentials() -> (String, String)? {
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: Constants.keychainServer,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: 1
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        print("Keychain querying finished with status: \(status)")
        
        if let resultArray = result as? NSDictionary,
           let username = resultArray[kSecAttrAccount] as? String,
           let passwordData = resultArray[kSecValueData] as? Data,
           let password = String(data: passwordData, encoding: .utf8) {
            return (username, password)
        } else {
            return nil
        }
    }
    
    private func deleteCredentials(username: String) {
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: Constants.keychainServer,
            kSecAttrAccount: username
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
