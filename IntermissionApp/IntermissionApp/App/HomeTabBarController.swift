//
//  HomeTabBarController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/30/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

// TODO: Update to use dependency injection via guest user or authed user
class HomeTabBarController: TabBarController {
    
    enum HomeTab: Int {
        case dash, feed, store, profile
    }
    
    private let dashVC: DashboardViewController
    private let feedVC: FeedViewController
    private let storeVC: StoreViewController
    private let profileVC: ProfileViewController
    
    private let dashboardNav: NavigationController
    private let feedNav: NavigationController
    private let storeNav: NavigationController
    private let profileNav: NavigationController
    
    private var tabDict: [HomeTab : NavigationController] {
        return [.dash : dashboardNav,
                .feed : feedNav,
                .store: storeNav,
                .profile : profileNav]
    }
    
    init(with user: User) {
        dashVC = DashboardViewController(user: user)
        feedVC = FeedViewController(user: user)
        storeVC = StoreViewController(user: user)
        profileVC = ProfileViewController(user: user)
        
        dashboardNav = NavigationController(rootViewController: dashVC)
        feedNav = NavigationController(rootViewController: feedVC)
        storeNav = NavigationController(rootViewController: storeVC)
        profileNav = NavigationController(rootViewController: profileVC)
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    init(with guest: GuestUser) {
        dashVC = DashboardViewController(guest: guest)
        feedVC = FeedViewController(guest: guest)
        storeVC = StoreViewController(guest: guest)
        profileVC = ProfileViewController(guest: guest)
        
        dashboardNav = NavigationController(rootViewController: dashVC)
        feedNav = NavigationController(rootViewController: feedVC)
        storeNav = NavigationController(rootViewController: storeVC)
        profileNav = NavigationController(rootViewController: profileVC)
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    private func commonInit() {
        self.setViewControllers([dashboardNav, feedNav, storeNav, profileNav], animated: false)
        self.tabBar.tintColor = .cta
        self.delegate = self
    }
    
    deinit {
        print("Home Tab Deinited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func route(to tab: HomeTab) {
        switch tab {
        case .dash: self.selectedViewController = dashboardNav
        case .feed: self.selectedViewController = feedNav
        case .store: self.selectedViewController = storeNav
        case .profile: self.selectedViewController = profileNav
        }
    }
}

extension HomeTabBarController {
    
    // TODO: decide whether or not to keep transition animation
    /*
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let orderedVCs = [dashboardNav, feedNav, storeNav, profileNav].enumerated().map { (idx, vc) -> (Int, UIViewController) in
            return (idx, vc)
        }
        
        guard
            let from = orderedVCs.first(where: { $0.1 === fromVC} ),
            let to = orderedVCs.first(where: { $0.1 === toVC })
        else { return nil }
        
        let direction: TabSwitchingTransition.Direction = from.0 - to.0 < 0 ? .leftToRight : .rightToLeft
        return TabSwitchingTransition(from: fromVC, to: toVC, intermediary: [], direction: direction)
    }
    */
}
