//
//  CallView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 22/03/2024.
//

import Combine
import SwiftUI
import VonageClientSDK

struct CallView: View {
    @StateObject var viewModel: CallViewModel
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text(viewModel.callStatus)
                    .padding(16)
                Text(viewModel.callTime)
                    .padding(16)
                if viewModel.callActive {
                    HStack {
                        Button("Hang Up") {
                            Task {
                                await viewModel.hangup()
                            }
                        }
                        .tint(.red)
                        .buttonStyle(.bordered)
                        
                        Button(viewModel.muteButtonText) {
                            Task {
                                await viewModel.toggleMute()
                            }
                        }.buttonStyle(.bordered)
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.errorContainer.hasError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorContainer.text))
        }
        .navigationTitle(viewModel.callee)
        .navigationBarTitleDisplayMode(.inline)
    }
}

final class CallViewModel: ObservableObject {
    private let clientManager = ClientManager.shared
    private let formatter = DateComponentsFormatter()
    private var subscriptions = Set<AnyCancellable>()
    
    private var callTimer: Timer?
    private var callCounter = 0
    
    private let callId: String
    let callee: String
    
    @Published var muteButtonText = "Mute"
    @Published var callStatus = ""
    @Published var callTime = ""
    @Published var callActive = true
    
    @Published var errorContainer = (hasError: false, text: "")
    
    init(callId: String, callee: String) {
        self.callId = callId
        self.callee = callee
        
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
        
        clientManager.onCallEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .hangup(let callId, let reason):
                    guard callId == self?.callId else { return }
                    self?.callActive = false
                    self?.resetTimer()
                    switch reason {
                    case .remoteHangup:
                        self?.callStatus = "\(callee) Hung Up"
                    case .remoteReject:
                        self?.callStatus = "\(callee) Rejected"
                    case .remoteNoAnswerTimeout:
                        self?.callStatus = "\(callee) Did not answer"
                    case .localHangup:
                        self?.callStatus = "Call Ended"
                    default:
                        break
                    }
                case .update(let callId, _, let status):
                    guard callId == self?.callId else { return }
                    switch status {
                    case .ringing:
                        self?.callStatus = "Ringing"
                    case .answered:
                        self?.callStatus = "On Call"
                    case .completed:
                        self?.callStatus = "Call Completed"
                    case .unknown:
                        break
                    @unknown default:
                        break
                    }
                }
            }.store(in: &subscriptions)
    }
    
    @MainActor
    @objc func incrementTimer() {
        callCounter += 1
        callTime = formatter.string(from: TimeInterval(callCounter)) ?? ""
    }
    
    @MainActor
    func hangup() async {
        do {
            try await clientManager.client.hangup(callId)
            callActive = false
            resetTimer()
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    @MainActor
    func toggleMute() async {
        do {
            if muteButtonText == "Mute" {
                try await clientManager.client.mute(callId)
                muteButtonText = "Unmute"
            } else {
                try await clientManager.client.unmute(callId)
                muteButtonText = "Mute"
            }
        } catch {
            errorContainer = (true, error.localizedDescription)
        }
    }
    
    private func resetTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }
}
