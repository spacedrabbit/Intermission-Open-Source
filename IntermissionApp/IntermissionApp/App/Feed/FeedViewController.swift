//
//  FeedViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/30/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

class FeedViewController: TableViewController {
    private var user: User?
    private var guest: GuestUser?
    private var feedPage: FeedPage?
    
    private let refreshControl = UIRefreshControl()
    
    private let safeAreaCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .navBarGreen
        return view
    }()
    
    private let feedHeaderView: FeedHeaderView = FeedHeaderView()
    
    // MARK: Calculators
    
    private let calculator = Calculator()
    private struct Calculator {
        let pagingCell = PagingTableViewCell()
    }
    
    // MARK: ReuseIdentifiers
    
    private struct ReuseIdentifiers {
        static let filteredHeader = "filteredHeaderIdentifier"
    }
    
    // MARK: - Filtering -
    
    // TODO: property observers to reload?
    private var filtersActive: Bool { return filterShowing || filteredTags.count > 0 }
    private var filterShowing: Bool = false
    private var filteredTags: [Tag] = []
    private var filterEmptyState = UIView() // TODO: img
    private var filterEmptyYogiImage: ImageView = {
        let imageView = ImageView(image: Decorative.Yogi.yogiLongCrow.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // Need this to be under the wave image asset in the feed header, but over the table view
    // to block a sliver of odd empty space when scrolling with active filters (the cell headers
    // stick to the contentInset but the content scrolls past that)
    private let filterActiveWaveCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.paleLavendar.withAlphaComponent(0.95)
        view.isHidden = true
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFilterDidAppear(notification:)), name: .feedHeaderWillShowFilter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFilterWillHide(notification:)), name: .feedHeaderWillHideFilter, object: nil)
        
        self.view.backgroundColor = .white
        self.tabBarItem = UITabBarItem(title: "Feed", image: TabIcon.feed.inactive, selectedImage: TabIcon.feed.active)
        
        self.delegate = self
        feedHeaderView.delegate = self
        self.isNavigationBarHidden = true
        
        tableView.register(PagingTableViewCell.self, forCellReuseIdentifier: PagingTableViewCell.reuseIdentifier)
        tableView.register(HorizontalPostsCell.self, forCellReuseIdentifier: HorizontalPostsCell.reuseIdentifier)
        tableView.register(WaveBorderCell.self, forCellReuseIdentifier: WaveBorderCell.reuseIdentifier)
        
        // Filter cells/views
        tableView.register(FilteredVideoTableViewCell.self, forCellReuseIdentifier: FilteredVideoTableViewCell.reuseIdentifier)
        tableView.register(FilterReuseableHeader.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifiers.filteredHeader)
        
        reload()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(filterActiveWaveCoverView)
        self.view.addSubview(safeAreaCoverView)
        self.view.addSubview(feedHeaderView)

        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .automatic

        // basic refresh control
        self.tableView.refreshControl = refreshControl
        refreshControl.tintColor = .accent
        refreshControl.attributedTitle = "meditating...".set(style: Font.refreshControlText)
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        // Empty state
        filterEmptyState.isHidden = true
        filterEmptyState.alpha = 0.0
        filterEmptyState.backgroundColor = .paleLavendar
        self.view.addSubview(filterEmptyState)
        filterEmptyState.addSubview(filterEmptyYogiImage)

        filterEmptyState.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(safeAreaCoverView.snp.bottom)
        }
        
        filterEmptyYogiImage.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.bottom.equalTo(filterEmptyState.snp.bottom)
        }
        
        filterActiveWaveCoverView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaCoverView.snp.bottom)
            make.bottom.equalTo(feedHeaderView.snp.bottom)
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdated(notification:)), name: .userInfoUpdateSuccess, object: nil)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // This is strictly to cover the status bar/notch area with a green background
        safeAreaCoverView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.w,
                                         height: self.view.safeAreaInsets.top - feedHeaderView.requiredContentHeight())
        
        if filtersActive {
            filterActiveWaveCoverView.isHidden = false
            tableView.backgroundColor = .paleLavendar
        } else {
            filterActiveWaveCoverView.isHidden = true
            tableView.backgroundColor = .white
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutHeader()
        adjustInsets()
    }
    
    // MARK: - Layout -
    
    private func layoutHeader() {
        let requiredHeight = feedHeaderView.requiredContentHeight()
        feedHeaderView.frame = CGRect(x: 0.0, y: safeAreaCoverView.y + safeAreaCoverView.h,
                                      width: self.view.w, height: requiredHeight)
    }
    
    private func adjustInsets() {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: feedHeaderView.h, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Reload -
    
    @objc
    override func reload() {
        guard !filtersActive else {
            SearchManager.retrievePostsIfNeeded { (result) in
                switch result {
                case .success(let posts):
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    // Adding a delay makes this transition much smoother
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        if self.refreshControl.isRefreshing {
                            self.refreshControl.endRefreshing()
                        }
                    })
                case .failure(let error):
                    Track.track(error: error)
                }
            }
            return
        }
        
        FeedService.getFeed { [weak self] (result) in
            guard let self = self else { return }
            defer {
                // Adding a delay makes this transition much smoother
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                })
            }
            
            switch result {
            case .success(let feedPage):
                DispatchQueue.main.async {
                    self.feedPage = feedPage
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("We got an error: \(error)")
                self.state = .error
            }
        }
        
        getTags()
    }
    
    private func getTags() {
        
        ContentfulService.getTagsSortedByCategory { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let dict):
                DispatchQueue.main.async {
                    self.feedHeaderView.configure(with: dict, targetWidth: UIScreen.main.bounds.width)
                }
            case .failure(let error):
                self.presentAlert(with: error.displayError)
            }
        }
        
    }
    
    
    // MARK: - Notification Handling
    
    @objc
    private func handleUserUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let user = userInfo[DatabaseUpdatedNotificationKey.user] as? User else { return }
        self.user?.decorate(with: user)
        self.tableView.reloadData()
    }
    
    @objc
    private func handleFilterDidAppear(notification: Notification) {
        guard
            let duration = notification.userInfo?[FeedHeaderFilterKey.animationPresentationDuration] as? TimeInterval,
            let options = notification.userInfo?[FeedHeaderFilterKey.animationOptions] as? UIView.AnimationOptions
            else { return }
        
        // Stop the scroll view's scrolling, otherwise we can end up in a weird content inset state
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.layoutHeader()
            self.adjustInsets()
        }, completion: nil)
    }
    
    @objc
    private func handleFilterWillHide(notification: Notification) {
        guard
            let duration = notification.userInfo?[FeedHeaderFilterKey.animationDismissalDuration] as? TimeInterval,
            let options = notification.userInfo?[FeedHeaderFilterKey.animationOptions] as? UIView.AnimationOptions
            else { return }
        
        // Stop the scroll view's scrolling, otherwise we can end up in a weird content inset state
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.layoutHeader()
            self.adjustInsets()
        }, completion: nil)
    }
    
    // MARK: - Helpers -
    
    private func tag(forSection section: Int) -> Tag? {
        guard filtersActive, section + 1 <= numberOfSectionsForFilteredResults() else { return nil }
        return filteredTags[section]
    }
    
    private func numberOfTags(forSection section: Int) -> Int {
        guard
            filtersActive,
            section + 1 <= numberOfSectionsForFilteredResults(),
            let tag = tag(forSection: section)
        else { return 0 }
        return SearchManager.entries(for: tag).count
    }
    
    private func entries(forSection section: Int) -> [VideoHistoryEntry] {
        guard
            filtersActive,
            section + 1 <= numberOfSectionsForFilteredResults(),
            let sectionTag = tag(forSection: section)
        else { return [] }
        return SearchManager.entries(for: sectionTag)
    }
    
    private func entry(for index: IndexPath) -> VideoHistoryEntry? {
        let entriesForSection = entries(forSection: index.section)
        guard entriesForSection.count >= index.row + 1 else { return nil }
        return entriesForSection[index.row]
    }
    
    private func numberOfSectionsForFilteredResults() -> Int {
        guard filtersActive else { return 0 }
        return filteredTags.count
    }

    private func filterEmptyStateCheck() {
        guard filtersActive else {
            hideEmptyState()
            return
        }
        
        if filteredTags.count == 0 {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        self.filterEmptyState.alpha = 0.0
        self.filterEmptyState.isHidden = false
        self.view.insertSubview(self.filterEmptyState, belowSubview: feedHeaderView)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.filterEmptyState.alpha = 1.0
        }) { (complete) in
            if complete { }
        }
    }
    
    private func hideEmptyState() {
        UIView.animate(withDuration: 0.20, animations: {
            self.filterEmptyState.alpha = 0.0
        }) { (complete) in
            if complete {
                self.view.sendSubviewToBack(self.filterEmptyState)
                self.filterEmptyState.isHidden = true
            }
        }
    }
}

