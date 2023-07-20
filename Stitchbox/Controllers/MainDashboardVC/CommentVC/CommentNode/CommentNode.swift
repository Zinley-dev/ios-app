//
//  CommentNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/22/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire
import ActiveLabel


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10


class CommentNode: ASCellNode {
    
    var replyUsername = ""
    var finalText: NSAttributedString!
    var replyUID = ""
    var post: CommentModel!
    var count = 0
    var userNameNode: ASTextNode!
    var cmtNode: ASTextNode!
    var replyToNode: ASTextNode!
    var timeNode: ASTextNode!
    var imageView: ASImageNode!
    var avatarNode: ASNetworkImageNode!
    var textNode: ASTextNode!
    var loadReplyBtnNode: ASButtonNode!
    var replyBtnNode: ASButtonNode!
    var infoNode: ASDisplayNode!
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    var replyBtn : ((ASCellNode) -> Void)?
    var reply : ((ASCellNode) -> Void)?
    var isLiked = false
   
    
    var like : ((ASCellNode) -> Void)?
    
    init(with post: CommentModel) {
        
        self.post = post
        self.userNameNode = ASTextNode()
        self.cmtNode = ASTextNode()
        self.avatarNode = ASNetworkImageNode()
        self.loadReplyBtnNode = ASButtonNode()
        self.infoNode = ASDisplayNode()
        self.imageView = ASImageNode()
        self.textNode = ASTextNode()
        self.timeNode = ASTextNode()
        self.replyBtnNode = ASButtonNode()
        self.replyToNode = ASTextNode()
        
        super.init()
        
        self.replyBtnNode.setTitle("Reply", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.darkGray, for: .normal)

        self.replyBtnNode.addTarget(self, action: #selector(CommentNode.replyBtnPressed), forControlEvents: .touchUpInside)
        self.selectionStyle = .none
        avatarNode.contentMode = .scaleAspectFill
        avatarNode.cornerRadius = OrganizerImageSize/2
        avatarNode.clipsToBounds = true
        cmtNode.truncationMode = .byTruncatingTail
       
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        avatarNode.shouldRenderProgressImages = true
        
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Light style
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]

        let timeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Light style
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]

        
        
