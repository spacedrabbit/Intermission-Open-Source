//
//  TableViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/31/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class TableViewController: ScrollViewController {
    
    /// Clears selected cells (if any) on viewWillAppear. Default value is `true`.
    public var clearsSelectionOnViewWillAppear: Bool = true
    
    public let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    public var delegate: (UITableViewDelegate & UITableViewDataSource)? {
        didSet {
            tableView.delegate = delegate
            tableView.dataSource = delegate
            
            // If we've added this to a VC already, reload the data immediately
            if self.parent != nil { tableView.reloadData() }
        }
    }
    
    override func loadView() {
        self.view = UIView()
        self.scrollView = tableView
        self.view.addSubview(self.scrollView)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if clearsSelectionOnViewWillAppear, let selectedIndicies = tableView.indexPathsForSelectedRows {
            selectedIndicies.forEach { tableView.deselectRow(at: $0, animated: false) }
        }
    }
}
