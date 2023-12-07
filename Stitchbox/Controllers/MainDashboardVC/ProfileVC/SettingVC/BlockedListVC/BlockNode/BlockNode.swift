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
    
    deinit {
        print("BlockNode is being deallocated.")
    }
    
    var user: BlockUserModel!
    
    var userNameNode: ASTextNode!
    var nameNode: ASTextNode!
    var avatarNode: ASNetworkImageNode!
    var actionBtnNode: ASButtonNode!
    var allowProcess = true
    
    
    lazy var delayItem = workItem()
    
    var isBlock = true
    var isFollowingUser = false
    
    init(with user: BlockUserModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.avatarNode = ASNetworkImageNode()
        self.actionBtnNode = ASButtonNode()
        self.nameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        avatarNode.cornerRadius = OrganizerImageSize/2
        avatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        avatarNode.isLayerBacked = true
        nameNode.isLayerBacked = true
        
        userNameNode.backgroundColor = UIColor.clear
        nameNode.backgroundColor = UIColor.clear
        
        
        
        userNameNode.tintColor = UIColor.white
        nameNode.tintColor = UIColor.white
        avatarNode.tintColor = UIColor.white
        
        userNameNode.textColorFollowsTintColor = true
        nameNode.textColorFollowsTintColor = true
        
        //
        
        actionBtnNode.addTarget(self, action: #selector(BlockNode.actionBtnPressed), forControlEvents: .touchUpInside)
        
        
        //
        
        automaticallyManagesSubnodes = true
        

    }
    
    override func didLoad() {
        super.didLoad()
        setupLayout()
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        loadInfo(uid: user.blockId)
    }
    
    override func didExitDisplayState() {
        super.didExitDisplayState()
        cleanupInfo()
    }
    
    func setupLayout() {
        if isBlock {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.actionBtnNode.backgroundColor = .secondary
                self.actionBtnNode.layer.borderWidth = 1.0
                self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.actionBtnNode.layer.cornerRadius = 10.0
                self.actionBtnNode.clipsToBounds = true
                self.actionBtnNode.setTitle("Unblock", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)
               
            }
            
        }
        
    }

    
    @objc func actionBtnPressed() {
        
        if allowProcess {
            self.allowProcess = false
            if isBlock {
                
                unblock()
                
            } else {
                
                if isFollowingUser {
                    
                    unfollowUser()
                    
                } else {
                    
                    followUser()
                }
                
                
            }
            
        }
        
    }
    
    func unblock() {
        
        DispatchQueue.main.async {
            self.isFollowingUser = false
            self.actionBtnNode.backgroundColor = .secondary
            self.actionBtnNode.layer.borderWidth = 1.0
            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.actionBtnNode.layer.cornerRadius = 10.0
            self.actionBtnNode.clipsToBounds = true
            self.actionBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)
        
        }
        
        APIManager.shared.deleteBlocks(params: ["blockId": user.blockId]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                
                self.isBlock = false
                self.allowProcess = true
                
            case .failure(_):
                
                DispatchQueue.main.async {
                    self.allowProcess = true
                    showNote(text: "Something happened!")
                }
                
                
                DispatchQueue.main.async {
                    self.isBlock = true
                    self.actionBtnNode.backgroundColor = .secondary
                    self.actionBtnNode.layer.borderWidth = 1.0
                    self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.actionBtnNode.layer.cornerRadius = 10.0
                    self.actionBtnNode.clipsToBounds = true
                    self.actionBtnNode.setTitle("Unblock", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

                }
            }
            
        }
        
        
    }
    
    
    func followUser() {
        
        DispatchQueue.main.async {
            self.isFollowingUser = true
            self.actionBtnNode.backgroundColor = .normalButtonBackground
            self.actionBtnNode.layer.borderWidth = 1.0
            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.actionBtnNode.layer.cornerRadius = 10.0
            self.actionBtnNode.clipsToBounds = true
            self.actionBtnNode.setTitle("Following", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.black, for: .normal)

        }
        
        
        APIManager.shared.insertFollows(params: ["FollowId": user.blockId]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                
                
                self.isFollowingUser = true
                needRecount = true
                self.allowProcess = true
                
                
            case .failure(_):
                
                DispatchQueue.main.async {
                    self.allowProcess = true
                    showNote(text: "Something happened!")
                }
                
                
                DispatchQueue.main.async {
                    self.isFollowingUser = false
                    self.actionBtnNode.backgroundColor = .secondary
                    self.actionBtnNode.layer.borderWidth = 1.0
                    self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.actionBtnNode.layer.cornerRadius = 10.0
                    self.actionBtnNode.clipsToBounds = true
                    self.actionBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

                    
                }
            }
            
        }
        
        
        
    }
    
    
    func unfollowUser() {
        
        DispatchQueue.main.async {
            
            self.actionBtnNode.backgroundColor = .secondary
            self.actionBtnNode.layer.borderWidth = 1.0
            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.actionBtnNode.layer.cornerRadius = 10.0
            self.actionBtnNode.clipsToBounds = true
            self.actionBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

            
        }
        
        APIManager.shared.unFollow(params: ["FollowId": user.blockId]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.isFollowingUser = false
                needRecount = true
                self.allowProcess = true
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.allowProcess = true
                    showNote(text: "Something happened!")
                }
                
                DispatchQueue.main.async {
                    self.actionBtnNode.backgroundColor = .normalButtonBackground
                    self.actionBtnNode.layer.borderWidth = 1.0
                    self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.actionBtnNode.layer.cornerRadius = 10.0
                    self.actionBtnNode.clipsToBounds = true
                    self.actionBtnNode.setTitle("Following", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.black, for: .normal)


                    
                }
                
            }
        }
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        avatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        actionBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, nameNode]
        
        
        let headerStack = ASStackLayoutSpec.horizontal()
        
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [avatarNode, headerSubStack, actionBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
        
    }
    
    func loadInfo(uid: String ) {
        userNameNode.attributedText = NSAttributedString(string: "@\(user.blockUser.userName)")
        nameNode.attributedText = NSAttributedString(string: user.blockUser.name)
        
        if user.blockUser.avatarURL != "" {
            avatarNode.url = URL(string: user.blockUser.avatarURL)
        } else {
            avatarNode.image = UIImage.init(named: "defaultuser")
        }
        
    }
    
    /// Cleans up the nodes by resetting their states to defaults.
    func cleanupInfo() {
        // Reset the text of userNameNode and nameNode to empty or default values.
        userNameNode.attributedText = nil
        nameNode.attributedText = nil

        // Reset the avatarNode's image to a default image or nil.
        avatarNode.image = nil // or UIImage(named: "defaultAvatar") if you have a default avatar image.
        avatarNode.url = nil
    }

    
}
