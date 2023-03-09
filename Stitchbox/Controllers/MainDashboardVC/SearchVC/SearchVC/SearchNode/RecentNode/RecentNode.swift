//
//  RecentNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13


class RecentNode: ASCellNode {
    
    weak var item: RecentModel!

    var upperNameNode: ASTextNode!
    var belowNameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    
    
    init(with item: RecentModel) {
        
        self.item = item
        self.upperNameNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.belowNameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        imageNode.cornerRadius = OrganizerImageSize/2
        imageNode.clipsToBounds = true
        upperNameNode.isLayerBacked = true
        imageNode.shouldRenderProgressImages = true
        imageNode.isLayerBacked = true

   
        upperNameNode.backgroundColor = UIColor.clear
        belowNameNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
         
        
        if item.type == "game" {
            DispatchQueue.main.async {
                
                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
                self.upperNameNode.attributedText = NSAttributedString(string: item.game_name ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
                self.belowNameNode.attributedText = NSAttributedString(string: item.game_shortName ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

                
                self.imageNode.url = URL(string: item.coverUrl ?? "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg")
                
            }
        } else if item.type == "user" {
            
            DispatchQueue.main.async {
                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
                self.upperNameNode.attributedText = NSAttributedString(string: item.user_nickname ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
                self.belowNameNode.attributedText = NSAttributedString(string: item.user_name ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

                
                self.imageNode.url = URL(string: item.avatarUrl ?? "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg")
            }
            

        }

        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        headerSubStack.children = [upperNameNode, belowNameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [imageNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
