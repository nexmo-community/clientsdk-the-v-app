import UIKit
import NexmoClient

protocol ConversationListViewControllerDelegate: AnyObject {
    func conversationListViewControllerDelegateDidRefreshList(_ conversationListViewController: ConversationListViewController)
}

class ConversationListViewController: UIViewController {
    
    private lazy var listViewController: ListViewController<Conversations.Conversation> = {
        let vc = ListViewController(data: conversations)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private var conversations: [Conversations.Conversation]
    
    weak var delegate: ConversationListViewControllerDelegate?
    
    init(conversations: [Conversations.Conversation]) {
        self.conversations = conversations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        guard let homeViewController = tabBarController as? HomeViewController else { return }
        homeViewController.homeDelegate = self
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(listViewController.view)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension ConversationListViewController: ListViewControllerDelegate {
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) where T : Hashable, T : ListViewPresentable {
        delegate?.conversationListViewControllerDelegateDidRefreshList(self)
    }
    
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T : Hashable, T : ListViewPresentable {
        if let conversation = data as? Conversations.Conversation {
            navigationController?.pushViewController(ChatViewController(conversation: conversation), animated: true)
        }
    }
}

extension ConversationListViewController: HomeViewControllerDelegate {
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didCreateConversation conversation: Conversations.Conversation, conversations: [Conversations.Conversation]) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.conversations = conversations
            self.listViewController.triggerUpdate(with: self.conversations)
            self.navigationController?.pushViewController(ChatViewController(conversation: conversation), animated: true)
        }
    }
    
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadConversations conversations: [Conversations.Conversation]) {
        self.conversations = conversations
        self.listViewController.triggerUpdate(with: self.conversations)
    }
    
    func homeViewControllerDelegate(_ HomeViewController: HomeViewController, didLoadUsers users: [Users.User]) {}
}
