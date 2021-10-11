//
//  VButton.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 23/09/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class VButton: UIButton {
    
    init(title: String, isSecondary: Bool = false) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        layer.cornerRadius = 10
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        if isSecondary {
            backgroundColor = .white
            setTitleColor(Constants.highlightColor, for: .normal)
            layer.borderColor = Constants.highlightColor.cgColor
            layer.borderWidth = 3
        } else {
            backgroundColor = Constants.highlightColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
