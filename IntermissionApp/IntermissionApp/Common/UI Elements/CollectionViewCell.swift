//
//  CollectionViewCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell, ActivityPresentable {
    private let reloadView: ReloadView = ReloadView()

    // MARK: - Activity Presentable -
    
    func showActivity() {
        guard reloadView.superview == nil else {
            reloadView.removeFromSuperview()
            showActivity()
            return
        }
        
        reloadView.alpha = 0.0
        self.contentView.addSubview(reloadView)
        self.contentView.bringSubviewToFront(reloadView) // sanity
        reloadView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        reloadView.startAnimating()
        UIView.animate(withDuration: 0.15) {
            self.reloadView.alpha = 1.0
        }
    }
    
    func hideActivity() {
        guard reloadView.superview != nil else { return }
        reloadView.removeFromSuperview()
        reloadView.stopAnimating()
    }
}

class ShrinkableCollectionViewCell: CollectionViewCell {
    
    // MARK: - Constructors
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    // MARK: - Animations
    
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.transform = .identity
                }, completion: nil)
            }
        }
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        guard !self.isHighlighted else { return }
        super.layoutSubviews()
    }
    
}
