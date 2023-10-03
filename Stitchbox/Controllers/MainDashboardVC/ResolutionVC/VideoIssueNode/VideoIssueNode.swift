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
    private var descriptionNode: ASTextNode!
    private var reasonNode: ASTextNode!
    private var actionTakenNode: ASTextNode!
    private var timeNode: ASTextNode!
    private let paragraphStyles = NSMutableParagraphStyle()
    
    deinit {
        print("VideoIssueNode is being deallocated.")
    }
    
    init(with videoIssue: VideoIssueModel) {
        
        self.videoIssue = videoIssue
        self.descriptionNode = ASTextNode()
        self.reasonNode = ASTextNode()
        self.actionTakenNode = ASTextNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        descriptionNode.isLayerBacked = true
        reasonNode.isLayerBacked = true
        actionTakenNode.isLayerBacked = true
        timeNode.isLayerBacked = true
        
        automaticallyManagesSubnodes = true
        
        paragraphStyles.alignment = .left
        
        let keyAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
        
        let timeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
        
        if let date = self.videoIssue.moderationLog?.actionTime {
            let time = NSAttributedString(string: "\(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
            timeNode.attributedText = time
        }
        
        descriptionNode.attributedText = NSAttributedString(string: "Issue for your video:", attributes: keyAttributes)
        
        if let reason = videoIssue.contentModerationMessage {
            reasonNode.attributedText = NSAttributedString(string: "\(reason).", attributes: valueAttributes)
        }
        
        if let actionTaken = videoIssue.moderationLog?.actionTaken {
            let actionAttributes: [NSAttributedString.Key: Any]
           
            if actionTaken.lowercased() == "delete" {
                actionAttributes = [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                    NSAttributedString.Key.paragraphStyle: paragraphStyles
                ]
            } else {
                actionAttributes = valueAttributes
            }
            
            // Create two separate attributed strings
            let actionLabel = NSAttributedString(string: "Action taken: ", attributes: keyAttributes)
            let actionValue = NSAttributedString(string: "deleted", attributes: actionAttributes)
            
            // Combine them into a single string
            let combinedAttributedString = NSMutableAttributedString()
            combinedAttributedString.append(actionLabel)
            combinedAttributedString.append(actionValue)
            
            actionTakenNode.attributedText = combinedAttributedString
        }

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let issueSubStack = ASStackLayoutSpec.vertical()
        issueSubStack.spacing = 12.0
        issueSubStack.children = [descriptionNode, reasonNode, actionTakenNode, timeNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: issueSubStack)
    }
}

// Note: The VideoIssueModel and the `timeAgoSinceDate` function are assumed to be elsewhere in your code.
