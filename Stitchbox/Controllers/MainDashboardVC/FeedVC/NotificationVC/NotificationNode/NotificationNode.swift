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
    
    
    init(with notification: UserNotificationModel) {
        
        self.notification = notification
        self.upperTextNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
    }
    
}
