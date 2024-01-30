//
//  OnboardingViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/26/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - OnboardingUserNameViewController -

/** First step in a new user onboarding flow. This shows a simple animation to prompt a new user to fill out their name
 
 */
class OnboardingUserNameViewController: TableViewController {
    private let user: User
    private let userDataCoordinator = UserDataCoordinator()
    weak var onboardingDelegate: OnboardingDelegate?
    
    private let nameCaptureView = OnboardingNameCaptureView()
    private let saveButton = CTAButton()
    private var firstNameCell: TextFieldCell?
    private var lastNameCell: TextFieldCell?
    private var animationsFinished: Bool = false
    
    // MARK: - ReuseIdentifier
    
    private struct ReuseIdentifier {
        static let firstNameCell = "firstNameCellIdentifier"
        static let lastNameCell = "lastNameCellIdentifier"
    }
    
    // MARK: - Constructors -
    
    init(with user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        self.isNavigationBarHidden = true
        userDataCoordinator.delegate = self
        
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
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isHidden = true
        
        self.view.addSubview(nameCaptureView)
        self.view.addSubview(saveButton)
        
        nameCaptureView.delegate = self
        nameCaptureView.configure(for: user)
        
        saveButton.setText("SAVE")
        saveButton.addTarget(self, action: #selector(handleSaveTapped), for: .touchUpInside)
        saveButton.isEnabled = !user.name.isMissingInfo
        
        nameCaptureView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-24.0)
            make.width.equalTo(250.0)
            make.height.equalTo(50.0)
            make.centerX.equalToSuperview()
        }
        
        // Cell Registering
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.firstNameCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ReuseIdentifier.lastNameCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameCaptureView.beginAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: nameCaptureView.h, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    // MARK: - Events
    
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

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension OnboardingUserNameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
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
            
            // TODO: this animation isn't quite working at all
            firstNameCell = cell
            firstNameCell?.alpha = animationsFinished ? 1.0 : 0.0
            
            return cell
        } else {
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
            
            // TODO: this animation isn't quite working at all
            lastNameCell = cell
            lastNameCell?.alpha = animationsFinished ? 1.0 : 0.0
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
}

// MARK: - UserDataCoordinatorDelegate -

extension OnboardingUserNameViewController: UserDataCoordinatorDelegate {
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didCompleteUpdate intent: UserUpdateIntent, forUser user: User) {
        guard case UserUpdateIntent.username = intent else {
            self.state = .ready
            let errorDomain = ErrorType.Onboarding.Subtype.saveName
            
            self.ia_presentAlert(with: "Something went wrong.", message: "We're not entirely sure what the problem was, but you should try saving your name again.\n\n If it happens again, message our support team at \(CustomerSupportManager.emailAddress) with error info:\n\nError Code: \(errorDomain.errorCode) - \(errorDomain.displayName ?? "")")
            Track.track(domain: errorDomain)
            return
        }
        
        if self.state == .loading { self.state = .ready }
        onboardingDelegate?.onboardingDelegate(self, didUpdateNameForUser: user)
    }
    
    func userDataCoordinator(_ userDataCoordinator: UserDataCoordinator, didFailUpdate intent: UserUpdateIntent, error: DisplayableError) {
        if self.state == .loading { self.state = .ready }
        self.ia_presentAlert(with: error.title, message: error.message)
        
        // TODO: offer a way to skip? Don't want folks to get stuck here.
        // Perhaps just offer the option to continue w/o updating their name and then the can come back to it.
        // This will have implecations for the dashboard and profile header
    }
    
}

// MARK: - OnboardingNameCaptureViewDelegate -

extension OnboardingUserNameViewController: OnboardingNameCaptureViewDelegate {
    
    func nameCaptureViewDidFinishAnimating(_ nameCaptureView: OnboardingNameCaptureView) {
        guard !animationsFinished else { return }
        tableView.isHidden = false
        
        firstNameCell?.alpha = 0.0
        lastNameCell?.alpha = 0.0
        firstNameCell?.transform = CGAffineTransform(translationX: 0.0, y: 60.0)
        lastNameCell?.transform = CGAffineTransform(translationX: 0.0, y: 60.0)
        
        lastNameCell?.isHidden = true
        
        UIView.animate(withDuration: 0.75, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.firstNameCell?.transform = .identity
            self.firstNameCell?.alpha = 1.0
        }) { (complete) in }
        
        UIView.animate(withDuration: 0.65, delay: 0.5, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.lastNameCell?.isHidden = false
            
            self.lastNameCell?.transform = .identity
            self.lastNameCell?.alpha = 1.0
        }) { (complete) in
            self.animationsFinished = true
        }
    }
    
}

// MARK: - TextFieldCellDelegate -

extension OnboardingUserNameViewController: TextFieldCellDelegate {
    
    func textFieldCellDidEndEditing(_ textFieldCell: TextFieldCell) {
        
    }
    
    func textFieldCellShouldReturn(_ textFieldCell: TextFieldCell) -> Bool {
        textFieldCell.textField.resignFirstResponder()
        return true
    }
    
    func textFieldCell(_ textFieldCell: TextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if firstNameCell?.textField.isValid == true && lastNameCell?.textField.isValid == true {
            saveButton.isEnabled = true
        }
        
        return true
    }
    
}

// MARK: - OnboardingViewControllerDelegate Protocol -

protocol OnboardingDelegate: class {
    
