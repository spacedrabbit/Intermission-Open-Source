//
//  LinkRenderer.swift
//  IntermissionApp
//
//  Created by Louis Tur on 9/2/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful
import ContentfulRichTextRenderer

/// NodeRenderer used to render links in the correct style for Contentful markdown fields
struct LinkRenderer: NodeRenderer {
    
    func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey : Any]) -> [NSMutableAttributedString] {
        guard let linkNode = node as? Hyperlink else { return [] }
        
        let attributes: [NSAttributedString.Key : Any] = [
            .link : linkNode.data.uri,
            .foregroundColor : UIColor.cta,
            .font : UIFont.footnote,
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        
        let renderedHyperlinkChildren = linkNode.content.reduce(into: [NSAttributedString]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }
        
        let hyperlinkString = renderedHyperlinkChildren.reduce(into: NSMutableAttributedString()) { (mutableString, renderedChild) in
            mutableString.append(renderedChild)
        }
        
        hyperlinkString.addAttributes(attributes, range: NSRange(location: 0, length: hyperlinkString.length))
        return [hyperlinkString]
    }
    
}
