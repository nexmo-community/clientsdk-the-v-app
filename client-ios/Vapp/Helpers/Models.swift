//
//  Models.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import Foundation
import ExyteChat
import VonageClientSDK

extension VGConversation: Identifiable {}

struct Users: Codable, Hashable {
    static let path = "/users"
    
    struct List: Codable {
        typealias Response = [User]
    }
    
    struct User: Codable, Hashable, Identifiable {
        let id: String
        let name: String
        let displayName: String
        let imageURL: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case imageURL = "image_url"
            case displayName = "display_name"
        }
    }
}

struct Auth: Codable {
    static let signupPath = "/signup"
    static let loginPath = "/login"
    static let refreshPath = "/token"
    
    struct Body: Codable {
        let name: String
        let password: String
        let displayName: String?
        
        enum CodingKeys: String, CodingKey {
            case name, password
            case displayName = "display_name"
        }
    }
    
    struct Response: Codable {
        let user: Users.User
        let token: String
        let users: [Users.User]
    }
    
    struct RefreshResponse: Codable {
        let token: String
    }
}

struct APIError: Codable {
    let type: String?
    let title: String?
    let detail: String?
    let invalidParameters: [[String: String]]?
    
    enum CodingKeys: String, CodingKey {
        case type, title, detail
        case invalidParameters = "invalid_parameters"
    }
    
    var description: String {
        var descriptionString: String = self.detail ?? ""
        
        if let invalidParameters = invalidParameters {
            for invalidParameter in invalidParameters {
                descriptionString += "\n \(invalidParameter.description)"
            }
        }
        
        return descriptionString
    }
}
