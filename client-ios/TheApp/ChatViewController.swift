//
//  ChatViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 14/09/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class ChatViewController: UIViewController {
    
    @IBOutlet var inputField: UITextField!
    @IBOutlet var conversationTextView: UITextView!
    
    private let client = NXMClient.shared
    public var user: User!
    var conversation: NXMConversation?
    var events: [NXMEvent]? {
        didSet {
            processEvents()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        conversationTextView.isUserInteractionEnabled = false
        
        inputField.delegate = self
        inputField.returnKeyType = .send
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logout))
        title = "Conversation with \(user.chatPartnerName)"
        
        getConversation()
    }
    
    func getConversation() {
        client.getConversationWithUuid("CONVERSATION_ID") { [weak self] (error, conversation) in
            self?.conversation = conversation
            if conversation != nil {
                self?.getEvents()
            }
            conversation?.delegate = self
        }
    }
    
    func getEvents() {
        guard let conversation = self.conversation else { return }
        conversation.getEventsPage(withSize: 100, order: .asc) { (error, page) in
            self.events = page?.events
        }
    }
    
    func processEvents() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.conversationTextView.text = ""
            self.events?.forEach { event in
                if let memberEvent = event as? NXMMemberEvent {
                    self.showMemberEvent(event: memberEvent)
                }
                if let textEvent = event as? NXMTextEvent {
                    self.showTextEvent(event: textEvent)
                }
            }
        }
    }
    
    func showMemberEvent(event: NXMMemberEvent) {
        switch event.state {
        case .invited:
            addConversationLine("\(event.member.user.name) was invited.")
        case .joined:
            addConversationLine("\(event.member.user.name) joined.")
        case .left:
            addConversationLine("\(event.member.user.name) left.")
        @unknown default:
            fatalError("Unknown member event state.")
        }
    }
    
    func showTextEvent(event: NXMTextEvent) {
        if let message = event.text {
            addConversationLine("\(event.fromMember?.user.name ?? "A user") said: '\(message)'")
        }
    }
    
    func addConversationLine(_ line: String) {
        if let text = conversationTextView.text, text.count > 0 {
            conversationTextView.text = "\(text)\n\(line)"
        } else {
            conversationTextView.text = line
        }
    }
    
    func send(message: String) {
      // set current state for input field
      DispatchQueue.main.async { [weak self] in
          self?.inputField.text = ""
          self?.inputField.resignFirstResponder()
          self?.inputField.isEnabled = false
      }
      // send message
      conversation?.sendText(message, completionHandler: { [weak self] (error) in
          DispatchQueue.main.async { [weak self] in
              self?.inputField.isEnabled = true
          }
      })
    }
    
    @objc private func logout() {
        client.logout()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height - 20, right: 0)
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            send(message: text)
        }
        return true
    }
}

extension ChatViewController: NXMConversationDelegate {
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {
        NSLog("Conversation error: \(error.localizedDescription)")
    }

    func conversation(_ conversation: NXMConversation, didReceive event: NXMTextEvent) {
        self.events?.append(event)
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMessageStatusEvent) {
        print(event)
    }
}
