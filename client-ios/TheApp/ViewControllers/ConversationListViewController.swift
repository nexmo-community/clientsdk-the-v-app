import UIKit
import NexmoClient

class ConversationListViewController: UIViewController {
    
    private lazy var listViewController: ListViewController<Conversations.Conversation> = {
        let vc = ListViewController(data: conversations)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private let data: Auth.Response
    private var conversations: [Conversations.Conversation]
    
    init(data: Auth.Response) {
        self.data = data
        self.conversations = data.conversations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }
    
    private func setUpView() {
        title = "The V app"
        view.backgroundColor = .white
        view.addSubview(listViewController.view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(newConversationButtonTapped))
        self.navigationItem.hidesBackButton = true
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func loadConversations() {
        let token = NXMClient.shared.authToken
        
        RemoteLoader.load(path: Conversations.path,
                          authToken: token,
                          body: Optional<String>.none,
                          responseType: Conversations.List.Response.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let conversations):
                self.listViewController.triggerUpdate(with: conversations)
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    @objc func newConversationButtonTapped() {
        let createConversationViewController = CreateConversationViewController(users: data.users)
        createConversationViewController.delegate = self
        navigationController?.present(createConversationViewController, animated: true, completion: nil)
    }
}

extension ConversationListViewController: CreateConversationViewControllerDelegate {
    func createConversationViewController(_ createConversationViewController: CreateConversationViewController, didCreateConversation conversation: Conversations.Conversation) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.conversations.append(conversation)
            self.listViewController.triggerUpdate(with: self.conversations)
            self.navigationController?.pushViewController(ChatViewController(conversation: conversation), animated: true)
        }
    }
}

extension ConversationListViewController: ListViewControllerDelegate {
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) where T : Hashable, T : ListViewPresentable {
        self.loadConversations()
    }
    
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T : Hashable, T : ListViewPresentable {
        if let conversation = data as? Conversations.Conversation {
            navigationController?.pushViewController(ChatViewController(conversation: conversation), animated: true)
        }
    }
}
