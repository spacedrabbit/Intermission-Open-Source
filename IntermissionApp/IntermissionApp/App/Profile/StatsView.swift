//
//  StatsView.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/30/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// MARK: - StatsView -

/// Simple collection view to display some basic usage stats for a user
class StatsView: UIView {
    weak var delegate: StatsViewDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let statItems: [StatItem] = [.numberVideosWatched, .numberMinutesWatched, .longestStreak, .currentStreak, .numberVideosFavorited, .mostWatchedVideo]
    
    private let edgeMargins: CGFloat = 20.0
    private let interitemMargin: CGFloat = 10.0
    
    // MARK: - Initializers -
    
    init() {
        super.init(frame: .zero)
        
        // View setup
        self.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Cell registering
        collectionView.register(StatsCollectionViewCell.self, forCellWithReuseIdentifier: StatsCollectionViewCell.reuseIdentifier)
        
        // Constraints
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userAddedVideoToHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userUpdatedVideoHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userRemoveVideoHistory, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userAddedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userUpdatedFavorites, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userRemovedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userFavoritesErrored, object: nil)
        
        reload()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Reload
    
    private func reload() {
        self.collectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    @objc
    private func handleUserHistoryDidChange() {
        self.reload()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate -

extension StatsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let statItem = statItems[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatsCollectionViewCell.reuseIdentifier, for: indexPath) as! StatsCollectionViewCell
        cell.isHidden = false // need this because mostWatched gets reused and it's hidden
        
        switch statItem {
        case .numberVideosWatched: cell.configure(with: "\(VideoHistoryManager.numberOfVideosWatched)", statItem: statItem)
        case .numberMinutesWatched: cell.configure(with: "\(VideoHistoryManager.totalMinutesWatched)", statItem: statItem)
        case .longestStreak: cell.configure(with: "\(VideoHistoryManager.longestStreak)", statItem: statItem)
        case .currentStreak: cell.configure(with: "\(VideoHistoryManager.currentStreak)", statItem: statItem)
        case .numberVideosFavorited: cell.configure(with: "\(FavoritesManager.favoritePostsCount)", statItem: statItem)
        case .mostWatchedVideo:
            // TODO: figure out what to show for this case
//            if let mostWatched = VideoHistoryManager.mostWatchVideo {
//                cell.isHidden = false
//                cell.configure(with: "\(mostWatched.)", statItem: statItem)
//            } else {
                cell.isHidden = true
//            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: figure out what to show for this case
        if case StatItem.mostWatchedVideo = statItems[indexPath.row] {
            return .zero
        }

        let maxWidth = collectionView.w - edgeMargins - edgeMargins - interitemMargin
        let maxFrameHeight = collectionView.h

        let itemWidth = maxWidth / 2.0
        let itemHeight = maxFrameHeight / 6.0

        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.statsViewDidSelectItem(self, index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: edgeMargins, bottom: 0.0, right: edgeMargins)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return edgeMargins
    }
}

// MARK: - StatItem -

enum StatItem {
    case numberVideosWatched, numberMinutesWatched, longestStreak, currentStreak, numberVideosFavorited, mostWatchedVideo
    
    var detailString: String {
        switch self {
        case .numberVideosWatched: return "videos watched"
        case .numberMinutesWatched: return "yogi minutes"
        case .longestStreak: return "longest streak"
        case .currentStreak: return "days in a row"
        case .numberVideosFavorited: return "favorites"
        case .mostWatchedVideo: return "most watched"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .numberVideosWatched: return Icon.Stats.playOutline.image
        case .numberMinutesWatched: return Icon.Stats.timer.image
        case .longestStreak: return Icon.Stats.star.image
        case .currentStreak: return Icon.Stats.calendar.image
        case .numberVideosFavorited: return Icon.Stats.heart.image
        case .mostWatchedVideo: return Icon.Stats.history.image
        }
    }
    
    var iconHighlighted: UIImage? {
        switch self {
        case .numberVideosWatched: return Icon.Stats.playOutline.highlightImage
        case .numberMinutesWatched: return Icon.Stats.timer.highlightImage
        case .longestStreak: return Icon.Stats.star.highlightImage
        case .currentStreak: return Icon.Stats.calendar.highlightImage
        case .numberVideosFavorited: return Icon.Stats.heart.highlightImage
        case .mostWatchedVideo: return Icon.Stats.history.highlightImage
        }
    }
}

// MARK: - StatsViewDelegate -

/**
    This currently isnt used, but it might be nice in a v2 or v3 to give a detailed breakdown of each stat when pressed
 */
protocol StatsViewDelegate: class {
    
    func statsViewDidSelectItem(_ statsView: StatsView, index: Int)
    
}
