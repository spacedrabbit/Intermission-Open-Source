//
//  AnimatedBarCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 4/20/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

/** Displays an AnimatedBar in a TableViewCell
 
 */
class AnimatedBarCell: TableViewCell {
    weak var delegate: AnimatedBarCellDelegate?
    private let animatedBarView = AnimatedBarView(with: .lightBackground)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(animatedBarView)
        animatedBarView.configure(with: ["SIGN UP", "LOG IN"], targetWidth: 0.0)
        animatedBarView.delegate = self
        
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.selectionStyle = .none
        self.topSeparator.isHidden = true
        self.bottomSeparator.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectedIndex(_ index: Int) {
        animatedBarView.setSelected(index, animated: true, normalizeUnderline: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animatedBarView.frame = CGRect(x: 0.0, y: 10.0, width: self.contentView.w, height: AnimatedBarView.height)
    }

    class var height: CGFloat {
        return 60.0
    }
}

extension AnimatedBarCell: AnimatedBarViewDelegate {

    func animatedBarView(_ animatedBarView: AnimatedBarView, didSelectItemAt index: Int) {
        delegate?.animatedBarCell(self, didSelectItemAt: index)
    }

}

protocol AnimatedBarCellDelegate: class {
    
    func animatedBarCell(_ animatedBarCell: AnimatedBarCell, didSelectItemAt index: Int)
    
}
