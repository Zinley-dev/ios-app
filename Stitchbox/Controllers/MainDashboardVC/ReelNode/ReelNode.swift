//
//  ReelNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/2/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit
import ActiveLabel


fileprivate let FontSize: CGFloat = 14
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class ReelNode: ASCellNode, ASVideoNodeDelegate {
    
    deinit {
        print("ReelNode is being deallocated.")
    }
    
    var allowProcess = true
    var isFollowingUser = false
    var isSave = false
    var previousTimeStamp: TimeInterval = 0.0
    var totalWatchedTime: TimeInterval = 0.0
    var roundedCornerNode: RoundedCornerNode
    var collectionNode: ASCollectionNode?
    var post: PostModel!
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var videoNode: RoundedCornerVideoNode
    var imageNode: RoundedCornerImageNode
    var contentNode: ASTextNode
    var headerNode: ASDisplayNode
    var buttonNode: ASDisplayNode
    var toggleContentNode = ASTextNode()
    var backgroundImage: GradientImageNode
    var shouldCountView = true
    var headerView: PostHeader!
    var buttonsView: ButtonsHeader!
    var sideButtonsView: ButtonSideList!
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
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!

    //var panGestureRecognizer: UIPanGestureRecognizer!
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
 
    let maximumShowing = 100

    init(with post: PostModel) {
        self.post = post
        self.imageNode = RoundedCornerImageNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.roundedCornerNode = RoundedCornerNode()
        self.videoNode = RoundedCornerVideoNode()
        self.gradientNode = GradienView()
        self.backgroundImage = GradientImageNode()
        self.buttonNode = ASDisplayNode()
       
        super.init()
        
        self.gradientNode.isLayerBacked = true
        self.gradientNode.isOpaque = false
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setupLabel()
            self.setupGestureRecognizers()
            self.setupViews()
            
            self.setupDefaultContent()
            self.contentNode.backgroundColor = .clear
            
            self.headerView.usernameLbl.text = "@\(self.post.owner?.username ?? "")"
            self.updatePostStatistics()
        }
       
        
        automaticallyManagesSubnodes = true
    
        if post.muxPlaybackId != "" {
            configureVideoNode(for: post)
        }
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setupSideButtonsView()
            self.setupGestures()
        }

  
    }
    
    func setupLabel() {
        label = ActiveLabel()
        label.backgroundColor = .clear
        contentNode.view.isUserInteractionEnabled = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        let customType = ActiveType.custom(pattern: "\\*more\\b|\\*hide\\b")
        label.customColor[customType] = .lightGray
        label.numberOfLines = Int(contentNode.lineCount)
        label.enabledTypes = [.hashtag, .url, customType]
        label.attributedText = contentNode.attributedText

        // Set custom colors
        label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)

        label.handleCustomTap(for: customType) { [weak self] element in
            guard let self = self else { return }
            if element == "*more" {
                self.seeMore()
            } else if element == "*hide" {
                self.hideContent()
            }
        }

        label.handleHashtagTap { [weak self] hashtag in
            guard let self = self else { return }
            self.navigateToHashtag(hashtag)
        }

        label.handleURLTap { [weak self] string in
            guard let self = self else { return }
            self.navigateToHashtag(string.absoluteString)
        }
    }

    func setupGestureRecognizers() {
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:))))
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.minimumNumberOfTouches = 2
        view.addGestureRecognizer(panGestureRecognizer)
        
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeHandle))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        doubleTap.delaysTouchesBegan = true

        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(settingTapped))
        longPress.minimumPressDuration = 0.65
        view.addGestureRecognizer(longPress)
        longPress.delaysTouchesBegan = true
    }

    func setupViews() {
        setupHeaderView()
        setupButtonsView()
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

    
    func setupHeaderView() {
        headerView = PostHeader()
        headerNode.view.addSubview(headerView)

        headerView.pinToSuperviewEdges()
        adjustHeaderViewVisibility()
    }

    func setupButtonsView() {
        buttonsView = ButtonsHeader()
        buttonNode.view.addSubview(buttonsView)

        buttonsView.pinToSuperviewEdges()
        setupButtons()
    }

    func adjustHeaderViewVisibility() {
        let isOwnedByUser = _AppCoreData.userDataSource.value?.userID == post.owner?.id
        let isStitchAllowed = post.setting?.allowStitch ?? false

        headerView.followBtn.isHidden = isOwnedByUser
        headerView.createStitchView.isHidden = isOwnedByUser || !isStitchAllowed
        headerView.createStitchStack.isHidden = isOwnedByUser || !isStitchAllowed
        headerView.stichBtn.isHidden = isOwnedByUser || !isStitchAllowed
    }

    func setupButtons() {
        buttonsView.likeBtn.setImage(nil, for: .normal)
        buttonsView.commentBtn.setImage(cmtImage, for: .normal)
        buttonsView.shareBtn.setImage(shareImage, for: .normal)
        buttonsView.saveBtn.setImage(unsaveImage, for: .normal)

        setupButtonGestures()
    }

    func setupButtonGestures() {
        let buttons = [
            buttonsView.likeBtn,
            buttonsView.shareBtn,
            buttonsView.saveBtn,
            buttonsView.commentBtn,
            headerView.stichBtn
        ]
        
        let selectors = [
            #selector(likeTapped),
            #selector(shareTapped),
            #selector(onClickSave),
            #selector(cmtTapped),
            #selector(stitchTapped)
        ]
        
        for (index, button) in buttons.enumerated() {
            let tap = UITapGestureRecognizer(target: self, action: selectors[index])
            tap.numberOfTapsRequired = 1
            button?.addGestureRecognizer(tap)
        }
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        labelTap.numberOfTapsRequired = 1
        headerView.usernameLbl.addGestureRecognizer(labelTap)
    }

    func updatePostStatistics() {
        checkIfLike()
        totalLikeCount()
        totalCmtCount()
        shareCount()
        getSaveCount()
        checkIfSave()
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
        self.videoNode.url = self.getThumbnailBackgroundVideoNodeURL(post: post)
        self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
        self.videoNode.shouldAutoplay = false
        self.videoNode.shouldAutorepeat = true
        self.videoNode.muted = false
        self.videoNode.delegate = self
        
        setNodeContentMode(for: post, node: self.videoNode, defaultContentMode: .scaleAspectFit)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
        }
    }
    
    private func setupSideButtonsView() {
        self.sideButtonsView = ButtonSideList()
        self.sideButtonsView.backgroundColor = .clear
        self.sideButtonsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.sideButtonsView)
        self.originalCenter = self.view.center

        NSLayoutConstraint.activate([
            self.sideButtonsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            self.sideButtonsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -55),
            self.sideButtonsView.widthAnchor.constraint(equalToConstant: 55),
            self.sideButtonsView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        ])
    }

    private func setupGestures() {
        let viewStitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.viewStitchTapped))
        viewStitchTap.numberOfTapsRequired = 1
        self.sideButtonsView.viewStitchBtn.addGestureRecognizer(viewStitchTap)
    }
    
    func setupDefaultContent() {

        headerNode.backgroundColor = UIColor.clear

        let hashtagsText = post.hashtags.joined(separator: " ")
        let finalText = post.content + " " + hashtagsText
        var truncatedText: String
        
        if post.content == "" {
            truncatedText = truncateTextIfNeeded(hashtagsText)
        } else {
            truncatedText = truncateTextIfNeeded(finalText)
        }
        
        self.contentNode.attributedText = NSAttributedString(string: truncatedText, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        setNeedsLayout()
        layoutIfNeeded()

        label.attributedText = self.contentNode.attributedText
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
            self.isFollowingUser = false
            let followTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReelNode.followTap))
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
        
        let hashtagsText = post.hashtags.joined(separator: " ")
        let finalText = post.content + " " + hashtagsText
        var contentText: String

        if post.content == "" {
            contentText = processTextForHiding(hashtagsText)
        } else {
            contentText = processTextForHiding(finalText)
        }
        
        self.contentNode.attributedText = NSAttributedString(string: contentText, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        setNeedsLayout()
        layoutIfNeeded()

        label.attributedText = self.contentNode.attributedText
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

    
    @objc private func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        //guard let view = videoNode.view else { return }
    
        if recognizer.state == .began {
            disableScroll()
        }

        if recognizer.state == .changed {
            let scale = recognizer.scale
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
          
            
            if post.muxPlaybackId != "" {
                let tempTransform = videoNode.view.transform.concatenating(scaleTransform)
                videoNode.view.transform = tempTransform
            } else {
                let tempTransform = imageNode.view.transform.concatenating(scaleTransform)
                imageNode.view.transform = tempTransform
            }
            
        
            recognizer.scale = 1
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            
            let scale = recognizer.scale
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
            
            if post.muxPlaybackId != "" {
                let tempTransform = videoNode.view.transform.concatenating(scaleTransform)
                
                UIView.animate(withDuration: 0.2, animations: {
                    if tempTransform.a < 1.0 {
                        self.videoNode.view.transform = CGAffineTransform.identity
                        //self.videoNode.view.center = self.originalCenter!
                    }
                        }, completion: { _ in
                            self.enableScroll()
                })
            } else {
                let tempTransform = imageNode.view.transform.concatenating(scaleTransform)
                
                UIView.animate(withDuration: 0.2, animations: {
                    if tempTransform.a < 1.0 {
                        self.imageNode.view.transform = CGAffineTransform.identity
                        //self.imageNode.view.center = self.originalCenter!
                    }
                        }, completion: { _ in
                            self.enableScroll()
                })
            }
  
        
        }
    }

  

    func walkthroughPanAndZoom() {
        // Store original center for later use
        let originalCenter = videoNode.view.center
        
        // Disable scrolling during walkthrough
        disableScroll()

        // Simulate pan by translating center
        let simulatedTranslation = CGPoint(x: 30, y: 30)
        videoNode.view.center = CGPoint(x: videoNode.view.center.x + simulatedTranslation.x, y: videoNode.view.center.y + simulatedTranslation.y)
        
        // Animate zoom in and pan back to original center with spring effect
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            self.videoNode.view.transform = CGAffineTransform(scaleX: 1.6, y: 1.6) // Increased zoom
            self.videoNode.view.center = originalCenter
        }) { _ in
            // Animate zoom out with spring effect
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
                self.videoNode.view.transform = CGAffineTransform.identity
            }) { _ in
                // Re-enable scrolling once walkthrough is complete
                self.enableScroll()
            }
        }
    }




    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        //guard let view = recognizer.view else { return }

        if recognizer.state == .began {
            disableScroll()
           
        }

        if recognizer.state == .changed {
            
            if post.muxPlaybackId != "" {
                
                let translation = recognizer.translation(in: videoNode.view)
                videoNode.view.center = CGPoint(x: videoNode.view.center.x + translation.x, y: videoNode.view.center.y + translation.y)
                recognizer.setTranslation(.zero, in: videoNode.view)
                
            } else {
                
                let translation = recognizer.translation(in: imageNode.view)
                imageNode.view.center = CGPoint(x: imageNode.view.center.x + translation.x, y: imageNode.view.center.y + translation.y)
                recognizer.setTranslation(.zero, in: imageNode.view)
                
            }
            
            
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
           
            UIView.animate(withDuration: 0.2, animations: {
                        
                    }, completion: { _ in
                        self.enableScroll()
                    })
            
        }
    }


    
    
    func getThumbnailBackgroundVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=0.025"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
        
    }

    func getThumbnailVideoNodeURL(post: PostModel) -> URL? {
        
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.png?time=1"
            
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
    
    func setVideoProgress(rate: Float, currentTime: TimeInterval, maxDuration: CMTime) {
        if let vc = UIViewController.currentViewController() {
            if let update1 = vc as? FeedViewController {
                updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.playTimeBar)
            } else if let update1 = vc as? SelectedPostVC {
                updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.playTimeBar)
            } else if let update1 = vc as? PreviewVC {
                updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.playTimeBar)
            }
        }
    }

    func updateSlider(currentTime: TimeInterval, maxDuration: CMTime, playTimeBar: UISlider?) {
        guard let playTimeBar = playTimeBar else { return }

        let maxDurationSeconds = CMTimeGetSeconds(maxDuration)

        // Check if maxDurationSeconds is not NaN and more than 0
        if maxDurationSeconds.isNaN || maxDurationSeconds <= 0 {
            print("Invalid maxDurationSeconds: \(maxDurationSeconds)")
            return
        }

        playTimeBar.maximumValue = Float(maxDurationSeconds)
        playTimeBar.setValue(Float(currentTime), animated: true)
    }


    
    

}

