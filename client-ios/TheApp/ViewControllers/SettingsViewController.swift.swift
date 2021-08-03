//
//  SettingsViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 19/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, LoadingViewController {
    
    private static let settings = [
        Setting(
            id: "1",
            displayName: "Change profile picture",
            type: .picture,
            iconString: "person.crop.square.fill"
        ),
        Setting(
            id: "2",
            displayName: "Log out",
            type: .logout,
            iconString: "person.fill.badge.minus"
        )
    ]
    
    private lazy var profilePicView: VProfilePictureView = {
        let imageView = VProfilePictureView()
        imageView.imageURL = imageURL
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Logged in as \(username)"
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var listViewController: ListViewController<Setting> = {
        let vc = ListViewController(data: SettingsViewController.settings, supportsMultipleSelection: false)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }()
    
    lazy var spinnerView = SpinnerView(parentView: view)
    
    private let username: String = ClientManager.shared.user?.displayName ?? ""
    private let imageURL = ClientManager.shared.user?.imageURL
    private let token = ClientManager.shared.token
    
    private var image: UIImage?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubviews(profilePicView, nameLabel, listViewController.view)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            profilePicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profilePicView.widthAnchor.constraint(equalToConstant: 200),
            profilePicView.heightAnchor.constraint(equalToConstant: 200),
            profilePicView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profilePicView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            listViewController.view.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 50),
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SettingsViewController: ListViewControllerDelegate {
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T : Hashable, T : ListViewPresentable {
        if let setting = data as? Setting {
            switch setting.type {
            case .picture:
                self.present(imagePicker, animated: true, completion: nil)
            case .logout:
                ClientManager.shared.logout()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let imageData = pickedImage.jpegData(compressionQuality: 0.1) {
                toggleLoading()
                spinnerView.setDetailText(text: "Uploading your image")
                RemoteLoader.uploadImage(authToken: token, body: imageData) { result in
                    DispatchQueue.main.async {
                        self.toggleLoading()
                        switch result {
                        case .success:
                            self.profilePicView.image = pickedImage
                        case .failure(let error):
                            self.showErrorAlert(message: error.localizedDescription)
                        }
                    }
                    
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
