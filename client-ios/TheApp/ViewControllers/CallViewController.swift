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
    
    private let user: Users.User

    private var call: NXMCall?
    
    init(user: Users.User) {
        self.user = user
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
//        ClientManager.shared.call(name: user.name)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
    }
    
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubviews(profilePicView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            profilePicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profilePicView.widthAnchor.constraint(equalToConstant: 50),
            profilePicView.heightAnchor.constraint(equalToConstant: 50),
            profilePicView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
        ])
    }
}

extension CallViewController: ClientManagerCallDelegate {
    func clientManager(_ clientManager: ClientManager, didMakeCall call: NXMCall?) {
        self.call = call
        self.call?.setDelegate(self)
    }
    
    func clientManager(_ clientManager: ClientManager, makeCallDidFail errorMessage: String?) {
        
    }
}

extension CallViewController: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate member: NXMMember, with status: NXMCallMemberStatus) {
        
    }
    
    func call(_ call: NXMCall, didUpdate member: NXMMember, isMuted muted: Bool) {
        
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        
    }
}
