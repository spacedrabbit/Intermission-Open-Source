//
//  VDPViewController.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 1/27/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

// MARK: - VDPViewController -

class VDPViewController: TableViewController {
    // TODO: VideoHistoryEntry is the one source of truth
    // It's useful to have the Post passed in since we dont need to make another request, but the post represents a static
    // post on Contentful whereas the VideoHistoryEntry represents the currently logged in user's history of this video.
    private var post: Post?
    private var videoHistoryEntry: VideoHistoryEntry?
    private var user: User?
    private var guest: GuestUser?
    private var relatedPosts: [String : [Post]] = [:]
    private let targetRelatedTagQueryCount = 3
    private var playerCoordinator: PlayerCoordinator?
    
    private var videoIsPresenting: Bool = false
    private var videoWasDismissed: Bool = false

    private let calc = Calculator()
    private struct Calculator {
        let tagLayoutCell = VDPTagLabelCell()
    }
    
    private let shareButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.shareFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.shareFilledDark.image, for: .highlighted)
        return button
    }()
    
    private let favoriteButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.Hearts.filledLight.image, for: .normal)
        button.setImage(Icon.Hearts.filledDark.image, for: .highlighted)
        return button
    }()
    
    // MARK: - Initializers
    
    init(with post: Post, user: User?, guest: GuestUser?) {
        self.post = post
        self.user = user
        self.guest = guest
        super.init(nibName: nil, bundle: nil)

        // We always want to have a video history entry because we're going to use it to record info to the DB
        // This could potentially have unintended side effects later on. Consider the case where our VideoHistoryManager
        // errors on getting its entries. Right now, we should still be fairly safe because in merging the values of
        // a video history entry, our DB will still reflect the latest changes for this entry. However as we change
        // implementation details in the future, this might result in some data de-synchronizatin since we dont necessarily
        // start with the most up to date entry
        if let existingEntry = VideoHistoryManager.entry(for: post) {
            self.videoHistoryEntry = existingEntry
        } else {
            self.videoHistoryEntry = VideoHistoryEntry(post: post)
        }
        
        // We only need to create the playerCoordinator here because init'ing with a videoHistoryEntry always
        // forces a retrieval of the full Post, and in the success block we create the entry.
        // But starting with a post means we skip that, and so we just do it here (e.g. as early as possible)
        if let url = self.videoHistoryEntry?.playbackUrl {
            self.playerCoordinator = PlayerCoordinator(videoURL: url)
            self.playerCoordinator?.delegate = self
        }

        commonInit()
    }
    
    init(with videoHistoryEntry: VideoHistoryEntry, user: User) {
        self.videoHistoryEntry = videoHistoryEntry
        self.user = user
        super.init(nibName: nil, bundle: nil)

        commonInit()
    }
    
    init(with videoHistoryEntry: VideoHistoryEntry, user: User?, guest: GuestUser?) {
        self.videoHistoryEntry = videoHistoryEntry
        self.user = user
        self.guest = guest
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.playerCoordinator = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Common
    
    private func commonInit() {
        self.view.backgroundColor = .background
        self.delegate = self
        self.isNavigationBarHidden = true
        reload()
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesNotification(notification:)), name: .userAddedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesNotification(notification:)), name: .userUpdatedFavorites, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesNotification(notification:)), name: .userRemovedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesNotification(notification:)), name: .userFavoritesErrored, object: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Common Set up
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 300
        
        self.navigationItem.rightNavigationButtons = Flags.postsAreShareable
            ? [shareButton, favoriteButton]
            : [favoriteButton]
        
        self.hidesBottomBarWhenPushed = true
        
        // Cell Registering
        self.tableView.register(VDPContentCell.self, forCellReuseIdentifier: VDPContentCell.reuseIdentifier)
        self.tableView.register(VDPTagLabelCell.self, forCellReuseIdentifier: VDPTagLabelCell.reuseIdentifier)
        self.tableView.register(VDPDetailCell.self, forCellReuseIdentifier: VDPDetailCell.reuseIdentifier)
        self.tableView.register(HorizontalPostsCell.self, forCellReuseIdentifier: HorizontalPostsCell.reuseIdentifier)

        shareButton.addTarget(self, action: #selector(handleShareButtonTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(handleFavoriteButtonTapped), for: .touchUpInside)
        
        if let post = post {
            setPostIsFavorite(FavoritesManager.isFavorite(post: post))
        }
    }
    
    // MARK: - Reload -
    
    override func reload() {
        // If we reload and we have the post already, just get the related videos
        // Otherwise, we need to get the Post first and then the related videos
        if let _ = post {
            getRelatedVideos()
        } else if let videoEntry = videoHistoryEntry {
            getPost(from: videoEntry)
        }
    }
    
    /* Note: At the time of this writing, the Contentful API was limited in a fairly critical way: you are unable
        to query for linked entries by multiple entries.
     
     Practically speaking, this means it isn't possible to make a request like "getPosts(for tags:[Tag])`.
     
     As an alternative, I kick off up to 3 asynchronous requests and add them to a dispatch group. When they complete,
     I proceed with a UI update. If either request fails, we treat it as though both failed, and display an appropriate
     error. If the requests succeed, then we add the returned [Post] to a dict and reload our tableview to display
     the results
 
     */
    private func getRelatedVideos() {
        guard let tags = self.post?.tags else {
            // TODO: how should we handle state in this case where there are no tags available with a post?
            return
        }
        
        let group = DispatchGroup()
        var errors: [ContentError] = []
        let relatedPostsCount = min(max(0, tags.count), targetRelatedTagQueryCount)
        
        (0..<relatedPostsCount).forEach { (idx: Int) in
            
            group.enter()
            ContentfulService.getPosts(for: tags[idx], completion: { [weak self] (result) in
                switch result {
                case .success(let posts):
                    self?.relatedPosts[tags[idx].slug] = posts
                    
                case .failure(let error):
                    // TODO: log error w/ crashlytics
                    errors.append(error)
                }
                
                group.leave()
            })
        }

        group.notify(queue: .main) { [weak self] () -> Void in
            guard let self = self else { return }
            if !errors.isEmpty, let firstError = errors.first {
                self.presentAlert(with: firstError.displayError)
                return
            }
            
            // TODO: show a reload icon over the collection views? or try request again? or fail silently and do something else?
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func getPost(from entry: VideoHistoryEntry) {
        self.state = .loading
        ContentfulService.getPost(for: entry) { [weak self] (result) in
            switch result {
            case .success(let post):
                self?.post = post

                if let url = VideoHistoryEntry(post: post)?.playbackUrl {
                    self?.playerCoordinator = PlayerCoordinator(videoURL: url)
                    self?.playerCoordinator?.delegate = self
                }
                
                DispatchQueue.main.async {
                    self?.setPostIsFavorite(FavoritesManager.isFavorite(post: post))
                    self?.tableView.reloadData()
                }
                self?.getRelatedVideos()
                
            case .failure(let error):
                self?.presentAlert(with: error.displayError)
                self?.state = .error
            }
            
            self?.state = .ready
        }
    }
    
    // MARK: - Actions -
    
    @objc
    private func handleShareButtonTapped() {
        self.ia_presentAlert(with: "Share me!", message: "You've selected share info on this video! But we don't yet have this feature implemented. Come back later and check in on our progress 🤓")
    }
    
    @objc
    private func handleFavoriteButtonTapped() {
        
        if let user = self.user, let post = post {
            // Blocks button UI while request is made
            favoriteButton.showActivity()
            FavoritesManager.isFavorite(post: post)
                ? DatabaseService.removeFromFavorites(post: post, for: user)
                : DatabaseService.addToFavorites(post: post, for: user)
            
        } else if let _ = self.guest {
            let primaryAction = AlertAction(title: "OK") { (_, _) in
                NotificationCenter.default.post(name: .didRequestModalLogin, object: self, userInfo: [ModalLoginKeys.authenticationOption : ModalLoginValues.signup])
            }
            
            let secondaryAction = AlertAction(title: "CANCEL") { (controller, _) in
                controller.dismiss(animated: true, completion: nil)
            }

            self.presentAlert(with: "Enjoyed the video?",
                              message: "To keep save of all your favorite videos and track your journey, take a super-quick intermission from your Intermission to sign up!",
                              primary: primaryAction,
                              secondary: secondaryAction)
        }
    }
    
    // MARK: - Notifications
    
    @objc
    private func handleFavoritesNotification(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let favoritesUpdateType = userInfo[FavoritesNotificationKey.type] as? FavoritesUpdateType,
            let postsChanged = userInfo[FavoritesNotificationKey.favorites] as? [VideoHistoryEntry]
        else { return}
        
        favoriteButton.hideActivity()
        
        // Check Type, and then make sure that the post we're looking at was the one that we updated
        switch favoritesUpdateType {
        case .added, .modified:
            if postsChanged.contains(where: { $0.postId == self.post?.id }) {
                setPostIsFavorite(true)

                guard let postTitle = self.post?.title else { return }
                ToastManager.show(title: "Added \(postTitle) to favorites!",
                    highlightedTitle: postTitle,
                    accessory: .heart, position: .bottom)
            }
            
        case .removed:
            if postsChanged.contains(where: { $0.postId == self.post?.id }) {
                setPostIsFavorite(false)
            }
            
        case .error:
            if let error = userInfo[FavoritesNotificationKey.error] as? DisplayableError, let post = post {
                setPostIsFavorite(FavoritesManager.isFavorite(post: post)) // revert to whatever manager has
                self.presentAlert(with: error)
            }
        }
    }

    // MARK: - Helper
    
    private func setPostIsFavorite(_ isFavorite: Bool) {
        if isFavorite {
            favoriteButton.setImage(Icon.Hearts.filledHeartedLight.image, for: .normal)
            favoriteButton.setImage(Icon.Hearts.filledHeartedDark.image, for: .highlighted)
        } else {
            favoriteButton.setImage(Icon.Hearts.filledLight.image, for: .normal)
            favoriteButton.setImage(Icon.Hearts.filledDark.image, for: .highlighted)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension VDPViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : self.relatedPosts.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section, indexPath.row) {
        case (0, 0): // Thumb and play video cell
            let cell = tableView.dequeueReusableCell(withIdentifier: VDPContentCell.reuseIdentifier) as! VDPContentCell
            cell.bottomSeparator.isHidden = true
            cell.topSeparator.isHidden = true
            
            if let entry = videoHistoryEntry {
                cell.configure(with: entry)
                cell.delegate = self
            }
            
            return cell
        
        case (0, 1): // Pill Tags
            let cell = tableView.dequeueReusableCell(withIdentifier: VDPTagLabelCell.reuseIdentifier, for: indexPath) as! VDPTagLabelCell
            
            if let tags = self.post?.tags {
                cell.configure(with: tags, style: .grayFill, targetWidth: tableView.w - 20.0 - 20.0)
            }
            
            return cell
            
        case (0, 2): // Post Details (rich text)
            let cell = tableView.dequeueReusableCell(withIdentifier: VDPDetailCell.reuseIdentifier) as! VDPDetailCell
            
            if let post = post, let richText = post.description {
                cell.configure(with: richText)
            }
            
            return cell
            
        default: // Related Video Collection Cells (Section 1, up to 3 rows)
            let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalPostsCell.reuseIdentifier) as! HorizontalPostsCell
            if indexPath.row == 0 {
                cell.topSeparator.isHidden = false
                cell.bottomSeparator.isHidden = true
            } else {
                cell.topSeparator.isHidden = true
                cell.bottomSeparator.isHidden = true
            }
            
            if let tags = self.post?.tags,
                tags.count >= indexPath.row,
                let relatedPosts = self.relatedPosts[tags[indexPath.row].slug] {
                cell.configure(with: relatedPosts, relatedTag: tags[indexPath.row])
                cell.delegate = self
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            calc.tagLayoutCell.frame = CGRect(x: 0.0, y: 0.0, width: tableView.w, height: 0.0)
            
            if let tags = self.post?.tags {
                calc.tagLayoutCell.configure(with: tags, style: .grayFill, targetWidth: tableView.w - 20.0 - 20.0)
            }
            
            return calc.tagLayoutCell.h
        }
        
        return UITableView.automaticDimension
    }
    
}

// MARK: - VDPContentCellDelegate -

extension VDPViewController: VDPContentCellDelegate {
    
    func vdpContentCellDidPressPlay(_ vdpContentCellCell: VDPContentCell) {
        guard let entry = self.videoHistoryEntry else { return }
        
        // Re-create the player if necessary (in the event they play the video, dismiss it and go to play it again
        if self.playerCoordinator == nil, let url = entry.playbackUrl {
            self.playerCoordinator = PlayerCoordinator(videoURL: url)
            self.playerCoordinator?.delegate = self
        }
        
        guard let coordinator = self.playerCoordinator else { return }
        
        // Start from the beginning if we're over 95% the way to the end
        let skipSeconds: Int? = entry.progress > 0.945
            ? 0
            : entry.secondsWatched
        
        coordinator.presentVideo(in: self, skipSeconds: skipSeconds)
    }
    
}

extension VDPViewController: PlayerCoordinatorDelegate {
    
    func playerCoordinator(_ playerCoordinator: PlayerCoordinator, willAppear playerController: AVPlayerViewController) {
        // Not used
    }
    
    func playerCoordinator(_ playerCoordinator: PlayerCoordinator, willDismiss playerController: AVPlayerViewController) {
        // We need to call update on a pre-guard binding check because otherwise, we don't actually
        // update the struct... we'd be updating a copy of it otherwise
        self.videoHistoryEntry?.update(secondsWatched: Int(playerCoordinator.currentTime))
        
        guard let entry = videoHistoryEntry else { return }
        if let user = self.user {
            DatabaseService.addOrUpdateHistory(entry: entry, for: user)
        } else if let guest = self.guest {
            DatabaseService.addOrUpdateHistory(entry: entry, for: guest)
        }
        
        self.tableView.reloadData()
    }
    
    func playerCoordinatorWasDismissed(_ playerCoordinator: PlayerCoordinator) {
        self.playerCoordinator = nil
    }
    
    func playerCoordinator(_ playerCoordinator: PlayerCoordinator, didAppear playerController: AVPlayerViewController) {
        // Not Used
    }
    
}

// MARK: - HorizontalPostsCellDelegate -

extension VDPViewController: HorizontalPostsCellDelegate {
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didPressChevron button: ChevronButton) {
        guard
            let index = tableView.indexPath(for: horizontalPostsCell),
            let tags = self.post?.tags else
        { return }
        let tag = tags[index.row]
        
        if let user = user {
            let dtvc = VideoHistoryListingController(user: user, listingType: .tag(tag))
            self.iaNavigationController?.pushViewController(dtvc, animated: true)
        } else if let guest = guest {
            let dtvc = VideoHistoryListingController(guest: guest, tag: tag)
            self.iaNavigationController?.pushViewController(dtvc, animated: true)
        }
        
    }
    
    func horizontalPostsCell(_ horizontalPostsCell: HorizontalPostsCell, didSelectItem index: Int) {
        guard let tags = self.post?.tags else { return }
        
        if let indexPath = self.tableView.indexPath(for: horizontalPostsCell),
            let posts = relatedPosts[tags[indexPath.row].slug] {
            
            let dtvc = VDPViewController(with: posts[index], user: user, guest: guest)
            self.navigationController?.pushViewController(dtvc, animated: true)
        }
    }

}


