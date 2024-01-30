//
//  PodsViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 9/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - PodsViewController -

class PodsViewController: TableViewController {
    private let pods: [Pod]
    
    private struct ReuseIdentifiers {
        static let podCell = "podCellIdentifier"
    }
    
    // MARK: - Initializers
    
    init(pods: [Pod]) {
        self.pods = pods
        super.init(nibName: nil, bundle: nil)
        self.title = "Open Source Libraries"
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .cta
        self.tableView.contentInsetAdjustmentBehavior = .always
        tableView.register(SettingsCell.self, forCellReuseIdentifier: ReuseIdentifiers.podCell)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension PodsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.podCell, for: indexPath) as! SettingsCell
        
        let pod = self.pods[indexPath.row]
        cell.configure(with: pod.name, leftAccessory: .github)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPodLink = self.pods[indexPath.row]
        UIApplication.shared.open(selectedPodLink.link.url, options: [:], completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsCell.height
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
