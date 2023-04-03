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
    var nameNode: ASTextNode!
    var avatarNode: ASNetworkImageNode!
    var actionBtnNode: ASButtonNode!
    var isFollowingUser = false
    var allowProcess = true
    
    
    lazy var delayItem = workItem()
   
    init(with user: FistBumpUserModel) {
        
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
        
        userNameNode.backgroundColor = UIColor.clear
        nameNode.backgroundColor = UIColor.clear
        
        
        
        userNameNode.tintColor = UIColor.white
        nameNode.tintColor = UIColor.white
        avatarNode.tintColor = UIColor.white
        
        userNameNode.textColorFollowsTintColor = true
        nameNode.textColorFollowsTintColor = true
        
        //
        
        actionBtnNode.addTarget(self, action: #selector(FistBumpNode.actionBtnPressed), forControlEvents: .touchUpInside)
        
        
        //
        
        automaticallyManagesSubnodes = true

     
        loadInfo(uid: user.userID)
        
        if user.isFollowing {
            
            DispatchQueue.main.async {
                self.isFollowingUser = true
                self.actionBtnNode.backgroundColor = .primary
                self.actionBtnNode.layer.borderWidth = 1.0
                self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.actionBtnNode.layer.cornerRadius = 10.0
                self.actionBtnNode.clipsToBounds = true
                self.actionBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.isFollowingUser = false
                self.actionBtnNode.backgroundColor = .white
                self.actionBtnNode.layer.borderWidth = 1.0
                self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.actionBtnNode.layer.cornerRadius = 10.0
                self.actionBtnNode.clipsToBounds = true
                self.actionBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
            }
            
        }
        
    }
    
    
    func checkIfFollow() {
        
        
         APIManager().isFollowing(uid: user.userID) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                        return
                    }
                    
                    if isFollowing {
                        
                        DispatchQueue.main.async {
                            self.isFollowingUser = true
                            self.actionBtnNode.backgroundColor = .primary
                            self.actionBtnNode.layer.borderWidth = 1.0
                            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                            self.actionBtnNode.layer.cornerRadius = 10.0
                            self.actionBtnNode.clipsToBounds = true
                            self.actionBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            self.isFollowingUser = false
                            self.actionBtnNode.backgroundColor = .white
                            self.actionBtnNode.layer.borderWidth = 1.0
                            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                            self.actionBtnNode.layer.cornerRadius = 10.0
                            self.actionBtnNode.clipsToBounds = true
                            self.actionBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                        }
                        
                        
                    }
                   
                case .failure(let error):
                    print(error)
                    self.actionBtnNode.isHidden = true
                  
            }
        }
        
       
        
        
    }
    
    
    @objc func actionBtnPressed() {
       
        if allowProcess {
            
            allowProcess = false
            
            if isFollowingUser {
                
                unfollowUser()
                
            } else {
                
                followUser()
            }
            
        }
        
        
        
        
    }
    
    func followUser() {
        
        DispatchQueue.main.async {
            self.isFollowingUser = true
            self.actionBtnNode.backgroundColor = .primary
            self.actionBtnNode.layer.borderWidth = 1.0
            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.actionBtnNode.layer.cornerRadius = 10.0
            self.actionBtnNode.clipsToBounds = true
            self.actionBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
        }

        
        APIManager().insertFollows(params: ["FollowId": user.userID]) { result in
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
                    self.actionBtnNode.backgroundColor = .white
                    self.actionBtnNode.layer.borderWidth = 1.0
                    self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.actionBtnNode.layer.cornerRadius = 10.0
                    self.actionBtnNode.clipsToBounds = true
                    self.actionBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                   
                }
            }
            
        }
        
        
        
    }
    
    func unfollowUser() {
        
        DispatchQueue.main.async {
          
            self.actionBtnNode.backgroundColor = .white
            self.actionBtnNode.layer.borderWidth = 1.0
            self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.actionBtnNode.layer.cornerRadius = 10.0
            self.actionBtnNode.clipsToBounds = true
            self.actionBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
            
        }
        
        APIManager().unFollow(params: ["FollowId": user.userID]) { result in
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
                    self.actionBtnNode.backgroundColor = .primary
                    self.actionBtnNode.layer.borderWidth = 1.0
                    self.actionBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.actionBtnNode.layer.cornerRadius = 10.0
                    self.actionBtnNode.clipsToBounds = true
                    self.actionBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                  
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
    
    func loadInfo(uid: String) {
        userNameNode.attributedText = NSAttributedString(string: user.userName)
        nameNode.attributedText = NSAttributedString(string: user.name ?? "")
        
        if user.avatar != "" {
            avatarNode.url = URL(string: user.avatar)
        } else {
            avatarNode.image = UIImage.init(named: "defaultuser")
        }
       
    }
    
}
