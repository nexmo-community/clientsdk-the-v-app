import UIKit

class SpinnerView: UIActivityIndicatorView {
    init(superView: UIView) {
        super.init(style: .large)
        self.isHidden = true
        self.backgroundColor = .lightGray
        self.layer.cornerRadius = 2
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpConstraints(with: superView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints(with superView: UIView) {
        superView.addSubview(self)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            centerYAnchor.constraint(equalTo: superView.centerYAnchor),
            widthAnchor.constraint(equalToConstant: 50),
            heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func toggle() {
        if self.isHidden {
            self.isHidden = false
            self.startAnimating()
        } else {
            self.isHidden = true
            self.stopAnimating()
        }
    }
}
