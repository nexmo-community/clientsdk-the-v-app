//
//  HomeViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 19/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

protocol HomeViewControllerDelegate: AnyObject {
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didCreateConversation conversation: Conversations.Conversation, conversations: [Conversations.Conversation])
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadConversations conversations: [Conversations.Conversation])
}

class HomeViewController: UITabBarController {
    
    private let data: Auth.Response
    private var conversations: [Conversations.Conversation]
    
    //TODO: Make lazy
    private let conversationListViewController: ConversationListViewController
    private let contactsViewController: ContactsViewController
    private let settingsViewController = SettingsViewController()
    
    private var newConversationButton: UIBarButtonItem?
    
    weak var homeDelegate: HomeViewControllerDelegate?
    
    init(data: Auth.Response) {
        self.data = data
        self.conversations = data.conversations
        self.conversationListViewController = ConversationListViewController(conversations: conversations)
        self.contactsViewController = ContactsViewController(users: data.users)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The V app"
        
        newConversationButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(newConversationButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = newConversationButton
        self.navigationItem.hidesBackButton = true
        
        delegate = self
        conversationListViewController.delegate = self
        
        self.viewControllers = VTabBarItem.allCases.map { createTabBarViewControllers(for: $0) }
    }
    
    public func conversationListViewControllerDidRefresh() {
        print("refresh")
    }
    
    private func createTabBarViewControllers(for vBarItem: VTabBarItem) -> UIViewController {
        let item = UITabBarItem(title: vBarItem.title, image: vBarItem.image, tag: vBarItem.tag)
        let viewController: UIViewController
        
        switch vBarItem {
        case .chats :
            viewController = conversationListViewController
        case .contacts:
            viewController = contactsViewController
        case .settings:
            viewController = settingsViewController
        }
            
        viewController.tabBarItem = item
        return viewController
    }
    
    @objc private func newConversationButtonTapped() {
        let createConversationViewController = CreateConversationViewController(users: data.users)
        createConversationViewController.delegate = self
        navigationController?.present(createConversationViewController, animated: true, completion: nil)
    }
    
    private func loadConversations() {
        let token = NXMClient.shared.authToken
        
        RemoteLoader.load(path: Conversations.path,
                          authToken: token,
                          body: Optional<String>.none,
                          responseType: Conversations.List.Response.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let conversations):
                self.homeDelegate?.homeViewControllerDelegate(self, didLoadConversations: conversations)
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}

extension HomeViewController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag != VTabBarItem.chats.tag {
            newConversationButton?.isHidden = true
        } else {
            newConversationButton?.isHidden = false
        }
    }
}

extension HomeViewController: CreateConversationViewControllerDelegate {
    func createConversationViewController(_ createConversationViewController: CreateConversationViewController, didCreateConversation conversation: Conversations.Conversation) {
        self.conversations.append(conversation)
        homeDelegate?.homeViewControllerDelegate(self, didCreateConversation: conversation, conversations: conversations)
    }
}

extension HomeViewController: ConversationListViewControllerDelegate {
    func conversationListViewControllerDelegateDidRefreshList(_ conversationListViewController: ConversationListViewController) {
        loadConversations()
    }
}
