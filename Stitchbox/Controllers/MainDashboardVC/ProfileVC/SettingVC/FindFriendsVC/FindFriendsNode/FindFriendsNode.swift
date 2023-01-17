//
//  FindFriendsNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire
import Messages
import MessageUI


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class FindFriendsNode: ASCellNode {
    
    weak var user: FindFriendsModel!
    var followAction : ((ASCellNode) -> Void)?
    lazy var delayItem = workItem()
    var attemptCount = 0
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var followBtnNode: ASButtonNode!
   
    var desc = ""
    
    
    init(with user: FindFriendsModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.followBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true

        //self.backgroundColor = UIColor.red
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        followBtnNode.backgroundColor = UIColor.clear
        
          //
        
        followBtnNode.addTarget(self, action: #selector(FindFriendsNode.followBtnPressed), forControlEvents: .touchUpInside)
        
       //
        
        automaticallyManagesSubnodes = true
        
        if user._userUID != nil {
            
            if user._avatarURL != nil {
                
                AvatarNode.url = URL.init(string: user._avatarURL)
                
            }
            
            if user._username != nil {
                
                if let username = user._username {
                    
                    self.userNameNode.attributedText = NSAttributedString(string: "@\(username)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                    
                }
              
            }
            
            /*
            if user._userUID != Auth.auth().currentUser?.uid {
                
                if !global_block_list.contains(user._userUID) {
                    
                    checkIfFollowing(uid: user._userUID)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                        self.followBtnNode.backgroundColor = UIColor.clear
                        self.followBtnNode.layer.borderWidth = 1.0
                        self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                        self.followBtnNode.layer.cornerRadius = 3.0
                        self.followBtnNode.clipsToBounds = true
                        self.followBtnNode.setTitle("Blocked", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.white, for: .normal)
                        
                    }
                    
                }
                
              
                
            } else {
                
                
                DispatchQueue.main.async {
                    
                    self.followBtnNode.backgroundColor = UIColor.clear
                    self.followBtnNode.layer.borderWidth = 1.0
                    self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.followBtnNode.layer.cornerRadius = 3.0
                    self.followBtnNode.clipsToBounds = true
                    self.followBtnNode.setTitle("You", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.white, for: .normal)
                    
                }
                
                
            } */
            
    
        } else {
            
            AvatarNode.url = nil
            
            if user.imageData != nil {
               
                AvatarNode.image = UIImage(data: user.imageData)
                
            } else {
                
                AvatarNode.image = UIImage(named: "defaultuser")
                
            }
            
            DispatchQueue.main.async {
                
                self.followBtnNode.backgroundColor = .tertiary
                self.followBtnNode.layer.borderWidth = 0.0
                self.followBtnNode.layer.borderColor = UIColor.clear.cgColor
                self.followBtnNode.layer.cornerRadius = 5.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Invite", with: UIFont.boldSystemFont(ofSize: FontSize), with: .primary, for: .normal)
                
            }
        
            
            self.userNameNode.attributedText = NSAttributedString(string: "@None", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        }
        
        if user.firstName != "" || user.familyName != "" {
            
            var firstName = ""
            var familyName = ""
            
            if user.firstName != "" {
                firstName = user.firstName
            }
            
            if user.familyName != "" {
                familyName = user.familyName
            }
            
        
            self.NameNode.attributedText = NSAttributedString(string: "\(firstName) \(familyName)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        } else {
            
            self.NameNode.attributedText = NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        }
         
        
        
    }
    
    
    
    func checkIfUserDidFollowMe(uid: String) {
        
        
        
    }
    
    func checkIfFollowing(uid: String) {
        
        
        
    }
    
  
    @objc func followBtnPressed() {
        
        
        
    }
    
    
    
    func performCheckAndAdFollow(uid: String) {
        
     
        
    }
    
    func addFollow(uid: String, Follower_username: String, Follower_name: String) {
        
        
        
    }
    
    
    func unfollow(uid: String) {
        
        
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        followBtnNode.style.preferredSize = CGSize(width: 100.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [AvatarNode, headerSubStack, followBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
}
