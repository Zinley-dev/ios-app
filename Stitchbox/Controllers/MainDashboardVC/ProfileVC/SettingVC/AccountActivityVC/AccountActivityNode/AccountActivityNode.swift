//
//  AccountActivityNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class AccountActivityNode: ASCellNode {
    
    
    var activity: UserActivityModel
    var descriptionNode: ASTextNode!
    var timeNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    let paragraphStyles = NSMutableParagraphStyle()
    
    
    init(with activity: UserActivityModel) {
        
        self.activity = activity
        self.descriptionNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()

        

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
       
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [descriptionNode, timeNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
