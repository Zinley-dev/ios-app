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
    
    weak var hashtag: HashtagsModel!

    var hashtagTextNode: ASTextNode!
    var hashtagSymbolImg: ASTextNode!
    var coutNode: ASTextNode!
   
    
    init(with hashtag: HashtagsModel) {
        
        self.hashtag = hashtag
        self.hashtagTextNode = ASTextNode()
        self.hashtagSymbolImg = ASTextNode()
        self.coutNode = ASTextNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none

        hashtagTextNode.isLayerBacked = true
        hashtagTextNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .right
        
        
        if !hashtag.keyword.isEmpty {
            
            hashtagSymbolImg.attributedText = NSAttributedString(string: "#", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: FontSize + 5), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            

            hashtagTextNode.attributedText = NSAttributedString(string: String(self.hashtag.keyword.dropFirst(1)), attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
           
            self.coutNode.attributedText = NSAttributedString(string: "\(formatPoints(num: Double(hashtag.count))) posts", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        }
        
        coutNode.backgroundColor = UIColor.clear
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        
        coutNode.style.preferredSize = CGSize(width: 60.0, height: 15.0)
    
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
        headerStack.children = [verticalStack, coutNode]


        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
        
    }
    
    

}
