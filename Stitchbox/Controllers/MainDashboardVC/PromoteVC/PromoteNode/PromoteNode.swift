//
//  PromoteNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/18/23.
//

import UIKit
import AsyncDisplayKit


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class PromoteNode: ASCellNode {
    
    weak var promote: PromoteModel!
    var titleNode: ASTextNode!
    var timeNode: ASTextNode!
    var maxMemberNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    var activeStatusNode: ASDisplayNode!
    var imageBackgroundNode: ASNetworkImageNode!
    var overlayNode: ASDisplayNode!
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    init(with promote: PromoteModel) {
        
        self.promote = promote
        self.titleNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.imageBackgroundNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        self.maxMemberNode = ASTextNode()
        self.activeStatusNode = ASDisplayNode()
        self.overlayNode = ASDisplayNode()
        
        super.init()
        
        self.backgroundColor = .background
        
        // Active status node setup
        activeStatusNode.backgroundColor = promote.isActive ? .green : .gray
        activeStatusNode.style.preferredSize = CGSize(width: 10, height: 10)
        activeStatusNode.cornerRadius = 5
        activeStatusNode.clipsToBounds = true
        
        // Background image node setup
        imageBackgroundNode.url = promote.imageUrl
        imageBackgroundNode.contentMode = .scaleAspectFill
        
        // Overlay node setup
        overlayNode.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        imageNode.cornerRadius = OrganizerImageSize/2
        imageNode.clipsToBounds = true
        imageNode.url = promote.imageUrl
        
        print(promote.imageUrl)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: FontSize + 2),
            .foregroundColor: UIColor.white
        ]
        titleNode.attributedText = NSAttributedString(
            string: promote.name,
            attributes: titleAttributes
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = "\(dateFormatter.string(from: promote.startDate)) - \(dateFormatter.string(from: promote.endDate))"
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: FontSize),
            .foregroundColor: UIColor.lightGray
        ]
        timeNode.attributedText = NSAttributedString(
            string: timeString,
            attributes: timeAttributes
        )
        
        let maxMemberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: FontSize - 2),
            .foregroundColor: UIColor.gray
        ]
        maxMemberNode.attributedText = NSAttributedString(
            string: "Max members: \(promote.maxMember)",
            attributes: maxMemberAttributes
        )
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        headerSubStack.style.flexShrink = 1.0
        headerSubStack.style.flexGrow = 1.0
        headerSubStack.spacing = 8.0
        headerSubStack.children = [titleNode, timeNode, maxMemberNode]
        
        let activeStatusInsetSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: HorizontalBuffer),
            child: activeStatusNode
        )
        
        let headerStack = ASStackLayoutSpec.horizontal()
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.children = [activeStatusInsetSpec, imageNode, headerSubStack]
        
        let headerInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
        
        let overlayInsetSpec = ASInsetLayoutSpec(insets: .zero, child: overlayNode)
        overlayInsetSpec.style.flexGrow = 1.0
        
        let backgroundStack = ASStackLayoutSpec.vertical()
        backgroundStack.children = [imageBackgroundNode, overlayInsetSpec, headerInsetSpec]
        
        return backgroundStack
    }
    
}





