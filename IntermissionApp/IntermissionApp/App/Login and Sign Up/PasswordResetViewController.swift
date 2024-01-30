//
//  PasswordResetViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/29/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString
import FirebaseAuth

class PasswordResetViewController: TableViewController {
    private var emailCell: TextFieldCell?
    
    private struct ReuseIdentifier {
        static let emailCell = "emailCellIdentifier"
        static let buttonCell = "sendResetEmailCellIdentifier"
    }
    
    // MARK: - Constructors -
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .always

        let titleLabel = Label()
        titleLabel.style = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 24.0)
            $0.color = UIColor.textColor
            $0.lineSpacing = 0.0
            $0.alignment = .center
            $0.maximumLineHeight = 28.0
        }
        titleLabel.styledText = "Password Reset"
        
        let headerView = UIView()
        headerView.addSubview(titleLabel)
        headerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.w, height: 60.0)
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        tableView.tableHeaderView = headerView
        
        // Cell registering
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.emailCell)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ReuseIdentifier.buttonCell)
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSaveTapped() {
        self.view.findAndResignFirstResponder()
        
        guard
            let emailCell = emailCell,
            validate([emailCell.textField])
            else { return }

    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource  -

extension PasswordResetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.emailCell, for: indexPath) as! TextFieldCell
            
            cell.configure(placeholder: "Enter Email", validator: Validator(rules: [EmailRule()], identifier: "Email Address"), textFieldStyle: .onboardingStyle)
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.delegate = self
            emailCell = cell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.buttonCell, for: indexPath) as! ButtonCell
            cell.delegate = self
            cell.setButtonText("Send Reset Email".uppercased())
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        } else {
            return ButtonCell.height
        }
    }
    
}

// MARK: - ButtonCellDelegate -

extension PasswordResetViewController: ButtonCellDelegate {
    
    func buttonCellWasTapped(_ buttonCell: ButtonCell) {
        guard
            let emailCell = emailCell,
            validate([emailCell.textField])
        else { return }
        
        buttonCell.showActivity()
        SessionService.sendPasswordReset(to: emailCell.textField.iaText) { (result) in
            switch result {
            case .success:
                let dismissAction = AlertAction(title: "OK", action: { (alertController, _) in
                    alertController.dismiss(animated: true, completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                })
                
                self.presentAlert(with: "On it's way", message: "Our robots confirmed that they have sent you a password reset email! Take a look at your inbox and follow the instructions provided.\n\nSee you in just a minute 🚀", primary: dismissAction, secondary: nil, canTapToDismiss: false)
                
            case .failure(let error):
                self.presentAlert(with: error.displayError)
            }
            buttonCell.hideActivity()
        }
    }
    
}

// MARK: - TextFieldCellDelegate -

extension PasswordResetViewController: TextFieldCellDelegate {
    
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
