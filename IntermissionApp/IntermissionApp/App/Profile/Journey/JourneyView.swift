//
//  JourneyView.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/17/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import FirebaseAuth

/** Journey view is a simple view that contains a tableview to display a user's video history
 
 */
class JourneyView: UIView {
    weak var delegate: JourneyViewDelegate?
    private let tableView = UITableView(frame: .zero)
    private var videoHistoryEntries: [VideoHistoryEntry] = []
    private let emptyStateImageView = ImageView(image: Decorative.Yogi.standingPlant.image)
    
    // MARK: - Initializers
    
    private override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        // View Setup
        self.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 300.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 0.0) // gives it a little space at the bottom
        
        // Constraints
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.centerY.centerX.equalToSuperview()
        }
        
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addSubview(emptyStateImageView)
        
        emptyStateImageView.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview().inset(20.0)
        }

        // Cell Register
        tableView.register(JourneyTableViewCell.self, forCellReuseIdentifier: JourneyTableViewCell.reuseIdentifier)

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userAddedVideoToHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userUpdatedVideoHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserHistoryDidChange), name: .userRemoveVideoHistory, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    
    func configure(with videoHistoryEntries: [VideoHistoryEntry]) {
        self.videoHistoryEntries = VideoHistoryManager.buildOrderedJourney(from: videoHistoryEntries)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Notifications
    
    @objc
    private func handleUserHistoryDidChange() {
        self.configure(with: VideoHistoryManager.shared.userVideoHistory)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension JourneyView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoHistoryEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JourneyTableViewCell.reuseIdentifier) as! JourneyTableViewCell
        
        var trailLineOptions: JourneyTableViewCell.TrailLineOption = [.top, .bottom]
        
        // Remove the top optional trail line if it's the first cell
        if indexPath.row == 0 {
            trailLineOptions.remove(.top)
        }
        // Remove the bottom optional trail line if it's the last cell
        if indexPath.row == videoHistoryEntries.count - 1 {
            trailLineOptions.remove(.bottom)
        }
        
        cell.configure(with: videoHistoryEntries[indexPath.row], trailOptions: trailLineOptions)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.journeyViewDidSelectItem(self, index: indexPath.row)
    }
    
}

// MARK: - JourneyViewDelegate Protocol -

protocol JourneyViewDelegate: class {
    func journeyViewDidSelectItem(_ journeyView: JourneyView, index: Int)
}