// MARK: - UITableViewDelegate/UITableViewDataSource

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filtersActive ? numberOfSectionsForFilteredResults() : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !filtersActive else {
            return numberOfTags(forSection: section)
        }
        return section == 0
            ? 2 // Featured Posts, Waveborder
            : self.feedPage?.feedModules.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Handle Filtered State
        guard !filtersActive else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FilteredVideoTableViewCell.reuseIdentifier, for: indexPath) as! FilteredVideoTableViewCell
            cell.configure(with: entries(forSection: indexPath.section)[indexPath.row])
            return cell
        }
        
        // Non-Filtered State
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: PagingTableViewCell.reuseIdentifier) as! PagingTableViewCell
                
                if let featuredPosts = feedPage?.featuredPosts {
                    cell.configure(with: featuredPosts)
                    cell.delegate = self
                }
                cell.bottomSeparator.isHidden = true
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: WaveBorderCell.reuseIdentifier, for: indexPath) as! WaveBorderCell
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalPostsCell.reuseIdentifier, for: indexPath) as! HorizontalPostsCell
            
            if let feedPageModules = self.feedPage?.feedModules, feedPageModules.count >= indexPath.row + 1 {
                let postFeedModules = feedPageModules.filter { $0.type == FeedModuleType.posts([]) }
                cell.configure(with: postFeedModules[indexPath.row])
                cell.delegate = self
                cell.bottomSeparator.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filtersActive, let entry = entry(for: indexPath) {
            let dtvc = VDPViewController(with: entry, user: user, guest: guest)
            self.navigationController?.pushViewController(dtvc, animated: true)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if filtersActive {
            return UITableView.automaticDimension
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            } else{
                return WaveBorderCell.height
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filtersActive ? FilterReuseableHeader.height : 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if filtersActive, let sectionTag = tag(forSection: section) {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifiers.filteredHeader) as? FilterReuseableHeader
            view?.configure(with: sectionTag, count: numberOfTags(forSection: section))
            return view
        }
        
        return nil
    }
}

