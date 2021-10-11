//
//  TextCollectionViewCell.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 06/08/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    
    private lazy var chatTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chatBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var leadingLabelConstraint: NSLayoutConstraint!
    private var trailingLabelConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews(chatBackground, chatTextLabel)
        
        NSLayoutConstraint.activate([
            chatTextLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 144),
            chatTextLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            chatTextLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            chatBackground.topAnchor.constraint(equalTo: chatTextLabel.topAnchor, constant: -8),
            chatBackground.leadingAnchor.constraint(equalTo: chatTextLabel.leadingAnchor, constant: -8),
            chatBackground.trailingAnchor.constraint(equalTo: chatTextLabel.trailingAnchor, constant: 8),
            chatBackground.bottomAnchor.constraint(equalTo: chatTextLabel.bottomAnchor, constant: 8)
        ])
        
        trailingLabelConstraint =  chatTextLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        leadingLabelConstraint = chatTextLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatTextLabel.text = nil
    }
    
    public func configure(with chatMessage: ChatMessage, isSender: Bool) {
        if case let .text(text) = chatMessage.content {
            chatBackground.backgroundColor = isSender ? .systemBlue : .lightGray
            leadingLabelConstraint.isActive = !isSender
            trailingLabelConstraint.isActive = isSender
            
            chatTextLabel.text = text
        }
    }
}
