//
//  FilterReuseableHeader.swift
//  IntermissionApp
//
//  Created by Louis Tur on 5/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

// MARK: - FilterReuseableHeader -

class FilterReuseableHeader: UITableViewHeaderFooterView {
    
    private let tagLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.videoCollectionCellTitle]
        return label
    }()
    
    private let countLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.helperText]
        return label
    }()
    
    // MARK: - Initializers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(tagLabel)
        self.contentView.addSubview(countLabel)
        
        // Yes, this is needed...ffs
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.paleLavendar.withAlphaComponent(0.95)
        
        tagLabel.safelyEnforceSizeOnAutoLayout()
        countLabel.safelyEnforceSizeOnAutoLayout()
        
        tagLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.bottom.equalToSuperview().inset(8.0)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20.0)
            make.baseline.equalTo(tagLabel.snp.baseline)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with tag: Tag, count: Int) {
        tagLabel.styledText = tag.title.uppercased()
        countLabel.styledText = "Total: \(count)"
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Height -
    
    class var height: CGFloat {
        return 60.0
    }
}
