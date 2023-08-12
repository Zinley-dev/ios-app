//
//  StitchControlForRemoveNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/23/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit
import ActiveLabel


fileprivate let FontSize: CGFloat = 12
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class StitchControlForRemoveNode: ASCellNode, ASVideoNodeDelegate {
    
    deinit {
        print("StitchControlForRemoveNode is being deallocated.")
    }
    
    var allowProcess = true
    var isFollowingUser = false
    var isSave = false
    var previousTimeStamp: TimeInterval = 0.0
    var totalWatchedTime: TimeInterval = 0.0
    var post: PostModel!
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var videoNode: ASVideoNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
   
    var toggleContentNode = ASTextNode()
   
    var headerView: PostHeader!
   
    var gradientNode: GradienView
    var time = 0
    var likeCount = 0
    var saveCount = 0
    var isLike = false
    var isSelectedPost = false
    var settingBtn : ((ASCellNode) -> Void)?
    var viewStitchBtn : ((ASCellNode) -> Void)?
    var soundBtn : ((ASCellNode) -> Void)?
    var isViewed = false
    var currentTimeStamp: TimeInterval!
    var originalCenter: CGPoint?
    var label: ActiveLabel!
    var buttonNode: ASDisplayNode
    var stitchView: UnStitchView!
   
    let maximumShowing = 100
    
    var unstitchBtn : ((ASCellNode) -> Void)?
    var stitchTo: Bool

    private lazy var infoNode: ASTextNode = {
        let textNode = ASTextNode()
        //textNode.style.preferredSize.width = 70
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        textNode.attributedText = NSAttributedString(
            string: "",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Bold style
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        textNode.backgroundColor = .black // set the background color to dark gray
        textNode.maximumNumberOfLines = 1

        DispatchQueue.main.async {
            textNode.view.cornerRadius = 3
        }
        
        return textNode
    }()
    
    init(with post: PostModel, stitchTo: Bool) {
        self.post = post
        self.stitchTo = stitchTo
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
      
        self.videoNode = ASVideoNode()
        self.gradientNode = GradienView()
        self.buttonNode = ASDisplayNode()
    
       
        super.init()
        
        self.gradientNode.isLayerBacked = true
        self.gradientNode.isOpaque = false
    
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.gradientNode.cornerRadius = 25
            self.gradientNode.clipsToBounds = true
            
            self.label = ActiveLabel()
           
            self.label.backgroundColor = .clear
            self.contentNode.view.isUserInteractionEnabled = true
        
            self.label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            self.label.setContentHuggingPriority(.defaultLow, for: .vertical)
            self.label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            self.label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

            

            let customType = ActiveType.custom(pattern: "\\*more\\b|\\*hide\\b")
            self.label.customColor[customType] = .lightGray
            self.label.numberOfLines = Int(self.contentNode.lineCount)
            self.label.enabledTypes = [.hashtag, .url, customType]
            self.label.attributedText = self.contentNode.attributedText
            
            
                //self.label.mentionColor = .secondary
            
            self.label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            self.label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
            
            self.label.handleCustomTap(for: customType) { [weak self] element in
                guard let self = self else { return }
                if element == "*more" {
                    self.seeMore()
                } else if element == "*hide" {
                    self.hideContent()
                }
            }

            self.label.handleHashtagTap { hashtag in
                
                var selectedHashtag = hashtag
                selectedHashtag.insert("#", at: selectedHashtag.startIndex)
                
            
                if let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                    
                    if let vc = UIViewController.currentViewController() {
                        
                        let nav = UINavigationController(rootViewController: PLHVC)

                        // Set the user ID, nickname, and onPresent properties of UPVC
                        PLHVC.searchHashtag = selectedHashtag
                        PLHVC.onPresent = true

                        // Customize the navigation bar appearance
                        nav.navigationBar.barTintColor = .background
                        nav.navigationBar.tintColor = .white
                        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                        nav.modalPresentationStyle = .fullScreen
                        vc.present(nav, animated: true, completion: nil)
               
                    }
                }
                
                
            }

            self.label.handleURLTap { [weak self] string in
                guard let self = self else { return }
                let url = string.absoluteString
                
                if url.contains("https://stitchbox.gg/app/account/") {
                    
                    if let id = self.getUIDParameter(from: url) {
                        self.moveToUserProfileVC(id: id)
                    }
        
                } else if url.contains("https://stitchbox.gg/app/post/") {
                
                    if let id = self.getUIDParameter(from: url) {
                        self.openPost(id: id)
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
            
            
            self.setupDefaultContent()
            
            self.contentNode.backgroundColor = .clear
            
            self.headerView = PostHeader()
            self.headerNode.view.addSubview(self.headerView)

            self.headerView.translatesAutoresizingMaskIntoConstraints = false
            self.headerView.topAnchor.constraint(equalTo: self.headerNode.view.topAnchor, constant: 0).isActive = true
            self.headerView.bottomAnchor.constraint(equalTo: self.headerNode.view.bottomAnchor, constant: 0).isActive = true
            self.headerView.leadingAnchor.constraint(equalTo: self.headerNode.view.leadingAnchor, constant: 0).isActive = true
            self.headerView.trailingAnchor.constraint(equalTo: self.headerNode.view.trailingAnchor, constant: 0).isActive = true
            
            self.headerView.createStitchView.isHidden = true
            self.headerView.createStitchStack.isHidden = true
            self.headerView.stichBtn.isHidden = true
            
            if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
                
                self.headerView.followBtn.isHidden = true
                
            } else {
                
                self.checkIfFollow()
               
            }

            
            let avatarTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.userTapped))
            avatarTap.numberOfTapsRequired = 1
          
            let usernameTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.userTapped))
            usernameTap.numberOfTapsRequired = 1
            self.headerView.usernameLbl.isUserInteractionEnabled = true
            self.headerView.usernameLbl.addGestureRecognizer(usernameTap)
            self.headerView.usernameLbl.font = FontManager.shared.roboto(.Bold, size: 12)

            
            let username2Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.userTapped))
            username2Tap.numberOfTapsRequired = 1

            
            
            self.headerView.usernameLbl.text = "@\(post.owner?.username ?? "")"
            
            
            self.stitchView = UnStitchView()
            self.buttonNode.view.addSubview(self.stitchView)
            self.stitchView.translatesAutoresizingMaskIntoConstraints = false
            self.stitchView.topAnchor.constraint(equalTo: self.buttonNode.view.topAnchor, constant: 0).isActive = true
            self.stitchView.bottomAnchor.constraint(equalTo: self.buttonNode.view.bottomAnchor, constant: 0).isActive = true
            self.stitchView.leadingAnchor.constraint(equalTo: self.buttonNode.view.leadingAnchor, constant: 0).isActive = true
            self.stitchView.trailingAnchor.constraint(equalTo: self.buttonNode.view.trailingAnchor, constant: 0).isActive = true
            
            
            //
            
            let unstitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.unstitchBtnTapped))
            unstitchTap.numberOfTapsRequired = 1
            self.stitchView.unstitchBtn.addGestureRecognizer(unstitchTap)
            
      
        }
       
        
        automaticallyManagesSubnodes = true
    
        if post.muxPlaybackId != "" {
            self.videoNode.url = self.getThumbnailBackgroundVideoNodeURL(post: post)
            self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
            self.videoNode.shouldAutoplay = false
            self.videoNode.shouldAutorepeat = true
            
            self.videoNode.muted = false
            self.videoNode.delegate = self
            
            
            if let width = self.post.metadata?.width, let height = self.post.metadata?.height, width != 0, height != 0 {
                // Calculate aspect ratio
                let aspectRatio = Float(width) / Float(height)
             
                // Set contentMode based on aspect ratio
                if aspectRatio >= 0.5 && aspectRatio <= 0.7 { // Close to 9:16 aspect ratio (vertical)
                    self.videoNode.contentMode = .scaleAspectFill
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                    self.videoNode.contentMode = .scaleAspectFit
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                    //self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                } else {
                    // Default contentMode, adjust as needed
                    self.videoNode.contentMode = .scaleAspectFit
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                    //self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
                }
            } else {
                // Default contentMode, adjust as needed
                self.videoNode.contentMode = .scaleAspectFill
                self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                //self.backgroundImage.setGradientImage(with: self.getThumbnailVideoNodeURL(post: post)!)
            }

            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
                self.videoNode.view.layer.cornerRadius = 25
                self.videoNode.view.clipsToBounds = true
            }
            
            if stitchTo {
                infoNode.cornerRadius = 3
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                if post.isApproved {
                    
                    infoNode.attributedText = NSAttributedString(
                        string: "Approved",
                        attributes: [
                            NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Bold style
                            NSAttributedString.Key.foregroundColor: UIColor.white,
                            NSAttributedString.Key.paragraphStyle: paragraphStyle
                        ]
                    )
                    
                } else {
                    
                    infoNode.attributedText = NSAttributedString(
                        string: "Pending",
                        attributes: [
                            NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: FontSize), // Using the Roboto Bold style
                            NSAttributedString.Key.foregroundColor: UIColor.white,
                            NSAttributedString.Key.paragraphStyle: paragraphStyle
                        ]
                    )
                    
                }
                
                
            }
            
        }
        
       
    }

    func navigateToHashtag(_ hashtag: String) {
        if let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                           
            if let vc = UIViewController.currentViewController() {
                               
                let nav = UINavigationController(rootViewController: PLHVC)

                // Set the user ID, nickname, and onPresent properties of UPVC
                PLHVC.searchHashtag = hashtag
                PLHVC.onPresent = true

                // Customize the navigation bar appearance
                nav.navigationBar.barTintColor = .background
                nav.navigationBar.tintColor = .white
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                nav.modalPresentationStyle = .fullScreen
                vc.present(nav, animated: true, completion: nil)
                      
            }
        }
    }

    func navigateToURL(url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func setNodeContentMode(for post: PostModel, node: ASNetworkImageNode, defaultContentMode: UIView.ContentMode) {
        if let width = post.metadata?.width, let height = post.metadata?.height, width != 0, height != 0 {
            let aspectRatio = Float(width) / Float(height)
            
            if aspectRatio >= 0.5 && aspectRatio <= 0.7 {
                node.contentMode = .scaleAspectFill
            } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 {
                node.contentMode = .scaleAspectFit
            } else {
                node.contentMode = defaultContentMode
            }
        } else {
            node.contentMode = defaultContentMode
        }
    }

    
    private func configureVideoNode(for post: PostModel) {
       // self.videoNode.url = self.getThumbnailBackgroundVideoNodeURL(post: post)
        self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
        self.videoNode.shouldAutoplay = false
        self.videoNode.shouldAutorepeat = true
        self.videoNode.muted = false
        self.videoNode.delegate = self
        
        setNodeContentMode(for: post, node: self.videoNode, defaultContentMode: .scaleAspectFill)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
        }
    }

    func setupDefaultContent() {

        headerNode.backgroundColor = UIColor.clear

        let hashtagsText = post.hashtags?.joined(separator: " ")
        let finalText = post.content + " " + (hashtagsText ?? "")
        var truncatedText: String
        
        if post.content == "" {
            truncatedText = truncateTextIfNeeded(hashtagsText ?? "")
        } else {
            truncatedText = truncateTextIfNeeded(finalText)
        }
        
        let attr1 = NSAttributedString(string: truncatedText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ])
            
        let attr2 = NSAttributedString(string: truncatedText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        self.contentNode.attributedText = attr1

        
        setNeedsLayout()
        layoutIfNeeded()

        label.attributedText = attr2
        self.label.removeFromSuperview()
        addActiveLabel()
    }

    private func truncateTextIfNeeded(_ text: String) -> String {
        if text.count > maximumShowing, text.count - maximumShowing >= 20 {
            return String(text.prefix(maximumShowing)) + " ..." + " *more"
        } else {
            return text
        }
    }



    
    func checkIfFollow() {
        
        APIManager.shared.isFollowing(uid: post.owner?.id ?? "") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                    hideFollowBtn()
                    return
                }
                
                if isFollowing {
                    hideFollowBtn()
                   
                    
                } else {
                    
                    setupFollowBtn()
                    
                }
                
            case .failure(let error):
                print(error)
                hideFollowBtn()
                
            }
        }
        
    }
    
    func setupFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = false
            self.headerView.followBtn.titleLabel?.font = FontManager.shared.roboto(.Regular, size: 12.0)
            self.isFollowingUser = false
            let followTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.followTap))
            followTap.numberOfTapsRequired = 1
            self.headerView.followBtn.addGestureRecognizer(followTap)
            
        }
    }
    
    func followUser() {
        
        if let userId = post.owner?.id {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.followBtn.setTitle("Following", for: .normal)
            }
            
            
            APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    
                    
                    self.isFollowingUser = true
                    self.allowProcess = true
                    
                    
                case .failure(_):
                    
                    DispatchQueue.main.async {
                        self.allowProcess = true
                        showNote(text: "Something happened!")
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.headerView.followBtn.setTitle("Follow", for: .normal)
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    
    func unfollowUser() {
        
        if let userId = post.owner?.id {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.followBtn.setTitle("Follow", for: .normal)
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
                        self.headerView.followBtn.setTitle("Following", for: .normal)
                    }
                    
                    
                    
                }
            }
            
        }
        
    }
    
    
    func hideFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = true
            self.isFollowingUser = true
        }
        
    }
    
    func setupHideContent() {
        
        headerNode.backgroundColor = UIColor.clear
        
        let hashtagsText = post.hashtags?.joined(separator: " ")
        let finalText = post.content + " " + (hashtagsText ?? "")
        var contentText: String

        if post.content == "" {
            contentText = processTextForHiding(hashtagsText ?? "")
        } else {
            contentText = processTextForHiding(finalText)
        }
        
        
        let attr1 = NSAttributedString(string: contentText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ])
            
        let attr2 = NSAttributedString(string: contentText, attributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Regular, size: FontSize), // Using the Roboto Regular style as an example
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        self.contentNode.attributedText = attr1

        setNeedsLayout()
        layoutIfNeeded()

        label.attributedText = attr2
        self.label.removeFromSuperview()
        addActiveLabel()
    }

    private func processTextForHiding(_ text: String) -> String {
        if text.count > maximumShowing {
            return text + " *hide"
        } else {
            return text
        }
    }

    
    func addActiveLabel() {
    
        self.contentNode.view.addSubview(self.label)
          
        // Set label's frame to match the contentNode's bounds.
        self.label.frame = self.contentNode.view.bounds
       
    }


    func getThumbnailBackgroundVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.jpg?time=0"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
        
    }

    func getThumbnailVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.jpg?time=1"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
        
    }
    
    func getVideoURLForRedundant_stream(post: PostModel) -> URL? {
    
        if post.muxPlaybackId != "" {
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8"
            return URL(string: urlString)
            
        } else {
            
            return nil
        }

    }
    


}

