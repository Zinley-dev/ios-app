//
//  TrendingHashtagNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/20/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire

fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class TrendingHashtagNode: ASCellNode {
    
    deinit {
        print("TrendingHashtagNode is being deallocated.")
    }
    
    var trendingHashtag: TrendingHashtag!
    var rank: Int!

    var rankNode: ASTextNode!
    var hashtagTextNode: ASTextNode!
    var viewsNode: ASTextNode!
   
    
    init(with trendingHashtag: TrendingHashtag, rank: Int) {
        
        self.trendingHashtag = trendingHashtag
        self.rank = rank
        self.rankNode = ASTextNode()
        self.hashtagTextNode = ASTextNode()
        self.viewsNode = ASTextNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none

        rankNode.isLayerBacked = true
        viewsNode.isLayerBacked = true
        hashtagTextNode.isLayerBacked = true
        hashtagTextNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left

        rankNode.attributedText = NSAttributedString(
            string: "\(rank).",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize + 5),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyles
            ]
        )

        hashtagTextNode.attributedText = NSAttributedString(
            string: self.trendingHashtag.hashtag,
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyles
            ]
        )

        viewsNode.attributedText = NSAttributedString(
            string: "\(formatPoints(num: Double(self.trendingHashtag.views))) views",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1),
                NSAttributedString.Key.foregroundColor: UIColor.black, // This is where you set the color
                NSAttributedString.Key.paragraphStyle: paragraphStyles
            ]
        )

        viewsNode.backgroundColor = UIColor.clear
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        viewsNode.style.flexShrink = 1.0
          
        rankNode.style.width = ASDimension(unit: .points, value: 35) // Set the width to 25
      
        let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,  // Adjust this value to add space between nodes
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [rankNode, hashtagTextNode])
            
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.style.flexShrink = 1.0
        verticalStack.style.flexGrow = 1.0
        verticalStack.spacing = 5.0   // Adjust this value to reduce the space between nodes
        verticalStack.children = [mainStack]

        let headerStack = ASStackLayoutSpec.horizontal()
        headerStack.spacing = 5   // Adjust this value to reduce the space between nodes
        headerStack.justifyContent = .start
        headerStack.alignItems = .center
        headerStack.children = [verticalStack, viewsNode]

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
    }


}
