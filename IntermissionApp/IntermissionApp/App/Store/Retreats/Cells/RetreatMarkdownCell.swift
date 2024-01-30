//
//  RetreatMarkdownCell.swift
//  IntermissionApp
//
//  Created by Louis Tur on 6/3/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

import Contentful
import ContentfulRichTextRenderer

/// A simple cell to render markdown for a Retreat
class RetreatDetailCell: TableViewCell {
    
    private let titleLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.style = Styles.styles[Font.retreatDetailSectionTitle]
        
        return label
    }()

    private let markdownTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.cta]
        
        return textView
    }()

    private let plainTextField: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.style = Styles.styles[Font.retreatDetailText]
        
        return label
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
    
    private var markdownTextFieldBottom: Constraint?
    private var plainTextFieldBottom: Constraint?
    
    // MARK: - Constructors -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.bottomSeparator.isHidden = true
        self.contentView.addSubviews([titleLabel,
                                      markdownTextView,
                                      plainTextField])
        
        titleLabel.setAutoLayoutHeightEnforcement(999.0)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview().offset(20.0).priority(900.0)
            make.width.equalToSuperview().inset(40.0).priority(900.0)
        }

        markdownTextView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0).priority(900.0)
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.width.equalToSuperview().inset(20.0).priority(900.0)

            self.markdownTextFieldBottom = make.bottom
                                            .equalToSuperview()
                                            .offset(0.0)
                                            .priority(910.0)
                                            .constraint
        }

        plainTextField.setAutoLayoutHeightEnforcement(lowerThan: titleLabel)
        plainTextField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0).priority(900.0)
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.width.equalToSuperview().inset(20.0).priority(900.0)

            self.plainTextFieldBottom = make.bottom
                                            .equalToSuperview()
                                            .offset(0.0)
                                            .priority(910.0)
                                            .constraint
        }

        markdownTextFieldBottom?.deactivate()
        plainTextFieldBottom?.deactivate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -

    func configure(with detailSection: DetailSection, preferMarkdown: Bool = true) {
        titleLabel.styledText = detailSection.title

        if let markdownText = detailSection.markdownDetails, preferMarkdown {
            var renderer = DefaultRichTextRenderer(styleConfig: rendererConfig)
            renderer.hyperlinkRenderer = LinkRenderer()
            renderer.textRenderer = StyledTextRenderer()
            
            let attribString = renderer.render(document: markdownText)
            
            markdownTextView.attributedText = attribString

            plainTextFieldBottom?.deactivate()
            markdownTextFieldBottom?.activate()
            
        } else if let plainText = detailSection.plainTextDetails {
            plainTextField.styledText = plainText
            
            markdownTextFieldBottom?.deactivate()
            plainTextFieldBottom?.activate()
            
            plainTextField.setNeedsLayout()
            plainTextField.layoutIfNeeded()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func configure(with detailGallerySection: DetailSectionWithGallery, preferMarkdown: Bool = true) {
        titleLabel.styledText = detailGallerySection.title
        
        if let markdownText = detailGallerySection.markdownDetails, preferMarkdown {
            var renderer = DefaultRichTextRenderer(styleConfig: rendererConfig)
            renderer.hyperlinkRenderer = LinkRenderer()
            renderer.textRenderer = StyledTextRenderer()
            
            let attribString = renderer.render(document: markdownText)
            
            markdownTextView.attributedText = attribString
            
            plainTextFieldBottom?.deactivate()
            markdownTextFieldBottom?.activate()
        } else if let plainText = detailGallerySection.plainTextDetails {
            plainTextField.styledText = plainText
            
            markdownTextFieldBottom?.deactivate()
            plainTextFieldBottom?.activate()
            
            plainTextField.setNeedsLayout()
            plainTextField.layoutIfNeeded()
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

}
