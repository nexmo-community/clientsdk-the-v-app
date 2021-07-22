import UIKit

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
