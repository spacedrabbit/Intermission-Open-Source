//
//  AboutAppViewController.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/24/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class AboutAppViewController: TableViewController {
    private let acknowledgements = AcknowledgementsManager.shared.acknowledgements
    private let sections: [[AboutAppItems]] = [
        [.turnTheSpotlight],
        [.contentful, .cloudinary],
        [.pods],
    ]
    
    private struct ReuseIdentifiers {
        static let aboutCell = "aboutCellIdentifier"
        static let aboutHeaderCell = "aboutHeaderCellIdentifier"
    }
    
    // MARK: - Initializers -
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
        self.title = "About the App"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .automatic
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "About", style: .plain, target: nil, action: nil)
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: ReuseIdentifiers.aboutCell)
        tableView.register(AboutAppHeaderView.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifiers.aboutHeaderCell)
    }
    
    // MARK: - Helpers -
    
    private func supporter(for index: IndexPath) -> Supporter? {
        let item = sections[index.section][index.row]
        switch item {
        case .turnTheSpotlight: return acknowledgements?.patrons.first
        case .contentful: return acknowledgements?.services.first(where: { $0.name == "Contentful" })
        case .cloudinary: return acknowledgements?.services.first(where: { $0.name == "Cloudinary" })
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension AboutAppViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.aboutCell, for: indexPath) as! SettingsCell
        cell.configure(with: item.rawValue, leftAccessory: nil, rightAccessory: .chevron)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section][indexPath.row]
        switch item {
        case .turnTheSpotlight:
            guard let turnTheSpotLight = supporter(for: indexPath) else { return }
            let dtvc = SupporterViewController(supporter: turnTheSpotLight)
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .cloudinary:
            guard let cloudinary = supporter(for: indexPath) else { return }
            let dtvc = SupporterViewController(supporter: cloudinary)
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .contentful:
            guard let contentful = supporter(for: indexPath) else { return }
            let dtvc = SupporterViewController(supporter: contentful)
            self.navigationController?.pushViewController(dtvc, animated: true)
            
        case .pods:
            guard let pods = self.acknowledgements?.pods else { return }
            let dtvc = PodsViewController(pods: pods)
            self.navigationController?.pushViewController(dtvc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifiers.aboutHeaderCell) as! AboutAppHeaderView
        
        switch section {
        case 0: view.configure("Patrons")
        case 1: view.configure("Content Services")
        case 2: view.configure("Open Source Libraries")
        default: print("Should not be here")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsCell.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AboutAppHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - AboutAppItems -

enum AboutAppItems: String {
    case pods = "Open Source Libraries",
    turnTheSpotlight = "Turn the Spotlight",
    contentful = "Contentful",
    cloudinary = "Cloudinary"
}

// MARK: - AboutAppHeaderView -

class AboutAppHeaderView: UITableViewHeaderFooterView {
    
    private let label: Label = {
        let label = Label()
        label.style = Styles.styles[Font.largeHeaderTitle]
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(label)
        
        label.safelyEnforceSizeOnAutoLayout()
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.bottom.equalToSuperview().inset(2.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ title: String) {
        label.styledText = title
    }
    
    class var height: CGFloat {
        return 80.0
    }
}
