//
//  VDPDetailCell.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 2/5/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

import Contentful
import ContentfulRichTextRenderer

class VDPDetailCell: TableViewCell {
    
    private let markdownTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.cta]
        
        return textView
    }()
    
    private let rendererConfig: RenderingConfiguration = {
        var config = RenderingConfiguration()
        config.baseFont = UIFont.body
        config.textColor = UIColor.textColor
        config.indentationMultiplier = 12.0
        config.distanceFromBulletMinXToCharMinX = 12.0
        config.blockQuoteColor = UIColor.lightTeal.withAlphaComponent(0.25)
        config.blockQuoteTextInset = 20.0
        
        // H1-H6
        config.fontsForHeadingLevels = [
            UIFont(name: Font.identifier(for: .bold), size: 28.0) ?? UIFont.systemFont(ofSize: 28.0, weight: .bold),
            UIFont(name: Font.identifier(for: .bold), size: 24.0) ?? UIFont.systemFont(ofSize: 24.0, weight: .bold),
            UIFont(name: Font.identifier(for: .bold), size: 20.0) ?? UIFont.systemFont(ofSize: 20.0, weight: .bold),
            UIFont(name: Font.identifier(for: .bold), size: 18.0) ?? UIFont.systemFont(ofSize: 18.0, weight: .bold),
            UIFont(name: Font.identifier(for: .bold), size: 16.0) ?? UIFont.systemFont(ofSize: 16.0, weight: .bold),
            UIFont(name: Font.identifier(for: .bold), size: 14.0) ?? UIFont.systemFont(ofSize: 14.0, weight: .bold)
        ]
        
        return config
    }()

    // MARK: - Initializers -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(markdownTextView)
        
        markdownTextView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20.0).priority(900.0)
            make.bottom.equalToSuperview().inset(20.0).priority(900.0)
            make.width.equalToSuperview().inset(20.0).priority(899.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with richTextDocument: RichTextDocument) {
        var renderer = DefaultRichTextRenderer(styleConfig: rendererConfig)
        renderer.hyperlinkRenderer = LinkRenderer()
        renderer.textRenderer = StyledTextRenderer()
        
        let attribString = renderer.render(document: richTextDocument)
        markdownTextView.attributedText = attribString
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}
