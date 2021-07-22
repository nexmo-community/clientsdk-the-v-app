//
//  ContactsViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 19/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

protocol ContactsViewControllerDelegate: AnyObject {
    func contactsViewControllerDelegateDidRefreshList(_ contactsViewControllerDelegate: ContactsViewController)
}

class ContactsViewController: UIViewController {
    
    private lazy var listViewController: ListViewController<Users.User> = {
        let vc = ListViewController(data: users)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private var users: [Users.User]
    
    weak var delegate: ContactsViewControllerDelegate?

    init(users: [Users.User]) {
        self.users =  users
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        guard let homeViewController = tabBarController as? HomeViewController else { return }
        homeViewController.homeDelegate = self
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(listViewController.view)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            listViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

// TODO: Make call
extension ContactsViewController: ListViewControllerDelegate {
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T : Hashable, T : ListViewPresentable {
        if let user = data as? Users.User {
            self.navigationController?.pushViewController(UserDetailViewController(user: user), animated: true)
        }
    }
    
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) where T : Hashable, T : ListViewPresentable {
        delegate?.contactsViewControllerDelegateDidRefreshList(self)
    }
}

extension ContactsViewController: HomeViewControllerDelegate {
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didCreateConversation conversation: Conversations.Conversation, conversations: [Conversations.Conversation]) {}
    
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadConversations conversations: [Conversations.Conversation]) {}
    
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadUsers users: [Users.User]) {
        self.users = users
        self.listViewController.triggerUpdate(with: users)
    }
}
