//
//  DelegateExtensions.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 28/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import NexmoClient


/*
 Providing a empty default implementation of the delegate functions
 allows delegate functions to be optional. This cleans up the delegate
 extensions around the code base.
 */

extension ClientManagerCallDelegate {
    func clientManager(_ clientManager: ClientManager, didMakeCall call: NXMCall?) {}
    func clientManager(_ clientManager: ClientManager, makeCallDidFail errorMessage: String?) {}
    func clientManager(_ clientManager: ClientManager, didReceiveCall call: NXMCall) {}
}

extension ListViewControllerDelegate {
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) {}
}

extension HomeViewControllerDelegate {
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didCreateConversation conversation: Conversations.Conversation, conversations: [Conversations.Conversation]) {}
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadConversations conversations: [Conversations.Conversation]) {}
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadUsers users: [Users.User]) {}
}
