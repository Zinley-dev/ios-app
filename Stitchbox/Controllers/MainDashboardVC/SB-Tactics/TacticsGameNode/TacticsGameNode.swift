//
//  TacticsGameNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import UIKit
import AsyncDisplayKit


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 15

class TacticsGameNode: ASCellNode {
    
    weak var game: TacticsGameModel!
    
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    var backgroundImageNode: ASImageNode!
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    init(with game: TacticsGameModel) {
        
        self.game = game
        self.nameNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.backgroundImageNode = ASImageNode()
        
        super.init()
        
        self.backgroundColor = .darkGray
        
        backgroundImageNode.image = UIImage.init(named: "universal_theme")
        backgroundImageNode.contentMode = .scaleAspectFill
        
        paragraphStyles.alignment = .center
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        self.nameNode.attributedText = NSAttributedString(string: "\(game.name ?? "")", attributes: textAttributes)
        self.imageNode.backgroundColor = .clear
       
        imageNode.url = URL(string: game.logo)
        imageNode.contentMode = .scaleAspectFit
        self.cornerRadius = 15
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        imageNode.style.preferredSize = CGSize(width: constrainedSize.max.width - 64, height: constrainedSize.max.width - 64)
       
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [nameNode]
      
        let headerStack = ASStackLayoutSpec.vertical()
      
        headerStack.spacing = 17
        headerStack.justifyContent = ASStackLayoutJustifyContent.center
        headerStack.alignItems = ASStackLayoutAlignItems.center
        
        headerStack.children = [imageNode, headerSubStack]
        
        let centerLayoutSpec = ASRelativeLayoutSpec(horizontalPosition: .center,
                                                     verticalPosition: .center,
                                                     sizingOption: [],
                                                     child: headerStack)
        
        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: centerLayoutSpec)
        
        if game.status == true {
            let backgroundImageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0), child: backgroundImageNode)
            
            let finalLayoutSpec = ASBackgroundLayoutSpec(child: insetLayoutSpec, background: backgroundImageInsetSpec)
            
            return finalLayoutSpec
        } else {
            return insetLayoutSpec
        }
    }

}
