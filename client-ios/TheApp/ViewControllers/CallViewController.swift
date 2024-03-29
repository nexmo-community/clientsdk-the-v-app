//
//  CallViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 28/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class CallViewController: UIViewController {
    
    enum CallState {
        case inactive
        case ringing
        case ongoing
        case ended(reason: String?)
        case error(reason: String?)
    }
    
    private lazy var profilePicView: VProfilePictureView = {
        let imageView = VProfilePictureView()
        imageView.imageURL = user.imageURL
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = user.displayName
        label.textAlignment = .natural
        label.textColor = Constants.primaryTextColor
        label.font = label.font.withSize(24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var callStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.primaryTextColor
        label.font = label.font.withSize(24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var endCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End Call", for: .normal)
        button.setTitleColor(Constants.destructiveTextColor, for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.setTitleColor(Constants.highlightColor, for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mute", for: .normal)
        button.isHidden = true
        button.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Constants.primaryTextColor
        button.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var muteIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mic.slash.fill"))
        imageView.isHidden = true
        imageView.tintColor = Constants.destructiveTextColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let user: Users.User

    private var call: NXMCall?
    private var isMuted = false
    private var callState: CallState = .inactive {
        didSet {
            DispatchQueue.main.async {
                self.updateUIForCallState()
            }
        }
    }
    
    init(user: Users.User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    init(call: NXMCall) {
        self.call = call
        guard let callUser = (call.allMembers.first { $0.user.name != ClientManager.shared.user?.name })?.user else { fatalError("Missing call member") }
        self.user = Users.User(
            id: callUser.uuid,
            name: callUser.name,
            displayName: callUser.displayName,
            imageURL: callUser.imageUrl
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        ClientManager.shared.callDelegate = self
        
        if call == nil {
            ClientManager.shared.call(name: user.name)
            callState = .ringing
        } else {
            call?.answer(nil)
            call?.setDelegate(self)
            callState = .ongoing
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callState = .ended(reason: "Call ended")
    }
    
    private func setUpView() {
        view.backgroundColor = Constants.secondaryBackgroundColor
        title = "Calling \(user.displayName)"
        view.addSubviews(profilePicView, nameLabel, muteIconImageView, callStatusLabel, muteButton, endCallButton, callButton)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            profilePicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            profilePicView.widthAnchor.constraint(equalToConstant: 64),
            profilePicView.heightAnchor.constraint(equalToConstant: 64),
            profilePicView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            
            nameLabel.centerYAnchor.constraint(equalTo: profilePicView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profilePicView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            muteIconImageView.centerXAnchor.constraint(equalTo: profilePicView.centerXAnchor),
            muteIconImageView.centerYAnchor.constraint(equalTo: profilePicView.centerYAnchor),
            muteIconImageView.widthAnchor.constraint(equalToConstant: 24),
            muteIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            callStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            callStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            callStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            muteButton.topAnchor.constraint(equalTo: callStatusLabel.bottomAnchor, constant: 16),
            muteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            muteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            endCallButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            endCallButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            endCallButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            callButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            callButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            callButton.bottomAnchor.constraint(equalTo: endCallButton.topAnchor, constant: -16)
        ])
    }
    
    private func endCall() {
        call?.hangup()
        call = nil
    }
    
    @objc private func endCallButtonTapped() {
        callState = .ended(reason: "Call ended")
    }
    
    @objc private func callButtonTapped() {
        callState = .ringing
        ClientManager.shared.call(name: user.name)
    }
    
    @objc private func muteButtonTapped() {
        if isMuted {
            call?.unmute()
            isMuted = false
            muteButton.setTitle("Mute", for: .normal)
        } else {
            call?.mute()
            isMuted = true
            muteButton.setTitle("Unmute", for: .normal)
        }
    }
    
    private func updateUIForCallState() {
        switch callState {
        case .inactive:
            callStatusLabel.text = nil
            callButton.isHidden = false
            endCallButton.isHidden = true
            muteButton.isHidden = true
        case .ringing:
            callStatusLabel.text = "Ringing..."
            callButton.isHidden = true
            endCallButton.isHidden = false
            muteButton.isHidden = true
        case .ongoing:
            callStatusLabel.text = "Call ongoing"
            callButton.isHidden = true
            endCallButton.isHidden = false
            muteButton.isHidden = false
        case .ended(let reason):
            callStatusLabel.text = reason
            callButton.isHidden = false
            endCallButton.isHidden = true
            muteButton.isHidden = true
            endCall()
        case .error(let reason):
            callStatusLabel.text = reason
            callButton.isHidden = false
            endCallButton.isHidden = true
            muteButton.isHidden = true
        }
    }
}

extension CallViewController: ClientManagerCallDelegate {
    func clientManager(_ clientManager: ClientManager, didMakeCall call: NXMCall?) {
        DispatchQueue.main.async {
            self.call = call
            self.callState = .ringing
            self.call?.setDelegate(self)
        }
    }
    
    func clientManager(_ clientManager: ClientManager, makeCallDidFail errorMessage: String?) {
        callState = .error(reason: errorMessage)
    }
}

extension CallViewController: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate member: NXMMember, with status: NXMCallMemberStatus) {
        guard member.user.name == user.name else { return }
        DispatchQueue.main.async {
            switch status {
            case .answered:
                // Person called picked up
                self.callState = .ongoing
            case .completed:
                // Person called ended the call
                self.callState = .ended(reason: "\(self.user.displayName) ended the call")
            case .cancelled, .rejected:
                // Person called rejected the call
                self.callState = .ended(reason: "\(self.user.displayName) rejected the call")
            case .busy, .failed, .timeout:
                // Issue with the call
                self.callState = .ended(reason: "There was an error with the call, try again")
            default:
                break
            }
        }
    }
    
    func call(_ call: NXMCall, didUpdate member: NXMMember, isMuted muted: Bool) {
        guard member.user.name == user.name else { return }
        DispatchQueue.main.async {
            self.muteIconImageView.isHidden = !muted
        }
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        DispatchQueue.main.async {
            self.callStatusLabel.text = error.localizedDescription
        }
    }
}
