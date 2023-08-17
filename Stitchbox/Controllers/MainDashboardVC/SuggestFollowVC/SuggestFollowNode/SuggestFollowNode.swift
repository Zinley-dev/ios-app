//
//  SuggestFollowNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class SuggestFollowNode: ASCellNode {
    
    deinit {
        print("SuggestFollowNode is being deallocated.")
        
        userNameNode.attributedText = nil
        nameNode.attributedText = nil
        avatarNode.url = nil
    }
    
    private weak var user: FriendSuggestionModel!

    let userNameNode = ASTextNode()
    let nameNode = ASTextNode()
  
    let avatarNode = ASNetworkImageNode()
    let followBtnNode = ASButtonNode()

    var isFollowingUser = false
    var denyBtn = false
    var allowProcess = true
    
    let font = FontManager.shared.roboto(.Medium, size: FontSize + 1)
    let textColor = UIColor.black
    
    init(with users: FriendSuggestionModel) {
        user = users
    
        super.init()

        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        avatarNode.cornerRadius = OrganizerImageSize/2
        avatarNode.clipsToBounds = true
        nameNode.isLayerBacked = true
        userNameNode.isLayerBacked = true
        avatarNode.shouldRenderProgressImages = true
        avatarNode.isLayerBacked = true
        userNameNode.backgroundColor = UIColor.clear
        nameNode.backgroundColor = UIColor.clear
        followBtnNode.backgroundColor = .secondary
       

        followBtnNode.addTarget(self, action: #selector(FollowNode.followBtnPressed), forControlEvents: .touchUpInside)
        
        
        if user.avatar != "" {
            avatarNode.url = URL(string: user.avatar)
        } else {
            avatarNode.image = UIImage.init(named: "defaultuser")
        }
        
        let commonAttributes = textAttributes(withFont: font)
    
        if user.username != "" {
            userNameNode.attributedText = NSAttributedString.init(attributedString: NSAttributedString(string: user.username, attributes: commonAttributes))
        }
        
        if user.name != "" {
            nameNode.attributedText = NSAttributedString.init(attributedString: NSAttributedString(string: user.name, attributes: commonAttributes))
        } else {
            nameNode.attributedText = NSAttributedString.init(attributedString: NSAttributedString(string: "None", attributes: commonAttributes))
        }
        
      
        automaticallyManagesSubnodes = true

    }
    
    
    func textAttributes(withFont font: UIFont) -> [NSAttributedString.Key: Any] {
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyles
        ]
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        if user.userId == _AppCoreData.userDataSource.value?.userID {
            denyBtn = true
        }

        self.checkIfFollow()
        
        
    }

    
    func checkIfFollow() {
        
        if user.userId != "" {
            
            APIManager.shared.isFollowing(uid: user.userId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                        return
                    }
                    
                    if isFollowing {
                        
                        DispatchQueue.main.async { [weak self]  in
                            guard let self = self else { return }
                            self.isFollowingUser = true
                            self.followBtnNode.backgroundColor = .normalButtonBackground
                            self.followBtnNode.layer.cornerRadius = 10.0
                            self.followBtnNode.clipsToBounds = true
                            self.followBtnNode.setTitle("Following", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.black, for: .normal)

                        }
                        
                    } else {
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.isFollowingUser = false
                            self.followBtnNode.backgroundColor = .secondary
                            self.followBtnNode.layer.cornerRadius = 10.0
                            self.followBtnNode.clipsToBounds = true
                            self.followBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

                        }
                        
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    self.followBtnNode.isHidden = true
                    
                }
            }
            
        }
        
    }
    
    
    @objc func followBtnPressed() {
        
        if !denyBtn, allowProcess {
            self.allowProcess = false
            if isFollowingUser {
                
                unfollowUser()
                
            } else {
                
                followUser()
            }
            
        }
        
        
        
    }
    
    func followUser() {
        
        if  user.userId != "" {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isFollowingUser = true
                self.followBtnNode.backgroundColor = .normalButtonBackground
                self.followBtnNode.layer.cornerRadius = 10.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Following", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.black, for: .normal)

            }
            
          
            
            APIManager.shared.insertFollows(params: ["FollowId": user.userId]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    
                    
                    self.isFollowingUser = true
                    needRecount = true
                    self.allowProcess = true
                    
                    
                case .failure(_):
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.allowProcess = true
                        showNote(text: "Something happened!")
                    }
                    
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.isFollowingUser = false
                        self.followBtnNode.backgroundColor = .secondary
                        self.followBtnNode.layer.cornerRadius = 10.0
                        self.followBtnNode.clipsToBounds = true
                        self.followBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

                      
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    
    func unfollowUser() {
        
        if user.userId != "" {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.followBtnNode.backgroundColor = .secondary
                self.followBtnNode.layer.cornerRadius = 10.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

            }
         
            
            APIManager.shared.unFollow(params: ["FollowId": user.userId]) { [weak self] result in
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
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.followBtnNode.backgroundColor = .normalButtonBackground
                        self.followBtnNode.layer.cornerRadius = 10.0
                        self.followBtnNode.clipsToBounds = true
                        self.followBtnNode.setTitle("Following", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.black, for: .normal)

                       
                    }
                    
                    
                    
                }
            }
            
        }
        
        
    }
    
   
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        avatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        followBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        headerSubStack.children = [userNameNode, nameNode]
        
        
        let headerStack = ASStackLayoutSpec.horizontal()
        
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [avatarNode, headerSubStack, followBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
        
    }
    
    
}
