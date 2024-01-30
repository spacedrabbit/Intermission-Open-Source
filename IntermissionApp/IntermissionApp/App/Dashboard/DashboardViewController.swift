//
//  DashboardViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/30/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class DashboardViewController: TableViewController {
    private var user: User?
    private var guest: GuestUser?
    private var errors: [DisplayableError] = []
    private let refreshControl = UIRefreshControl()
    
    // Content to Display
    private var lastViewed: VideoHistoryEntry?
    private var favoritedPosts: [VideoHistoryEntry]?
    private var recommendedPosts: [Post]?
    
    private let headerView = DashboardHeaderView()
    private let guestDashboardView: GuestDashboardView = GuestDashboardView()
    private let emptyDashboardView: EmptyUserDashboardView = EmptyUserDashboardView()
    
    private var homeTabBarController: HomeTabBarController? {
        return self.tabBarController as? HomeTabBarController
    }
    
    // MARK: Calculators
    private let calc = Calculators()
    private struct Calculators {
        let videoHistoryCell = DashboardVideoHistoryCell(frame: .zero)
    }
    
    // MARK: ReuseIdentifer
    private struct ReuseIdentifier {
        static let historyTopBorder = "historyTopBorderIdentifier"
        static let historyHelperText = "historyHelperTextIdentifier"
        static let historyYogi = "historyYogiIdentifier"
        static let historyBottomBorder = "historyBottomBorderIdentifier"
        static let history = "historyIdentifier"
        
        static let browseTopWave = "browseTopWaveIdentifier"
        static let browse = "browseIdentifier"
        
        static let favoritesTopBorder = "favoritesTopBorderIdentifier"
        static let favoritesHelperText = "favoritesHelperTextIdentifier"
        static let favorites = "favoritesIdentifier"
    
        static let bottom = "bottomIdentifier"
    }
    
    // MARK: Rows
    private let sections: [Sections] = Sections.allCases
    enum Sections: Int, CaseIterable {
        case history, browse, favorites, bottom
    }
    
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
        self.delegate = self
        self.tabBarItem = UITabBarItem(title: "Home", image: TabIcon.dashboard.inactive, selectedImage: TabIcon.dashboard.active)
        self.title = "Home"
        self.isNavigationBarHidden = true
        
        self.reload()
        
        var insets = self.tableView.contentInset
        insets.bottom = 44.0
        self.tableView.contentInset = insets
        
        // basic refresh control
        self.tableView.refreshControl = refreshControl
        refreshControl.tintColor = .accent
        refreshControl.attributedTitle = "meditating...".set(style: Font.refreshControlText)
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        self.guestDashboardView.delegate = self
        self.emptyDashboardView.delegate = self
        
        registerForNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Empty State Set up
        self.view.addSubview(emptyDashboardView)
        self.view.addSubview(guestDashboardView)
        
        guestDashboardView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        emptyDashboardView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Common
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableHeaderView = headerView
        tableView.contentInsetAdjustmentBehavior = .automatic
        
        // Cell Registering
        
        // History
        tableView.register(DashboardVideoHistoryCell.self, forCellReuseIdentifier: ReuseIdentifier.history)
        
        tableView.register(DashboardYogiDecoratorCell.self, forCellReuseIdentifier: ReuseIdentifier.historyYogi)
        tableView.register(DashboardHelperTextCell.self, forCellReuseIdentifier: ReuseIdentifier.historyHelperText)
        tableView.register(BorderCell.self, forCellReuseIdentifier: ReuseIdentifier.historyTopBorder)
        tableView.register(BorderCell.self, forCellReuseIdentifier: ReuseIdentifier.historyBottomBorder)
        
        // Browse
        tableView.register(BorderCell.self, forCellReuseIdentifier: ReuseIdentifier.browseTopWave)
        tableView.register(HorizontalPostsCell.self, forCellReuseIdentifier: ReuseIdentifier.browse)
        
        // Favorites
        tableView.register(GridTableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.favorites)
        tableView.register(BorderCell.self, forCellReuseIdentifier: ReuseIdentifier.favoritesTopBorder)
        tableView.register(DashboardHelperTextCell.self, forCellReuseIdentifier: ReuseIdentifier.favoritesHelperText)
        
        // Bottom
        tableView.register(DashboardYogiDecoratorCell.self, forCellReuseIdentifier: ReuseIdentifier.bottom)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func emptyStateCheck() {
        emptyDashboardView.isHidden = true
        guestDashboardView.isHidden = true
        
        let hasHistory = lastViewed != nil
        let hasFavorites = favoritedPosts != nil && !(favoritedPosts ?? []).isEmpty
        
        if let _ = guest {
            guestDashboardView.isHidden = false
            emptyDashboardView.isHidden = true
            
        } else if let user = user, !hasHistory && !hasFavorites{
            guestDashboardView.isHidden = true
            emptyDashboardView.isHidden = false
            
            var additionalText = ""
            if !user.name.first.isEmpty {
                additionalText = ", \(user.name.first)"
            }
            emptyDashboardView.setHeaderText("Welcome\(additionalText) 👋🏽👋🏾")
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        // User
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdated(notification:)), name: .userInfoUpdateSuccess, object: nil)
        
        // Favorites
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdatedNotification), name: .userAddedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdatedNotification), name: .userUpdatedFavorites, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdatedNotification), name: .userRemovedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdatedNotification), name: .userFavoritesErrored, object: nil)
        
        // Video History
        NotificationCenter.default.addObserver(self, selector: #selector(handleVideoHistoryUpdateNotification), name: .userAddedVideoToHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVideoHistoryUpdateNotification), name: .userUpdatedVideoHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVideoHistoryUpdateNotification), name: .userRemoveVideoHistory, object: nil)
    }
    
    private func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func handleFavoritesUpdatedNotification() {
        self.favoritedPosts = FavoritesManager.shared.userFavorites
        emptyStateCheck()
        self.tableView.reloadData()
    }
    
    @objc
    private func handleVideoHistoryUpdateNotification() {
        self.lastViewed = VideoHistoryManager.lastVideoInHistory
        emptyStateCheck()
        self.tableView.reloadData()
    }
    
    @objc
    private func handleUserUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let user = userInfo[DatabaseUpdatedNotificationKey.user] as? User else { return }
        self.user?.decorate(with: user)
        emptyStateCheck()
        headerView.configure(with: "Welcome, \(user.name.first) 👋🏽👋🏾")
        self.tableView.reloadData()
    }
    
    // MARK: - Reload -
    
    @objc
    override func reload() {
        emptyStateCheck()
        self.errors = [] // just in case
        if let _ = user {
            retrieveHomePage()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                NotificationCenter.default.post(name: .dashboardDidFinishLoading, object: nil)
            }
        }
    }
    
    private func retrieveHomePage() {
        
        self.state = .loading
        if let user = self.user {
            let group = DispatchGroup()
            
            // TODO: Would be nice to have some dynamic messaging
            headerView.configure(with: "Welcome, \(user.name.first) 👋🏽👋🏾")
            
            retrieveLastWatched(user: user, group: group)
            retrieveLastFourFavorited(user: user, group: group)
            retrieveRecommendedAssortment(user: user, group: group)
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                
                defer {
                    // Adding a delay makes this transition much smoother
                    NotificationCenter.default.post(name: .dashboardDidFinishLoading, object: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        if self.refreshControl.isRefreshing {
                            self.refreshControl.endRefreshing()
                        }
                    })
                }
                
                if self.errors.count != 0, let firstError = self.errors.first {
                    Track.track(displayableError: firstError, domain: ErrorType.Contentful.Subtype.retrievalError)
                    self.presentAlert(with: firstError)
                    // TODO: right now, any failure of a module in the dashboard will present the error screen
                    // It'd be much better, however, to present a per-module reload option so that the whole UI
                    // isn't an error state when, say, only 1 module isn't working correctly
                    self.state = .error
                    return
                }
                
                self.state = .ready
                self.errors = []
                DispatchQueue.main.async {
                    self.emptyStateCheck()
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    // Get the last viewed video for the user
    private func retrieveLastWatched(user: User, group: DispatchGroup) {
        group.enter()
        
        DatabaseService.getHistory(for: user, limit: 1, descending: true) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let videoEntry):
                self.lastViewed = videoEntry.first
                
            case .failure(let error):
                self.errors.append(error.displayError)
            }
            
            group.leave()
        }
    }
    
    // Get the lastest 4 saved videos for user
    private func retrieveLastFourFavorited(user: User, group: DispatchGroup) {
        group.enter()
        
        DatabaseService.getFavorites(for: user, limit: 4, descending: true) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let favoriteVideos):
                self.favoritedPosts = favoriteVideos
                
            case .failure(let error):
                self.errors.append(error.displayError)
            }
            
            group.leave()
        }
    }
    
    // Get the recommended posts for the user
    private func retrieveRecommendedAssortment(user: User, group: DispatchGroup) {
        group.enter()
        
        DashboardService.getDashboardRecommendedVideos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let recommendedPosts):
                self.recommendedPosts = recommendedPosts
                
            case .failure(let error):
                self.errors.append(error.displayError)
            }
            
            group.leave()
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard guest == nil || user != nil else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard guest == nil, let section = Sections(rawValue: section) else { return 0 }
        switch section {
        case .history:
            return lastViewed == nil ? 4 : 1 // (top, description, yogi decorator, bottom,) : (last viewed)
        case .browse:
            return 2 // (top wave, try something new)
        case .favorites:
            return favoritedPosts?.count == 0 ? 2 : 2 // (top border, helperText) : (favorites, top border)
        case .bottom:
            return 1 // bottom yogi
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section {
        case .history:
            if lastViewed == nil { // Show decorative & helper text
                if indexPath.row == 0 { // top wave
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.historyTopBorder, for: indexPath) as! BorderCell
                    cell.configure(with: .lavenderTop)
                    return cell
                    
                } else if indexPath.row == 1 { // detail text
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.historyHelperText, for: indexPath) as! DashboardHelperTextCell
                    cell.configure(with: .dashboardHistory)
                    return cell
                    
                } else if indexPath.row == 2 { // Yogi image
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.historyYogi, for: indexPath) as! DashboardYogiDecoratorCell
                    cell.configure(with: .dashboardHistory)
                    return cell
                    
                } else { // row == 3, bottom wave
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.historyBottomBorder, for: indexPath) as! BorderCell
                    cell.configure(with: .lavenderBottom)
                    return cell
                }
                
            } else { // Show single cell for last viewed post
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.history) as! DashboardVideoHistoryCell
                cell.isHidden = true
                if let lastVideo = lastViewed {
                    cell.configure(with: lastVideo, style: .history)
                    cell.delegate = self
                    cell.isHidden = false
                }
                return cell
            }

        case .browse:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.browseTopWave, for: indexPath) as! BorderCell
                cell.configure(with: .whiteBottom)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.browse, for: indexPath) as! HorizontalPostsCell
                cell.delegate = self
                
                if let posts = recommendedPosts {
                    cell.configure(with: posts, relatedTag: nil, style: .browse)
                    cell.bottomSeparator.isHidden = true
                }
                
                return cell
            }
            
            
        case .favorites:
            if let favoritePosts = favoritedPosts, favoritePosts.count > 0 {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.favorites, for: indexPath) as! GridTableViewCell
                    
                    cell.delegate = self
                    cell.configure(with: favoritePosts, style: .all)
                    cell.bottomSeparator.isHidden = true
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.favoritesTopBorder, for: indexPath) as! BorderCell
                    cell.configure(with: .lavenderTop)
                    return cell
                }
                
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.favoritesTopBorder, for: indexPath) as! BorderCell
                    cell.configure(with: .lavenderTop)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.favoritesHelperText, for: indexPath) as! DashboardHelperTextCell
                    cell.configure(with: .dashboardfavorites)
                    return cell
                }
            }
            
        case .bottom:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.bottom, for: indexPath) as! DashboardYogiDecoratorCell
            cell.configure(with: .dashboardFavorites)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        
        switch section {
        case .history:
            if lastViewed == nil { // Show decorative & helper text
                return UITableView.automaticDimension
            } else {
                calc.videoHistoryCell.frame = CGRect(x: 0.0, y: 0.0, width: self.tableView.w, height: 0.0)
                if let lastVideo = lastViewed {
                    calc.videoHistoryCell.configure(with: lastVideo, style: .history)
                } else { return 0.0 }
                
                return calc.videoHistoryCell.h
            }
        
        case .browse:
            return UITableView.automaticDimension
        
        case .favorites:
            return UITableView.automaticDimension
            
        case .bottom:
            return UITableView.automaticDimension
        
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        switch section {
        case .history:
            guard let lastViewedPost = lastViewed, let user = user else { return }
            Track.track(eventName: EventType.Dashboard.viewedLastWatched, user: user)
            
            let dtvc = VDPViewController(with: lastViewedPost, user: user)
            self.iaNavigationController?.pushViewController(dtvc, animated: true)
            
        default: return
        }
    }
}

