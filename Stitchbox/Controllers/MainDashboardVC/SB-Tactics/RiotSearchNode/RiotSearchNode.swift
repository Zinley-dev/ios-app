//
//  RiotSearchNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//

import UIKit
import AsyncDisplayKit


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class RiotSearchNode: ASCellNode {
    
    weak var user: RiotAccountModel!
    
    var nameNode: ASTextNode!
    var rankNode: ASTextNode!
    var avatarNode: ASNetworkImageNode!
    var rankImageNode: ASNetworkImageNode!
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    init(with user: RiotAccountModel) {
        
        self.user = user
        self.nameNode = ASTextNode()
        self.rankNode = ASTextNode()
        self.avatarNode = ASNetworkImageNode()
        self.rankImageNode = ASNetworkImageNode()
        
        super.init()
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        avatarNode.cornerRadius = OrganizerImageSize/2
        avatarNode.clipsToBounds = true
        
        nameNode.isLayerBacked = true
        avatarNode.shouldRenderProgressImages = true
        avatarNode.isLayerBacked = true
        rankImageNode.shouldRenderProgressImages = true
        rankImageNode.isLayerBacked = true

   
        nameNode.backgroundColor = UIColor.clear
        rankNode.backgroundColor = UIColor.clear
        

        automaticallyManagesSubnodes = true
        
        
        if let userAvatar = user.profile_image_url {
            
            avatarNode.url = URL(string: userAvatar)
            
        } else {
            
            avatarNode.image = UIImage.init(named: "defaultuser")
        }
        
        
        if let rankImage = user.tier_image_url {
            
            rankImageNode.url = URL(string: rankImage)
            
        }
        
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        self.nameNode.attributedText = NSAttributedString(string: "\(user.name ?? "")", attributes: textAttributes)
        
        
        if user.tier != "" {
            self.rankNode.attributedText = NSAttributedString(string: "\(user.tier ?? "") \(user.division ?? 0) - \(user.lp ?? 0)LP", attributes: textAttributes)
        }
        

        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        avatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        rankImageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        headerSubStack.children = [nameNode, rankNode]
    
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [avatarNode, headerSubStack, rankImageNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
        
    }

}
