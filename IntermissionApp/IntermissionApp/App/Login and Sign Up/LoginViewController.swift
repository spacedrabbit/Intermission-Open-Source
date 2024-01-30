//
//  LoginViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/26/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString
import FirebaseAuth
import Pastel

class LoginViewController: TableViewController {
    private let backgroundGradient = CAGradientLayer()
    private let loginHeader = LoginHeaderView()
    
    private let signUpContainer = UIView()
    private let loginContainer = UIView()
    private var hasDeferredLoginSwitch: Bool = false
    
    private var leadingContainerConstraint: Constraint?
    private var bottomContainerContraints: Constraint?

    private var animatedBarCell: AnimatedBarCell?
    
    private var emailCell: TextFieldCell?
    private var passwordCell: TextFieldCell?
    private var confirmPasswordCell: TextFieldCell?
    
    private var allTextFields: [TextField] {
        return [emailCell?.textField, passwordCell?.textField, confirmPasswordCell?.textField].compactMap { $0 }
    }
    
    private var signUpSwipeGesture: UISwipeGestureRecognizer?
    private var loginSwipeGesture: UISwipeGestureRecognizer?
    private var viewingSignUp: Bool = true
    private var currentIndex: Int = 0 // 0 for sign in, 1 for log in
    
    private struct ReuseIdentifier {
        static let emailCell = "emailCellIdentifier"
        static let passwordCell = "passwordCellIdentifier"
        static let confirmCell = "confirmPasswordCellIdentifer"
    }
    
    private let signUpButton: StandardButton = {
        let button = StandardButton()
        button.setText("SIGN UP")
        return button
    }()

    private let loginButton: StandardButton = {
        let button = StandardButton()
        button.setText("LOG IN")
        return button
    }()
    
    private let signupFacebookButton: FacebookButton = {
        let button = FacebookButton()
        button.configure(with: .signUp)
        return button
    }()
    
    private let loginFacebookButton: FacebookButton = {
        let button = FacebookButton()
        button.configure(with: .login)
        return button
    }()
    
    private let resetPasswordLinkLabelSignUp: LinkLabel = {
        let label = LinkLabel(style: .white)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private let resetPasswordLinkLabelLogin: LinkLabel = {
        let label = LinkLabel(style: .white)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    // Keeps a reference to database request responsible for creating a new user record
    private var newUserListener: Listener?
    weak var loginDelegate: LoginViewControllerDelegate?
    
    // MARK: - Initializers -
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginStateChange(notification:)), name: .loginRequestDidSucceed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginStateChange(notification:)), name: .loginRequestDidFail, object: nil)
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
        // TODO: debug this crazy layout
        // self.view.backgroundColor = .red
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        self.isNavigationBarHidden = true
        
        // Gradient
        let animatedGradientView = PastelView(frame: self.view.bounds)
        animatedGradientView.startPastelPoint = .topLeft
        animatedGradientView.endPastelPoint = .bottomRight
        animatedGradientView.animationDuration = 1.0
        animatedGradientView.setColors([.cta, .accent, .cta, .accent, .cta, .accent])
        animatedGradientView.startAnimation()
        
        tableView.backgroundView = animatedGradientView
        tableView.backgroundView?.frame = self.view.bounds
