//
//  ChatView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 18/03/2024.
//

import Combine
import SwiftUI
import VonageClientSDK

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @State private var message: String = ""
    @State private var listTopId: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.events.isEmpty || viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        ScrollViewReader { proxy in
                            List {
                                ForEach(viewModel.events.reversed(), id: \.id) { event in
                                    switch event.kind {
                                    case .memberJoined, .memberLeft, .memberInvited:
                                        let displayText = viewModel.generateDisplayText(event)
                                        Text(displayText.body)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    case.messageText:
                                        let displayText = viewModel.generateDisplayText(event)
                                        Text(displayText.body)
                                            .frame(maxWidth: .infinity, alignment: displayText.isUser ? .trailing : .leading)
                                    default:
                                        EmptyView()
                                    }
                                }.listRowSeparator(.hidden)
                            }
                            .onAppear {
                                proxy.scrollTo(viewModel.events.first!.id, anchor: .bottom)
                            }
                            .listStyle(.plain)
                            .refreshable {
                                Task {
                                    await viewModel.loadEarlierEvents()
                                    await MainActor.run {
                                        proxy.scrollTo(viewModel.cursorSize, anchor: .top)
                                    }
                                }
                            }
                            
                            Spacer(minLength: 16)
                            
                            HStack {
                                TextField("Message", text: $message)
                                Button("Send") {
                                    Task {
                                        await viewModel.sendMessage(message)
                                        self.message = ""
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            withAnimation(.easeInOut(duration: 1)) {
                                                proxy.scrollTo(viewModel.events.first!.id, anchor: .bottom)
                                            }
                                        }
                                    }
                                }.buttonStyle(.bordered)
                            }.padding(8)
                        }
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.errorContainer.hasError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorContainer.text))
        }
        .navigationTitle(viewModel.conversationDisplayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.showInviteUser = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showInviteUser) {
            ChatInviteView(viewModel: .init(conversationId: viewModel.conversationId))
        }
        .task {
            viewModel.isLoading = true
            await viewModel.getMemberIdIfNeeded()
            await viewModel.getInitialConversationEvents()
            viewModel.isLoading = false
        }
    }
}

final class ChatViewModel: ObservableObject {
    
    private var memberId: String?
    private var cursor: String? = nil
    private let clientManager = ClientManager.shared
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var events: [VGPersistentConversationEvent] = []
    @Published var showInviteUser = false
    @Published var isLoading = false
    
    @Published var errorContainer = (hasError: false, text: "")
    
    let conversationId: String
    let conversationDisplayName: String
    let cursorSize = 20
    
    init(conversationId: String, conversationDisplayName: String?) {
        self.conversationId = conversationId
        self.conversationDisplayName = conversationDisplayName ?? "Chat"
        
        clientManager.onEvent
            .receive(on: DispatchQueue.main)
            .map { $0 as! VGPersistentConversationEvent }
            .sink { [weak self] event in
                self?.events.insert(event, at: 0)
            }.store(in: &subscriptions)
    }
    
    
    // MARK: - Public
    
    func getMemberIdIfNeeded() async {
        guard memberId == nil else { return }
        await getMemberId()
    }
    
    func getInitialConversationEvents() async {
        let initialEvents = await getEvents()
        await MainActor.run {
            self.events = initialEvents
        }
    }
    
    private func getEvents() async -> [VGPersistentConversationEvent] {
        do {
            let params = VGGetConversationEventsParameters(order: .desc, pageSize: cursorSize, cursor: cursor)
            let eventsPage = try await clientManager.client.getConversationEvents(conversationId, parameters: params)
            cursor = eventsPage.nextCursor
            return eventsPage.events
        } catch {
            await MainActor.run {
                errorContainer = (true, error.localizedDescription)
            }
        }
        
        return []
    }
    
    func loadEarlierEvents() async {
        let earlierEvents = await getEvents()
        
        await MainActor.run {
            self.events += earlierEvents
        }
    }
    
    func sendMessage(_ message: String) async {
        guard !message.isEmpty else { return }
        
        do {
            _ = try await clientManager.client.sendMessageTextEvent(conversationId, text: message)
        } catch {
            await MainActor.run {
                errorContainer = (true, error.localizedDescription)
            }
        }
    }
    
    func generateDisplayText(_ event: VGPersistentConversationEvent) -> (body: String, isUser: Bool) {
        var from = "System"
        
        switch event.kind {
        case .memberInvited:
            let memberInvitedEvent = event as! VGMemberInvitedEvent
            from = memberInvitedEvent.body.user.name
            return ("\(from) Invited", false)
        case .memberJoined:
            let memberJoinedEvent = event as! VGMemberJoinedEvent
            from = memberJoinedEvent.body.user.name
            return ("\(from) joined", false)
        case .memberLeft:
            let memberLeftEvent = event as! VGMemberLeftEvent
            from = memberLeftEvent.body.user.name
            return ("\(from) left", false)
        case .messageText:
            let messageTextEvent = event as! VGMessageTextEvent
            var isUser = false
            
            if let userInfo = messageTextEvent.from as? VGEmbeddedInfo {
                isUser = userInfo.memberId == memberId
                from = isUser ? "" : "\(userInfo.user.name): "
            }
            
            return ("\(from) \(messageTextEvent.body.text)", isUser)
        default:
            return ("", false)
        }
    }
    
    // MARK: - Private
    
    private func getMemberId() async {
        do {
            let member = try await clientManager.client.getConversationMember(conversationId, memberId: "me")
        
            if member.state == .joined {
                memberId = member.id
                return
            }
            
            memberId = try await clientManager.client.joinConversation(conversationId)
        } catch {
            await MainActor.run {
                errorContainer = (true, error.localizedDescription)
            }
        }
    }
}