extension ReelNode {
    
    func didTap(_ videoNode: ASVideoNode) {
        
        if let vc = UIViewController.currentViewController() {
            if vc is PreviewVC {
                soundProcess()
            } else {
                soundBtn?(self)
            }
        }
    }
    
    
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
    
    
    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        
        let videoDuration = videoNode.currentItem?.duration.seconds ?? 0

        // Compute the time the user has spent actually watching the video
        if timeInterval >= previousTimeStamp {
            totalWatchedTime += timeInterval - previousTimeStamp
        }
        previousTimeStamp = timeInterval

        setVideoProgress(rate: Float(timeInterval/(videoNode.currentItem?.duration.seconds)!), currentTime: timeInterval, maxDuration: videoNode.currentItem!.duration)

        let watchedPercentage = totalWatchedTime/videoDuration
        let minimumWatchedPercentage: Double

        // Setting different thresholds based on video length
        switch videoDuration {
        case 0..<15:
            minimumWatchedPercentage = 0.8
        case 15..<30:
            minimumWatchedPercentage = 0.7
        case 30..<60:
            minimumWatchedPercentage = 0.6
        case 60..<90:
            minimumWatchedPercentage = 0.5
        case 90..<120:
            minimumWatchedPercentage = 0.4
        default:
            minimumWatchedPercentage = 0.5
        }
        
