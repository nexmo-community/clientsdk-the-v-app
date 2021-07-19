import NexmoClient

protocol ClientManagerDelegate: AnyObject {
    func clientManager(_ clientManager: ClientManager, responseForAuth response: Auth.Response)
    func clientManager(_ clientManager: ClientManager, authDidFail errorMessage: String?)
}

final class ClientManager: NSObject {
    
    static let shared = ClientManager()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var response: Auth.Response?
    
    weak var delegate: ClientManagerDelegate?
    
    override init() {
        super.init()
        initializeClient()
    }
    
    private func initializeClient() {
        NXMClient.shared.setDelegate(self)
    }
    
    func auth(username: String, password: String, displayName: String?, url: String) {
        let user = Auth.Body(name: username, password: password, displayName: displayName)
        
        RemoteLoader.load(path: url, body: user, responseType: Auth.Response.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.response = response
                NXMClient.shared.login(withAuthToken: response.token)
            case .failure(let error):
                switch error {
                case .api(error: let apiError):
                    self.delegate?.clientManager(self, authDidFail: apiError.detail)
                default:
                    self.delegate?.clientManager(self, authDidFail: error.localizedDescription)
                }
            }
        }
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
}
