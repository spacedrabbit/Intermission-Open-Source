//
//  UpdateEmailAddressController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - UpdateEmailAddressController -

/// Basic table view to update a user's email address
class UpdateEmailAddressController: TableViewController {
    private let user: User
    private let userDataCoordinator = UserDataCoordinator()
    private let rows: [UpdateEmailItem] = [.email, .password, .helper]
    private var reauthorizationRequired: Bool = false
    
    private var emailCell: TextFieldCell?
    private var passwordCell: TextFieldCell?
    
    private struct ReuseIdentifier {
        static let emailCell = "emailCellIdentifier"
        static let passwordCell = "passwordCellIdentifier"
        static let helperCell = "helperCellIdentifier"
    }
    
    // MARK: - Constructors -
    
    init(with user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        userDataCoordinator.delegate = self
        self.title = "Update Email"
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
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
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.emailCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.passwordCell)
        tableView.register(LabelTextCell.self, forCellReuseIdentifier: ReuseIdentifier.helperCell)
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSaveTapped() {
        self.view.findAndResignFirstResponder()
        
        if reauthorizationRequired {
            guard
                let emailCell = emailCell,
                let passwordCell = passwordCell,
                validate([emailCell.textField, passwordCell.textField])
            else { return }
            
            self.state = .loading
            do {
                try userDataCoordinator.updateUser(user.id,
                                                   email: emailCell.textField.iaText,
                                                   existingEmail: user.email,
                                                   password: passwordCell.textField.iaText)
            } catch (let e) {
                self.state = .ready
                self.presentAlert(with: "Something went wrong", message: e.localizedDescription)
            }
            
        } else {
            guard
                let emailCell = emailCell,
                validate([emailCell.textField])
            else { return }
            
            self.state = .loading
            do {
                try userDataCoordinator.updateUser(user.id, email: emailCell.textField.iaText)
                
            } catch UpdateRequestError.noCredentials {
                self.state = .ready
                
                self.presentAlert(with: UpdateRequestError.noCredentials.displayError)
                self.reauthorizationRequired = true
                self.tableView.reloadData()
            } catch (let e) {
                self.state = .ready
                self.presentAlert(with: "Something went wrong", message: e.localizedDescription)
            }
        }
        
        
        
    }
}

// MARK: - UpdateEmailItem -

private enum UpdateEmailItem {
    case email, helper, password
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension UpdateEmailAddressController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rows[indexPath.row]
        
        switch item {
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.emailCell, for: indexPath) as! TextFieldCell
            
            cell.configure(placeholder: "Email",
                           text: user.email,
                           validator: Validator(rules: [EmailRule()], identifier: "Email Address"),
                           textFieldStyle: .onboardingStyle)
            cell.shouldDisplayCheckmark = false
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.delegate = self
            cell.bottomSeparator.isHidden = true
            emailCell = cell
            
            return cell
            
        case .password:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.passwordCell, for: indexPath) as! TextFieldCell
            cell.configure(placeholder: "Enter Password", validator: Validator(rules: [MinLengthRule(minLength: 8)], identifier: "Password"))
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.isSecureTextEntry = true
            cell.delegate = self
            passwordCell = cell
            cell.isHidden = !reauthorizationRequired
            
            return cell
            
        case .helper:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.helperCell, for: indexPath) as! LabelTextCell
            cell.setLabelText("Enter your password here is so that we can verify your identity before updating your email address.")
            cell.isHidden = !reauthorizationRequired
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == rows.count - 1 {
            return UITableView.automaticDimension
        }
        
        return 80.0
    }
    
}

// MARK: - UserDataCoordinatorDelegate -

extension UpdateEmailAddressController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        self.state = .ready
        guard case UserUpdateIntent.email(let newEmail) = intent else { return }
        
        ToastManager.show(title: "Your email address has been updated to \(newEmail)!", highlightedTitle: newEmail, accessory: .checkmark, position: .top)
        self.navigationController?.popViewController(animated: true)
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        self.state = .ready
        self.ia_presentAlert(with: error.title, message: error.message)
    }
}

// MARK: - TextFieldCellDelegate -

extension UpdateEmailAddressController: TextFieldCellDelegate {
    
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
