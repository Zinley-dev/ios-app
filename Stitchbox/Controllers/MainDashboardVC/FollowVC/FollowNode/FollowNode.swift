//
//  FollowNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/24/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class FollowNode: ASCellNode {
    
    weak var user: FollowerModel!
    var followAction : ((ASCellNode) -> Void)?
    lazy var delayItem = workItem()
    var attemptCount = 0
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var followBtnNode: ASButtonNode!
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with user: FollowerModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.followBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true

   
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        followBtnNode.backgroundColor = UIColor.clear
        
          //
        
        followBtnNode.addTarget(self, action: #selector(FollowNode.followBtnPressed), forControlEvents: .touchUpInside)
        
       //
        
        automaticallyManagesSubnodes = true
         
        
//        if user.action == "Following" {
//            
//           
//            
//            
//            
//        } else if user.action == "Follower" {
//            
//            
//            
//        
//        }
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        self.userNameNode.attributedText = NSAttributedString(string: user.username ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

        
        AvatarNode.url = URL(string: user.avatar ?? "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg")
        
        
        
    }
    
    
    @objc func followBtnPressed() {
        
        
        
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        followBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [AvatarNode, headerSubStack, followBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
   
    
}