//        backgroundGradient.colors = [UIColor.cta.cgColor, UIColor.accent.cgColor]
//        backgroundGradient.startPoint = CGPoint(x: 0.0, y: 0.25)
//        backgroundGradient.endPoint = CGPoint(x: 1.0, y: 0.75)
//        tableView.backgroundView = UIView(frame: self.view.bounds)
//        tableView.backgroundView?.layer.addSublayer(backgroundGradient)
        
        // Header View
        tableView.tableHeaderView = loginHeader
 
        // Footer Buttons
        loginContainer.isUserInteractionEnabled = true
        signUpContainer.isUserInteractionEnabled = true
        
        self.view.addSubview(loginContainer)
        self.view.addSubview(signUpContainer)
        signUpContainer.addSubview(signUpButton)
        signUpContainer.addSubview(signupFacebookButton)
        signUpContainer.addSubview(resetPasswordLinkLabelSignUp)
        loginContainer.addSubview(loginButton)
        loginContainer.addSubview(loginFacebookButton)
        loginContainer.addSubview(resetPasswordLinkLabelLogin)
        
        // Button Actions
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        loginFacebookButton.addTarget(self, action: #selector(handleFacebookLogin), for: .touchUpInside)
        signupFacebookButton.addTarget(self, action: #selector(handleFacebookLogin), for: .touchUpInside)
        configureConstraints()
        
        // Link Label Setup
        resetPasswordLinkLabelSignUp.setLinkText("Forgot Your Password?",
                                                 linkText: "Forgot Your Password?",
                                                 delegate: self)
        resetPasswordLinkLabelLogin.setLinkText("Forgot Your Password?",
                                                linkText: "Forgot Your Password?",
                                                delegate: self)
        
        // Gesture
        signUpSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(sender:)))
        signUpSwipeGesture?.direction = [.left]
        if let gesture = signUpSwipeGesture {
            self.view.addGestureRecognizer(gesture)
        }
        
        loginSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(sender:)))
        loginSwipeGesture?.direction = [.right]
        if let gesture = loginSwipeGesture {
            self.view.addGestureRecognizer(gesture)
        }
 
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.emailCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.passwordCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.confirmCell)
        tableView.register(AnimatedBarCell.self, forCellReuseIdentifier: AnimatedBarCell.reuseIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Just in case, let's re-enable buttons when navigation away from this view
        self.iaNavigationController?.leftButtons.first?.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loginHeader.setNeedsLayout()
        loginHeader.layoutSubviews()
        backgroundGradient.frame = self.view.bounds

        tableView.contentInset.bottom = signUpContainer.h           // container height
            + max(self.view.safeAreaInsets.bottom, 0.0, 20.0)       // + distance from bottom for container
            + 40.0                                                  // + a little extra buffer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasDeferredLoginSwitch {
            showLogin(animated: true)
            hasDeferredLoginSwitch.toggle()
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        let offset = max(self.view.safeAreaInsets.bottom, 0.0, 20.0)
        bottomContainerContraints?.update(offset: -offset)
    }
    
    // MARK: - Layout -
    
    private func configureConstraints() {
        let widthOffset: CGFloat = -40.0
        let interButtonVerticalMargin: CGFloat = UIScreen.hasNotch ? 14.0 : 10.0
        let buttonHeight = UIScreen.hasNotch ? 50.0 : 40.0
        
        // Containers
        signUpContainer.snp.makeConstraints { (make) in
            leadingContainerConstraint = make.leading.equalToSuperview().constraint
            make.width.equalToSuperview()
            bottomContainerContraints = make.bottom.equalTo(self.view.snp.bottom).constraint
        }
        
        loginContainer.snp.makeConstraints { (make) in
            make.leading.equalTo(signUpContainer.snp.trailing)
            make.width.equalToSuperview()
            make.bottom.equalTo(signUpContainer.snp.bottom)
        }
        
        // Sign Up Buttons
        resetPasswordLinkLabelSignUp.setAutoLayoutHeightEnforcement(990.0)
        resetPasswordLinkLabelSignUp.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
        }
        
        signUpButton.snp.makeConstraints { (make) in
            make.top.equalTo(resetPasswordLinkLabelSignUp.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(widthOffset).priority(990.0)
            make.height.equalTo(buttonHeight)
        }
        
        signupFacebookButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(widthOffset).priority(990.0)
            make.height.equalTo(buttonHeight)
            make.top.equalTo(signUpButton.snp.bottom).offset(interButtonVerticalMargin)
            make.bottom.equalToSuperview()
        }

        // Login buttons
        resetPasswordLinkLabelLogin.setAutoLayoutHeightEnforcement(990.0)
        resetPasswordLinkLabelLogin.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(resetPasswordLinkLabelLogin.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(widthOffset).priority(990.0)
            make.height.equalTo(buttonHeight)
        }
        
        loginFacebookButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(widthOffset).priority(990.0)
            make.height.equalTo(buttonHeight)
            make.top.equalTo(loginButton.snp.bottom).offset(interButtonVerticalMargin)
            make.bottom.equalToSuperview()
        }
    }
    
    func markDeferredSwitchToLogin() {
        hasDeferredLoginSwitch = true
    }
    
    func showLogin(animated: Bool = true) {
        viewingSignUp = false
        currentIndex = 1
        animatedBarCell?.setSelectedIndex(currentIndex)
        tableView.reloadSections([1], with: .left)
        self.leadingContainerConstraint?.update(offset: -self.view.w)
        
        guard animated else {
            self.view.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: 0.30, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showSignUp(animated: Bool = true) {
        viewingSignUp = true
        currentIndex = 0
        animatedBarCell?.setSelectedIndex(currentIndex)
        tableView.reloadSections([1], with: .right)
        leadingContainerConstraint?.update(offset: 0.0)
        
        guard animated else {
            self.view.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: 0.30, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Actions -
    
    // TODO: @V2 make a proper paging footer button. I hate how hacky this footer button is...
    @objc
    private func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        guard leadingContainerConstraint != nil else { return }
        if viewingSignUp && sender === signUpSwipeGesture {
            showLogin()
        } else if !viewingSignUp && sender === loginSwipeGesture {
            showSignUp()
        }
    }
    
    @objc
    private func handleLogin() {
        self.view.endEditing(true)
        
        guard
            let emailCell = emailCell,
            let passwordCell = passwordCell,
            validate([emailCell.textField, passwordCell.textField])
        else { return }

        self.state = .loading
        self.iaNavigationController?.leftButtons.first?.isEnabled = false
        self.loginDelegate?.loginViewControllerDidRequestLogin(self, email: emailCell.textField.iaText, password: passwordCell.textField.iaText)
    }
    
    @objc
    private func handleSignup() {
        self.view.endEditing(true)
        
        guard
            let emailCell = emailCell,
            let passwordCell = passwordCell,
            let confirmCell = confirmPasswordCell,
            validate([emailCell.textField, passwordCell.textField, confirmCell.textField])
        else { return }
        
        guard passwordCell.textField.iaText == confirmCell.textField.iaText else {
            let displayError = DisplayableError(title: "Passwords didn't match", message: "According to our security robots, your passwords didn't match! Don't worry, they say this happens a lot and you should try to re-enter your passwords. 🤖")
            self.presentAlert(with: displayError)
            return
        }
        
        self.state = .loading
        self.iaNavigationController?.leftButtons.first?.isEnabled = false
        
        // Guest Signup
        if SessionManager.guestSessionExists, let firebaseGuestUser = SessionManager.guestUser {
            let user = GuestUser(firebaseGuestUser)
            self.loginDelegate?.loginViewControllerDidRequestRegisterGuest(self, guest: user,
                                                                           email: emailCell.textField.iaText,
                                                                           password: passwordCell.textField.iaText)
        } else {
        // New User Signup
            self.loginDelegate?.loginViewControllerDidRequestRegisterUser(self,
                                                                          email: emailCell.textField.iaText,
                                                                          password: passwordCell.textField.iaText)
        }
    }
    
    @objc
    private func handleFacebookLogin() {
        self.view.endEditing(true)
        self.loginDelegate?.loginViewControllerDidRequestFacebookLogin(self)
    }
    
    @objc
    private func handlePasswordReset() {
        let dtvc = PasswordResetViewController()
        self.navigationController?.pushViewController(dtvc, animated: true)
    }
    
    // MARK: - Notification Handling -
    
    @objc
    private func handleLoginStateChange(notification: Notification) {
        if notification.name == .loginRequestDidFail {
            
            self.state = .ready
            self.iaNavigationController?.leftButtons.first?.isEnabled = true
            guard
                let error = notification.userInfo?[LoginControllerStateKeys.requestError] as? DisplayableError,
                let intent = notification.userInfo?[LoginControllerStateKeys.requestIntent] as? AuthIntent
            else { return }
            print("Failed Intent: \(intent)")
            self.presentAlert(with: error)
            
        } else if notification.name == .loginRequestDidSucceed {
            self.iaNavigationController?.navigationItem.leftBarButtonItem?.isEnabled = true
            if self.isModal { self.dismiss(animated: true, completion: nil) }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return viewingSignUp ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AnimatedBarCell.reuseIdentifier, for: indexPath) as! AnimatedBarCell
            cell.delegate = self
            
            // Drawing the animated line requires this layout pass now
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            cell.setSelectedIndex(currentIndex)
            animatedBarCell = cell
            
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.emailCell, for: indexPath) as! TextFieldCell
                cell.configure(placeholder: "Enter Email", validator: Validator(rules: [EmailRule()], identifier: "Email Address"))
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
                cell.preventsWhitespaceCharacters = true
                
                cell.textField.textContentType = .emailAddress
                cell.textField.keyboardType = .emailAddress
                
                cell.delegate = self
                emailCell = cell
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.passwordCell, for: indexPath) as! TextFieldCell
                cell.configure(placeholder: "Enter Password", validator: Validator(rules: [MinLengthRule(minLength: 8)], identifier: "Password"))
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
                cell.preventsWhitespaceCharacters = true
                cell.textField.isSecureTextEntry = true
                
                if viewingSignUp {
                    cell.textField.textContentType = .newPassword
                    cell.textField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: digit; max-consecutive: 2; minlength: 8;")
                } else {
                    cell.textField.textContentType = .password
                }
            
                
                cell.delegate = self
                passwordCell = cell
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.confirmCell, for: indexPath) as! TextFieldCell
                cell.configure(placeholder: "Confirm Password", validator: Validator(rules: [MinLengthRule(minLength: 8)], identifier: "Confirm Password"))
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
                cell.preventsWhitespaceCharacters = true
                
                cell.textField.textContentType = .newPassword
                cell.textField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: digit; max-consecutive: 2; minlength: 8;")
                cell.textField.isSecureTextEntry = true
            
                cell.delegate = self
                confirmPasswordCell = cell
                
                return cell
            }
        }
        
        return TableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return AnimatedBarCell.height
        }
        
        return 80.0
    }
}

