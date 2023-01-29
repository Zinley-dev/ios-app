//
//  BlockNode.swift
//  The Stitchbox
//
//  Created by Khoi Nguyen on 5/11/21.
//


import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdUIKit

fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class BlockNode: ASCellNode {
    
    weak var user: BlockUserModel!
    var UnBlockAction : (() -> Void)?
    var FollowAction : (() -> Void)?
    
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var UnBlockBtnNode: ASButtonNode!
    var FollowBtnNode: ASButtonNode!
    
    lazy var delayItem = workItem()
    var desc = ""
    var attemptCount = 0
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with user: BlockUserModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.UnBlockBtnNode = ASButtonNode()
        self.FollowBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        UnBlockBtnNode.backgroundColor = UIColor.tertiary
        FollowBtnNode.backgroundColor = UIColor.primary
        
        
        userNameNode.tintColor = UIColor.white
        NameNode.tintColor = UIColor.white
        AvatarNode.tintColor = UIColor.white
        UnBlockBtnNode.tintColor  = UIColor.primary
        FollowBtnNode.tintColor  = UIColor.white
        
        userNameNode.textColorFollowsTintColor = true
        NameNode.textColorFollowsTintColor = true
        
        //
        
        UnBlockBtnNode.addTarget(self, action: #selector(BlockNode.UnblockBtnPressed), forControlEvents: .touchUpInside)
        FollowBtnNode.addTarget(self, action: #selector(BlockNode.FollowUnfollowBtnPressed), forControlEvents: .touchUpInside)
        
        //
        
        automaticallyManagesSubnodes = true
        
        
        
        DispatchQueue.main.async {
            
            self.UnBlockBtnNode.layer.borderWidth = 1.0
            self.UnBlockBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.UnBlockBtnNode.layer.cornerRadius = 10.0
            self.UnBlockBtnNode.clipsToBounds = true
            
            self.UnBlockBtnNode.setTitle("Unblock", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
            
            self.FollowBtnNode.layer.borderWidth = 1.0
            self.FollowBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.FollowBtnNode.layer.cornerRadius = 10.0
            self.FollowBtnNode.clipsToBounds = true
            self.FollowBtnNode.setTitle("Follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
        }
        
        
        
        desc = "Block"
        loadInfo(uid: user.blockId)
        
        
    }
    
    
    @objc func UnblockBtnPressed() {
        if let action = UnBlockAction {
            action()
        }
    }
    @objc func FollowUnfollowBtnPressed() {
        if let action = FollowAction {
            action()
        }
    }
    
    
    func performCheckAndAdFollow(uid: String) {
        
        
        
        
    }
    
    func addFollow(uid: String, Follower_username: String, Follower_name: String) {
        
        
        
        
    }
    
    
    func unfollow(uid: String) {
        
        
        
    }
    
    
    
    func unblock() {
        
    
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        UnBlockBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        FollowBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack, user.isBlock ? UnBlockBtnNode : FollowBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    func loadInfo(uid: String ) {
        userNameNode.attributedText = NSAttributedString(string: user.blockUser.userName)
        NameNode.attributedText = NSAttributedString(string: user.blockUser.name)
        AvatarNode.url = URL(string: user.blockUser.avatarURL)
    }
    
    
    
    
    
}
