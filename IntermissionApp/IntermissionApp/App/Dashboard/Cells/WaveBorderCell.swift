//
//  WaveBorderCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/18/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

// TODO: If BorderCell works fine, then remove this file
class WaveBorderCell: TableViewCell {
    
    private let waveImageView: ImageView = {
        let imageView = ImageView(image: Decorative.Wave.lightWaveBottom.image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentInsets = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.selectionStyle = .none
        self.contentView.addSubview(waveImageView)
        self.bottomSeparator.isHidden = true 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        waveImageView.frame = self.contentView.bounds
    }
    
    class var height: CGFloat {
        return 80.0
    }
}
