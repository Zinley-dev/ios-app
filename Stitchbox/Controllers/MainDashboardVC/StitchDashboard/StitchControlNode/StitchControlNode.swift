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
    
    deinit {
        print("StitchControlNode is being deallocated.")
    }
    
    var post: PostModel!
    var imageNode: ASNetworkImageNode!
 

    init(with post: PostModel) {
        
        self.post = post
        self.imageNode = ASNetworkImageNode()
        super.init()
        
        self.backgroundColor = .clear // set background to clear

        imageNode.isLayerBacked = true
        self.imageNode.backgroundColor = .clear
        
        imageNode.url = post.imageUrl
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 10 // set corner radius of imageNode to 15
        automaticallyManagesSubnodes = true
      
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
           
        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: imageNode)

        return insetLayoutSpec
        
    }


}
