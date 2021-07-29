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
    
    private lazy var profilePicView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = user.displayName
        label.textAlignment = .natural
        label.font = label.font.withSize(30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var callStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var endCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End Call", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mute", for: .normal)
        button.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray
        button.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var muteIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mic.slash.fill"))
        imageView.isHidden = true
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let user: Users.User

    private var call: NXMCall?
    private var isMuted = false
    
    init(user: Users.User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    init(call: NXMCall) {
        self.call = call
        guard let callUser = call.allMembers.first?.user else { fatalError("Missing call member") }
        self.user = Users.User(
            id: callUser.uuid,
            name: callUser.name,
            displayName: callUser.displayName
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
            callStatusLabel.text = "Ringing..."
        } else {
            call?.answer(nil)
            call?.setDelegate(self)
            callStatusLabel.text = "Call ongoing"
            endCallButton.isHidden = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endCall(with: "Call ended")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        title = "Calling \(user.displayName)"
        view.addSubviews(profilePicView, nameLabel, muteIconImageView, callStatusLabel, muteButton, endCallButton, callButton)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            profilePicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profilePicView.widthAnchor.constraint(equalToConstant: 70),
            profilePicView.heightAnchor.constraint(equalToConstant: 70),
            profilePicView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            
            nameLabel.centerYAnchor.constraint(equalTo: profilePicView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profilePicView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            muteIconImageView.centerXAnchor.constraint(equalTo: profilePicView.centerXAnchor),
            muteIconImageView.centerYAnchor.constraint(equalTo: profilePicView.centerYAnchor),
            muteIconImageView.widthAnchor.constraint(equalToConstant: 30),
            muteIconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            callStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            callStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            callStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            muteButton.topAnchor.constraint(equalTo: callStatusLabel.bottomAnchor, constant: 20),
            muteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            muteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endCallButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endCallButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            endCallButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            callButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            callButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            callButton.bottomAnchor.constraint(equalTo: endCallButton.topAnchor, constant: -20)
        ])
    }
    
    private func endCall(with endDescription: String) {
        call?.hangup()
        callStatusLabel.text = endDescription
        callButton.isHidden = false
        endCallButton.isHidden = true
        call = nil
    }
    
    @objc private func endCallButtonTapped() {
        endCall(with: "Call ended")
    }
    
    @objc private func callButtonTapped() {
        callButton.isHidden = true
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
}

extension CallViewController: ClientManagerCallDelegate {
    func clientManager(_ clientManager: ClientManager, didMakeCall call: NXMCall?) {
        DispatchQueue.main.async {
            self.call = call
            self.endCallButton.isHidden = false
            self.call?.setDelegate(self)
        }
    }
    
    func clientManager(_ clientManager: ClientManager, makeCallDidFail errorMessage: String?) {
        callStatusLabel.text = errorMessage
        callButton.isHidden = false
    }
}

extension CallViewController: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate member: NXMMember, with status: NXMCallMemberStatus) {
        guard member.user.name == user.name else { return }
        DispatchQueue.main.async {
            switch status {
            case .answered:
                // Person called picked up
                self.callStatusLabel.text = "Call ongoing"
            case .completed:
                // Person called ended the call
                self.endCall(with: "\(self.user.displayName) ended the call")
            case .cancelled, .rejected:
                // Person called rejected the call
                self.endCall(with: "\(self.user.displayName) rejected the call")
            case .busy, .failed, .timeout:
                // Issue with the call
                self.endCall(with: "There was an error with the call, try again")
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
