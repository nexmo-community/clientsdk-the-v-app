//
//  ImageCollectionViewCell.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 06/08/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    private lazy var chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var chatBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(chatBackground, chatImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatImageView.image = nil
    }
    
    public func configure(with chatMessage: ChatMessage, image: UIImage?, isSender: Bool) {
        chatBackground.backgroundColor = isSender ? .systemBlue : .lightGray
        setImage(with: image, isSender: isSender)
    }
    
    private func setImage(with image: UIImage?, isSender: Bool) {
        guard let image = image else { return }
        chatImageView.image = image
        
        let leadingLabelConstraint: NSLayoutConstraint
        let trailingLabelConstraint: NSLayoutConstraint
        
        let imageHeight: CGFloat
        let imageWidth: CGFloat
        
        if image.size.height >= image.size.width {
            chatImageView.contentMode = .scaleAspectFill
            imageHeight = 320
            imageWidth = 180
        } else {
            chatImageView.contentMode = .scaleAspectFit
            imageHeight = 180
            imageWidth = 320
        }
        
        if isSender {
            trailingLabelConstraint = chatImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            leadingLabelConstraint = chatImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: contentView.frame.width - imageWidth)
        } else {
            trailingLabelConstraint = chatImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -(contentView.frame.width - imageWidth))
            leadingLabelConstraint = chatImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        }
        
        NSLayoutConstraint.activate([
            leadingLabelConstraint,
            trailingLabelConstraint,
            chatImageView.heightAnchor.constraint(lessThanOrEqualToConstant: imageHeight),
            chatImageView.widthAnchor.constraint(lessThanOrEqualToConstant: imageWidth),
            chatImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            chatImageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            chatBackground.topAnchor.constraint(equalTo: chatImageView.topAnchor, constant: -8),
            chatBackground.leadingAnchor.constraint(equalTo: chatImageView.leadingAnchor, constant: -8),
            chatBackground.trailingAnchor.constraint(equalTo: chatImageView.trailingAnchor, constant: 8),
            chatBackground.bottomAnchor.constraint(equalTo: chatImageView.bottomAnchor, constant: 8)
        ])
    }
}
