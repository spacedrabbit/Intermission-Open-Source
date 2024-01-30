//
//  UpdatePasswordController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class UpdatePasswordController: TableViewController {
    private let user: User
    private let userDataCoordinator = UserDataCoordinator()
    
    private let rows: [UpdatePasswordItem] = [.newPassword, .confirmNewPassword, .oldPassword]
    
    private var newPasswordCell: TextFieldCell?
    private var confirmNewPasswordCell: TextFieldCell?
    private var oldPasswordCell: TextFieldCell?
    
    private struct ReuseIdentifier {
        static let newPasswordCell = "newPasswordCell"
        static let confirmNewPasswordCell = "confirmNewPasswordCell"
        static let oldPasswordCell = "oldPasswordCell"
    }
    
    // MARK: - Constructors -
    
    init(with user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        userDataCoordinator.delegate = self
        self.title = "Change Password"
        
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
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.newPasswordCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.confirmNewPasswordCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.oldPasswordCell)
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSaveTapped() {
        self.view.findAndResignFirstResponder()
        
        guard
            let newPassCell = newPasswordCell,
            let confirmNewCell = confirmNewPasswordCell,
            let oldPassCell = oldPasswordCell,
            let email = user.email,
            validate([newPassCell.textField, oldPassCell.textField, confirmNewCell.textField])
        else { return }
        
        guard newPassCell.textField.iaText == confirmNewCell.textField.iaText else {
            let displayError = DisplayableError(title: "Updated passwords didn't match", message: "According to our security robots, your passwords didn't match! Don't worry, they say this happens a lot and you should try to re-enter your passwords. 🤖")
            self.presentAlert(with: displayError)
            return
        }
        
        self.state = .loading
        do {
            try userDataCoordinator.updateUser(user.id,
                                               email: email,
                                               newPassword: newPassCell.textField.iaText,
                                               existingPassword: oldPassCell.textField.iaText)
        } catch (let e) {
            self.state = .ready
            self.presentAlert(with: "Something went wrong", message: e.localizedDescription)
        }
       
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension UpdatePasswordController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rows[indexPath.row]
        
        switch item {
        case .newPassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newPasswordCell, for: indexPath) as! TextFieldCell
            cell.configure(placeholder: "Enter New Password",
                           validator: Validator(rules: [MinLengthRule(minLength: 8)], identifier: "Password"),
                           textFieldStyle: .onboardingStyle)
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.isSecureTextEntry = true
            cell.shouldDisplayCheckmark = false
            cell.preventsWhitespaceCharacters = true
            cell.textField.textContentType = .newPassword
            cell.textField.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 8")
            
            if newPasswordCell == nil {
                newPasswordCell = cell
            }
            
            return cell
            
        case .confirmNewPassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.confirmNewPasswordCell, for: indexPath) as! TextFieldCell
            cell.configure(placeholder: "Confirm New Password",
                           validator: Validator(rules: [MinLengthRule(minLength: 8)], identifier: "Confirm Password"),
                           textFieldStyle: .onboardingStyle)
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.isSecureTextEntry = true
            cell.shouldDisplayCheckmark = false
            cell.preventsWhitespaceCharacters = true
            cell.textField.textContentType = .newPassword
            cell.textField.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 8")
            
            if confirmNewPasswordCell == nil {
                confirmNewPasswordCell = cell
            }
            
            return cell
            
        case .oldPassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.oldPasswordCell, for: indexPath) as! TextFieldCell
            cell.configure(placeholder: "Enter Existing Password",
                           validator: Validator(rules: [MinLengthRule(minLength: 8)], identifier: "Existing Password"),
                           textFieldStyle: .onboardingStyle)
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.isSecureTextEntry = true
            cell.shouldDisplayCheckmark = false
            cell.preventsWhitespaceCharacters = true
            cell.textField.textContentType = .password
            
            if oldPasswordCell == nil {
                oldPasswordCell = cell
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

private enum UpdatePasswordItem {
    case newPassword, confirmNewPassword, oldPassword
}

extension UpdatePasswordController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        self.state = .ready
        guard case UserUpdateIntent.password = intent else { return }
        
        ToastManager.show(title: "Your new password has been saved 🔑", highlightedTitle: "new password", accessory: .checkmark, position: .top)
        self.navigationController?.popViewController(animated: true)
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        self.state = .ready
        self.ia_presentAlert(with: error.title, message: error.message)
    }
    
}