        if self.post.reply_to != "" {
           
            if let username = self.post.reply_to_username {
                                
               let username = "\(username)"
                self.replyUsername = username
               
                if self.post.createdAt != nil {
                    
                    let user = NSMutableAttributedString()
              
                    let username = NSAttributedString(string: "\(username): ", attributes: textAttributes)
                    let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
                    var time: NSAttributedString?
                    
                    
                    
                    
                    if self.post.is_title == true {
                    
                        if self.post.updatedAt != Date() {
                            
                            time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.updatedAt, numericDates: true))", attributes: timeAttributes)
                            
                        } else {
                            
                            time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                            
                        }
                        
                    } else {
                        
                        time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                    }
                      
                    user.append(username)
                    user.append(text)
                    
                    
                    
                    self.timeNode.attributedText = time
                    self.cmtNode.attributedText = user
                    
                    
                }  else {
                                               
                    
                    let user = NSMutableAttributedString()
              
                    let username = NSAttributedString(string: "\(username): ", attributes: textAttributes)
                    
                    let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
                   
                    let time = NSAttributedString(string: "Just now", attributes: timeAttributes)
                    
                    user.append(username)
                    user.append(text)
                    
                    
                    self.timeNode.attributedText = time
                    self.cmtNode.attributedText = user
                   
                    
                }
                
                                  
                
            }
           
          
        } else {
            
            
            if self.post.createdAt != nil {
                
            
                let user = NSMutableAttributedString()
                
                let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
              
                var time: NSAttributedString?
                
                if self.post.is_title == true {
                    
                    if self.post.updatedAt != Date() {
                        
                        time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.updatedAt, numericDates: true))", attributes: timeAttributes)
                        
                    } else {
                        
                        time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                        
                    }
                    
                } else {
                    
                    time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                    
                }
                
               
                
                user.append(text)
                
                
                DispatchQueue.main.async { [self] in
                    timeNode.attributedText = time
                    cmtNode.attributedText = user
                }
                
                
            } else {
                
                
                let user = NSMutableAttributedString()
             
                let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
               
                let time = NSAttributedString(string: "Just now", attributes: timeAttributes)
                
                user.append(text)
                
                DispatchQueue.main.async { [self] in
                    timeNode.attributedText = time
                    cmtNode.attributedText = user
                }
               
            }
            
        }
        
        DispatchQueue.main.async {
            self.view.backgroundColor = .white
        }
       
        infoNode.backgroundColor = UIColor.clear
        
        loadReplyBtnNode.backgroundColor = UIColor.clear
        cmtNode.backgroundColor = UIColor.clear
        replyToNode.backgroundColor = UIColor.clear
        userNameNode.backgroundColor = UIColor.clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 2, y: 2, width: 25, height: 25)
    
    
        textNode.isLayerBacked = true
    
        textNode.backgroundColor = UIColor.clear
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
                                                     
        textNode.frame = CGRect(x: 0, y: 30, width: 30, height: 20)
       
        let button = ASButtonNode()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 60)
        button.backgroundColor = UIColor.clear
        
        
        infoNode.addSubnode(imageView)
        infoNode.addSubnode(textNode)
        infoNode.addSubnode(button)
   
        button.addTarget(self, action: #selector(CommentNode.LikedBtnPressed), forControlEvents: .touchUpInside)
        loadReplyBtnNode.addTarget(self, action: #selector(CommentNode.repliedBtnPressed), forControlEvents: .touchUpInside)
        
        
        loadInfo(uid: self.post.comment_uid)
        
        
        if self.post.has_reply == true {
            
            loadCmtCount()
            
        }
        
        
        checkLikeCmt()
        cmtCount()
        
        //
        
        
        automaticallyManagesSubnodes = true
        
        // add Button
        
        //userNameNode
        userNameNode.addTarget(self, action: #selector(CommentNode.usernameBtnPressed), forControlEvents: .touchUpInside)
        avatarNode.addTarget(self, action: #selector(CommentNode.usernameBtnPressed), forControlEvents: .touchUpInside)
          
    }
    
    @objc func replyToBtnPressed() {
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != post.reply_to {
            
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                
                if let vc = UIViewController.currentViewController() {
                    
                    let nav = UINavigationController(rootViewController: UPVC)

                    // Set the user ID, nickname, and onPresent properties of UPVC
                    UPVC.userId = post.reply_to
                    UPVC.nickname = post.reply_to_username
                    UPVC.onPresent = true

                    // Customize the navigation bar appearance
                    nav.navigationBar.barTintColor = .white
                    nav.navigationBar.tintColor = .black
                    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                    nav.modalPresentationStyle = .fullScreen
                    vc.present(nav, animated: true, completion: nil)
           
                }
            }
            
            
        }
        
        
    }
    
    @objc func usernameBtnPressed() {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != post.comment_uid {
            
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                
                if let vc = UIViewController.currentViewController() {
                    
                    let nav = UINavigationController(rootViewController: UPVC)

                    // Set the user ID, nickname, and onPresent properties of UPVC
                    UPVC.userId = post.comment_uid
                    UPVC.nickname = post.comment_username
                    UPVC.onPresent = true

                    // Customize the navigation bar appearance
                    nav.navigationBar.barTintColor = .white
                    nav.navigationBar.tintColor = .black
                    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                    nav.modalPresentationStyle = .fullScreen
                    vc.present(nav, animated: true, completion: nil)
                    
                }
            }
            
        }

        
    }
    
    
    @objc func LikedBtnPressed(sender: AnyObject!) {
  
        if isLiked {
            unlikeComment()
        } else {
            likeComment()
        }

    }
    
    func checkLikeCmt() {
        
        APIManager.shared.islike(comment: post.comment_id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                guard apiResponse.body?["message"] as? String == "success",
                      let checkIsLike = apiResponse.body?["liked"] as? Bool  else {
                        return
                }
                
                self.isLiked = checkIsLike
                
                if checkIsLike {
                    
                    DispatchQueue.main.async {
                        self.imageView.image = likeImage
                    }
                    
                    
                    
                   
            
                } else {
                    
                    DispatchQueue.main.async {
                        self.imageView.image = emptyLikeImageLM
                    }
            
                }
                
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.imageView.image = emptyLikeImageLM
                }
                print(error)
            }
        
        }

    }
    
    
    func cmtCount() {
        
        APIManager.shared.countLike(comment: post.comment_id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
    
                print(apiResponse)
                
                guard apiResponse.body?["message"] as? String == "success",
                      let likeCount = apiResponse.body?["liked"] as? Int  else {
                        return
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let LikeAttributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Using the Roboto Medium style
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]

              
                
                self.count = likeCount
                let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(likeCount)))", attributes: LikeAttributes)
                
                
                DispatchQueue.main.async {
                    self.textNode.attributedText = like
                }
               
                
            case .failure(let error):
                print(error)
            }
        
        }
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        avatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        infoNode.style.preferredSize = CGSize(width: 30.0, height: 60.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        let horizontalSubStack = ASStackLayoutSpec.horizontal()
        horizontalSubStack.spacing = 10
        horizontalSubStack.justifyContent = ASStackLayoutJustifyContent.start
        horizontalSubStack.children = [timeNode, replyBtnNode]

        if self.post.has_reply == true && loadReplyBtnNode.isHidden == false {
            headerSubStack.children = [userNameNode, cmtNode, horizontalSubStack, loadReplyBtnNode]
        } else {
            headerSubStack.children = [userNameNode, cmtNode, horizontalSubStack]
        }

        let headerStack = ASStackLayoutSpec.horizontal()
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.children = [avatarNode, headerSubStack, infoNode]
        
        if self.post.isReply == true {
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 40, bottom: 16, right: 20), child: headerStack)
        } else {
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
        }
    }

    
    func addReplyUIDBtn(label: ActiveLabel) {
        
        DispatchQueue.main.async {
        
            
            self.replyToNode.attributedText = NSAttributedString(
                string: "\(self.replyUsername): ",
                attributes: [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Light style
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ]
            )

            let size = self.replyToNode.attributedText?.size()
            
            let userButton = ASButtonNode()
            userButton.backgroundColor = UIColor.clear
            userButton.frame = CGRect(x: 0, y: 0, width: size!.width, height: size!.height)
            self.cmtNode.view.addSubnode(userButton)
            
            userButton.addTarget(self, action: #selector(CommentNode.replyToBtnPressed), forControlEvents: .touchUpInside)
            
        
        }
        
        
    }
    
    
    @objc func replyBtnPressed(sender: AnyObject!) {
  
        replyBtn?(self)
  
        
    }
    
    
    override func layout() {
        delay(0.025) {
            self.addActiveLabelToCmtNode()
        }
    }
    
    
    func addActiveLabelToCmtNode() {
        
        DispatchQueue.main.async {
            
            self.cmtNode.view.isUserInteractionEnabled = true
            
            
            let label = ActiveLabel()
            
            //
            self.cmtNode.view.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: self.cmtNode.view.topAnchor, constant: 0).isActive = true
            label.leadingAnchor.constraint(equalTo: self.cmtNode.view.leadingAnchor, constant: 0).isActive = true
            label.trailingAnchor.constraint(equalTo: self.cmtNode.view.trailingAnchor, constant: 0).isActive = true
            label.bottomAnchor.constraint(equalTo: self.cmtNode.view.bottomAnchor, constant: 0).isActive = true
            
                    
            label.customize { label in
                
               
                label.numberOfLines = Int(self.cmtNode.lineCount)
                label.enabledTypes = [.mention, .hashtag, .url]
                
                label.attributedText = self.cmtNode.attributedText
                //label.attributedText = textAttributes
            
                label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
                label.mentionColor = .secondary
                label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
                
                if self.post.reply_to != "" {
                    self.addReplyUIDBtn(label: label)
                }
                
                
                label.handleMentionTap {  mention in
                    
                  
                    if let mentionArr = self.post.mention {
                        
                        for item in mentionArr {
                            
                            if let username = item["username"] as? String, username == mention {
                                
                                if let id = item["_id"] as? String {
                                    
                                    if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                                        
                                        if let vc = UIViewController.currentViewController() {
                                            
                                            let nav = UINavigationController(rootViewController: UPVC)

                                            // Set the user ID, nickname, and onPresent properties of UPVC
                                            UPVC.userId = id
                                            UPVC.nickname = username
                                            UPVC.onPresent = true

                                            // Customize the navigation bar appearance
                                            nav.navigationBar.barTintColor = .white
                                            nav.navigationBar.tintColor = .black
                                            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                                            nav.modalPresentationStyle = .fullScreen
                                            vc.present(nav, animated: true, completion: nil)
                                            return


                                        }
                                    }
                                    
                                }
                                
                              
                            }
                                
                            
                        }
                        
                    }
                    
                }
                
                label.handleHashtagTap { hashtag in
                          
                    var selectedHashtag = hashtag
                    selectedHashtag.insert("#", at: selectedHashtag.startIndex)
                    
                
                    if let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            let nav = UINavigationController(rootViewController: PLHVC)

                            // Set the user ID, nickname, and onPresent properties of UPVC
                            PLHVC.searchHashtag = selectedHashtag
                            PLHVC.onPresent = true

                            // Customize the navigation bar appearance
                            nav.navigationBar.barTintColor = .white
                            nav.navigationBar.tintColor = .black
                            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                            nav.modalPresentationStyle = .fullScreen
                            vc.present(nav, animated: true, completion: nil)
                   
                        }
                    }
                    
                    
                    
                    
                }
                
                label.handleURLTap { [weak self] string in
                    
                    
                    let url = string.absoluteString
                    
                    if url.contains("https://stitchbox.gg/app/account/") {
                        
                        if let id = self?.getUIDParameter(from: url) {
                            self?.moveToUserProfileVC(id: id)
                        }
            
                    } else if url.contains("https://stitchbox.gg/app/post/") {
                    
                        if let id = self?.getUIDParameter(from: url) {
                            self?.openPost(id: id)
                        }

                    } else {
                        
                        guard let requestUrl = URL(string: url) else {
                            return
                        }

                        if UIApplication.shared.canOpenURL(requestUrl) {
                             UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                        }
                    }
                    
                    
                }
                
                
                
            }
            
        }
            
    }
    
    func moveToUserProfileVC(id: String) {
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            if let vc = UIViewController.currentViewController() {
                

                if general_vc != nil {
                    general_vc.viewWillDisappear(true)
                    general_vc.viewDidDisappear(true)
                }
                
              
                
                let nav = UINavigationController(rootViewController: UPVC)

                // Set the user ID, nickname, and onPresent properties of UPVC
                UPVC.userId = id
                UPVC.onPresent = true

                // Customize the navigation bar appearance
                nav.navigationBar.barTintColor = .white
                nav.navigationBar.tintColor = .black
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                nav.modalPresentationStyle = .fullScreen
                vc.present(nav, animated: true, completion: nil)


            }
        }
        
    }
    
    func openPost(id: String) {
      
        presentSwiftLoader()

        APIManager.shared.getPostDetail(postId: id) { result in
         
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body else {
                    Dispatch.main.async {
                        SwiftLoader.hide()
                    }
                  return
                }
               
                if !data.isEmpty {
                    Dispatch.main.async {
                        SwiftLoader.hide()
                        
                        if let post = PostModel(JSON: data) {
                            
                            if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                                
                                if let vc = UIViewController.currentViewController() {
                                

                                    if general_vc != nil {
                                        general_vc.viewWillDisappear(true)
                                        general_vc.viewDidDisappear(true)
                                    }
                                    
                               
                                    
                                    RVC.onPresent = true
                                    
                                    let nav = UINavigationController(rootViewController: RVC)

                                    // Set the user ID, nickname, and onPresent properties of UPVC
                                    RVC.posts = [post]
                                   
                                    // Customize the navigation bar appearance
                                    nav.navigationBar.barTintColor = .white
                                    nav.navigationBar.tintColor = .black
                                    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

                                    nav.modalPresentationStyle = .fullScreen
                                    
                                    vc.present(nav, animated: true, completion: nil)
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                } else {
                    Dispatch.main.async {
                        SwiftLoader.hide()
                    }
                }

            case .failure(let error):
                print(error)
                Dispatch.main.async {
                    SwiftLoader.hide()
                }
                
            }
        }
        
    }
    
    func loadCmtCount() {
        if self.post.has_reply == true {
            if self.post.hasLoadedReplied {
                self.loadReplyBtnNode.setTitle("Show more", with: FontManager.shared.roboto(.Regular, size: FontSize), with: UIColor.darkGray, for: .normal)
                self.loadReplyBtnNode.contentHorizontalAlignment = .left
            } else {
                self.loadReplyBtnNode.setTitle("Replied (\(self.post.replyTotal ?? 0))", with: FontManager.shared.roboto(.Regular, size: FontSize), with: UIColor.darkGray, for: .normal)
                self.loadReplyBtnNode.contentHorizontalAlignment = .left
                self.post.hasLoadedReplied = true
            }
        }
    }

    func loadInfo(uid: String ) {
        if post.comment_avatarUrl != "" {
            avatarNode.url = URL(string: post.comment_avatarUrl)
        } else {
            avatarNode.image = UIImage.init(named: "defaultuser")
        }
        
        if self.post.comment_uid == self.post.owner_uid {
            if self.post.is_pinned == true {
                userNameNode.attributedText = NSAttributedString(
                    string: "@\(self.post.comment_username ?? "") - author (pinned)",
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), // Using the Roboto Medium style
                        NSAttributedString.Key.foregroundColor: UIColor.darkGray
                    ]
                )
            } else {
                userNameNode.attributedText = NSAttributedString(
                    string: "@\(self.post.comment_username ?? "") - author",
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), // Using the Roboto Medium style
                        NSAttributedString.Key.foregroundColor: UIColor.darkGray
                    ]
                )
            }
        } else {
            if self.post.is_pinned == true {
                userNameNode.attributedText = NSAttributedString(
                    string: "@\(self.post.comment_username ?? "") (pinned)",
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), // Using the Roboto Medium style
                        NSAttributedString.Key.foregroundColor: UIColor.darkGray
                    ]
                )
            } else {
                userNameNode.attributedText = NSAttributedString(
                    string: "@\(self.post.comment_username ?? "")",
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize + 1), // Using the Roboto Medium style
                        NSAttributedString.Key.foregroundColor: UIColor.darkGray
                    ]
                )
            }
        }
    }

    
  
    
    @objc func repliedBtnPressed(sender: AnyObject!) {
  
        reply?(self)
  
    }
    
}


