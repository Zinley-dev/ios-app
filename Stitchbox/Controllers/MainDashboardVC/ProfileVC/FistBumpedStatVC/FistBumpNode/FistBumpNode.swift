//
//  FistBumpNode.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//


import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdUIKit

fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class FistBumpNode: ASCellNode {
    
    weak var user: FistBumpUserModel!
    var UnFistBumpAction : (() -> Void)?
    var FollowAction : (() -> Void)?
    var UnfollowAction : (() -> Void)?
    
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var UnFistBumpBtnNode: ASButtonNode!
    var FollowBtnNode: ASButtonNode!
    var UnfollowBtnNode: ASButtonNode!
    
    lazy var delayItem = workItem()
    var desc = ""
    var attemptCount = 0
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with user: FistBumpUserModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.UnFistBumpBtnNode = ASButtonNode()
        self.FollowBtnNode = ASButtonNode()
        self.UnfollowBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        UnFistBumpBtnNode.backgroundColor = UIColor.tertiary
        FollowBtnNode.backgroundColor = UIColor.tertiary
        UnfollowBtnNode.backgroundColor = UIColor.primary
        
        
        userNameNode.tintColor = UIColor.white
        NameNode.tintColor = UIColor.white
        AvatarNode.tintColor = UIColor.white
        
        userNameNode.textColorFollowsTintColor = true
        NameNode.textColorFollowsTintColor = true
        
        //
        
        UnFistBumpBtnNode.addTarget(self, action: #selector(FistBumpNode.UnFistBumpBtnPressed), forControlEvents: .touchUpInside)
        FollowBtnNode.addTarget(self, action: #selector(FistBumpNode.FollowBtnPressed), forControlEvents: .touchUpInside)
        UnfollowBtnNode.addTarget(self, action: #selector(FistBumpNode.UnfollowBtnPressed), forControlEvents: .touchUpInside)
        
        //
        
        automaticallyManagesSubnodes = true
        
        DispatchQueue.main.async {
            
            self.UnFistBumpBtnNode.layer.borderWidth = 1.0
            self.UnFistBumpBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.UnFistBumpBtnNode.layer.cornerRadius = 10.0
            self.UnFistBumpBtnNode.clipsToBounds = true
            
            self.UnFistBumpBtnNode.setTitle("UnFistBump", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
            
            self.FollowBtnNode.layer.borderWidth = 1.0
            self.FollowBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.FollowBtnNode.layer.cornerRadius = 10.0
            self.FollowBtnNode.clipsToBounds = true
            self.FollowBtnNode.setTitle("+ Follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
            
            self.UnfollowBtnNode.layer.borderWidth = 1.0
            self.UnfollowBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.UnfollowBtnNode.layer.cornerRadius = 10.0
            self.UnfollowBtnNode.clipsToBounds = true
            self.UnfollowBtnNode.setTitle("Following", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
        }
        
        desc = "FistBump"
        loadInfo(uid: user.userID)
        
    }
    
    
    @objc func UnFistBumpBtnPressed() {
        if let action = UnFistBumpAction {
            action()
        }
    }
    
    @objc func FollowBtnPressed() {
        if let action = FollowAction {
            action()
        }
    }
    
    @objc func UnfollowBtnPressed() {
        if let action = UnfollowAction {
            action()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        UnFistBumpBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        FollowBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        UnfollowBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack, user.isFollowing ? UnfollowBtnNode : FollowBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    func loadInfo(uid: String) {
        userNameNode.attributedText = NSAttributedString(string: user.userName)
        AvatarNode.url = URL(string: user.avatar)
        
    }
    
}
