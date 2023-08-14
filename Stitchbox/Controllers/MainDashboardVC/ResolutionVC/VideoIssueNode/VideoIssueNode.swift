//
//  VideoIssueNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/13/23.
//

import Foundation
import UIKit
import AsyncDisplayKit

class VideoIssueNode: ASCellNode {
    
    var videoIssue: VideoIssueModel
    var descriptionNode: ASTextNode!
    var actionTakenNode: ASTextNode!
    var timeNode: ASTextNode!
    let paragraphStyles = NSMutableParagraphStyle()
    
    deinit {
        print("VideoIssueNode is being deallocated.")
    }
    
    init(with videoIssue: VideoIssueModel) {
        
        self.videoIssue = videoIssue
        self.descriptionNode = ASTextNode()
        self.actionTakenNode = ASTextNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        descriptionNode.isLayerBacked = true
        actionTakenNode.isLayerBacked = true
        paragraphStyles.alignment = .left

        descriptionNode.backgroundColor = UIColor.clear
        actionTakenNode.backgroundColor = UIColor.clear
        timeNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let date = self.videoIssue.reportedAt
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),  // Replace with your FontManager if required
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
        
        let timeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),  // Replace with your FontManager if required
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
        
        let time = NSAttributedString(string: "\(timeAgoSinceDate(date!, numericDates: true))", attributes: timeAttributes)
    
        timeNode.attributedText = time
        
        if let reason = videoIssue.reason {
            descriptionNode.attributedText = NSAttributedString(string: "Your video was detected for \(reason.rawValue).", attributes: textAttributes)
        }
        if let actionTaken = videoIssue.actionTaken {
            actionTakenNode.attributedText = NSAttributedString(string: "Action taken: \(actionTaken.rawValue).", attributes: textAttributes)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let issueSubStack = ASStackLayoutSpec.vertical()
        issueSubStack.spacing = 8.0
        issueSubStack.children = [descriptionNode, actionTakenNode, timeNode]
      
        let issueStack = ASStackLayoutSpec.horizontal()
        issueStack.spacing = 10
        issueStack.justifyContent = ASStackLayoutJustifyContent.start
        issueStack.children = [issueSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: issueStack)
    }
}
