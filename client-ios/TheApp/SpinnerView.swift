import UIKit

class SpinnerView: UIView {
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.backgroundColor = .white
        spinner.color = .purple
        spinner.layer.cornerRadius = 12
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = label.font.withSize(16)
        label.numberOfLines = 0
        label.isHidden = true
        label.textColor = Constants.primaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(parentView: UIView) {
        super.init(frame: .zero)
        self.isHidden = true
        setUpConstraints(parentView: parentView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints(parentView: UIView) {
        parentView.addSubviews(spinner, detailLabel)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: 48),
            spinner.heightAnchor.constraint(equalToConstant: 48),
            
            detailLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            detailLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16)
        ])
    }
    
    func setDetailText(text: String) {
        detailLabel.isHidden = false
        detailLabel.text = text
    }
    
    func toggle() {
        if self.isHidden {
            self.isHidden = false
            spinner.startAnimating()
        } else {
            self.isHidden = true
            detailLabel.isHidden = true
            spinner.stopAnimating()
        }
    }
}
