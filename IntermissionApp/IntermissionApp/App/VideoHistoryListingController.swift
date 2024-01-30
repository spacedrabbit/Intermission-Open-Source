//
//  VideoHistoryListingController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/23/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// TODO: adjust styling of cells to include date watched/favorited

enum VideoListingType {
    case history
    case favorites
    case tag(Tag)
}

// MARK: - VideoHistoryListingController -

class VideoHistoryListingController: TableViewController {
    private var user: User?
    private let guest: GuestUser?
    
    private let listingType: VideoListingType
    private var entries: [VideoHistoryEntry] = []
    
    private struct ReuseIdentifier {
        static let videoHistoryCell = "videoHistoryCellIdentifier"
    }
    
    private let safeAreaCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let mockNavView = MockNavigationBarView()
    
    // MARK: - Initializer
    
    init(user: User, listingType: VideoListingType) {
        self.user = user
        self.guest = nil
        self.listingType = listingType
        
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    init(guest: GuestUser, tag: Tag) {
        self.listingType = .tag(tag)
        self.guest = guest
        
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.isNavigationBarHidden = true

        tableView.delegate = self
        tableView.dataSource = self
        
        switch listingType {
        case .favorites:
            mockNavView.configure("Favorites")
        case .history:
            mockNavView.configure("History")
        case .tag(let tag):
            mockNavView.configure("More \(tag.title.capitalized)")
        }
        
        self.view.addSubview(safeAreaCoverView)
        self.view.addSubview(mockNavView)
        
        registerForNotifications()
        reload()
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never
 
        // Cell Registering
        tableView.register(VideoHistoryEntryTableCell.self, forCellReuseIdentifier: ReuseIdentifier.videoHistoryCell)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        safeAreaCoverView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(self.view.safeAreaInsets.top)
        }
        
        mockNavView.snp.makeConstraints { (make) in
            make.centerX.width.equalToSuperview()
            make.height.equalTo(MockNavigationBarView.height)
            make.top.equalTo(safeAreaCoverView.snp.bottom)
        }
        
        // 60pt comes from the height of the opaque part of the mock navbar
        self.tableView.contentInset = UIEdgeInsets(top: self.view.safeAreaInsets.top + 80.0,
                                                   left: 0.0,
                                                   bottom: self.view.safeAreaInsets.bottom,
                                                   right: 0.0)
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        
        // TODO: figure out why this works
        self.tableView.contentOffset = CGPoint(x: 0.0, y: -150.0)
    }
    
    // MARK: - Reload
    
    @objc
    override func reload() {
        switch listingType {
        case .history: requestUserVideoHistory()
        case .tag(let tag): requestVideosByTag(tag)
        case .favorites: requestUserFavorites()
        }
    }
    
    private func requestUserVideoHistory() {
        // We're going to display the videos by last viewed dates. So there will be at most, a single
        // video entry for each post (we will show regardless if they finished watching it)
        let managedHistory = VideoHistoryManager.shared.userVideoHistory
        entries = managedHistory.sorted(by: { (entryA, entryB) -> Bool in
            return (entryA.lastDateWatched ?? Date()) > (entryB.lastDateWatched ?? Date())
        })
        
        tableView.reloadData()
    }
    
    
    private func requestUserFavorites() {
        entries = FavoritesManager.shared.userFavorites
        tableView.reloadData()
    }
    
    private func requestVideosByTag(_ tag: Tag) {
        
        self.state = .loading
        ContentfulService.getPosts(for: tag) {[weak self] (result) in
            switch result {
            case .success(let posts):
                let entries = posts.compactMap(VideoHistoryEntry.init(post:))
                self?.entries = entries.sorted(by: { (entryA, entryB) -> Bool in
                    return (entryA.dateFavorited ?? Date()) > (entryB.dateFavorited ?? Date())
                })
                self?.state = .ready
                self?.tableView.reloadData()

            case .failure(let error):
                self?.state = .error
                self?.presentAlert(with: error.displayError)
            }
        }
    }

    // MARK: - Notifications
    
    private func registerForNotifications() {
        // Favorites
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .userAddedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .userUpdatedFavorites, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .userRemovedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .userFavoritesErrored, object: nil)
        
        // Video History
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .userAddedVideoToHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .userUpdatedVideoHistory, object: nil)

    }
    
    private func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension VideoHistoryListingController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.videoHistoryCell, for: indexPath) as! VideoHistoryEntryTableCell
        cell.configure(with: entries[indexPath.row])
        cell.bottomSeparator.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VideoHistoryEntryTableCell.height(for: tableView.w)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        let dtvc = VDPViewController(with: entry, user: user, guest: guest)
        self.iaNavigationController?.pushViewController(dtvc, animated: true)
    }
    
}

// MARK: - VideoHistoryEntryTableCell -

class VideoHistoryEntryTableCell: TableViewCell {
    
    private let videoImageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        return imageView
    }()
    
    private let videoTitleLabel: Label = {
        let label = Label()
        label.numberOfLines = 2
        label.font = .title2
        label.textColor = .textColor
        return label
    }()
    
    private let durationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.Duration.light.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let durationLabel: Label = {
        let label = Label()
        label.numberOfLines = 1
        label.font = .caption2
        label.textColor = .lightTextColor
        return label
    }()
    
    // MARK: - Initializers -
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.clipsToBounds = false
        
        self.contentView.addSubview(videoImageView)
        self.contentView.addSubview(videoTitleLabel)
        self.contentView.addSubview(durationIconImageView)
        self.contentView.addSubview(durationLabel)
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func configureConstraints() {
        
        videoImageView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(995.0)
            make.height.equalTo(videoImageView.snp.width).multipliedBy(9.0/16.0)
        }
        
        durationIconImageView.snp.makeConstraints { make in
            make.top.equalTo(videoImageView.snp.bottom).offset(8.0)
            make.width.height.equalTo(12.0)
            make.leading.equalTo(videoImageView.snp.leading)
        }
        
        durationLabel.enforceSizeOnAutoLayout()
        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(durationIconImageView.snp.trailing).offset(4.0)
            make.centerY.equalTo(durationIconImageView.snp.centerY)
        }
        
        videoTitleLabel.safelyEnforceHeightOnAutoLayout()
        videoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(durationLabel.snp.bottom).offset(6.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priority(990.0)
        }
    }
    
    // MARK: - Configure
    
    func configure(with entry: VideoHistoryEntry) {
        let titleStyle = Style {
            $0.font = UIFont.title2
            $0.color = UIColor.textColor
            $0.lineSpacing = 0.0
            $0.maximumLineHeight = 28.0
            $0.alignment = .left
        }
        
        videoTitleLabel.attributedText = entry.postTitle.set(style: titleStyle)
        durationLabel.text = entry.durationSeconds.minuteString()
        videoImageView.setImage(url: entry.thumbnailURL)
    }
    
    // MARK: - Helpers -
    
    static func height(for width: CGFloat) -> CGFloat {
        let imageHeight = (9.0/16.0) * (width - 20.0 - 20.0)
        return imageHeight + 120.0 // 120.0 is arbitrary, just picking something that works
    }
}