        // Check if user has watched a certain minimum amount of time (e.g. 5 seconds)
        let minimumWatchedTime = 5.0
        if shouldCountView && totalWatchedTime >= minimumWatchedTime && watchedPercentage >= minimumWatchedPercentage {
            shouldCountView = false
            endVideo(watchTime: Double(totalWatchedTime))
        }
        
        // Optionally, add another condition to check if user is actively engaging with the video
        // if shouldCountView && userIsEngagingWithVideo {
        //     endVideo(watchTime: Double(totalWatchedTime))
        // }
    }
    
    func videoDidPlay(toEnd videoNode: ASVideoNode) {
    
        shouldCountView = true
       
        
    }
    
    @objc func endVideo(watchTime: Double) {
        
        if _AppCoreData.userDataSource.value != nil {
            
            time += 1
            
            if time < 2 {
                
                last_view_timestamp = NSDate().timeIntervalSince1970
                isViewed = true
            
                APIManager.shared.createView(post: post.id, watchTime: watchTime) { result in
                    
                    switch result {
                    case .success(let apiResponse):
            
                        print(apiResponse)
                        
                    case .failure(let error):
                        print(error)
                    }
                
                }
                
            }
            
        }
        
        
    }
    
    func endImage(id: String) {
        
        if _AppCoreData.userDataSource.value != nil {
            
            time += 1
            
            if time < 2 {
                
                last_view_timestamp = NSDate().timeIntervalSince1970
                isViewed = true
            
                APIManager.shared.createView(post: id, watchTime: 0) { result in
                    
                    switch result {
                    case .success(let apiResponse):
            
                        print(apiResponse)
                        
                    case .failure(let error):
                        print(error)
                    }
                
                }
                
            }
            
        }
        
        
    }
    
    
    @objc func zoomAnimation() {
        
        let imgView = UIImageView()
        imgView.frame.size = CGSize(width: 170, height: 120)
        
        imgView.center = self.view.center
        self.view.addSubview(imgView)
        
        let tapImages: [UIImage] = [
            UIImage(named: "zoom1")!,
            UIImage(named: "zoom2")!,
            UIImage(named: "zoom3")!
        ]
        
        imgView.animationImages = tapImages
        imgView.animationDuration = 1.5 // time duration for complete animation cycle
        imgView.animationRepeatCount = 1 // number of times the animation repeats, set to 1 to play once
        imgView.startAnimating()
        
        // Optional: clear images after animation ends
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            imgView.animationImages = nil
            imgView.removeFromSuperview()
        }
        
    }
    
}


