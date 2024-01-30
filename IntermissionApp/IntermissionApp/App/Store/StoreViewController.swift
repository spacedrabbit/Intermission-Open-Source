//
//  StoreViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/30/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - StoreViewController -

class StoreViewController: TableViewController {
    private var user: User?
    private var guest: GuestUser?
    private var retreats: [Retreat] = []
    
    private let refreshControl = UIRefreshControl()
    
    private let headerView = StoreHeaderView()
    
    private let safeAreaCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .navBarGreen
        return view
    }()
    
    // MARK: - Initializers -
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    init(guest: GuestUser) {
        self.guest = guest
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    private func commonInit() {
        self.view.backgroundColor = .white
        self.isNavigationBarHidden = true
        
        let title = Flags.shouldDisplayShop ? "Shop" : "Retreats"
        self.title = title
        self.tabBarItem = UITabBarItem(title: title, image: TabIcon.store.inactive, selectedImage: TabIcon.store.active)
        
        // Setup Views
        self.view.addSubview(safeAreaCoverView)
        self.view.addSubview(headerView)
        headerView.delegate = self
        
        // Constraints
        safeAreaCoverView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().priority(999.0)
            make.bottom.equalTo(headerView.snp.top).priority(999.0)
        }
        
        headerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().priority(999.0)
            make.height.equalTo(StoreHeaderView.requiredContentHeight).priority(998.0)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).priority(998.0)
        }
        
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdated(notification:)), name: .userInfoUpdateSuccess, object: nil)
        
        
        // Reload
        reload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table Set up
        tableView.contentInsetAdjustmentBehavior = .automatic
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        
        // Update Insets to include mocked header
        self.additionalSafeAreaInsets = UIEdgeInsets(top: StoreHeaderView.requiredContentHeight,
                                                     left: 0.0, bottom: 0.0, right: 0.0)
        
        // basic refresh control
        self.tableView.refreshControl = refreshControl
        refreshControl.tintColor = .accent
        refreshControl.attributedTitle = "meditating...".set(style: Font.refreshControlText)
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        // Registering Cells
        tableView.register(RetreatTableViewCell.self, forCellReuseIdentifier: RetreatTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Reload -
    
    @objc
    override func reload() {
        ContentfulService.getRetreats { [weak self] (result: IAResult<[Retreat], ContentError>) in
            switch result {
            case .success(let retreats):
                self?.retreats = retreats
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                // Adding a delay makes this transition much smoother
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                })
                
            case .failure(let error):
                self?.presentAlert(with: error.displayError)
            }
        }
    }
    
    // MARK: - Notifications -
    
    @objc
    private func handleUserUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let user = userInfo[DatabaseUpdatedNotificationKey.user] as? User else { return }
        self.user?.decorate(with: user)
        self.tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension StoreViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return retreats.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RetreatTableViewCell.reuseIdentifier) as! RetreatTableViewCell
        
        if retreats.count >= indexPath.row + 1 {
            cell.configure(with: self.retreats[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if retreats.count >= indexPath.row + 1 {
            let selectedRetreat = retreats[indexPath.row]
            
            if let user = user {
                let dtvc = RetreatViewController(with: selectedRetreat, user: user)
                self.navigationController?.pushViewController(dtvc, animated: true)
            } else if let guest = guest {
                let dtvc = RetreatViewController(with: selectedRetreat, guestUser: guest)
                self.navigationController?.pushViewController(dtvc, animated: true)
            }
        }
    }
    
}

// MARK: -

extension StoreViewController: StoreHeaderViewDelegate {
    
    func storeHeaderView(_ storeHeaderView: StoreHeaderView, didTapCart button: Button) {
        self.ia_presentAlert(with: "The Cart!", message: "You've selected to view your cart. But we don't yet have this feature implemented. Come back later and check in on our progress 🤓")
    }
    
}
