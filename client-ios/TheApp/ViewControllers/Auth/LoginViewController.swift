import UIKit

class LoginViewController: UIViewController, LoadingViewController {
    
    private let usernameField = VTextField(placeholder: "Username")
    private let passwordField = VTextField(placeholder: "Password", isSecure: true)
    lazy var spinnerView = SpinnerView(parentView: view)
    
    private lazy var loginButton: UIButton = {
        let button = VButton(title: "Login")
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var newUserButton: UIButton = {
        let button = VButton(title: "New User?", isSecondary: true)
        button.addTarget(self, action: #selector(newUserButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var loggedin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        checkExistingTokenAndLogin()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if loggedin {
            resetView()
        }
    }
    
    private func setUpView() {
        view.backgroundColor = Constants.backgroundColor
        stackView.addArrangedSubviews(
            usernameField,
            passwordField,
            UIStackView.spacing(value: 4),
            loginButton,
            newUserButton
        )
        view.addSubviews(logoView, stackView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 96),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -96),
            
            logoView.heightAnchor.constraint(equalToConstant: 300),
            logoView.widthAnchor.constraint(equalToConstant: 300),
            usernameField.heightAnchor.constraint(equalToConstant: 48),
            passwordField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func checkExistingTokenAndLogin() {
        if let credentials = ClientManager.shared.getCredentials() {
            ClientManager.shared.delegate = self
            toggleLoading()
            ClientManager.shared.auth(username: credentials.0, password: credentials.1, displayName: nil, url: Auth.loginPath, storeCredentials: false)
            toggleViewVisibility(hidden: true)
            spinnerView.setDetailText(text: "Welcome back \(credentials.0)")
        }
    }
    
    private func toggleViewVisibility(hidden: Bool) {
        DispatchQueue.main.async {
            self.stackView.isHidden = hidden
            self.usernameField.isHidden = hidden
            self.passwordField.isHidden = hidden
        }
    }
    
    private func resetView() {
        loggedin = false
        toggleViewVisibility(hidden: false)
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
        loggedin = true
        usernameField.text = ""
        passwordField.text = ""
        navigationController?.pushViewController(HomeViewController(data: response), animated: true)
    }
    
    func clientManager(_ clientManager: ClientManager, authDidFail errorMessage: String?) {
        toggleLoading()
        resetView()
        showErrorAlert(message: errorMessage)
    }
}
