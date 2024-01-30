//
//  OnboardViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/10/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

/// Simple ViewController with a paging Scroll view to display a 3-screen tutorial flow
class TutorialViewController: ViewController {
    weak var tutorialDelegate: TutorialViewControllerDelegate?
    
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .paleLavendar
        scrollview.alwaysBounceHorizontal = false
        scrollview.alwaysBounceVertical = false
        return scrollview
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .cta
        return pageControl
    }()
    
    private lazy var firstPage = TutorialView(stage: .first, delegate: self)
    private lazy var secondPage = TutorialView(stage: .second, delegate: self)
    private lazy var thirdPage = TutorialView(stage: .third, delegate: self)
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        pageControl.numberOfPages = 3
        
        scrollView.addSubview(firstPage)
        scrollView.addSubview(secondPage)
        scrollView.addSubview(thirdPage)

        self.view.addSubview(pageControl)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.size.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(10.0)
        }
        
        firstPage.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            make.bottom.equalTo(pageControl.snp.top)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
        }
        
        secondPage.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.width.height.equalTo(firstPage)
            make.leading.equalTo(firstPage.snp.trailing)
            make.bottom.equalTo(pageControl.snp.top)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
        }
        
        thirdPage.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.width.height.equalTo(firstPage)
            make.trailing.equalTo(scrollView.contentLayoutGuide)
            make.leading.equalTo(secondPage.snp.trailing)
            make.bottom.equalTo(pageControl.snp.top)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
        }
    }
    
    func reset() {
        self.scrollView.contentOffset = .zero
        pageControl.currentPage = 0
    }
    
}

// MARK: - Tutorial View Delegate

extension TutorialViewController: TutorialViewDelegate {
    
    func tutorialViewDidPressPrimaryCTA(_ tutorialView: TutorialView) {
        self.tutorialDelegate?.tutorialViewControllerDidTapLoginSignup(self)
    }
    
    func tutorialViewDidPressSecondaryCTA(_ tutorialView: TutorialView) {
        self.tutorialDelegate?.tutorialViewControllerDidTapContinueAsGuest(self)
    }
    
}

// MARK: - Scroll View Delegation

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / scrollView.w
        pageControl.currentPage = Int(index)
    }
    
}

// MARK: - OnboardViewControllerDelegate Protocol -

protocol TutorialViewControllerDelegate: class {
    
    func tutorialViewControllerDidTapLoginSignup(_ tutorialViewController: TutorialViewController)
    
    func tutorialViewControllerDidTapContinueAsGuest(_ tutorialViewController: TutorialViewController)
    
}
