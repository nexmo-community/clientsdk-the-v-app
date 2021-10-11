//
//  ChatListViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 06/08/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {
    
    private lazy var tableView = makeTableView()
    
    private var messages: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }
    
    private func setUpView() {
        view.backgroundColor = Constants.backgroundColor
        view.addSubview(tableView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeTableView() -> UITableView {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = Constants.backgroundColor
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: "TextChat")
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: "InfoChat")
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "ImageChat")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return tableView
    }
    
    public func setMessages(messages: [ChatMessage]) {
        self.messages = messages.reversed()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    public func appendMessage(_ message: ChatMessage) {
        messages.insert(message, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension ChatListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isSender =  message.sender == ClientManager.shared.user?.displayName
        
        switch message.content {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoChat") as! InfoTableViewCell
            cell.configure(with: message)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextChat") as! TextTableViewCell
            cell.configure(with: message, isSender: isSender)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        case .image(let urlString):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageChat") as! ImageTableViewCell
            loadImageFor(cell, with: message, urlString: urlString, isSender: isSender)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    private func loadImageFor(_ cell: ImageTableViewCell, with message: ChatMessage, urlString: String?, isSender: Bool) {
        guard let urlString = urlString else { return }
        RemoteLoader.fetchData(url: urlString, authToken: ClientManager.shared.token) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        cell.configure(with: message, image: image, isSender: isSender)
                        self.tableView.endUpdates()
                    }
                }
            default:
                break
            }
        }
    }
}
