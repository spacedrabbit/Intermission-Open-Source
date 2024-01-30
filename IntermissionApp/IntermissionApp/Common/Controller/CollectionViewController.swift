//
//  CollectionViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/31/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class CollectionViewController: ScrollViewController {
    
    public let collectionView: UICollectionView
    
    /// Clears selected cells (if any) on viewWillAppear. Default value is `true`.
    public var clearsSelectionOnViewWillAppear: Bool = true
    
    public var delegate: (UICollectionViewDataSource & UICollectionViewDelegate)? {
        didSet {
            collectionView.delegate = delegate
            collectionView.dataSource = delegate
            
            // If we've added this to a VC already, reload the data immediately
            if self.parent != nil {
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Constructors
    
    public init(collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    // MARK: - View Lifecycle
    
    open override func viewDidLoad() {
        // assign the scrollView reference
        self.scrollView = collectionView
        
        // adds the collectionView to self.view
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if clearsSelectionOnViewWillAppear, let selectedIndicies = collectionView.indexPathsForSelectedItems {
            selectedIndicies.forEach{ collectionView.deselectItem(at: $0, animated: false) }
        }
    }
    
    
}