extension StitchControlForRemoveNode {
    
    /*
    func didTap(_ videoNode: ASVideoNode) {
        
        soundProcess()
        
    } */
    
    
    @objc func soundProcess() {
        
        if videoNode.muted == true {
            videoNode.muted = false
            shouldMute = false
            animateUnmute()
    
        } else {
            videoNode.muted = true
            shouldMute = true
            animateMute()
        }
        
    }
    
    
}


extension StitchControlForRemoveNode {
    
    
    @objc func userTapped() {
        
        if let userId = post.owner?.id, let username = post.owner?.username, userId != "", username != "" {
            
            if userId != _AppCoreData.userDataSource.value?.userID  {
                
                if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                    
                    if let vc = UIViewController.currentViewController() {
                        
                        let nav = UINavigationController(rootViewController: UPVC)

                        // Set the user ID, nickname, and onPresent properties of UPVC
                        UPVC.userId = userId
                        UPVC.nickname = username
                        UPVC.onPresent = true

                        // Customize the navigation bar appearance
                        nav.navigationBar.barTintColor = .background
                        nav.navigationBar.tintColor = .white
                        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                        nav.modalPresentationStyle = .fullScreen
                        vc.present(nav, animated: true, completion: nil)

               
                    }
                }
                
            }
            
            
        }
 
        
    }

    @objc func followTap() {
        
        if allowProcess {
            self.allowProcess = false
            if isFollowingUser {
                
                unfollowUser()
                
            } else {
                
                followUser()
            }
            
        }
         
    }

  
    
    
    func animateMute() {
        let imgView = UIImageView(image: muteImage)
        imgView.frame.size = CGSize(width: 45, height: 45)
        imgView.center = self.view.center
        self.view.addSubview(imgView)

        UIView.animate(withDuration: 0.5, animations: {
            imgView.alpha = 0
            imgView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            imgView.removeFromSuperview()
        }
    }

    func animateUnmute() {
        let imgView = UIImageView(image: unmuteImage)
        imgView.frame.size = CGSize(width: 45, height: 45)
        imgView.center = self.view.center
        self.view.addSubview(imgView)

        UIView.animate(withDuration: 0.5, animations: {
            imgView.alpha = 0
            imgView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            imgView.removeFromSuperview()
        }
    }


}


extension StitchControlForRemoveNode {
    
    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        
        let change = constrainedSize.max.width - ( constrainedSize.max.height * 9 / 16)
        let padding = change / 2
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 55)
        let buttonsInset = UIEdgeInsets(top: 10, left: padding, bottom: -10, right: padding)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            
        let change = constrainedSize.max.width - ( constrainedSize.max.height * 9 / 16)
        let padding = change / 2
        
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1
      
        
        let headerInset = UIEdgeInsets(top: 0, left: padding, bottom: 2, right: 8 + padding)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)
        
        let contentInset = UIEdgeInsets(top: 2, left: 20 + padding, bottom: 2, right: 70 + padding)
        let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)
        
        let verticalStack = ASStackLayoutSpec.vertical()
        
        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)
        verticalStack.children = [headerInsetSpec]
        
        if !post.content.isEmpty || ((post.hashtags?.contains(where: { !$0.isEmpty })) != nil) {
            verticalStack.children?.append(contentInsetSpec)
        }

        verticalStack.children?.append(buttonsInsetSpec)
        
        let verticalStackInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: verticalStack)

        let inset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        let gradientInsetSpec = ASInsetLayoutSpec(insets: inset, child: gradientNode)

        let videoInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)

        var overlay = ASOverlayLayoutSpec(child: videoInsetSpec, overlay: gradientInsetSpec)

        if stitchTo {
            infoNode.style.preferredSize = CGSize(width: 75, height: 15)
            let stitchCountInsets = UIEdgeInsets(top: 8, left: 8 + padding, bottom: .infinity, right: .infinity)
            let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: infoNode)
            let overlay2 = ASOverlayLayoutSpec(child: overlay, overlay: stitchCountInsetSpec)
            overlay = overlay2
        }
        
        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: verticalStackInsetSpec)
        let finalOverlay = ASOverlayLayoutSpec(child: overlay, overlay: relativeSpec)

        return finalOverlay
    }

}

extension StitchControlForRemoveNode {

    func getUIDParameter(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return components?.queryItems?.first(where: { $0.name == "uid" })?.value
        } else {
            return nil
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
                nav.navigationBar.barTintColor = .background
                nav.navigationBar.tintColor = .white
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

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
    
}

extension StitchControlForRemoveNode {
    
    func seeMore() {
        
        setupHideContent()
        setNeedsLayout()
        
    }
    
    func hideContent() {
        
        setupDefaultContent()
        setNeedsLayout()
    }
    
    @objc func unstitchBtnTapped() {
        
        unstitchBtn?(self)
        
    }
    
   
}
