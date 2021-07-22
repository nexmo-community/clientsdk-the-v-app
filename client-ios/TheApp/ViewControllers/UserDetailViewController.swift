//
//  UserDetailViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 22/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class UserDetailViewController: UIViewController {
    
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
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(50)
        button.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubviews(profilePicView, nameLabel, callButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            profilePicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profilePicView.widthAnchor.constraint(equalToConstant: 200),
            profilePicView.heightAnchor.constraint(equalToConstant: 200),
            profilePicView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profilePicView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            callButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc func callButtonTapped() {
        NXMClient.shared.call(user.name, callHandler: .inApp) { error, call in
            if error != nil {
                self.showErrorAlert(message: error?.localizedDescription)
                return
            }
            self.call = call
        }
    }
}
