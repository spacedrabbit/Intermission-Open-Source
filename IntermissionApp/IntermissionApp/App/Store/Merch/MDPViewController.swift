//
//  MDPViewController.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 4/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

class MDPViewController: TableViewController {
    
//    private let merch: TempMerch
    
    private let cartButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.cartFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.cartFilledDark.image, for: .highlighted)
        return button
    }()
    
    private let shareButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.shareFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.shareFilledDark.image, for: .highlighted)
        return button
    }()
    
    // MARK: - Initializers -
    
//    init(with merch: TempMerch) {
//        self.merch = merch
//        super.init(nibName: nil, bundle: nil)
//        commonInit()
//    }
    
    private func commonInit() {
        self.delegate = self
        self.isNavigationBarHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightNavigationButtons = [cartButton, shareButton]
        
        tableView.register(MDPHeroCell.self, forCellReuseIdentifier: MDPHeroCell.reuseIdentifier)
        tableView.register(MDPHeadingCell.self, forCellReuseIdentifier: MDPHeadingCell.reuseIdentifier)
        tableView.register(MDPMenuCell.self, forCellReuseIdentifier: MDPMenuCell.reuseIdentifier)
        tableView.register(StoreFooterCell.self, forCellReuseIdentifier: StoreFooterCell.reuseIdentifier)
        
        shareButton.addTarget(self, action: #selector(handleShareButtonTapped), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(handleCartButtonTapped), for: .touchUpInside)
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension MDPViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: MDPHeroCell.reuseIdentifier) as! MDPHeroCell
//            cell.configure(with: self.merch)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: MDPHeadingCell.reuseIdentifier) as! MDPHeadingCell
//            cell.configure(with: self.merch)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: MDPMenuCell.reuseIdentifier) as! MDPMenuCell
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: StoreFooterCell.reuseIdentifier) as! StoreFooterCell
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - Actions -
    
    @objc
    private func handleCartButtonTapped() {
        print("Add to Cart tapped")
    }
    
    @objc
    private func handleShareButtonTapped() {
        print("Share tapped")
    }
}
