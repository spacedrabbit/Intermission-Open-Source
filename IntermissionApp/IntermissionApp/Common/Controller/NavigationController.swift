//
//  NavigationController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/25/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    private(set) var leftButtons = [UIButton]()
    private(set) var rightButtons = [UIButton]()
    private var animateButtonLayout = false
    
    private var preferredBarStyle: UIStatusBarStyle = .lightContent
    
    var showNavButtonsWhenBarIsHidden = true
    
    private struct ButtonLayout {
        static let xMargin: CGFloat = 14.0
        static let yMargin: CGFloat = 26.0
        static let spacing: CGFloat = 18.0
    }
    
    // MARK: - Constructors -
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    private func commonInit() {
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigationButtonsDidChange(notification:)), name: .didChangeNavigationButtons, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didChangeNavigationButtons, object: nil)
    }
        
    // MARK: - Notifications -
        
    @objc
    func handleNavigationButtonsDidChange(notification: Notification) {
        guard let navigationItem = notification.userInfo?[NavigationItemKeys.item] as? UINavigationItem, navigationItem === self.topViewController?.navigationItem else { return }
        reloadNavigationButtons()
    }
        
    // MARK: - Navigation Items
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.isHidden = self.topViewController?.isNavigationBarHidden ?? false
        reloadNavigationButtons(animated: animateButtonLayout)
    }
    
    private func reloadNavigationButtons(animated: Bool = false) {
        if let topController = self.topViewController {
            layoutNavigationButtons(for: topController, animated: animated)
        }
    }
    
    private func layoutNavigationButtons(for controller: UIViewController, animated: Bool = false) {
        animateButtonLayout = false
        
        let duration: TimeInterval = controller.transitionCoordinator?.transitionDuration ?? 0.0
        
        if animated {
            let left = leftButtons
            let right = rightButtons
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
                left.forEach { $0.alpha = 0.0 }
                right.forEach { $0.alpha = 0.0 }
            }, completion: { _ in
                left.forEach { $0.removeFromSuperview() }
                right.forEach { $0.removeFromSuperview() }
            })
        } else {
            leftButtons.forEach { $0.removeFromSuperview() }
            rightButtons.forEach { $0.removeFromSuperview() }
        }
        
        leftButtons = controller.navigationItem.leftNavigationButtons
        rightButtons = controller.navigationItem.rightNavigationButtons
        
        // if the controller is showing the navigation bar there's nothing else to do
        if !controller.isNavigationBarHidden { return }
        
        // Some plain-english logic
        let controllerIsInStack = self.viewControllers.contains(controller)
        let controllerIsntFirstInStack = self.viewControllers.first !== controller
        let controllerIsFirstInStackAndModallyPresented = self.viewControllers.first === controller && controller.isModal
        let controllerShowsBackButton = !controller.navigationItem.hidesBackButton
        
        if leftButtons.count == 0
            && controllerIsInStack
            && (controllerIsntFirstInStack || controllerIsFirstInStackAndModallyPresented)
            && controllerShowsBackButton
            && showNavButtonsWhenBarIsHidden {

            // add the back button
            let button = Button()
            button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
            
            // TODO: disabled state image
            if controller.isModal {
                button.setImage(Icon.NavBar.xCloseFilledLight.image, for: .normal)
                button.setImage(Icon.NavBar.xCloseFilledDark.image, for: .highlighted)
                button.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
            } else {
                button.setImage(Icon.Chevron.backFilledLight.image, for: .normal)
                button.setImage(Icon.Chevron.backFilledDark.image, for: .highlighted)
                button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
            }
            
            button.layer.shadowColor = UIColor.navBarGreen.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            button.layer.shadowRadius = 5.0
            
            leftButtons.append(button)
        }
        
        var xPos: CGFloat = ButtonLayout.xMargin
        leftButtons.forEach { button in
            self.view.addSubview(button)
            // use the top safe area inset on iPhone X, otherwise use the yMargin constant
            button.frame = CGRect(x: xPos,
                                  y: UIScreen.hasNotch ? self.view.safeAreaInsets.top : ButtonLayout.yMargin,
                                  width: button.frame.size.width, height: button.frame.size.height)
            xPos += button.frame.size.width + ButtonLayout.spacing
        }
        
        xPos = self.view.frame.size.width - ButtonLayout.xMargin
        rightButtons.forEach { button in
            self.view.addSubview(button)
            xPos -= button.frame.size.width
            // use the top safe area inset on iPhone X, otherwise use the yMargin constant
            button.frame = CGRect(x: xPos,
                                  y: UIScreen.hasNotch ? self.view.safeAreaInsets.top : ButtonLayout.yMargin,
                                  width: button.frame.size.width, height: button.frame.size.height)
            
            button.layer.shadowColor = UIColor.navBarGreen.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            button.layer.shadowRadius = 5.0
            
            xPos -= ButtonLayout.spacing
        }
        
        if animated {
            leftButtons.forEach { $0.alpha = 0.0 }
            rightButtons.forEach { $0.alpha = 0.0 }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
                self.leftButtons.forEach { $0.alpha = 1.0 }
                self.rightButtons.forEach { $0.alpha = 1.0 }
            }, completion: nil)
        } else {
            leftButtons.forEach { $0.alpha = 1.0 }
            rightButtons.forEach { $0.alpha = 1.0 }
        }
    }
    
    // MARK: - Events -
    
    @objc
    private func handleBackTapped() {
        _ = self.popViewController(animated: true)
    }
    
    @objc
    private func handleCloseTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation -
    
    override func popViewController(animated: Bool) -> UIViewController? {
        animateButtonLayout = animated
        return super.popViewController(animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        animateButtonLayout = animated
        super.pushViewController(viewController, animated: animated)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        animateButtonLayout = animated
        return super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        animateButtonLayout = flag
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    // MARK: - Transition Support -
    
    open func pushViewController(_ viewController: UIViewController, transition: Transition) {
        animateButtonLayout = true
        viewController.transitioningDelegate = transition
        super.pushViewController(viewController, animated: true)
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let toTransition = toVC.iaNavigationTransition, operation == .push {
            toTransition.isPresenting = true
            return toTransition
        } else if let fromTransition = fromVC.iaNavigationTransition, operation == .pop {
            fromTransition.isPresenting = false
            return fromTransition
        }
        
        return nil
    }
    
}