    func onboardingDelegate(_ onboardingViewController: OnboardingUserNameViewController, didUpdateNameForUser user: User)
    
    func onboardingDelegate(_ onboardingViewController: OnboardingProfileImageController, didUploadProfileImage url: URL, user: User)
    
    func onboardingDelegate(_ onboardingViewController: OnboardingProfileImageController, didSkipProfileImageUpload user: User)
    
    func onboardingDelegatedidFinishRegistering(user: User)
    
}


// MARK: - OnboardingNameCaptureView -

class OnboardingNameCaptureView: UIView {
    weak var delegate: OnboardingNameCaptureViewDelegate?
    private var propertyAnimator: UIViewPropertyAnimator?
    
    private let titleLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingTitleText]
        label.numberOfLines = 3
        return label
    }()
    
    private let detailLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingDetailText]
        label.numberOfLines = 2
        return label
    }()
    
    private let elenaIconImageView: ProfileImageButton = ProfileImageButton()
    private let melissaIconImageView: ProfileImageButton = ProfileImageButton()
    
    private let elenaNameLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingDetailText]
        label.numberOfLines = 1
        return label
    }()
    
    private let melissaNameLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingDetailText]
        label.numberOfLines = 1
        return label
    }()
    
    private let andLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.onboardingDetailText]
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initializers -
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        [titleLabel, detailLabel,
         elenaIconImageView, melissaIconImageView,
         elenaNameLabel, melissaNameLabel, andLabel].forEach {
            self.addSubview($0)
        }
        
        elenaIconImageView.adjustForOnboarding(image: Onboarding.People.el.image)
        melissaIconImageView.adjustForOnboarding(image: Onboarding.People.mel.image)
        
        configureConstraints()
        prepareAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(for user: User) {
        melissaNameLabel.styledText = "I'm Melissa"
        elenaNameLabel.styledText = "I'm Elena"
        andLabel.styledText = "and"
        
        titleLabel.styledText = "We're so excited to take an Intermission with you!"
        if user.name.isMissingInfo {
            detailLabel.styledText = "What should we call you?"
        } else { // Presumably facebook-backed info
            detailLabel.styledText = "Did we get your name right?"
        }
    }
    
    private func configureConstraints() {
        
        titleLabel.enforceHeightOnAutoLayout()
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(995.0)
        }
        
        elenaIconImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40.0)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.width.height.equalTo(90.0)
        }
        
        elenaNameLabel.enforceSizeOnAutoLayout()
        elenaNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(elenaIconImageView.snp.centerX)
            make.top.equalTo(elenaIconImageView.snp.bottom).offset(6.0)
        }
        
        andLabel.enforceSizeOnAutoLayout()
        andLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.baseline.equalTo(elenaNameLabel.snp.baseline)
        }
        
        melissaIconImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40.0)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.width.height.equalTo(90.0)
        }
        
        melissaNameLabel.enforceSizeOnAutoLayout()
        melissaNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(melissaIconImageView.snp.centerX)
            make.top.equalTo(melissaIconImageView.snp.bottom).offset(6.0)
        }
        
        detailLabel.enforceHeightOnAutoLayout()
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40.0)
            make.top.equalTo(elenaNameLabel.snp.bottom).offset(70.0)
            make.bottom.equalToSuperview().inset(60.0)
        }
    }
    
    // MARK: - Animations
    
    func beginAnimation() {
        propertyAnimator?.startAnimation()
    }
    
    private func prepareAnimation() {
        [titleLabel, detailLabel,
         elenaIconImageView, melissaIconImageView,
         elenaNameLabel, melissaNameLabel, andLabel]
            .forEach {
                $0.alpha = 0.0
                $0.transform = CGAffineTransform(translationX: 0.0, y: 12.0)
        }
        
        let detailLabelAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut) {
            self.detailLabel.transform = .identity
            self.detailLabel.alpha = 1.0
        }

        let elenaAnimator = UIViewPropertyAnimator(duration: 0.75, curve: .linear) {
            self.elenaNameLabel.transform = .identity
            self.elenaIconImageView.transform = .identity
            self.elenaNameLabel.alpha = 1.0
            self.elenaIconImageView.alpha = 1.0
        }

        let andAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.andLabel.transform = .identity
            self.andLabel.alpha = 1.0
        }
        
        let melissaAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.melissaIconImageView.transform = .identity
            self.melissaNameLabel.transform = .identity
            self.melissaNameLabel.alpha = 1.0
            self.melissaIconImageView.alpha = 1.0
        }

        propertyAnimator = UIViewPropertyAnimator(duration: 1.5, curve: .linear) {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1.0
        }
        
        // Ok, now get everything in order
        propertyAnimator?.addCompletion({ (position) in
            elenaAnimator.startAnimation()
        })
        
        elenaAnimator.addCompletion { (position) in
            andAnimator.startAnimation()
        }
        
        andAnimator.addCompletion { (position) in
            melissaAnimator.startAnimation()
        }
        
        melissaAnimator.addCompletion { (position) in
            detailLabelAnimator.startAnimation()
        }
        
        detailLabelAnimator.addCompletion { (position) in
            self.delegate?.nameCaptureViewDidFinishAnimating(self)
        }
    }
    
    
}

// MARK: - OnboardingNameCaptureViewDelegate Protocol -

protocol OnboardingNameCaptureViewDelegate: class {
    
    func nameCaptureViewDidFinishAnimating(_ nameCaptureView: OnboardingNameCaptureView)
    
}
