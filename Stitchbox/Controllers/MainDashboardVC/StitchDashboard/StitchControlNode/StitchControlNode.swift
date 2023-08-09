//
//  StitchControlNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/22/23.
//

import Foundation
import UIKit
import AsyncDisplayKit

fileprivate let FontSize: CGFloat = 13

class StitchControlNode: ASCellNode {
    
    var post: PostModel!
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
 

    init(with post: PostModel) {
        
        self.post = post
        self.imageNode = ASNetworkImageNode()
        self.nameNode = ASTextNode()
        super.init()
        
        self.backgroundColor = .clear // set background to clear

      
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15

      
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
           
        let imageNodeMinHeight: CGFloat = constrainedSize.max.height
        imageNode.style.minHeight = ASDimension(unit: .points, value: imageNodeMinHeight)
        imageNode.style.flexGrow = 1.0 // Allows imageNode to fill remaining space

        let stack = ASStackLayoutSpec.vertical()
        stack.justifyContent = .start // align items to start
        stack.alignItems = .stretch // stretch items to fill the width
        stack.children = [imageNode]

        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: stack)

        return insetLayoutSpec
    }


}
