import UIKit

class VTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false, isChat: Bool = false) {
        super.init(frame: .zero)
        self.textAlignment = .center
        self.backgroundColor = Constants.secondaryBackgroundColor
        self.textColor = Constants.primaryTextColor
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : Constants.secondaryTextColor])
        self.isSecureTextEntry = isSecure
        self.autocapitalizationType = .none
        self.layer.borderWidth = isChat ? 0 : 3
        self.layer.cornerRadius = isChat ? 12 : 0
        self.layer.borderColor = UIColor.purple.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