extension ReelNode {
    
    
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
    
    @objc func onClickSave() {
        
        if isSave {
            
            isSave = false
            self.saveCount -= 1
            
            
            unSaveAnimation()
            
            APIManager.shared.unsavePost(postId: post.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                   
                case .failure(let error):
                    print("SaveCount: \(error)")
                    isSave = true
                    saveAnimation()
                }
            }

            
        } else {
            
            self.saveCount += 1
            isSave = true
            
            saveAnimation()
            
            APIManager.shared.savePost(postId: post.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                   
                case .failure(let error):
                    print("SaveCount: \(error)")
                    isSave = false
                    unSaveAnimation()
                }
            }
            
        }
        
        
        
        
    }
    
    
    func unsave() {
        
        APIManager.shared.unsavePost(postId: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print("Share get: \(apiResponse)")
                
                
            case .failure(let error):
                print("SaveCount: \(error)")
            }
        }
        
    }
    
    
    func checkIfSave() {
        
        APIManager.shared.checkSavedPost(pid: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):

                print("Save checked: \(apiResponse)")
                
                guard apiResponse.body?["message"] as? String == "success",
                      let getIsSaved = apiResponse.body?["saved"] as? Bool  else {
                        return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
            
                    isSave = getIsSaved
                    
                    if isSave {
                        saveAnimation()
                    } else {
                        unSaveAnimation()
                    }
                }
            
            case .failure(let error):
                print("SaveCount: \(error)")
                
            }
        }
       
        
    }
    
    func getSaveCount() {
        
        APIManager.shared.countSavedPost(pid: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                
                print("Save check: \(apiResponse)")
                
                guard apiResponse.body?["message"] as? String == "success",
                      let CountFromQuery = apiResponse.body?["saved"] as? Int  else {
                        return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.saveCount = CountFromQuery
                    self.buttonsView.saveCountLbl.text = "\(formatPoints(num: Double(CountFromQuery)))"
                }
               
            case .failure(let error):
                print("SaveCount: \(error)")
            }
        }
        
    }
    
    
    func shareCount() {
        APIManager.shared.countShare(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                print("shareCheck: \(apiResponse)")

                guard let message = apiResponse.body?["message"] as? String,
                      message == "success",
                      let CountFromQuery = apiResponse.body?["data"] as? Int else {
                    print("Error: Invalid or missing data in response")
                    return
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.buttonsView.shareCountLbl.text = "\(formatPoints(num: Double(CountFromQuery)))"
                }

            case .failure(let error):
                print("shareCount Error: \(error)")
            }
        }
    }

    
    @objc func shareTapped() {
    
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        APIManager.shared.createShare(postId: post.id, userId: userUID) { result in
            switch result {
            case .success(let apiResponse):
    
                print(apiResponse)
                
            case .failure(let error):
                print(error)
            }
        
        }
        
        
        let loadUsername = userDataSource.userName
        
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.gg/app/post/?uid=\(post.id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        
        if let vc = UIViewController.currentViewController() {
            
            vc.present(ac, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    @objc func cmtTapped() {
        
        
        if let vc = UIViewController.currentViewController() {
            
            general_vc = vc
            
            let slideVC = CommentVC()
            
            slideVC.post = self.post
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = vc.self
            global_presetingRate = Double(0.75)
            global_cornerRadius = 35
            vc.present(slideVC, animated: true, completion: nil)
            
        }
        
    }
    
    @objc func stitchTapped() {
        
        if let vc = UIViewController.currentViewController() {
            
            if let update1 = vc as? FeedViewController {
                update1.editeddPost = post
            } else if let update1 = vc as? SelectedPostVC {
                update1.editeddPost = post
            }
            
            general_vc = vc
            
            let slideVC = StitchSettingVC()
            
            if vc is FeedViewController {
                slideVC.isFeed = true
            } else {
                slideVC.isFeed = false
            }
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = vc.self
            global_presetingRate = Double(0.30)
            global_cornerRadius = 35
            vc.present(slideVC, animated: true, completion: nil)
            
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
    
    
    @objc func likeTapped() {
        
        if isLike == false {
            performLike()
        } else {
            performUnLike()
        }
         
    }
    
    
    @objc func settingTapped() {
        
        settingBtn?(self)
        
    }
    
    
    @objc func viewStitchTapped() {
        
        viewStitchBtn?(self)
        
    }
    
    @objc func likeHandle() {
        
        
        let imgView = UIImageView()
        imgView.image = popupLikeImage
        imgView.frame.size = CGSize(width: 120, height: 120)
        imgView.contentMode = .scaleAspectFit
        imgView.center = self.view.center
        self.view.addSubview(imgView)
        
        
        self.fireworkController.addFirework(sparks: 10, above: imgView)
        self.fireworkController2.addFireworks(count: 10, sparks: 8, around: imgView)
        
        imgView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.5) {
            
            imgView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if imgView.alpha == 0 {
                
                imgView.removeFromSuperview()
                
            }
            
        }
        
        if isLike == false {
            performLike()
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

        if let vc = UIViewController.currentViewController() {
            
            if let update1 = vc as? FeedViewController {
                                
                imgView.center = update1.view.center
                update1.view.addSubview(imgView)
                                
            } else if let update1 = vc as? SelectedPostVC {
                                
                imgView.center = update1.view.center
                update1.view.addSubview(imgView)
                                
            }
            
            
           
        }

        UIView.animate(withDuration: 0.5, animations: {
            imgView.alpha = 0
            imgView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            imgView.removeFromSuperview()
        }
    }


    
    func checkIfLike() {
        
        APIManager.shared.hasLikedPost(id: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
    
                guard apiResponse.body?["message"] as? String == "success",
                      let checkIsLike = apiResponse.body?["islike"] as? Bool  else {
                        return
                }
                
                self.isLike = checkIsLike
                if self.isLike {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        
        }
    }
    
    func performLike() {

        self.likeCount += 1
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = true
        }
        
        APIManager.shared.likePost(id: post.id) { result in
            switch result {
            case .success(let apiResponse):
               print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func performUnLike() {
        
        
        self.likeCount -= 1
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unlikeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = false
        }
        
        APIManager.shared.unlikePost(id: post.id) { result in

            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func likeAnimation() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.likeBtn.transform = self.buttonsView.likeBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
            
            
            
            
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.likeBtn.transform = CGAffineTransform.identity
              })
        })
        
    }
    
    func saveAnimation() {
        
        
        self.buttonsView.saveCountLbl.text =  "\(formatPoints(num: Double(self.saveCount)))"
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.saveBtn.transform = self.buttonsView.saveBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.saveBtn.setImage(saveImage!, for: .normal)
            
            
            
            
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.saveBtn.transform = CGAffineTransform.identity
              })
        })
        
    }
    
    func unSaveAnimation() {
        
        self.buttonsView.saveCountLbl.text =  "\(formatPoints(num: Double(self.saveCount)))"
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.saveBtn.transform = self.buttonsView.saveBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.saveBtn.setImage(unsaveImage!, for: .normal)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.saveBtn.transform = CGAffineTransform.identity
              })
        })
        
    }
    
    func unlikeAnimation() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.likeBtn.transform = self.buttonsView.saveBtn.transform.scaledBy(x: 0.9, y: 0.9)
            self.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                  self.buttonsView.likeBtn.transform = CGAffineTransform.identity
              })
        })
    }

}

