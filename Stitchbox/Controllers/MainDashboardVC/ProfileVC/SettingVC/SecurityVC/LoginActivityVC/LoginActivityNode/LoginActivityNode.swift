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
        timeNode.isLayerBacked = true
        //
        paragraphStyles.alignment = .left

   
        descriptionNode.backgroundColor = UIColor.clear
        timeNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        guard shouldAllowAfterInactive else {
            return
        }
        setupLayout()
    }
    
    override func didExitDisplayState() {
        super.didExitDisplayState()
        guard shouldAllowAfterInactive else {
            return
        }
        cleanup()
    }
    
    /// Cleans up the node when it goes off-screen or is no longer needed.
    func cleanup() {
        // Reset attributed texts to nil to release any resources they might be holding
        timeNode.attributedText = nil
        descriptionNode.attributedText = nil

        // Release the avatar image or URL to free memory
        AvatarNode.url = nil


        // Reset any other properties or references that need cleaning
        // ...

        // If there are any custom cleanup actions required for your specific case, add them here
        // ...
    }


    /// Sets up the layout for the activity node.
    func setupLayout() {

        // Common attributes for description text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.roboto(.Medium, size: FontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyles
        ]

        // Attributes for time text
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.roboto(.Medium, size: FontSize),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyles
        ]

        // Set the time node text
        let timeString = timeAgoSinceDate(activity.createdAt, numericDates: true)
        timeNode.attributedText = NSAttributedString(string: timeString, attributes: timeAttributes)

        // Set the description node text based on activity action
        switch activity.action {
        case "Create":
            descriptionNode.attributedText = NSAttributedString(string: "Your account is created", attributes: textAttributes)
        case "Update":
            descriptionNode.attributedText = NSAttributedString(string: "Your account has been updated", attributes: textAttributes)
        case "Login":
            descriptionNode.attributedText = NSAttributedString(string: "Your account has been logged in", attributes: textAttributes)
        case "Logout":
            descriptionNode.attributedText = NSAttributedString(string: "Your account has been logged out", attributes: textAttributes)
        case "Change Password":
            descriptionNode.attributedText = NSAttributedString(string: "You have changed your password", attributes: textAttributes)
        case "Update my profile":
            descriptionNode.attributedText = NSAttributedString(string: "You have updated your profile", attributes: textAttributes)
        default:
            print(activity.action, activity.content)
        }

        // Set the avatar node URL
        if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, !avatarUrl.isEmpty {
            AvatarNode.url = URL(string: avatarUrl)
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

