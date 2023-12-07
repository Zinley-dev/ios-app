//
//  HashtagSearchNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//


import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class HashTagSearchNode: ASCellNode {
    
    deinit {
        print("HashTagSearchNode is being deallocated.")
    }
    
    var hashtag: HashtagsModel!

    var hashtagTextNode: ASTextNode!
    var hashtagSymbolImg: ASTextNode!
    var countNode: ASTextNode!
    
    init(with hashtag: HashtagsModel) {
        
        self.hashtag = hashtag
        self.hashtagTextNode = ASTextNode()
        self.hashtagSymbolImg = ASTextNode()
        self.countNode = ASTextNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none

        hashtagTextNode.isLayerBacked = true
        hashtagSymbolImg.isLayerBacked = true
        countNode.isLayerBacked = true
        hashtagTextNode.backgroundColor = UIColor.clear
        hashtagTextNode.maximumNumberOfLines = 2
        
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
    
    
    func cleanup() {

        // Clear attributed texts
        hashtagTextNode.attributedText = nil
        countNode.attributedText = nil
        hashtagSymbolImg.attributedText = nil

    }

    func setupLayout() {
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .right
        
        
        if !hashtag.keyword.isEmpty {
            hashtagSymbolImg.attributedText = NSAttributedString(
                string: "#",
                attributes: [
                    NSAttributedString.Key.font:  FontManager.shared.roboto(.Regular, size: FontSize + 5),
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            )

            hashtagTextNode.attributedText = NSAttributedString(
                string: String(self.hashtag.keyword.dropFirst(1)),
                attributes: [
                    NSAttributedString.Key.font:  FontManager.shared.roboto(.Regular, size: FontSize + 1),
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            )
            
            self.countNode.attributedText = NSAttributedString(
                string: "\(formatPoints(num: Double(hashtag.count))) posts",
                attributes: [
                    NSAttributedString.Key.font:  FontManager.shared.roboto(.Medium, size: FontSize + 1),
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            )
        }

        countNode.backgroundColor = UIColor.clear
    
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        
        countNode.style.preferredSize = CGSize(width: 100.0, height: 15.0)
    
        //
      
        
        let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 0.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                            children: [hashtagSymbolImg, hashtagTextNode])
        
        let verticalStack = ASStackLayoutSpec.vertical()
        
        
            
        verticalStack.style.flexShrink = 16.0
        verticalStack.style.flexGrow = 16.0
        verticalStack.spacing = 8.0
            
            
        verticalStack.children = [mainStack]

    
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [verticalStack, countNode]


        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
        
    }
    
    

}