extension ReelNode {
    
    func totalLikeCountFromLocal() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.post.estimatedCount?.sizeLikes ?? 0)))"
        }
        
    }
    
    func totalCmtCountFromLocal() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(self.post.estimatedCount?.sizeComments ?? 0)))"
        }
        
    }
    
    func totalLikeCount() {
        
        APIManager.shared.countLikedPost(id: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
    
                guard apiResponse.body?["message"] as? String == "success",
                      let likeCountFromQuery = apiResponse.body?["likes"] as? Int  else {
                        return
                }
                
                self.likeCount = likeCountFromQuery
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(likeCountFromQuery)))"
                }
               
            case .failure(let error):
                print("LikeCount: \(error)")
            }
        }
        
    }
    
    func totalCmtCount() {
        
        APIManager.shared.countComment(post: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
             
                guard apiResponse.body?["message"] as? String == "success",
                      let commentsCountFromQuery = apiResponse.body?["comments"] as? Int  else {
                        return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(commentsCountFromQuery)))"
                }
                
            case .failure(let error):
                print("CmtCount: \(error)")
            }
        }
        
    }
    
}

extension ReelNode {

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
         
        setupSpace(constrainedSize: constrainedSize)
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1

        let headerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 8)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)

      
        let contentInset = UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 70)
        let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)
        
        let verticalStack = ASStackLayoutSpec.vertical()
        

        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)
        
        verticalStack.children = [headerInsetSpec]
        
        if !post.content.isEmpty || post.hashtags.contains(where: { !$0.isEmpty }) {
            verticalStack.children?.append(contentInsetSpec)
        }

        verticalStack.children?.append(buttonsInsetSpec)
       
                
        let verticalStackInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: verticalStack)
        
   

        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: verticalStackInsetSpec)

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let textInsetSpec1 = ASInsetLayoutSpec(insets: inset, child: gradientNode)
        let textInsetSpec2 = ASInsetLayoutSpec(insets: inset, child: backgroundImage)
     

        if post.muxPlaybackId != "" {
            let textInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)
            
            let backgroundSpec = ASBackgroundLayoutSpec(child: textInsetSpec, background: roundedCornerNode)
            let firstOverlay = ASOverlayLayoutSpec(child: textInsetSpec2, overlay: backgroundSpec)

            let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: textInsetSpec1)
            let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: relativeSpec)

            return thirdOverlay
        } else {
            let imageInsetSpec = ASInsetLayoutSpec(insets: inset, child: imageNode)
            
            let backgroundSpec = ASBackgroundLayoutSpec(child: imageInsetSpec, background: roundedCornerNode)
            let firstOverlay = ASOverlayLayoutSpec(child: textInsetSpec2, overlay: backgroundSpec)
            
            let secondOverlay = ASOverlayLayoutSpec(child: firstOverlay, overlay: textInsetSpec1)
            let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: relativeSpec)

            return thirdOverlay
        }
    }

    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 45)
        let buttonsInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }

    private func setupSpace(constrainedSize: ASSizeRange) {
        delay(0.25) { [weak self] in
            guard let self = self else { return }
            if let buttonsView = self.buttonsView {
             
                let leftAndRightPadding: CGFloat = 16 * 2 // Padding for both sides
                let itemWidth: CGFloat = 60
                let numberOfItems: CGFloat = 4 // Number of items in the stack view
                let superViewWidth: CGFloat = constrainedSize.min.width // Assuming this is the superview's width
                
                // Calculate the total width of items
                let totalItemWidth: CGFloat = numberOfItems * itemWidth
                
                // Calculate the total space we have left for spacing after subtracting the item widths and paddings
                let totalSpacingWidth: CGFloat = superViewWidth - totalItemWidth - leftAndRightPadding
                
                // Calculate the spacing by dividing the total space by the number of spaces (which is 3, for 4 items)
                let spacing: CGFloat = totalSpacingWidth / (numberOfItems - 1)
                
                // Set the calculated spacing
                print(spacing)
                buttonsView.stackView.spacing = spacing
            }
        }
    }



}


