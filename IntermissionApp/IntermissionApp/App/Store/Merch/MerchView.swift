//
//  MerchView.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 2/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/**
 
 Note: This is curerntly an un-used class. It is likely that by the time we add in merch again the design will have changed
 We're keeping this file for design and usage reference, but it will ultimately need to be deleted
 
 */

protocol MerchViewDelegate: class {
    func merchViewDidSelectItem(_ merchView: MerchView, index: Int)
}

class MerchView: UIView {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
//
//    private var merch: [TempMerch] = [] {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
    
    weak var delegate: MerchViewDelegate?
    
    private override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(collectionView)
        
        collectionView.register(MerchCollectionViewCell.self, forCellWithReuseIdentifier: MerchCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
//    func configure(with merch: [TempMerch]) {
//        self.merch = merch
//    }
}

extension MerchView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
        //        return self.merch.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MerchCollectionViewCell.reuseIdentifier, for: indexPath) as! MerchCollectionViewCell
//        cell.configure(with: self.merch[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height - 100
        let scaleFactorWidth = (screenWidth / 2) - 10
        let scaleFactorHeight = (screenHeight / 3)
        
        return CGSize(width: scaleFactorWidth, height: scaleFactorHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.merchViewDidSelectItem(self, index: indexPath.row)
    }
}
