//
//  InfoCollectionViewCell.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 06/08/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    private lazy var chatTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = label.font.withSize(16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .lightGray
        return label
    }()
    
    private lazy var chatBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews(chatBackground, chatTextLabel)
        
        NSLayoutConstraint.activate([
            chatTextLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            chatTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            chatTextLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            chatBackground.topAnchor.constraint(equalTo: chatTextLabel.topAnchor, constant: -8),
            chatBackground.leadingAnchor.constraint(equalTo: chatTextLabel.leadingAnchor, constant: -8),
            chatBackground.trailingAnchor.constraint(equalTo: chatTextLabel.trailingAnchor, constant: 8),
            chatBackground.bottomAnchor.constraint(equalTo: chatTextLabel.bottomAnchor, constant: 8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatTextLabel.text = nil
    }
    
    public func configure(with chatMessage: ChatMessage) {
        chatBackground.backgroundColor = .lightGray
        
        if case let .info(info) = chatMessage.content {
            chatTextLabel.text = info
            chatTextLabel.sizeToFit()
        }
    }
}
