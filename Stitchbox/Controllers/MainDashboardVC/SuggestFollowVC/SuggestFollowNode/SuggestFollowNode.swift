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
    }
    
    var user: FriendSuggestionModel!
    var followAction : ((SuggestFollowNode) -> Void)?
    lazy var delayItem = workItem()
    var attemptCount = 0
    var userNameNode: ASTextNode!
    var nameNode: ASTextNode!
    var avatarNode: ASNetworkImageNode!
    var followBtnNode: ASButtonNode!
    var selectedColor = UIColor(red: 53, green: 46, blue: 113, alpha: 0.4)
    var isFollowingUser = false
    var denyBtn = false
    var allowProcess = true
    
    init(with user: FriendSuggestionModel) {
        self.user = user
        self.userNameNode = ASTextNode()
        self.avatarNode = ASNetworkImageNode()
        self.followBtnNode = ASButtonNode()
        self.nameNode = ASTextNode()

        super.init()

        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        avatarNode.cornerRadius = OrganizerImageSize/2
        avatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        avatarNode.shouldRenderProgressImages = true
        avatarNode.isLayerBacked = true

        userNameNode.backgroundColor = UIColor.clear
        nameNode.backgroundColor = UIColor.clear
        followBtnNode.backgroundColor = .secondary
       

        followBtnNode.addTarget(self, action: #selector(FollowNode.followBtnPressed), forControlEvents: .touchUpInside)

        automaticallyManagesSubnodes = true

        if let user = user.userId {
            if user == _AppCoreData.userDataSource.value?.userID {
                denyBtn = true
            }
        }

        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        self.userNameNode.attributedText = NSAttributedString(string: "@\(user.username ?? "@")" , attributes: [NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles])
        
        
        if user.name != " " {
            
         
            self.nameNode.attributedText = NSAttributedString(string: user.name ?? "None", attributes: [NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        } else {
            
            self.nameNode.attributedText = NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        }
        
        

        if let userAvatar = user.avatar, userAvatar != "" {
            avatarNode.url = URL(string: userAvatar)
        } else {
            avatarNode.image = UIImage.init(named: "defaultuser")
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        self.checkIfFollow()
        
    }

    
    func checkIfFollow() {
        
        if let userId = user.userId {
            
            APIManager.shared.isFollowing(uid: userId) { [weak self] result in
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
                        
                        DispatchQueue.main.async {
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
        
        if let userId = user.userId {
            
            DispatchQueue.main.async {
                self.isFollowingUser = true
                self.followBtnNode.backgroundColor = .normalButtonBackground
                self.followBtnNode.layer.cornerRadius = 10.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Following", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.black, for: .normal)

            }
            
          
            
            APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
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
        
        if let userId = user.userId {
            
            DispatchQueue.main.async {
                
                self.followBtnNode.backgroundColor = .secondary
                self.followBtnNode.layer.cornerRadius = 10.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("+ Follow", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.white, for: .normal)

            }
         
            
            APIManager.shared.unFollow(params: ["FollowId":userId]) { [weak self] result in
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
