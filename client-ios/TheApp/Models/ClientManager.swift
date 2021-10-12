import NexmoClient

protocol ClientManagerDelegate: AnyObject {
    func clientManager(_ clientManager: ClientManager, responseForAuth response: Auth.Response)
    func clientManager(_ clientManager: ClientManager, authDidFail errorMessage: String?)
}

protocol ClientManagerCallDelegate: AnyObject {
    func clientManager(_ clientManager: ClientManager, didMakeCall call: NXMCall?)
    func clientManager(_ clientManager: ClientManager, makeCallDidFail errorMessage: String?)
}

protocol ClientManagerConversationDelegate: AnyObject {
    func clientManager(_ clientManager: ClientManager, didGetConversation conversation: NXMConversation?)
    func clientManager(_ clientManager: ClientManager, getConversationDidFail errorMessage: String?)
}

protocol ClientManagerIncomingCallDelegate: AnyObject {
    func clientManager(_ clientManager: ClientManager, didReceiveCall call: NXMCall)
}

final class ClientManager: NSObject {
    
    static let shared = ClientManager()
    
    public var token: String {
        return NXMClient.shared.authToken ?? ""
    }
    
    private var response: Auth.Response?
    public var user: Users.User?
    
    weak var delegate: ClientManagerDelegate?
    weak var callDelegate: ClientManagerCallDelegate?
    weak var incomingCallDelegate: ClientManagerIncomingCallDelegate?
    weak var conversationDelegate: ClientManagerConversationDelegate?
    
    override init() {
        super.init()
        initializeClient()
    }
    
    private func initializeClient() {
        NXMClient.shared.setDelegate(self)
    }
    
    func auth(username: String, password: String, displayName: String?, url: String, storeCredentials: Bool = true) {
        let user = Auth.Body(name: username, password: password, displayName: displayName)
        
        RemoteLoader.load(path: url, body: user, responseType: Auth.Response.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.response = response
                self.user = response.user
                NXMClient.shared.login(withAuthToken: response.token)
                if storeCredentials {
                    self.storeCredentials(username: username, password: password)
                }
            case .failure(let error):
                switch error {
                case .api(error: let apiError):
                    self.delegate?.clientManager(self, authDidFail: apiError.description)
                default:
                    self.delegate?.clientManager(self, authDidFail: error.localizedDescription)
                }
            }
        }
    }
    
    func call(name: String) {
        NXMClient.shared.serverCall(withCallee: name, customData: nil) { [weak self] error, call in
            guard let self = self else { return }
            if error != nil {
                self.callDelegate?.clientManager(self, makeCallDidFail: error?.localizedDescription)
                return
            }

            self.callDelegate?.clientManager(self, didMakeCall: call)
        }
    }
    
    func getConversation(conversationID: String) {
        NXMClient.shared.getConversationWithUuid(conversationID) { [weak self] error, conversation in
            guard let self = self else { return }
            if error != nil {
                self.conversationDelegate?.clientManager(self, getConversationDidFail: error?.localizedDescription)
                return
            }
            
            self.conversationDelegate?.clientManager(self, didGetConversation: conversation)
        }
    }
    
    func logout() {
        deleteCredentials()
        NXMClient.shared.logout()
    }
}

extension ClientManager {
    private func storeCredentials(username: String, password: String) {
        if let passwordData = password.data(using: .utf8) {
            let keychainItem = [
                kSecClass: kSecClassInternetPassword,
                kSecAttrServer: Constants.keychainServer,
                kSecReturnData: true,
                kSecReturnAttributes: true,
                kSecAttrAccount: username,
                kSecValueData: passwordData
            ] as CFDictionary
            
            let status = SecItemAdd(keychainItem, nil)
            print("Keychain storing finished with status: \(status)")
        }
    }
    
    func getCredentials() -> (String, String)? {
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: Constants.keychainServer,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: 1
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        print("Keychain querying finished with status: \(status)")
        
        if let resultArray = result as? NSDictionary,
           let username = resultArray[kSecAttrAccount] as? String,
           let passwordData = resultArray[kSecValueData] as? Data,
           let password = String(data: passwordData, encoding: .utf8) {
            return (username, password)
        } else {
            return nil
        }
    }
    
    private func deleteCredentials() {
        guard let user = user else { return }
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: Constants.keychainServer,
            kSecAttrAccount: user.name
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}

extension ClientManager: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        switch status {
        case .connected:
            delegate?.clientManager(self, responseForAuth: response!)
        default:
            break
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        self.delegate?.clientManager(self, authDidFail: error.localizedDescription)
    }
    
    func client(_ client: NXMClient, didReceive call: NXMCall) {
        incomingCallDelegate?.clientManager(self, didReceiveCall: call)
    }
}
