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
    
    
    var activity: UserActivityModel
    var userNameNode: ASTextNode!
    var timeNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
   
    var desc = ""

    let paragraphStyles = NSMutableParagraphStyle()
    
    
    init(with activity: UserActivityModel) {
        
        self.activity = activity
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        AvatarNode.contentMode = .scaleAspectFill
        userNameNode.isLayerBacked = true
        
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true
        
        //
        paragraphStyles.alignment = .left

   
        userNameNode.backgroundColor = UIColor.clear
        timeNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        //let date = self.activity.timeStamp.dateValue()
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: FontSize), NSAttributedString.Key.foregroundColor: UIColor.primary, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: FontSize), NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
       // let time = NSAttributedString(string: "\(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
    
        //timeNode.attributedText = time
        
        if activity.Field == "Account" {
            
            loadAvatar(uid: activity.userUID)
            
            //Create, updateInfo(phone, email, password, general information), login, logout
            if activity.Action == "Create" {
                
                userNameNode.attributedText = NSAttributedString(string: "Your account is created", attributes: textAttributes)
                
            } else if activity.Action == "Update" {
                
                if let info = activity.info {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have updated \(info.lowercased())", attributes: textAttributes)
                    
                }
                             
            } else if activity.Action == "Login" {
                
                if let device = activity.Device {
                    
                    userNameNode.attributedText = NSAttributedString(string: "Your account has been logged in from \(device)", attributes: textAttributes)
                    
                }
                
            } else if activity.Action == "Logout" {
                
                if let device = activity.Device {
                    
                    userNameNode.attributedText = NSAttributedString(string: "Your account has been logged out from \(device)", attributes: textAttributes)
                    
                }
                
                
            }
            
            
        } else if activity.Field == "Challenge" {
             
           //Challenge (Accept, reject, send)
            
            if let uid = activity.toUserUID {
                
               
                
            }
            
  
        } else if activity.Field == "Highlight" {
            
            loadLogo(category: activity.category)
     
            if activity.Action == "Create" {
          
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have created a new \(category) highlight", attributes: textAttributes)
                    
                }
                
                
            } else if activity.Action == "Update" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have updated a \(category) highlight", attributes: textAttributes)
                    
                }
            
            } else if activity.Action == "Delete" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have deleted a \(category) highlight", attributes: textAttributes)
                    
                }
            } else if activity.Action == "Like-post" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have liked a \(category) highlight", attributes: textAttributes)
                    
                }
                
                
            } else if activity.Action == "Like-comment" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have liked a comment from the \(category) highlight", attributes: textAttributes)
                    
                }
                
            }
            
            
        } else if activity.Field == "Follow" {
            
            
            if let uid = activity.toUserUID {
                
                
                
            }
            
            
            
            
        } else if activity.Field == "Comment" {
            
            if let category = activity.category {
                 
                if let id = activity.Cmt_user_uid {
                    
                   
                    
                }
                
                
                
                
            }
            
            
        } else if activity.Field == "Challenge" {
            
            if let uid = activity.toUserUID, let category = activity.category {
                
               
                
            }
            
            
        }
         
        
        
    }
    
    func loadLogo(category: String) {
        
        if category == "Others" {
            
            self.AvatarNode.image = UIImage(named: "more")
            
        } else {
            
           
            
        }
        
        
        
    }
    
    func loadAvatar(uid: String) {
        
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
       
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, timeNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
