import UIKit

class SignUpViewController: UIViewController, LoadingViewController {
    
    private let displayNameField = VTextField(placeholder: "Display Name")
    private let usernameField = VTextField(placeholder: "Username")
    private let passwordField = VTextField(placeholder: "Password", isSecure: true)
    lazy var spinnerView = SpinnerView(parentView: view)
    
    private lazy var signUpButton: UIButton = {
        let button = VButton(title: "Sign Up")
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        title = "The V App"
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    private func setUpView() {
        view.backgroundColor = Constants.backgroundColor
        stackView.addArrangedSubviews(
            displayNameField,
            usernameField,
            passwordField,
            UIStackView.spacing(value: 4),
            signUpButton)
        view.addSubviews(stackView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 96),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -96),
            
            displayNameField.heightAnchor.constraint(equalToConstant: 48),
            usernameField.heightAnchor.constraint(equalToConstant: 48),
            passwordField.heightAnchor.constraint(equalToConstant: 48)
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
        navigationController?.pushViewController(HomeViewController(data: response), animated: true)
    }
    
    func clientManager(_ clientManager: ClientManager, authDidFail errorMessage: String?) {
        toggleLoading()
        showErrorAlert(message: errorMessage)
    }
}
