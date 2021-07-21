//
//  ContactsViewController.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 19/07/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    
    private lazy var listViewController: ListViewController<Users.User> = {
        let vc = ListViewController(data: users, supportsMultipleSelection: false)
        vc.delegate = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private let users: [Users.User]

    init(users: [Users.User]) {
        self.users =  users
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
        view.addSubview(listViewController.view)
    }
    
    private func setUpConstraints() {
        // TODO: heights of the tab and nav bar
        NSLayoutConstraint.activate([
            listViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }

}

extension ContactsViewController: ListViewControllerDelegate {
    func listViewControllerDelegate<T>(_: ListViewController<T>, didSelectRow data: T) where T : Hashable, T : ListViewPresentable {
        
    }
    
    func listViewControllerDelegateDidRefresh<T>(_: ListViewController<T>) where T : Hashable, T : ListViewPresentable {}
    
    
}
