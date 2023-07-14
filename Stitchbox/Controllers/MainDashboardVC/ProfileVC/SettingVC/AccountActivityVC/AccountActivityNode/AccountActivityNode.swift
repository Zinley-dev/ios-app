//
//  AccountActivityNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class AccountActivityNode: ASCellNode {
    
    deinit {
        print("AccountActivityNode is being deallocated.")
    }
    
    var activity: UserActivityModel
    var descriptionNode: ASTextNode!
    var timeNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    let paragraphStyles = NSMutableParagraphStyle()
    
    
    init(with activity: UserActivityModel) {
        
        self.activity = activity
        self.descriptionNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        AvatarNode.contentMode = .scaleAspectFill
        descriptionNode.isLayerBacked = true
        
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true
        
        //
        paragraphStyles.alignment = .left

   
        descriptionNode.backgroundColor = UIColor.clear
        timeNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let date = self.activity.createdAt
    
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
        let time = NSAttributedString(string: "\(timeAgoSinceDate(date!, numericDates: true))", attributes: timeAttributes)
    
        timeNode.attributedText = time

        if activity.content == "follows an account" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have followed a new user", attributes: textAttributes)
            
        } else if activity.content == "unfollows a user" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have followed a new user", attributes: textAttributes)
            
        } else if activity.content == "removes a follower" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have removed a follower", attributes: textAttributes)
            
        } else if activity.content == "fistbump a user" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have fistbumped a new user", attributes: textAttributes)
            
        } else if activity.content == "un-fistbump a user" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have un-fistbumped a user", attributes: textAttributes)
            
        } else if activity.content == "block-account" {
            
            if activity.action == "CREATE" {
                
                descriptionNode.attributedText = NSAttributedString(string: "You have blocked a user", attributes: textAttributes)
                
            } else if activity.action == "DELETE" {
                
                descriptionNode.attributedText = NSAttributedString(string: "You have unblocked a user", attributes: textAttributes)
                
            }
            
            
        } else if activity.content == "Like a post" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have liked a new post", attributes: textAttributes)
            
        } else if activity.content == "Delete a like post" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have unliked a post", attributes: textAttributes)
            
        } else if activity.content == "comment" {
           
            if activity.action == "CREATE" {
                descriptionNode.attributedText = NSAttributedString(string: "You just created a new comment", attributes: textAttributes)
            } else if activity.action == "DELETE" {
                descriptionNode.attributedText = NSAttributedString(string: "You just deleted a comment", attributes: textAttributes)
            } else if activity.action == "UPDATE" {
                descriptionNode.attributedText = NSAttributedString(string: "You just updated a comment", attributes: textAttributes)
            }
            
        } else if activity.content == "Upload image" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You just uploaded a new image", attributes: textAttributes)
            
        } else if activity.content == "post" {
            
            if activity.action == "CREATE" {
                descriptionNode.attributedText = NSAttributedString(string: "You just created a new post", attributes: textAttributes)
            } else if activity.action == "DELETE" {
                descriptionNode.attributedText = NSAttributedString(string: "You just deleted a post", attributes: textAttributes)
            } else if activity.action == "UPDATE" {
                descriptionNode.attributedText = NSAttributedString(string: "You just updated a post", attributes: textAttributes)
            }
            
        } else if activity.content == "Upload video" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You just uploaded a new video", attributes: textAttributes)
            
        }
        
        
        if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
            let url = URL(string: avatarUrl)
            AvatarNode.url = url
        }

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
       
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [descriptionNode, timeNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
