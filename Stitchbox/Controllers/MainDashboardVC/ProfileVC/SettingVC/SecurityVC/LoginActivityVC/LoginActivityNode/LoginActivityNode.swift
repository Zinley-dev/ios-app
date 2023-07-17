//
//  LoginActivityNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/20/23.
//


import UIKit
import AsyncDisplayKit
import Alamofire



fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class LoginActivityNode: ASCellNode {
    
    var activity: UserLoginActivityModel
    var descriptionNode: ASTextNode!
    var timeNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
   
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    init(with activity: UserLoginActivityModel) {
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
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
        let timeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]

        
        let time = NSAttributedString(string: "\(timeAgoSinceDate(activity.createdAt, numericDates: true))", attributes: timeAttributes)
        
        timeNode.attributedText = time
        
      
        if activity.action == "Create" {
            
            descriptionNode.attributedText = NSAttributedString(string: "Your account is created", attributes: textAttributes)
            
        } else if activity.action == "Update" {
            
            descriptionNode.attributedText = NSAttributedString(string: "Your account has been updated", attributes: textAttributes)
                         
        } else if activity.action == "Login" {
            
            descriptionNode.attributedText = NSAttributedString(string: "Your account has been logged in", attributes: textAttributes)
            
        } else if activity.action == "Logout" {
            
            descriptionNode.attributedText = NSAttributedString(string: "Your account has been logged out", attributes: textAttributes)
            
            
        } else if activity.action == "Change Password" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have changed your password", attributes: textAttributes)
            
            
        } else if activity.action == "Update my profile" {
            
            descriptionNode.attributedText = NSAttributedString(string: "You have updated your profile", attributes: textAttributes)
            
            
        } else {
            
            print(activity.action, activity.content)
            
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

