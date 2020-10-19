//
//  ViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 14/09/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class ViewController: UIViewController {
    
    var user: User?
    let client = NXMClient.shared
    
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func setUserAsAbdul(_ sender: Any) {
        self.user = User.Abdul
        login()
    }
    
    @IBAction func setUserAsPaul(_ sender: Any) {
        self.user = User.Paul
        login()
    }
    
    private func login() {
        guard let user = self.user else { return }
        client.setDelegate(self)
        client.login(withAuthToken: user.jwt)
    }
}

extension ViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        switch status {
        case .connected:
            setStatusLabel("Connected")
            let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChatViewController") as! ChatViewController
            chatViewController.user = user
            let navigationController = UINavigationController(rootViewController: chatViewController)
            present(navigationController, animated: true, completion: nil)
        case .disconnected:
            setStatusLabel("Disconnected")
        case .connecting:
            setStatusLabel("Connecting")
        @unknown default:
            setStatusLabel("Unknown")
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        setStatusLabel(error.localizedDescription)
    }
    
    func setStatusLabel(_ newStatus: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = newStatus
        }
    }
}


struct User {
    let name: String
    let jwt: String
    let chatPartnerName: String
    
    static let Abdul = User(name: "Abdul",
                            jwt:"ABDUL_JWT",
                            chatPartnerName: "Paul")
    static let Paul = User(name: "Paul",
                            jwt:"PAUL_JWT",
                            chatPartnerName: "Abdul")
}

