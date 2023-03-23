//
//  FollowNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/24/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class FollowNode: ASCellNode {
    
    weak var user: FollowModel!
    var followAction : ((FollowNode) -> Void)?
    lazy var delayItem = workItem()
    var attemptCount = 0
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var followBtnNode: ASButtonNode!
    var selectedColor = UIColor(red: 53, green: 46, blue: 113, alpha: 0.4)
    var isFollowingUser = false
    
    init(with user: FollowModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.followBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true

   
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        followBtnNode.backgroundColor = user.action == "following" ? UIColor.primary : UIColor.white
        followBtnNode.tintColor  = UIColor.primary

          //
        
        followBtnNode.addTarget(self, action: #selector(FollowNode.followBtnPressed), forControlEvents: .touchUpInside)
        
        //
        automaticallyManagesSubnodes = true
        
  
        if user.needCheck == false, user.action == "following" {
            
            self.isFollowingUser = true
            DispatchQueue.main.async {
                self.followBtnNode.layer.borderWidth = 1.0
                self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.followBtnNode.layer.cornerRadius = 10.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
            }
            
       
        } else {
            
            checkIfFollow()
            
        }
        

        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        self.userNameNode.attributedText = NSAttributedString(string: user.username ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

        
        AvatarNode.url = URL(string: user.avatar ?? "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg")
    
        
        
    }
    
    func checkIfFollow() {
        
        if let userId = user.userId {
            
                APIManager().isFollowing(uid: userId) { result in
                    switch result {
                    case .success(let apiResponse):
                        
                        guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                            return
                        }
                        
                        if isFollowing {
                            
                            DispatchQueue.main.async {
                                self.isFollowingUser = true
                                self.followBtnNode.backgroundColor = .primary
                                self.followBtnNode.layer.borderWidth = 1.0
                                self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                                self.followBtnNode.layer.cornerRadius = 10.0
                                self.followBtnNode.clipsToBounds = true
                                self.followBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                            }
                            
                        } else {
                            
                            if self.user.loadFromUserId == _AppCoreData.userDataSource.value?.userID, self.user.loadFromMode == "follower" {
                                
                                DispatchQueue.main.async {
                                    self.isFollowingUser = false
                                    self.followBtnNode.backgroundColor = .white
                                    self.followBtnNode.layer.borderWidth = 1.0
                                    self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                                    self.followBtnNode.layer.cornerRadius = 10.0
                                    self.followBtnNode.clipsToBounds = true
                                    self.followBtnNode.setTitle("+ follow back", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                                }
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    self.isFollowingUser = false
                                    self.followBtnNode.backgroundColor = .white
                                    self.followBtnNode.layer.borderWidth = 1.0
                                    self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                                    self.followBtnNode.layer.cornerRadius = 10.0
                                    self.followBtnNode.clipsToBounds = true
                                    self.followBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                                }
                                
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
        
        if isFollowingUser {
            
            unfollowUser()
            
        } else {
            
            followUser()
        }
        
    }
    
    func followUser() {
        
        if let userId = user.userId {
            
            DispatchQueue.main.async {
                self.isFollowingUser = true
                self.followBtnNode.backgroundColor = .primary
                self.followBtnNode.layer.borderWidth = 1.0
                self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.followBtnNode.layer.cornerRadius = 10.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
            }
            
            updateTotal(isIncreased: true)
            
            APIManager().insertFollows(params: ["FollowId": userId]) { result in
                switch result {
                case .success(_):
                  
                    
                    self.isFollowingUser = true
                    needRecount = true
                    
                    
                case .failure(_):
                    
                    DispatchQueue.main.async {
                        showNote(text: "Something happened!")
                    }
                    
                    
                    if self.user.loadFromUserId == _AppCoreData.userDataSource.value?.userID, self.user.loadFromMode == "follower" {
                        
                        DispatchQueue.main.async {
                            self.isFollowingUser = false
                            self.followBtnNode.backgroundColor = .white
                            self.followBtnNode.layer.borderWidth = 1.0
                            self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                            self.followBtnNode.layer.cornerRadius = 10.0
                            self.followBtnNode.clipsToBounds = true
                            self.followBtnNode.setTitle("+ follow back", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                            self.updateTotal(isIncreased: false)
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            self.isFollowingUser = false
                            self.followBtnNode.backgroundColor = .white
                            self.followBtnNode.layer.borderWidth = 1.0
                            self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                            self.followBtnNode.layer.cornerRadius = 10.0
                            self.followBtnNode.clipsToBounds = true
                            self.followBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                            self.updateTotal(isIncreased: false)
                        }
                        
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    
    func unfollowUser() {
        
        if let userId = user.userId {
            
            if self.user.loadFromUserId == _AppCoreData.userDataSource.value?.userID, self.user.loadFromMode == "follower" {
                
                DispatchQueue.main.async {
                   
                    self.followBtnNode.backgroundColor = .white
                    self.followBtnNode.layer.borderWidth = 1.0
                    self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.followBtnNode.layer.cornerRadius = 10.0
                    self.followBtnNode.clipsToBounds = true
                    self.followBtnNode.setTitle("+ follow back", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                  
                    self.followBtnNode.backgroundColor = .white
                    self.followBtnNode.layer.borderWidth = 1.0
                    self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.followBtnNode.layer.cornerRadius = 10.0
                    self.followBtnNode.clipsToBounds = true
                    self.followBtnNode.setTitle("+ follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.primary, for: .normal)
                    
                }
                
            }
            
            updateTotal(isIncreased: false)
            
            APIManager().unFollow(params: ["FollowId":userId]) { result in
                switch result {
                case .success(_):
                    self.isFollowingUser = false
                    needRecount = true
                    
                case .failure(_):
                    DispatchQueue.main.async {
                        showNote(text: "Something happened!")
                    }
                    
                    DispatchQueue.main.async {
                        self.followBtnNode.backgroundColor = .primary
                        self.followBtnNode.layer.borderWidth = 1.0
                        self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                        self.followBtnNode.layer.cornerRadius = 10.0
                        self.followBtnNode.clipsToBounds = true
                        self.followBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                        self.updateTotal(isIncreased: true)
                    }
                    
                    
                    
                }
            }
            
        }
        
        
    }
    
    func updateTotal(isIncreased: Bool) {
        if self.user.loadFromUserId == _AppCoreData.userDataSource.value?.userID {
            if let vc = UIViewController.currentViewController() {
                if vc is MainFollowVC {
                    if let update1 = vc as? MainFollowVC {
                        update1.followingCount += isIncreased ? 1 : -1
                        update1.followingBtn.setTitle("\(formatPoints(num: Double(update1.followingCount))) Followings", for: .normal)
                    }
                }
            }
        }
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        followBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
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
