import UIKit

class SignUpViewController: UIViewController, LoadingViewController {
    
    private let displayNameField = VTextField(placeholder: "Display Name")
    private let usernameField = VTextField(placeholder: "Username")
    private let passwordField = VTextField(placeholder: "Password", isSecure: true)
    lazy var spinnerView = SpinnerView(superView: view)
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        stackView.addArrangedSubviews(displayNameField, usernameField, passwordField, signUpButton)
        view.addSubviews(stackView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            
            displayNameField.heightAnchor.constraint(equalToConstant: 50),
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func toggleLoading() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled.toggle()
            self.spinnerView.toggle()
        }
    }
    
    @objc func signUpButtonTapped() {
        if let displayName = displayNameField.text,let username = usernameField.text, let password = passwordField.text {
            ClientManager.shared.delegate = self
            toggleLoading()
            ClientManager.shared.auth(username: username, password: password, displayName: displayName, url: Auth.signupPath)
        } else {
            showErrorAlert(message: "Validation error")
        }
    }
}


extension SignUpViewController: ClientManagerDelegate {
    func clientManager(_ clientManager: ClientManager, responseForAuth response: Auth.Response) {
        toggleLoading()
        navigationController?.pushViewController(ConversationListViewController(data: response), animated: true)
    }
    
    func clientManager(_ clientManager: ClientManager, authDidFail errorMessage: String?) {
        toggleLoading()
        showErrorAlert(message: errorMessage)
    }
}
