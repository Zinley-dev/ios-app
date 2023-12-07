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
    
    deinit {
        print("RecentNode is being deallocated.")
    }
    
    var item: RecentModel!

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
        upperNameNode.isLayerBacked = true
        belowNameNode.isLayerBacked = true
        imageNode.isLayerBacked = true
        upperNameNode.backgroundColor = UIColor.clear
        belowNameNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
          
    }
    
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        setupLayout()
    }
    
    override func didExitDisplayState() {
        super.didExitDisplayState()
        cleanup()
    }
    
    func setupLayout() {
        if item.type == "user" {
            
            imageNode.cornerRadius = OrganizerImageSize/2
            imageNode.clipsToBounds = true
            imageNode.shouldRenderProgressImages = true
            imageNode.isLayerBacked = true
            
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .left
            self.upperNameNode.attributedText = NSAttributedString(
                string: item.user_nickname ?? "@",
                attributes: [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize + 1),
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            )
            
            self.belowNameNode.attributedText = NSAttributedString(
                string: item.user_name ?? "@",
                attributes: [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize + 1),
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            )

            if item.avatarUrl != "" {
                self.imageNode.url = URL(string: item.avatarUrl)
            } else {
                self.imageNode.image = UIImage.init(named: "defaultuser")
            }

            

        } else if item.type == "text" {
            
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .left
            self.upperNameNode.attributedText = NSAttributedString(
                string: item.text ?? "@",
                attributes: [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize + 1),
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            )

            self.imageNode.image = UIImage.init(named: "search-lightmode")
            self.imageNode.contentMode = .scaleAspectFit

            
        }
        
        
    }
    
    func cleanup() {
        // Reset imageNode
        imageNode.url = nil
        imageNode.cornerRadius = 0
        imageNode.clipsToBounds = false
        imageNode.shouldRenderProgressImages = false
        imageNode.isLayerBacked = false

        // Clear attributed texts
        upperNameNode.attributedText = nil
        belowNameNode.attributedText = nil
    }

  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        if item.type == "text" {
            headerSubStack.children = [upperNameNode]
            imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize - 10)
        } else {
            headerSubStack.children = [upperNameNode, belowNameNode]
            imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        }
        
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        
        if item.type == "user" {
            
            headerStack.children = [imageNode, headerSubStack]
            
        } else {
            headerStack.children = [imageNode, headerSubStack]
        }
        
      
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