// MARK: - PagingVideoTableCellDelegate -

extension FeedViewController: PagingVideoTableCellDelegate {
    func pagingVideoTableCell(_ pagingVideoTableCell: PagingTableViewCell, didSelectItem index: Int) {
        guard let posts = feedPage?.featuredPosts else { return }
        self.navigationController?.pushViewController(VDPViewController(with: posts[index], user: user, guest: guest), animated: true)
    }
}


// MARK: - HorizontalPostsCellDelegate

extension FeedViewController: HorizontalPostsCellDelegate {
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didSelectItem index: Int) {
        guard
            let cellIndex = tableView.indexPath(for: horizontalPostsCell),
            let feedModules = feedPage?.feedModules
            else { return }
        let module = feedModules[cellIndex.row]
        
        if case let FeedModuleType.posts(posts) = module.type {
            let selectedPost = posts[index]
            let dtvc = VDPViewController(with: selectedPost, user: user, guest: guest)
            self.iaNavigationController?.pushViewController(dtvc, animated: true)
        } else {
            // TODO: this shouldnt happen/error state currently. update with new module types in future
        }
    }
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didPressChevron button: ChevronButton) {
        // TODO: anything?
    }
    
}

// MARK: - FeedHeaderViewDelegate -

extension FeedViewController: FeedHeaderViewDelegate {
    
    func feedHeaderView(_ feedHeaderView: FeedHeaderView, filterWasSelected filterActive: Bool) {
        self.filterShowing = filterActive
        filterEmptyStateCheck()
        self.tableView.reloadData()
    }
    
    /// Filtered tags are returned in the order in which they are selected/deselected
    func feedHeaderView(_ feedHeaderView: FeedHeaderView, didUpdateFilters filteredTags: [Tag]) {
        self.filteredTags = filteredTags
        filterEmptyStateCheck()
        self.tableView.reloadData()
    }
    
    func feedHeaderViewDidClearFilters(_ feedHeaderView: FeedHeaderView) {
        self.filteredTags = []
        filterEmptyStateCheck()
        self.tableView.reloadData()
        
        if !filterShowing {
            filterActiveWaveCoverView.isHidden = true
            tableView.backgroundColor = .white
        }
    }

}