extension ReelNode {
    
    func disableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            

            if let update1 = vc as? FeedViewController {
                            
                update1.collectionNode.view.isScrollEnabled = false
                            
                        } else if let update1 = vc as? SelectedPostVC {
                            
                            update1.collectionNode.view.isScrollEnabled = false
                            
                        }
            
            
        }
        
        
    }
    
    func enableScroll() {
        
        if let vc = UIViewController.currentViewController() {
            
            if let update1 = vc as? FeedViewController {
                            
                update1.collectionNode.view.isScrollEnabled = true
                            
                        } else if let update1 = vc as? SelectedPostVC {
                            
                            update1.collectionNode.view.isScrollEnabled = true
                            
                        }
            
            
        }
        
    }
    
}

extension ReelNode: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer || otherGestureRecognizer is UIPinchGestureRecognizer {
            return true
        }

        // Check for the collectionNode's panGestureRecognizer
        if let collectionNodePanGestureRecognizer = collectionNode?.view.panGestureRecognizer, otherGestureRecognizer == collectionNodePanGestureRecognizer {
            return true
        }
        
        if gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }

        return false
    }

    
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
                                    nav.navigationBar.barTintColor = .background
                                    nav.navigationBar.tintColor = .white
                                    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

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

extension ReelNode {
    
    func seeMore() {
        
        setupHideContent()
        setNeedsLayout()
        
    }
    
    func hideContent() {
        
        setupDefaultContent()
        setNeedsLayout()
    }
    
}

class RoundedCornerNode: ASDisplayNode {
    override func didLoad() {
        super.didLoad()
        self.clipsToBounds = true
        self.cornerRadius = 25
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
    }
}

class RoundedCornerImageNode: ASNetworkImageNode {
    override func didLoad() {
        super.didLoad()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
        view.clipsToBounds = true
    }
}

class RoundedCornerVideoNode: ASVideoNode {
    override func didLoad() {
        super.didLoad()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left and right corners
        view.clipsToBounds = true
    }
}


extension UIView {
    func pinToSuperviewEdges() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }
}
