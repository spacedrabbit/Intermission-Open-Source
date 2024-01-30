//
//  UpdateInfoViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/28/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - UpdateInfoViewController -

/// Basic table view to update a user's first/last name
class UpdateInfoViewController: TableViewController {
    private let user: User
    private let userDataCoordinator = UserDataCoordinator()
    private let rows: [UpdateInfoItem] = [.firstname, .lastname]
    
    private var firstNameCell: TextFieldCell?
    private var lastNameCell: TextFieldCell?
    
    private struct ReuseIdentifier {
        static let firstNameCell = "firstNameCellIdentifier"
        static let lastNameCell = "lastNameCellIdentifier"
    }
    
    // MARK: - Constructors
    
    init(with user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        userDataCoordinator.delegate = self
        self.title = "Update Info"
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .paleLavendar
        tableView.backgroundView = UIView(frame: self.view.bounds)
        tableView.backgroundView?.backgroundColor = .paleLavendar
        tableView.contentInsetAdjustmentBehavior = .always
        self.navigationController?.navigationBar.tintColor = .cta
        
        let saveButton = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(handleSaveTapped))
        saveButton.tintColor = .cta
        self.navigationItem.rightBarButtonItem = saveButton
        
        // Cell registering
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.firstNameCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.lastNameCell)
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSaveTapped() {
        self.view.findAndResignFirstResponder()
        
        guard
            let firstNameCell = firstNameCell,
            let lastNameCell = lastNameCell,
            validate([firstNameCell.textField, lastNameCell.textField])
            else { return }
        
        self.state = .loading
        userDataCoordinator.updateUser(user.id,
                                       firstName: firstNameCell.textField.iaText,
                                       lastName: lastNameCell.textField.iaText)
        
    }
}

// MARK: - UpdateInfoItem -

private enum UpdateInfoItem {
    case firstname, lastname
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension UpdateInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rows[indexPath.row]
        
        switch item {
        case .firstname:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.firstNameCell, for: indexPath) as! TextFieldCell

            let text: String? = user.name.first.isEmpty
                ? nil
                : user.name.first
            
            cell.configure(placeholder: "First", text: text, validator: Validator(rules: [MinLengthRule(minLength: 1)], identifier: "First Name"), textFieldStyle: .onboardingStyle)
            cell.shouldDisplayCheckmark = false
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.delegate = self
            cell.bottomSeparator.isHidden = true
            firstNameCell = cell
        
            return cell
        case .lastname:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.lastNameCell, for: indexPath) as! TextFieldCell

            let text: String? = user.name.last.isEmpty
                ? nil
                : user.name.last
            
            cell.configure(placeholder: "Last", text: text, validator: Validator(rules: [MinLengthRule(minLength: 1)], identifier: "Last Name"), textFieldStyle: .onboardingStyle)
            cell.shouldDisplayCheckmark = false
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.delegate = self
            cell.bottomSeparator.isHidden = true
            lastNameCell = cell
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
}

// MARK: - UserDataCoordinatorDelegate -

extension UpdateInfoViewController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        guard case UserUpdateIntent.username(let updatedName) = intent else { return }
        
        ToastManager.show(title: "Your name has been updated to \(updatedName.0) \(updatedName.1)", highlightedTitle: "\(updatedName.0) \(updatedName.1)", accessory: .checkmark, position: .top)
        self.navigationController?.popViewController(animated: true)
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        self.state = .ready
        self.ia_presentAlert(with: error.title, message: error.message)
    }
    
}

// MARK: - TextFieldCellDelegate -

extension UpdateInfoViewController: TextFieldCellDelegate {
    
    func textFieldCellDidEndEditing(_ textFieldCell: TextFieldCell) {
        
    }
    
    func textFieldCellShouldReturn(_ textFieldCell: TextFieldCell) -> Bool {
        textFieldCell.textField.resignFirstResponder()
        return true
    }
    
    func textFieldCell(_ textFieldCell: TextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
}