// MARK: - AnimatedBarCellDelegate -

extension LoginViewController: AnimatedBarCellDelegate {
    
    func animatedBarCell(_ animatedBarCell: AnimatedBarCell, didSelectItemAt index: Int) {
        if index == 0 && !viewingSignUp {
            showSignUp()
        } else if index == 1 && viewingSignUp {
            showLogin()
        }
    }
    
}

// MARK: - TextFieldCellDelegate -

extension LoginViewController: TextFieldCellDelegate {
    
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

// MARK: - LinkLabelDelegate -

extension LoginViewController: LinkLabelDelegate {
    
    func linkLabel(_ linkLabel: LinkLabel, didSelectLink link: URL) {
        handlePasswordReset()
    }
    
}

// MARK: - LoginViewControllerDelegate Protocol -

protocol LoginViewControllerDelegate: class {
    
    func loginViewControllerDidRequestLogin(_ loginViewController: LoginViewController, email: String, password: String)
    
    func loginViewControllerDidRequestGuestLogin(_ loginViewController: LoginViewController)
    
    func loginViewControllerDidRequestRegisterUser(_ loginViewController: LoginViewController, email: String, password: String)
    
    func loginViewControllerDidRequestRegisterGuest(_ loginViewController: LoginViewController, guest: GuestUser, email: String, password: String)
    
    func loginViewControllerDidRequestFacebookLogin(_ loginViewController: LoginViewController)
    
}

// MARK: - Notification Names -

extension Notification.Name {
    
    static let loginRequestDidSucceed = Notification.Name(rawValue: "com.ia.loginController.requestDidSucceed")
    static let loginRequestDidFail = Notification.Name(rawValue: "com.ia.loginController.requestFailed")

}

// MARK: - Notification Keys -

struct LoginControllerStateKeys {
    
    static let requestIntent = "com.ia.loginControllerState.intentKey"
    static let requestError = "com.ia.loginControllerState.errorKey"

}
