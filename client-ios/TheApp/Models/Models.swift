import Foundation

enum ChatMessageContent: Hashable, Equatable {
    case info(content: String)
    case text(content: String)
    case image(urlString: String)
}

protocol ListViewPresentable {
    var id: String { get }
    var displayName: String { get }
}

struct ChatMessage: Hashable {
    let id: Int
    let sender: String
    let content: ChatMessageContent
    let date: Date
}

struct Setting: Hashable, ListViewPresentable {
    
    enum SettingType {
        case picture
        case logout
    }
    
    let id: String
    let displayName: String
    let type: SettingType
    let iconString: String
}

struct Image: Codable {
    static let path = "/image"
    
    struct Body: Codable  {
        let imageURL: String
        
        enum CodingKeys: String, CodingKey {
            case imageURL = "image_url"
        }
    }
}

struct Users: Codable, Hashable {
    static let path = "/users"
    
    struct List: Codable {
        typealias Response = [User]
    }
    
    struct User: Codable, Hashable, ListViewPresentable {
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

struct Conversations: Codable {
    static let path = "/conversations"
    
    struct Create: Codable {
        struct Body: Codable {
            let users: [String]
        }
        
        typealias Response = Conversation
    }
    
    struct List: Codable {
        typealias Response = [Conversation]
    }
    
    struct Decorate: Codable {
        typealias Response = Conversation
    }
    
    struct Conversation: Codable, Hashable, ListViewPresentable {
        let state: String
        let id: String
        let createdAt: String
        let joinedAt: String?
        let displayName: String
        let users: [Users.User]
        let events: [Event]?
        
        enum CodingKeys: String, CodingKey {
            case state, id, users, events
            case displayName = "name"
            case createdAt = "created_at"
            case joinedAt = "joined_at"
        }
        
        struct Event: Codable, Hashable {
            let id: String
            let from: String
            let type: String
            let content: String?
            let timestamp: String
        }
    }
    
}

struct Auth: Codable {
    static let signupPath = "/signup"
    static let loginPath = "/login"
    
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
        let conversations: [Conversations.Conversation]
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
