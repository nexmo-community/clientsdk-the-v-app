//
//  VTabBarItem.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 19/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

enum VTabBarItem: CaseIterable {
    case chats
    case contacts
    case settings
    
    var title: String {
        switch self {
        case .chats:
            return "Chats"
        case .contacts:
            return "Contacts"
        case .settings:
            return "Settings"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .chats:
            return UIImage(systemName: "text.bubble.fill")
        case .contacts:
            return UIImage(systemName: "person.3.fill")
        case .settings:
            return UIImage(systemName: "gearshape.fill")
        }
    }
    
    var tag: Int {
        switch self {
        case .chats:
            return 0
        case .contacts:
            return 1
        case .settings:
            return 2
        }
    }
}
