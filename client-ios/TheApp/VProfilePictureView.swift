//
//  VProfilePictureView.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 29/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class VProfilePictureView: UIImageView {
    
    lazy var spinnerView = SpinnerView(parentView: self)
    
    public var imageURL: String? {
        didSet {
            guard imageURL != nil else { return }
            loadImage()
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.clipsToBounds = true
        self.backgroundColor = .gray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadImage() {
        spinnerView.toggle()
        RemoteLoader.fetchData(url: imageURL!) { result in
            self.spinnerView.toggle()
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            default:
                break
            }
        }
    }
}
