//
//  UIViewController+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - Validations -

extension UIViewController {
    
    /**
     Validates an array of `Validatable`s and optionally presents an alert if a field fails validation. Returns `false`
     if an error was encountered and `true` if all fields passed validation.
     
     */
    func validate(_ validatables: [Validatable], failSilently: Bool = false) -> Bool {
        let failures = validatables.compactMap { (field: Validatable) -> (validatable: Validatable, rule: Rule)? in
            if let failedRule = field.validator.validate(string: field.validationText) {
                return (validatable: field, rule: failedRule)
            }
            return nil
        }
        
        if let validatable = failures.first?.validatable, let rule = failures.first?.rule {
            if !failSilently {
                let error = rule.error(for: validatable.validationText, identifier: validatable.validator.identifier)
                self.presentAlert(with: error)
            }
            
            return false
        }
        
        return true
    }
    
}

// MARK: - Alerts -

extension UIViewController {
    
    /**
     Convenience method of presenting an alert.
     
     */
    func presentAlert(with displayError: DisplayableError) {
        guard !displayError.isIgnored else { return }
        ia_presentAlert(with: displayError.title, message: displayError.message)
    }
    
    /**
     Convenience method used to display an alert. By default if `actions` is omitted, there will be a single "OK" action made available
     
     */
    func presentAlert(with title: String, message: String, primary: AlertAction = .okAction, secondary: AlertAction? = nil, canTapToDismiss: Bool = true) {
        DispatchQueue.main.async {
            self.view.findAndResignFirstResponder()
        
            let alertController = AlertViewController(with: title, message: message, primaryAction: primary, secondaryAction: secondary)
            alertController.allowTapToDismiss(canTapToDismiss)
            
            if let navVC = self.navigationController {
                navVC.present(alertController, with: SlideFromTopTransition())
            } else {
                self.present(alertController, with: SlideFromTopTransition())
            }
        }
    }
    
    func ia_presentAlert(with title: String, message: String) {
        DispatchQueue.main.async {
            self.view.findAndResignFirstResponder()
            
            let okAction: AlertAction = AlertAction(title: "OK", action: { (controller, _) in
                controller.dismiss(animated: true, completion: nil)
            })
            
            let alertController = AlertViewController(with: title, message: message, primaryAction: okAction, secondaryAction: nil)
            if let navVC = self.navigationController {
                navVC.present(alertController, with: SlideFromTopTransition())
            } else {
                self.present(alertController, with: SlideFromTopTransition())
            }
        }
    }
}

// MARK: - Transitions/Other -

extension UIViewController {
    
    // MARK: - Custom Modal Transitions
    
    func present(_ viewControllerToPresent: UIViewController, with transition: Transition, modalPresentationStyle: UIModalPresentationStyle = .custom, completion: (() -> Swift.Void)? = nil) {
//        self.iaModalTransition = transition
        
        viewControllerToPresent.iaModalTransition = transition
        viewControllerToPresent.transitioningDelegate = transition
        viewControllerToPresent.modalPresentationStyle = modalPresentationStyle
        self.present(viewControllerToPresent, animated: true, completion: completion)
    }
    
    // MARK: - Generated Getters -
    
    var iaNavigationController: NavigationController? {
        return self.navigationController as? NavigationController
    }
    
    // taken from https://stackoverflow.com/a/43020070
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Stored Properties
    
    private struct Keys {
        static var modalTransition = "com.ia.viewController.modalTransition"
        static var navigationBarHidden = "com.ia.viewController.navigationBarHidden"
        static var navigationTransition = "com.ia.viewController.navigationTransition"
    }
    
    public var isNavigationBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &Keys.navigationBarHidden) as? Bool ?? false
        }
        set {
            // strong
            objc_setAssociatedObject(self, &Keys.navigationBarHidden, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let navigationController = iaNavigationController {
                navigationController.navigationBar.isHidden = newValue
                
                // reload the navigation buttons
                NotificationCenter.default.post(name: .didChangeNavigationButtons, object: nil, userInfo: [NavigationItemKeys.item: self.navigationItem])
            }
        }
    }
    
    var iaModalTransition: Transition? {
        get {
            return objc_getAssociatedObject(self, &Keys.modalTransition) as? Transition
        }
        set {
            // strong
            objc_setAssociatedObject(self, &Keys.modalTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var iaNavigationTransition: Transition? {
        get {
            return objc_getAssociatedObject(self, &Keys.navigationTransition) as? Transition
        }
        set {
            // strong
            objc_setAssociatedObject(self, &Keys.navigationTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
