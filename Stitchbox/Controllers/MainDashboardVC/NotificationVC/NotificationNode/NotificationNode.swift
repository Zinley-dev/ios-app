//
//  NotificationNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/9/23.
//

import UIKit
import AsyncDisplayKit


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class NotificationNode: ASCellNode {
    
    weak var notification: UserNotificationModel!
    var upperTextNode: ASTextNode!
    var timeNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    init(with notification: UserNotificationModel) {
        
        self.notification = notification
        self.upperTextNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        if self.notification._isRead == false {
            
            self.backgroundColor = UIColor.textLightMode
            
        } else {
            
            self.backgroundColor = UIColor.background
            
        }
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
        self.upperTextNode.attributedText = NSAttributedString(string: notification.content, attributes: textAttributes)
        
        let time = NSAttributedString(string: "\(timeAgoSinceDate(notification.updatedAt, numericDates: true))", attributes: timeAttributes)
        timeNode.attributedText = time
        imageNode.url = URL(string: notification.avatarUrl)
        imageNode.cornerRadius = OrganizerImageSize/2
        imageNode.clipsToBounds = true
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
       
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [upperTextNode, timeNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [imageNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
}
