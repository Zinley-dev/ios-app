//
//  CategoryNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/25/23.
//

import AsyncDisplayKit

class CategoryNode: ASCellNode {
    // ASTextNode to display the category name
    let textNode = ASTextNode()
    let backgroundNode = ASDisplayNode()
    
    
    init(categoryName: String) {
        super.init()
        
        // Configure textNode
        textNode.maximumNumberOfLines = 3
        textNode.attributedText = NSAttributedString(string: categoryName, attributes: [
            .font: FontManager.shared.roboto(.Regular, size: 12),
            .foregroundColor: UIColor.black
        ])
        
        // Configure backgroundNode
        backgroundNode.backgroundColor = .normalButtonBackground // Unselected color
        backgroundNode.cornerRadius = 10.0
        backgroundNode.clipsToBounds = true
        
        // Add the background and text nodes as subnodes
        addSubnode(backgroundNode)
        addSubnode(textNode)
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: textNode)
        let backgroundOverlaySpec = ASOverlayLayoutSpec(child: backgroundNode, overlay: textCenterSpec)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), child: backgroundOverlaySpec)
    }
}

