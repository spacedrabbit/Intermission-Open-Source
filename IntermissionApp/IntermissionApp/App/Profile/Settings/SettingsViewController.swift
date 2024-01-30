//
//  SettingsViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - SettingsViewController -

class SettingsViewController: TableViewController {
    private var user: User
    private let userDataCoordinator = UserDataCoordinator()
    
    private let footer = SettingsFooterView()
    
    private let closeButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        button.setImage(Icon.NavBar.xClose.image, for: .normal)
        button.setImage(Icon.NavBar.xCloseHighlighted.image, for: .highlighted)
        return button
    }()
    
    private struct ReuseIdentifiers {
        static let settingsCell = "settingsCellIdentifier"
        static let settingsHeaderCell = "settingsHeaderCellIdentifier"
    }
    
    // TODO: there's too many moving parts for the small subset of people that will use the facebook connect feature,
    // going to ignore it for now
    private let sections: [[SettingsRow]] = Flags.enableFacebookDisconnect
        ? [ [.email, .password, .info, .facebook], [.about, .contact] ]
        : [ [.email, .password, .info], [.about, .contact]]

    // MARK: - Initializers -
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.title = "Settings"
        self.delegate = self
        self.userDataCoordinator.delegate = self
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleCloseTapped), name: .didFinishLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdated(notification:)), name: .userInfoUpdateSuccess, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(footer)
        tableView.contentInsetAdjustmentBehavior = .always
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        footer.logoutButton.addTarget(self, action: #selector(handleLogoutTapped), for: .touchUpInside)
        
        footer.snp.makeConstraints { (make) in
            make.centerX.width.bottom.equalToSuperview()
        }
        
        // Cell Registering
        tableView.register(SettingsCell.self, forCellReuseIdentifier: ReuseIdentifiers.settingsCell)
        tableView.register(AboutAppHeaderView.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifiers.settingsHeaderCell)
    }
    
    // MARK: - Events
    
    @objc
    private func handleCloseTapped() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func handleLogoutTapped() {
        
        let logout = AlertAction(title: "Sign out") { (alert, _) in
            alert.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .userLoggedOut, object: nil)
            })
        }
        
        let cancel = AlertAction(title: "Cancel") { (alert, _) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let alert = AlertViewController(with: "Sign out?", message: "Are you sure you want to sign out?\n\np.s. You can come back anytime 👩🏽👩🏾‍🦱", primaryAction: logout, secondaryAction: cancel)
        
        self.present(alert, with: SlideFromTopTransition())
    }
    
    @objc
    private func handleUserUpdated(notification: Notification) {
        guard notification.name == .userInfoUpdateSuccess,
            let userInfo = notification.userInfo,
            let updatedUser = userInfo[DatabaseUpdatedNotificationKey.user] as? User
        else { return }
        
        self.user = updatedUser
    }
    
    // MARK: - Facebook Link/Unlink
    
    private func handleFacebookLinkCellTapped() {
        self.state = .loading
        FacebookManager.isSessionActive
            ? userDataCoordinator.updateUserUnlinkingFacebook(user.id)
            : userDataCoordinator.updateUserLinkingFacebook(user.id, inViewController: self)
    }
    
    private func handleContactUsTapped() {
        let supportAction = UIAlertAction(title: "For Support", style: .default) { (_) in
            CustomerSupportManager.shared.presentEmail(in: self, intent: .support)
        }
        
        let commentAction = UIAlertAction(title: "For Comments", style: .default) { (_) in
            CustomerSupportManager.shared.presentEmail(in: self, intent: .comment)
        }
        
        let featureRequestAction = UIAlertAction(title: "For Feature Request", style: .default) { (_) in
            CustomerSupportManager.shared.presentEmail(in: self, intent: .featureRequest)
        }
        
        let bugReportAction = UIAlertAction(title: "For Bug Reporting", style: .default) { (_) in
            CustomerSupportManager.shared.presentEmail(in: self, intent: .bug, showDeviceDetails: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: "Contact us", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(supportAction)
        alertController.addAction(commentAction)
        alertController.addAction(featureRequestAction)
        alertController.addAction(bugReportAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource  -

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.settingsCell, for: indexPath) as! SettingsCell
        
        let rowItem = sections[indexPath.section][indexPath.row]
        switch rowItem {
        case .email:
            cell.configure(with: "Change Email", leftAccessory: nil, rightAccessory: .chevron)
            
        case .password:
            cell.configure(with: "Change Password", leftAccessory: nil, rightAccessory: .chevron)
            
        case .info:
            cell.configure(with: "Update Info", leftAccessory: nil, rightAccessory: .chevron)
            
        case .facebook:
            let facebookText = FacebookManager.isSessionActive
                ? "Disconnect Facebook"
                : "Connect with Facebook"
            cell.configure(with: facebookText, leftAccessory: .facebook, rightAccessory: nil)
            
        case .about:
            cell.configure(with: "About the App", leftAccessory: nil, rightAccessory: .chevron)
            
        case .contact:
            cell.configure(with: "Contact Us", leftAccessory: nil, rightAccessory: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowItem = sections[indexPath.section][indexPath.row]
        switch rowItem {
        case .email:
            let dtvc = UpdateEmailAddressController(with: user)
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .password:
            let dtvc = UpdatePasswordController(with: user)
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .info:
            let dtvc = UpdateInfoViewController(with: user)
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .facebook:
            handleFacebookLinkCellTapped()
            
        case .about:
            let dtvc = AboutAppViewController()
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .contact:
            handleContactUsTapped()
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsCell.height
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifiers.settingsHeaderCell) as! AboutAppHeaderView
        
        switch section {
        case 0: view.configure("Profile")
        case 1: view.configure("About")
        default: print("Should not be here")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AboutAppHeaderView.height
    }
}

// MARK: - SettingsRow -

fileprivate enum SettingsRow {
    case email, password, info, facebook, contact, about
}

// MARK: - UserDataCoordinator Delegate -

extension SettingsViewController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        self.state = .ready
        guard case UserUpdateIntent.providerId = intent else { return }
        self.user.decorate(with: user)
        self.tableView.reloadData()
        
        self.presentAlert(with: "Success!", message: "Your account is now disconnected from Facebook. When you log in next time, use the same email address and password you would normally use for Facebook.")
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        self.state = .ready
        self.tableView.reloadData()
        self.presentAlert(with: error)
    }
    
}
