import UIKit
import NexmoClient

protocol LoadingViewController {
    var spinnerView: SpinnerView { get }
}

extension LoadingViewController where Self: UIViewController {
    func toggleLoading() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled.toggle()
            self.spinnerView.toggle()
        }
    }
}

extension UIViewController {
    func showErrorAlert(message: String?) {
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            self.addSubview(view)
        }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
    
    static func spacing(value: CGFloat) -> UIView {
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: value).isActive = true
        return spacerView
    }
}

extension UIBarButtonItem {
    var isHidden: Bool {
        get {
            return !self.isEnabled
        }
        set {
            if newValue {
                self.tintColor = .clear
                self.isEnabled = false
                self.isAccessibilityElement = false
            } else {
                self.tintColor = .systemBlue
                self.isEnabled = true
                self.isAccessibilityElement = true
            }
        }
    }
}

extension Notification.Name {
    static let incomingCall = Notification.Name("Call")
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

extension NXMMessageEvent {
    func asChatMessage() -> ChatMessage {
        let displayName = embeddedInfo?.user.displayName ?? ""
        switch self.messageType {
        case .image:
            return ChatMessage(id: uuid,
                               sender: displayName,
                               content: .image(urlString: imageUrl!),
                               date: Date(timeIntervalSinceReferenceDate: creationDate.timeIntervalSinceReferenceDate))
        default:
            return ChatMessage(id: uuid,
                               sender: displayName,
                               content: .text(content: text ?? ""),
                               date: Date(timeIntervalSinceReferenceDate: creationDate.timeIntervalSinceReferenceDate))
        }
    }
}

extension NXMTextEvent {
    func asChatMessage() -> ChatMessage {
        let displayName = embeddedInfo?.user.displayName ?? ""
        return ChatMessage(id: uuid,
                           sender: displayName,
                           content: .text(content: text ?? ""),
                           date: Date(timeIntervalSinceReferenceDate: creationDate.timeIntervalSinceReferenceDate))
    }
}

extension NXMMemberEvent {
    func asChatMessage() -> ChatMessage {
        let displayName = embeddedInfo?.user.displayName ?? ""
        let text: String
        switch state {
        case .invited:
            text = "\(displayName) was invited."
        case .joined:
            text = "\(displayName) was joined."
        case .left:
            text = "\(displayName) was left."
        case .unknown:
            fatalError("Unknown member event state.")
        @unknown default:
            fatalError("Unknown member event state.")
        }
        
        return ChatMessage(id: self.uuid,
                           sender: displayName,
                           content: .info(content: text),
                           date: Date(timeIntervalSinceReferenceDate: self.creationDate.timeIntervalSinceReferenceDate))
    }
}

extension NXMImageEvent {
    func asChatMessage() -> ChatMessage {
        let displayName = embeddedInfo?.user.displayName ?? ""
        return ChatMessage(id: uuid,
                           sender: displayName,
                           content: .image(urlString: mediumImage.url.absoluteString),
                           date: Date(timeIntervalSinceReferenceDate: creationDate.timeIntervalSinceReferenceDate))
    }
}