// MARK: - VideoModuleTableViewCellDelegate -

extension DashboardViewController: DashboardVideoHistoryCellDelegate {

    func dashboardHistoryCellCTAWasTapped(_ dashboardHistoryCell: DashboardVideoHistoryCell) {
        guard let user = user else { return }
        Track.track(eventName: EventType.Dashboard.viewedHistory, user: user)
        
        let dtvc = VideoHistoryListingController(user: user, listingType: .history)
        self.iaNavigationController?.pushViewController(dtvc, animated: true)
    }
    
}

// MARK: - VideoCollectionModuleTableViewCellDelegate -

extension DashboardViewController: HorizontalPostsCellDelegate {
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didSelectItem index: Int) {
        guard let posts = recommendedPosts, posts.count >= index + 1 else { return }
        let dtvc = VDPViewController(with: posts[index], user: user, guest: guest)
        self.iaNavigationController?.pushViewController(dtvc, animated: true)
    }
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didPressChevron button: ChevronButton) {
        Track.track(eventName: EventType.Dashboard.viewedSomethingNew)
        
        self.homeTabBarController?.route(to: .feed)
    }
    
}

// MARK: - GridModuleTableViewCellDelegate -

extension DashboardViewController: GridModuleTableViewCellDelegate {
    func gridModuleTableViewCellDidPressCTA(_ gridModuleTableViewCell: GridTableViewCell) {
        guard let user = user else { return }
        Track.track(eventName: EventType.Dashboard.viewedFavorites, user: user)
        
        let dtvc = VideoHistoryListingController(user: user, listingType: .favorites)
        self.iaNavigationController?.pushViewController(dtvc, animated: true)
    }
    
