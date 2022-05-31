import UIKit
import NexmoClient

class ChatViewController: UIViewController, LoadingViewController {
    /* TODO:
     image send loading indicator
     add message time
     if group chat add sender name
     */
    
    private lazy var chatListViewController: ChatListViewController = {
        let vc = ChatListViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.isHidden = true
        return vc
    }()
    
    private lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var inputField: VTextField = {
        let input = VTextField(placeholder: "Type a message", isChat: true)
        input.delegate = self
        input.returnKeyType = .send
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill"), for: .normal)
        button.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }()
    
    lazy var spinnerView = SpinnerView(parentView: view)
    
    private var nxmConversation: NXMConversation?
    private var conversation: Conversations.Conversation
    private var conversationsLoaded = (apiConv: false, nxmConv: false) {
        didSet {
            finishLoadingIfNeeded()
        }
    }
    
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
        ClientManager.shared.getConversation(conversationID: conversation.id)
        ClientManager.shared.conversationDelegate = self
        decorateConversation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func setUpView() {
        title = conversation.displayName
        view.backgroundColor = Constants.backgroundColor
        view.addSubviews(chatListViewController.view, inputStackView)
        inputStackView.addArrangedSubviews(imageButton, inputField, sendButton)
        
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
            chatListViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatListViewController.view.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -20),
            
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            inputStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            inputField.heightAnchor.constraint(equalToConstant: 44),
            
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            imageButton.widthAnchor.constraint(equalToConstant: 44),
            
            sendButton.imageView!.widthAnchor.constraint(equalToConstant: 25),
            sendButton.imageView!.heightAnchor.constraint(equalToConstant: 25),
            imageButton.imageView!.widthAnchor.constraint(equalToConstant: 25),
            imageButton.imageView!.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    
    private func finishLoadingIfNeeded() {
        if conversationsLoaded.apiConv == true && conversationsLoaded.nxmConv == true {
            toggleLoading()
            DispatchQueue.main.async {
                self.chatListViewController.view.isHidden = false
            }
        }
    }
    
    @objc private func keyboardWasShown(notification: NSNotification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height - 20, right: 0)
        }
    }
    
    @objc private func makeCallButtonTapped() {
        if let user = conversation.users.first {
            present(CallViewController(user: user), animated: true, completion: nil)
        }
    }
    
    private func decorateConversation() {
        let path = "\(Conversations.path)/\(conversation.id)"
        let token = ClientManager.shared.token
        RemoteLoader.load(path: path,
                          authToken: token,
                          body: Optional<String>.none,
                          responseType: Conversations.Decorate.Response.self) { [weak self] result in
            guard let self = self else { return }
            self.conversationsLoaded.apiConv = true
            switch result {
            case .success(let conversation):
                self.conversation = conversation
                if let events = conversation.events {
                    self.chatListViewController.setMessages(messages: self.processEvents(events: events))
                }
                
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func processEvents(events: [Conversations.Conversation.Event]) -> [ChatMessage] {
        guard let currentUser = ClientManager.shared.user else { return [] }
        
        var allUsers: [(id: String, displayName: String)] = conversation.users.map { ($0.id, $0.displayName) }
        allUsers.append((currentUser.id, currentUser.displayName))
        
        let processedEvents: [ChatMessage] =
            Array(Set(events))
            .compactMap { event in
                guard let user = (allUsers.first { $0.id == event.from }),
                      let eventID = Int(event.id),
                      let eventDate = VDateFormatter.dateFor(event.timestamp) else { return nil }
                
                if event.type.contains("message") {
                    switch event.type {
                    case "message.text":
                        return ChatMessage(id: eventID, sender: user.displayName, content: .text(content: event.content!), date: eventDate)
                    case "message.image":
                        return ChatMessage(id: eventID, sender: user.displayName, content: .image(urlString: event.content!), date: eventDate)
                    default:
                        return nil
                    }
                } else if event.type.contains("member") {
                    var action = event.type.split(separator: ":")[1]
                    
                    if action == "invited" {
                        action = "was invited"
                    }
                    let content = "\(user.displayName) \(action)."
                    return ChatMessage(id: eventID, sender: user.displayName, content: .info(content: content), date: eventDate)
                } else {
                    return nil
                }
            }
            .sorted { $0.id < $1.id }
        
        return processedEvents
    }
    
    @objc private func sendMessage() {
        guard let text = inputField.text else { return }
        // set current state for input field
        DispatchQueue.main.async { [weak self] in
            self?.inputField.text = ""
            self?.inputField.resignFirstResponder()
            self?.inputField.isEnabled = false
        }
        
        // send message
        let message = NXMMessage(text: text)
        nxmConversation?.sendMessage(message, completionHandler: { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                self?.inputField.isEnabled = true
            }
        })
    }
    
    @objc private func pickImage() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func sendImage(imageData: Data) {
        ClientManager.shared.uploadImage(imageData: imageData) { error, imageURL in
            if error != nil {
                self.showErrorAlert(message: error?.localizedDescription)
                return
            }
            
            let message = NXMMessage(fileUrl: imageURL!)
            self.nxmConversation?.sendMessage(message, completionHandler: { [weak self] error in
                self?.showErrorAlert(message: error?.localizedDescription)
            })
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

extension ChatViewController: NXMConversationDelegate {
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {
        showErrorAlert(message: error.localizedDescription)
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMTextEvent) {
        chatListViewController.appendMessage(event.asChatMessage())
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMemberEvent) {
        chatListViewController.appendMessage(event.asChatMessage())
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMImageEvent) {
        chatListViewController.appendMessage(event.asChatMessage())
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMessageEvent) {
        chatListViewController.appendMessage(event.asChatMessage())
    }
}

extension ChatViewController: ClientManagerConversationDelegate {
    func clientManager(_ clientManager: ClientManager, didGetConversation conversation: NXMConversation?) {
        conversationsLoaded.nxmConv = true
        self.nxmConversation = conversation
        self.nxmConversation?.delegate = self
    }
    
    func clientManager(_ clientManager: ClientManager, getConversationDidFail errorMessage: String?) {
        showErrorAlert(message: errorMessage)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let imageData = pickedImage.jpegData(compressionQuality: 0.1) {
                    sendImage(imageData: imageData)
                }
            }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
