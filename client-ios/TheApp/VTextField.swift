import UIKit

class VTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.textAlignment = .center
        self.isSecureTextEntry = isSecure
        self.autocapitalizationType = .none
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