    func gridModuleTableViewCell(_ gridModuleTableViewCell: GridTableViewCell, didSelectItem index: Int) {
        guard
            let favoriteVideos = favoritedPosts,
            favoriteVideos.count >= index + 1,
            let user = user else
        { return }
        
        let dtvc = VDPViewController(with: favoriteVideos[index], user: user)
        self.iaNavigationController?.pushViewController(dtvc, animated: true)
    }
}

// MARK: - EmptyUserDashboardViewDelegate -

extension DashboardViewController: EmptyUserDashboardViewDelegate {
    
    func emptyUserDashboardViewDidPressCTA(_ emptyDashView: EmptyUserDashboardView) {
        Track.track(eventName: EventType.Dashboard.tappedEmptyDashCTA)
        
        self.homeTabBarController?.route(to: .feed)
    }
    
}

// MARK: - GuestDashboardViewDelegate -

extension DashboardViewController: GuestDashboardViewDelegate {
    
    func guestDashboardViewDidRequestSignUp(_ guestDashboardView: GuestDashboardView) {
        NotificationCenter.default.post(name: .didRequestModalLogin, object: self, userInfo: [ModalLoginKeys.authenticationOption : ModalLoginValues.signup])
    }
    
    func guestDashboardViewDidRequestLogIn(_ guestDashboardView: GuestDashboardView) {
        NotificationCenter.default.post(name: .didRequestModalLogin, object: self, userInfo: [ModalLoginKeys.authenticationOption : ModalLoginValues.login])
    }
    
}

// MARK: - Notification.Name -

extension Notification.Name {
    static let dashboardDidFinishLoading = Notification.Name("com.ia.dashboardViewController.didFinishLoading")
}
