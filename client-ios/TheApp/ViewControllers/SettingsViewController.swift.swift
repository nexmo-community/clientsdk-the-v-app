//
//  SettingsViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 19/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private static let settings = [Setting(id: "1", displayName: "Log out", type: .logout)]
    
    private lazy var profilePicView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Logged in as \(username)"
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var listViewController: ListViewController<Setting> = {
        let vc = ListViewController(data: SettingsViewController.settings, supportsMultipleSelection: false)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private let username: String

    init() {
        self.username = ClientManager.shared.username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubviews(profilePicView, nameLabel, listViewController.view)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            profilePicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profilePicView.widthAnchor.constraint(equalToConstant: 200),
            profilePicView.heightAnchor.constraint(equalToConstant: 200),
            profilePicView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profilePicView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            listViewController.view.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 50),
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SettingsViewController: ListViewControllerDelegate {
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T : Hashable, T : ListViewPresentable {
        if let setting = data as? Setting {
            switch setting.type {
            case .logout:
                // TODO: logout and pop to login screen
                print("logout")
            }
        }
    }
    
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) where T : Hashable, T : ListViewPresentable {}
}
