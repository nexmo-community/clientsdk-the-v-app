import UIKit

class VTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        self.textAlignment = .center
        self.backgroundColor = .white.withAlphaComponent(0.1)
        self.textColor = Constants.primaryTextColor
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : Constants.secondaryTextColor])
        self.isSecureTextEntry = isSecure
        self.autocapitalizationType = .none
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.purple.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
