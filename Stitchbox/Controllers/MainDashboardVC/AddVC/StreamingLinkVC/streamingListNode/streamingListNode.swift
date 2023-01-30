//
//  streamingListNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/13/21.
//

import UIKit
import AsyncDisplayKit


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class streamingListNode: ASCellNode {
    
    
    var companyNode: ASTextNode!
    var domainNode: ASTextNode!
    var imageView: ASImageNode!
    
    //
    
    weak var post: StreamingDomainModel!
    
    
    init(with post: StreamingDomainModel) {
        self.post = post
        
        self.companyNode = ASTextNode()
        self.domainNode = ASTextNode()
        self.imageView = ASNetworkImageNode()
        
        super.init()
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        
        self.companyNode.attributedText = NSAttributedString(string: post.company, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
        
        paragraphStyles.alignment = .right
        paragraphStyles.lineSpacing = 5.0
        domainNode.truncationMode = .byWordWrapping
        
        self.domainNode.attributedText = NSAttributedString(string: post.domain.joined(separator: ", "), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
        self.domainNode.maximumNumberOfLines = 3
        
        
        DispatchQueue.main.async { 
            
            self.view.backgroundColor = UIColor.musicBackgroundDark
            
        }
        
        
       
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        if self.post.domain.count <= 2 {
            domainNode.style.preferredSize = CGSize(width: 250.0, height: 20.0)
        } else {
            domainNode.style.preferredSize = CGSize(width: 250.0, height: 40.0)
        }
        
    
        //
      
        let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 0.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                            children: [imageView, companyNode])
        
        let verticalStack = ASStackLayoutSpec.vertical()
        
        
            
        verticalStack.style.flexShrink = 16.0
        verticalStack.style.flexGrow = 16.0
        verticalStack.spacing = 8.0
            
            
        verticalStack.children = [mainStack]

    
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [verticalStack, domainNode]


        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
        
    }
    
}
