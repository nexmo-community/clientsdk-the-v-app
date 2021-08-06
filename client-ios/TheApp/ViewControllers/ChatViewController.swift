import UIKit
import NexmoClient

class ChatViewController: UIViewController, LoadingViewController {
    
    private lazy var inputField: VTextField = {
        let input = VTextField(placeholder: "Type a message")
        input.delegate = self
        input.returnKeyType = .send
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    private lazy var conversationTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .gray
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
    }()
    
    lazy var spinnerView = SpinnerView(parentView: view)
    
    var nxmConversation: NXMConversation?
    
    private let client = NXMClient.shared
    private var conversation: Conversations.Conversation
    
    init(conversation: Conversations.Conversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        
        toggleLoading()
        getConversation()
        decorateConversation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func setUpView() {
        title = conversation.displayName
        view.backgroundColor = .white
        view.addSubviews(conversationTextView, inputField)
        
        if conversation.users.count == 1 {
            let callButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            callButton.setImage(UIImage(systemName: "phone.fill.arrow.up.right"), for: .normal)
            callButton.addTarget(self, action: #selector(makeCallButtonTapped), for: .touchUpInside)
            let callButtonItem = UIBarButtonItem(customView: callButton)

            navigationItem.rightBarButtonItem = callButtonItem
        }
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            conversationTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            conversationTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            conversationTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            conversationTextView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -20),
            
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height - 20, right: 0)
        }
    }
    
    @objc func makeCallButtonTapped() {
        if let user = conversation.users.first {
            present(CallViewController(user: user), animated: true, completion: nil)
        }
    }
    
    func getConversation() {
        client.getConversationWithUuid(conversation.id) { [weak self] (error, conversation) in
            self?.nxmConversation = conversation
            conversation?.delegate = self
        }
    }
    
    func decorateConversation() {
        let path = "\(Conversations.path)/\(conversation.id)"
        let token = NXMClient.shared.authToken
        
        RemoteLoader.load(path: path,
                          authToken: token,
                          body: Optional<String>.none,
                          responseType: Conversations.Decorate.Response.self) { [weak self] result in
            guard let self = self else { return }
            self.toggleLoading()
            switch result {
            case .success(let conversation):
                self.conversation = conversation
                if let events = conversation.events {
                    self.processEvents(events: events)
                }
                
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    func processEvents(events: [Conversations.Conversation.Event]) {
        Array(Set(events))
            .sorted { $0.id < $1.id }
            .forEach { event in
            var allUsers: [(id: String, displayName: String)] = conversation.users.map { ($0.id, $0.displayName) }
            allUsers.append((client.user!.uuid, client.user!.displayName))
            
            guard let user = (allUsers.first { $0.id == event.from }) else { return }
            
            if let text = event.content, event.type == "text" {
                addConversationLine("\(user.displayName) said: '\(text)'")
            } else {
                var action = event.type.split(separator: ":")[1]
                
                if action == "invited" {
                    action = "was invited"
                }
                addConversationLine("\(user.displayName) \(String(describing: action)).")
            }
        }
    }
    
    func processNxmEvent(event: NXMEvent) {
        if let memberEvent = event as? NXMMemberEvent {
            showMemberEvent(event: memberEvent)
        }
        if let textEvent = event as? NXMTextEvent {
            showTextEvent(event: textEvent)
        }
    }
    
    func showMemberEvent(event: NXMMemberEvent) {
        guard let displayName = event.embeddedInfo?.user.displayName else { return }
        switch event.state {
        case .invited:
            addConversationLine("\(displayName) was invited.")
        case .joined:
            addConversationLine("\(displayName) joined.")
        case .left:
            addConversationLine("\(displayName) left.")
        case .unknown:
            fatalError("Unknown member event state.")
        @unknown default:
            fatalError("Unknown member event state.")
        }
    }
    
    func showTextEvent(event: NXMTextEvent) {
        if let message = event.text {
            addConversationLine("\(event.embeddedInfo?.user.displayName ?? "A user") said: '\(message)'")
        }
    }
    
    func addConversationLine(_ line: String) {
        DispatchQueue.main.async {
            if let text = self.conversationTextView.text, text.count > 0 {
                self.conversationTextView.text = "\(text)\n\(line)"
            } else {
                self.conversationTextView.text = line
            }
        }
    }
    
    func send(message: String) {
        // set current state for input field
        DispatchQueue.main.async { [weak self] in
            self?.inputField.text = ""
            self?.inputField.resignFirstResponder()
            self?.inputField.isEnabled = false
        }
        
        // send message
        nxmConversation?.sendText(message, completionHandler: { [weak self] (error) in
            DispatchQueue.main.async { [weak self] in
                self?.inputField.isEnabled = true
            }
        })
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            send(message: text)
        }
        return true
    }
}

extension ChatViewController: NXMConversationDelegate {
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {
        showErrorAlert(message: error.localizedDescription)
    }

    func conversation(_ conversation: NXMConversation, didReceive event: NXMTextEvent) {
        self.processNxmEvent(event: event)
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMemberEvent) {
        self.processNxmEvent(event: event)
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMessageStatusEvent) {
        print(event)
    }
}
