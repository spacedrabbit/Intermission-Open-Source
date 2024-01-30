//
//  RetreatExtendedInfoVC.swift
//  IntermissionApp
//
//  Created by Louis Tur on 8/25/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class RetreatExtendedInfoVC: TableViewController {
    private let extendedInfo: RetreatExtendedInfoPage
    private let sections: [[InfoItem]]
    
    private let safeAreaCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let mockNavView = MockNavigationBarView()
    
    private struct ReuseIdentifier {
        static let gallery = "galleryCellIdentifier"
        static let markdown = "markdownCellIdentifier"
    }
    
    // MARK: - Initializer -
    
    init(infoPage: RetreatExtendedInfoPage) {
        self.extendedInfo = infoPage
        self.sections = Array(repeating: [.gallery, .markdown],
                              count: infoPage.pageDetailSections.count)
        super.init(nibName: nil, bundle: nil)
        
        self.isNavigationBarHidden = true
        self.delegate = self
        
        mockNavView.configure(infoPage.pageTitle)
        self.view.addSubview(safeAreaCoverView)
        self.view.addSubview(mockNavView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.register(GalleryTableCell.self, forCellReuseIdentifier: ReuseIdentifier.gallery)
        tableView.register(RetreatDetailCell.self, forCellReuseIdentifier: ReuseIdentifier.markdown)
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
        self.tableView.contentInset = UIEdgeInsets(top: self.view.safeAreaInsets.top + 60.0, left: 0.0, bottom: self.tableView.contentInset.bottom, right: 0.0)
    }
    
}

extension RetreatExtendedInfoVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return extendedInfo.pageDetailSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // image gallery, markdown cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]
        let infoSection = extendedInfo.pageDetailSections[indexPath.section]
        
        switch item {
        case .gallery:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.gallery, for: indexPath) as! GalleryTableCell
            cell.configure(with: infoSection)
            
            return cell
            
        case .markdown:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.markdown, for: indexPath) as! RetreatDetailCell
            cell.configure(with: infoSection)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = sections[indexPath.section][indexPath.row]
        switch item {
        case .gallery:
            return tableView.w
        case .markdown:
            return UITableView.automaticDimension
        }
    }

}

enum InfoItem {
    case gallery, markdown
}

// MARK: - MockNavigationBarView -

/// - Note: This navbar assumes that there will be a single left button on a hidden navbar
class MockNavigationBarView: UIView {
    
    private let borderWaveView: UIImageView = {
        let imageView = UIImageView(image: Decorative.Wave.sectionHeader.image)
        return imageView
    }()
    
    private let label: Label = {
        let label = Label()
        label.style = Styles.styles[Font.tableHeaderTitle]
        return label
    }()
    
    private let opaqueContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.addSubview(opaqueContainerView)
        self.addSubview(label)
        self.addSubview(borderWaveView)
        
        opaqueContainerView.snp.makeConstraints { (make) in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(60.0)
        }
        
        let margin: CGFloat = 14.0 + 44.0 + 14.0 // this is equivalent to the left nav button + 14pt on a hidden nav
        label.safelyEnforceHeightOnAutoLayout()
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(margin)
            make.width.equalToSuperview().inset(margin * 2.0).priorityMedium()
            make.centerY.equalTo(opaqueContainerView.snp.centerY)
        }
        
        borderWaveView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(opaqueContainerView.snp.bottom)
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

// MARK: - TableSectionHeaderView -

class TableSectionHeaderView: UITableViewHeaderFooterView {
    
    private let borderWaveView: UIImageView = {
        let imageView = UIImageView(image: Decorative.Wave.sectionHeader.image)
        return imageView
    }()
    
    private let label: Label = {
        let label = Label()
        label.style = Styles.styles[Font.largeHeaderTitle]
        return label
    }()
    
    private let opaqueContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let clearView = UIView()
        clearView.backgroundColor = .clear
        self.backgroundView = clearView
        
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(opaqueContainerView)
        self.contentView.addSubview(label)
        self.contentView.addSubview(borderWaveView)
        
        opaqueContainerView.snp.makeConstraints { (make) in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(60.0)
        }
        
        label.safelyEnforceHeightOnAutoLayout()
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20.0).priorityMedium()
            make.bottom.equalTo(opaqueContainerView.snp.bottom).offset(-4.0)
        }
        
        borderWaveView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(opaqueContainerView.snp.bottom)
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
