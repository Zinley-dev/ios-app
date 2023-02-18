//
//  domainListNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/17/23.
//

import Foundation

import UIKit
import AsyncDisplayKit


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class domainListNode: ASCellNode {
    
    var idNode: ASTextNode!
    var domainNode: ASTextNode!
   
    //
    
    weak var post: GameStatsDomainModel!
    
    
    init(with post: GameStatsDomainModel) {
        self.post = post
        
        self.idNode = ASTextNode()
        self.domainNode = ASTextNode()
      
        super.init()
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .right
        
        
        self.idNode.attributedText = NSAttributedString(string: post.id, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
        
        paragraphStyles.alignment = .center
        paragraphStyles.lineSpacing = 5.0
        domainNode.truncationMode = .byWordWrapping
        
        self.domainNode.attributedText = NSAttributedString(string: post.domain, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
        self.domainNode.maximumNumberOfLines = 3
        
        
        DispatchQueue.main.async {
            
            self.view.backgroundColor = UIColor.musicBackgroundDark
            
        }
        
        
       
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        domainNode.style.flexGrow = 1.0
        domainNode.style.flexShrink = 1.0

        let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 16.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [idNode, domainNode])

        let insetStack = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                                           child: mainStack)

        return insetStack
    }

    
}
