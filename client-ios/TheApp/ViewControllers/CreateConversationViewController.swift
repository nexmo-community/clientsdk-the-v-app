import UIKit
import NexmoClient

protocol CreateConversationViewControllerDelegate: class {
    func createConversationViewController(_ createConversationViewController: CreateConversationViewController,
                                          didCreateConversation conversation: Conversations.Conversation)
}

class CreateConversationViewController: UIViewController, LoadingViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Select users to start a conversation with"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var listViewController: ListViewController<Users.User> = {
        let vc = ListViewController(data: users, supportsMultipleSelection: true)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Conversation", for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var spinnerView = SpinnerView(superView: view)
    
    weak var delegate: CreateConversationViewControllerDelegate?
    
    private let users: [Users.User]
    private var selectedUsers: [Users.User] = []
    
    init(users: [Users.User]) {
        self.users = users
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
        view.backgroundColor = .white
        view.addSubviews(titleLabel, listViewController.view, createButton)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            listViewController.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            createButton.topAnchor.constraint(equalTo: listViewController.view.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    @objc func createButtonTapped() {
        guard selectedUsers.count > 0 else {
            showErrorAlert(message: "No users selected")
            return
        }
        
        let token = NXMClient.shared.authToken
        let body = Conversations.Create.Body(users: selectedUsers.map { $0.id })
        toggleLoading()
        RemoteLoader.load(path: Conversations.path,
                          authToken: token,
                          body: body,
                          responseType: Conversations.Create.Response.self) { [weak self] result in
            guard let self = self else { return }
            self.toggleLoading()
            switch result {
            case .success(let conversation):
                self.delegate?.createConversationViewController(self, didCreateConversation: conversation)
            case .failure(let error):
                if case let RemoteLoaderError.api(apiError) = error {
                    self.showErrorAlert(message: apiError.detail)
                }
            }
        }
    }
}

extension CreateConversationViewController: ListViewControllerDelegate {
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T: Hashable, T: ListViewPresentable {
        if let user = data as? Users.User {
            if selectedUsers.contains(user) {
                if let existingIndex = selectedUsers.firstIndex(of: user) {
                    selectedUsers.remove(at: existingIndex)
                }
            } else {
                selectedUsers.append(user)
            }
        }
    }
    
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) where T : Hashable, T : ListViewPresentable {}
}
