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
    
    
    deinit {
        print("CommentNode is being deallocated.")
        NotificationCenter.default.removeObserver(self)
        
    }
    
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
    var label: ActiveLabel!

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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
              
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: FontManager.shared.roboto(.Regular, size: FontSize),
                .foregroundColor: UIColor.black
            ]

            let timeAttributes: [NSAttributedString.Key: Any] = [
                .font: FontManager.shared.roboto(.Regular, size: FontSize),
                .foregroundColor: UIColor.darkGray
            ]

            let clearTextAttributes: [NSAttributedString.Key: Any] = [
                .font: FontManager.shared.roboto(.Regular, size: FontSize),
                .foregroundColor: UIColor.clear
            ]


            
            if let replyToUsername = self.post.reply_to_username, !self.post.reply_to.isEmpty {
                self.replyUsername = replyToUsername
                let username = "\(replyToUsername): " // Remove "@" symbol here
                let clearUser = createAttributedString(username: username, text: self.post.text, clear: true, clearTextAttributes: clearTextAttributes, textAttributes: textAttributes)
                let user = createAttributedString(username: username, text: self.post.text, clear: false, clearTextAttributes: clearTextAttributes, textAttributes: textAttributes)
                let time = createTimeAttributedString(createdAt: self.post.createdAt, updatedAt: self.post.is_title == true ? self.post.updatedAt : nil, timeAttributes: timeAttributes)
                updateUI(username: username, clearUser: clearUser, user: user, time: time)
            } else {
                let clearUser = createAttributedString(username: nil, text: self.post.text, clear: true, clearTextAttributes: clearTextAttributes, textAttributes: textAttributes)
                let user = createAttributedString(username: nil, text: self.post.text, clear: false, clearTextAttributes: clearTextAttributes, textAttributes: textAttributes)
                let time = createTimeAttributedString(createdAt: self.post.createdAt, updatedAt: self.post.is_title == true ? self.post.updatedAt : nil, timeAttributes: timeAttributes)
                updateUI(username: nil, clearUser: clearUser, user: user, time: time)
            }

            
        }
        
        // Configure the reply button.
        self.replyBtnNode.setTitle("Reply", with: FontManager.shared.roboto(.Medium, size: FontSize), with: UIColor.darkGray, for: .normal)
        self.replyBtnNode.addTarget(self, action: #selector(CommentNode.replyBtnPressed), forControlEvents: .touchUpInside)

        // Set selection style and avatar properties.
        self.selectionStyle = .none
        avatarNode.contentMode = .scaleAspectFill
        avatarNode.cornerRadius = OrganizerImageSize / 2
        avatarNode.clipsToBounds = true
        avatarNode.shouldRenderProgressImages = true

        // Configure text alignment.
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left

        // Set background colors.
        DispatchQueue.main.async {
            self.view.backgroundColor = .white
        }

        infoNode.backgroundColor = UIColor.clear
        loadReplyBtnNode.backgroundColor = UIColor.clear
        cmtNode.backgroundColor = UIColor.clear
        replyToNode.backgroundColor = UIColor.clear
        userNameNode.backgroundColor = UIColor.clear
        textNode.backgroundColor = UIColor.clear
        imageView.backgroundColor = UIColor.clear

        // Set content modes.
        imageView.contentMode = .scaleAspectFit
        cmtNode.truncationMode = .byTruncatingTail

        // Set frames.
        imageView.frame = CGRect(x: 2, y: 2, width: 25, height: 25)
        textNode.frame = CGRect(x: 0, y: 30, width: 30, height: 20)

        // Configure button.
        let button = ASButtonNode()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 60)
        button.backgroundColor = UIColor.clear
        infoNode.addSubnode(imageView)
        infoNode.addSubnode(textNode)
        infoNode.addSubnode(button)
        button.addTarget(self, action: #selector(CommentNode.LikedBtnPressed), forControlEvents: .touchUpInside)

        // Add more targets.
        loadReplyBtnNode.addTarget(self, action: #selector(CommentNode.repliedBtnPressed), forControlEvents: .touchUpInside)
        userNameNode.addTarget(self, action: #selector(CommentNode.usernameBtnPressed), forControlEvents: .touchUpInside)
        avatarNode.addTarget(self, action: #selector(CommentNode.usernameBtnPressed), forControlEvents: .touchUpInside)

        // Other configurations.
        textNode.isLayerBacked = true
        automaticallyManagesSubnodes = true


          
    }
    
    override func didLoad() {
        super.didLoad()
        
        label = ActiveLabel()
          
        cmtNode.view.addSubview(self.label)
        cmtNode.view.isUserInteractionEnabled = true
                          
        label.enabledTypes = [.mention, .hashtag, .url]
        label.mentionColor = .secondary
                  
        // A blue color for hashtags
        label.hashtagColor = UIColor(red: 0.0/255, green: 204.0/255, blue: 255.0/255, alpha: 1)


        // A contrasting green color for URLs
        label.URLColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        
        self.label.customize { [weak self] label in
            guard let self = self else { return }
            if self.post.reply_to != "" {
                self.addReplyUIDBtn()
            }
            
            label.handleMentionTap { [weak self] mention in
                guard let self = self else { return }
                guard let mentionArr = self.post.mention else { return }
                
                for item in mentionArr {
                    guard let username = item["username"] as? String, username == mention,
                          let id = item["_id"] as? String else { continue }
                    
                    self.moveToViewController(id: id, identifier: "UserProfileVC")
                }
            }
            
            label.handleHashtagTap { [weak self] hashtag in
                guard let self = self else { return }
                let selectedHashtag = "#" + hashtag
                if let viewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                    viewController.searchHashtag = selectedHashtag
                    viewController.onPresent = true
                    self.present(viewController)
                }
            }
            
            label.handleURLTap { [weak self] string in
                guard let self = self else { return }
                
                let url = string.absoluteString
                if url.contains("https://stitchbox.net/app/account/") {
                    self.moveToUserProfileVC(id: self.getUIDParameter(from: url)!)
                } else if url.contains("https://stitchbox.net/app/post/") {
                    self.openPost(id: self.getUIDParameter(from: url)!)
                } else if let requestUrl = URL(string: url), UIApplication.shared.canOpenURL(requestUrl) {
                    UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                }
            }
        }
        
        
        // Load content based on the post.
        loadInfo(uid: self.post.comment_uid)
        if self.post.has_reply == true {
            loadCmtCount()
        }
        checkLikeCmt()
        cmtCount()
        
    }

    
    func present(_ viewController: UIViewController, animated: Bool = true) {
        if let vc = UIViewController.currentViewController() {
            let nav = UINavigationController(rootViewController: viewController)
            nav.navigationBar.barTintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            nav.modalPresentationStyle = .fullScreen
            vc.present(nav, animated: animated, completion: nil)
        }
    }

    func moveToViewController(id: String, identifier: String) {
        if let viewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: identifier) as? UserProfileVC {
            viewController.userId = id
            viewController.onPresent = true
            present(viewController)
        }
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
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.imageView.image = likeImage
                    }
                    
                    
                    
                   
            
                } else {
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.imageView.image = emptyLikeImageLM
                    }
            
                }
                
                
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
                
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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

    
    func addReplyUIDBtn() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
        
            
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
        super.layout()
        if self.label != nil {
            self.label.frame = self.cmtNode.bounds
            self.label.numberOfLines = Int(self.cmtNode.lineCount)
        } else {
            delay(1) { [weak self] in
                guard let self = self else { return }
                self.label.frame = self.cmtNode.bounds
                self.label.numberOfLines = Int(self.cmtNode.lineCount)
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
                    Dispatch.main.async { [weak self] in
                        guard let self = self else { return }
                        SwiftLoader.hide()
                    }
                  return
                }
               
                if !data.isEmpty {
                    Dispatch.main.async { [weak self] in
                        guard let self = self else { return }
                        SwiftLoader.hide()
                        
                        if let post = PostModel(JSON: data) {
                            
                            if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedParentVC") as? SelectedParentVC {
                                
                                if let vc = UIViewController.currentViewController() {
                                

                                    if general_vc != nil {
                                        general_vc.viewWillDisappear(true)
                                        general_vc.viewDidDisappear(true)
                                    }
                                    
                               
                                    
                                    RVC.onPresent = true
                                    
                                    let nav = UINavigationController(rootViewController: RVC)

                                    // Set the user ID, nickname, and onPresent properties of UPVC
                                    RVC.posts = [post]
                                    RVC.startIndex = 0

                                    nav.modalPresentationStyle = .fullScreen
                                    
                                    vc.present(nav, animated: true, completion: nil)
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                } else {
                    Dispatch.main.async { [weak self] in
                        guard let self = self else { return }
                        SwiftLoader.hide()
                    }
                }

            case .failure(let error):
                print(error)
                Dispatch.main.async { [weak self] in
                    guard let self = self else { return }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.textNode.attributedText = like
        }
        
        APIManager.shared.likeComment(comment: post.comment_id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                self.isLiked = true

            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.textNode.attributedText = like
                }
                
                print("CmtCount: \(error)")
            }
        }
    }

    
    func unlikeComment() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.textNode.attributedText = like
        }
        
        APIManager.shared.unlike(comment: post.comment_id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                self.isLiked = false

            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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

    func createTimeAttributedString(createdAt: Date?, updatedAt: Date?, timeAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString? {
        var dateToUse: Date? = createdAt

        if let updatedAt = updatedAt, updatedAt != Date() {
            dateToUse = updatedAt
        }

        if let date = dateToUse {
            return NSAttributedString(string: timeAgoSinceDate(date, numericDates: true), attributes: timeAttributes)
        }

        return nil
    }



    func createAttributedString(username: String?, text: String, clear: Bool, clearTextAttributes: [NSAttributedString.Key: Any], textAttributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let attributes = clear ? clearTextAttributes : textAttributes
        let user = NSMutableAttributedString()
        
        if let username = username {
            user.append(NSAttributedString(string: "@\(username)", attributes: attributes)) // Append "@" symbol here
        }
        
        user.append(NSAttributedString(string: text, attributes: attributes))
        return user
    }



    func updateUI(username: String?, clearUser: NSMutableAttributedString, user: NSMutableAttributedString, time: NSAttributedString?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            timeNode.attributedText = time
            cmtNode.attributedText = clearUser
            label.attributedText = user
        }
    }

    
}
