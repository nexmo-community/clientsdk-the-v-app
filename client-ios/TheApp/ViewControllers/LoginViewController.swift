import UIKit

class LoginViewController: UIViewController, LoadingViewController {
    
    private let usernameField = VTextField(placeholder: "Username")
    private let passwordField = VTextField(placeholder: "Password", isSecure: true)
    lazy var spinnerView = SpinnerView(parentView: view)
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var newUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New User?", for: .normal)
        button.addTarget(self, action: #selector(newUserButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The V App"
        setUpView()
        setUpConstraints()
        checkExistingTokenAndLogin()
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        stackView.addArrangedSubviews(usernameField, passwordField, loginButton, newUserButton)
        view.addSubviews(stackView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func checkExistingTokenAndLogin() {
        if let credentials = ClientManager.shared.getCredentials() {
            ClientManager.shared.delegate = self
            toggleLoading()
            ClientManager.shared.auth(username: credentials.0, password: credentials.1, displayName: nil, url: Auth.loginPath, storeCredentials: false)
            hideViews()
            spinnerView.setDetailText(text: "Welcome back \(credentials.0)")
        }
    }
    
    private func hideViews() {
        stackView.isHidden = true
        usernameField.isHidden = true
        passwordField.isHidden = true
    }
    
    @objc func loginButtonTapped() {
        if let username = usernameField.text, let password = passwordField.text {
            ClientManager.shared.delegate = self
            toggleLoading()
            ClientManager.shared.auth(username: username, password: password, displayName: nil, url: Auth.loginPath)
        } else {
            showErrorAlert(message: "Validation error")
        }
    }
    
    @objc func newUserButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
}

extension LoginViewController: ClientManagerDelegate {
    func clientManager(_ clientManager: ClientManager, responseForAuth response: Auth.Response) {
        toggleLoading()
        navigationController?.pushViewController(HomeViewController(data: response), animated: true)
    }
    
    func clientManager(_ clientManager: ClientManager, authDidFail errorMessage: String?) {
        toggleLoading()
        showErrorAlert(message: errorMessage)
    }
}