extension CommentNode {
    
    func likeComment() {
        DispatchQueue.main.async {
            self.imageView.image = likeImage
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let LikeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Use Roboto Medium style
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        self.count += 1
        let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(self.count)))", attributes: LikeAttributes)
        DispatchQueue.main.async {
            self.textNode.attributedText = like
        }
        
        APIManager.shared.likeComment(comment: post.comment_id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                self.isLiked = true

            case .failure(let error):
                DispatchQueue.main.async {
                    self.imageView.image = emptyLikeImageLM
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let LikeAttributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Use Roboto Medium style
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]
                
                self.count -= 1
                let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(self.count)))", attributes: LikeAttributes)
                DispatchQueue.main.async {
                    self.textNode.attributedText = like
                }
                
                print("CmtCount: \(error)")
            }
        }
    }

    
    func unlikeComment() {
        DispatchQueue.main.async {
            self.imageView.image = emptyLikeImageLM
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let LikeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Use Roboto Medium style
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        self.count -= 1
        let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(self.count)))", attributes: LikeAttributes)
        
        DispatchQueue.main.async {
            self.textNode.attributedText = like
        }
        
        APIManager.shared.unlike(comment: post.comment_id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                self.isLiked = false

            case .failure(let error):
                DispatchQueue.main.async {
                    self.imageView.image = likeImage
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let LikeAttributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.font: FontManager.shared.roboto(.Medium, size: FontSize), // Use Roboto Medium style
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]
                
                self.count += 1
                let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(self.count)))", attributes: LikeAttributes)
                DispatchQueue.main.async {
                    self.textNode.attributedText = like
                }
                
                print("CmtCount: \(error)")
            }
        }
    }

    
    func addReplyNodes(_ nodes: [CommentNode]) {
            for node in nodes {
                addSubnode(node) // assuming that CommentNode is a subclass of ASDisplayNode
            }
        }
    
  
    
    func getUIDParameter(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return components?.queryItems?.first(where: { $0.name == "uid" })?.value
        } else {
            return nil
        }
    }


    
}
