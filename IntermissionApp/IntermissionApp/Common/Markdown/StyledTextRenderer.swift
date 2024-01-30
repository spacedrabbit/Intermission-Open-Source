//
//  StyledTextRenderer.swift
//  IntermissionApp
//
//  Created by Louis Tur on 9/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful
import ContentfulRichTextRenderer

/// NodeRenderer used to render basic markdown styles (bold, italics & code)
struct StyledTextRenderer: NodeRenderer {
    
    func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        guard
            let text = node as? Text,
            let styleConfig = context[.renderingConfig] as? RenderingConfiguration
            else { return [] }
        
        let font = StyledTextRenderer.font(for: text, config: styleConfig)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = styleConfig.lineSpacing
        paragraphStyle.paragraphSpacing = styleConfig.paragraphSpacing
        //        paragraphStyle.firstLineHeadIndent = 12.0
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font : font,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSMutableAttributedString(string: text.value, attributes: attributes)
        return [attributedString]
    }
    
    static func font(for textNode: Text, config: RenderingConfiguration) -> UIFont {
        let markTypes = textNode.marks.map { $0.type }
        let fontSize = config.baseFont.pointSize
        var font: UIFont? = nil
        
        if markTypes.contains(.bold) && markTypes.contains(.italic) {
            font = UIFont(name: Font.identifier(for: .boldItalic), size: fontSize)
        } else if markTypes.contains(.bold) {
            font = UIFont(name: Font.identifier(for: .bold), size: fontSize)
        } else if markTypes.contains(.italic) {
            font = UIFont(name: Font.identifier(for: .italic), size: fontSize)
        } else if markTypes.contains(.code) {
            font = UIFont(name: "Menlo-Regular", size: fontSize)
        } else {
            Track.track(eventName: "render_font_failed")
        }
        
        return font ?? config.baseFont
    }
}
