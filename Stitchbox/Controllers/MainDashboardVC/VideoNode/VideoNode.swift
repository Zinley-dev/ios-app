//
//  TestNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/6/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import AVFoundation
import AVKit
import ActiveLabel


class VideoNode: ASCellNode, ASVideoNodeDelegate {

    deinit {
        //view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        print("VideoNode is being deallocated.")
    }
    
    var post: PostModel
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var totalWatchedTime: TimeInterval = 0.0
    var previousTimeStamp: TimeInterval = 0.0
    var videoNode: ASVideoNode
    var gradientNode: GradienView
    var time = 0
    var shouldCountView = true
    var isViewed = false
    var isOriginal = false
    //------------------------------------------//

    var isFirstItem = false
    weak var collectionNode: ASCollectionNode?
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    private var sideButtonsView: ButtonSideList!
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    
    
    private var headerView: PostHeader!
    private var buttonsView: ButtonsHeader!
    private var contentNode: ASTextNode
    private var headerNode: ASDisplayNode
    private var buttonNode: ASDisplayNode
    private var label: ActiveLabel!
    private let maximumShowing = 100
    private var isSave = false
    private var isFollowingUser = false
    private var allowStitch = false
    private var saveCount = 0
    private var likeCount = 0
    private var isLike = false
    private var allowProcess = true
    private var settingBtn : ((ASCellNode) -> Void)?
    fileprivate let FontSize: CGFloat = 14
    fileprivate let OrganizerImageSize: CGFloat = 30
    
    init(with post: PostModel, at: Int) {
        print("VideoNode \(at) is loading post: \(post.id)")
        self.post = post
        self.gradientNode = GradienView()
        self.videoNode = ASVideoNode()
        self.contentNode = ASTextNode()
        self.headerNode = ASDisplayNode()
        self.buttonNode = ASDisplayNode()
        
        super.init()

        configureGradientNode()
        configureVideoNode(with: post)
       
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        addPinchGestureRecognizer()
        addPanGestureRecognizer()
        setupLabel()
        setupViews()
        setupSpace(width: self.view.frame.width)
        
       
        if let parentVC = UIViewController.currentViewController() as? ParentViewController {
          
            if isOriginal {
                // Handle count stitch if not then hide
                
                addSideButtons(isOwned: true)
                
                
            } else {
                addSideButtons(isOwned: false)
            }
        }
    
     }
    
    override func layout() {
        super.layout()
        
        if label != nil {
            label.frame = contentNode.bounds
        }
     
    }
    
    private func setupSpace(width: CGFloat) {
        
        if let buttonsView = self.buttonsView {
         
            let leftAndRightPadding: CGFloat = 16 * 2 // Padding for both sides
            let itemWidth: CGFloat = 60
            let numberOfItems: CGFloat = 4 // Number of items in the stack view
            let superViewWidth: CGFloat = width // Assuming this is the superview's width
            
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
    
    override func didExitVisibleState() {
        videoNode.pause()
    }

    
    private func addSideButtons(isOwned: Bool) {
        sideButtonsView = ButtonSideList()
        sideButtonsView.backgroundColor = .clear
        sideButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideButtonsView)

        sideButtonsView.statusImg.isHidden = false
       
        NSLayoutConstraint.activate([
            sideButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            sideButtonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),
            sideButtonsView.widthAnchor.constraint(equalToConstant: 55),
            sideButtonsView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        if isOwned {
           
            sideButtonsView.originalStack.isHidden = false
            sideButtonsView.stickStack.isHidden = true
            
            let pushToStitch = UITapGestureRecognizer(target: self, action: #selector(VideoNode.pushToStitchView))
            pushToStitch.numberOfTapsRequired = 1
            sideButtonsView.originalStack.addGestureRecognizer(pushToStitch)
            
            sideButtonsView.originalStack.isUserInteractionEnabled = true
            
        } else {
            
            let viewStitchTap = UITapGestureRecognizer(target: self, action: #selector(VideoNode.viewStitchTapped))
            viewStitchTap.numberOfTapsRequired = 1
            sideButtonsView.viewStitchBtn.addGestureRecognizer(viewStitchTap)

            let backToOriginal = UITapGestureRecognizer(target: self, action: #selector(VideoNode.backToOriginal))
            backToOriginal.numberOfTapsRequired = 1
            sideButtonsView.backToOriginalBtn.addGestureRecognizer(backToOriginal)
            
            
            sideButtonsView.originalStack.isHidden = true
            sideButtonsView.stickStack.isHidden = false
            
        }
    
    }

    func updateStitchCount(text: String) {
        
        if sideButtonsView != nil {
            
            sideButtonsView.stitchCount.text = text
            
        }
        
    }

    private func configureGradientNode() {
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
    }

    private func configureVideoNode(with post: PostModel) {
        videoNode.url = getThumbnailURL(post: post)
        videoNode.shouldAutoplay = false
        videoNode.shouldAutorepeat = true
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        videoNode.delegate = self
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)

            if self.isFirstItem {
                self.videoNode.muted = shouldMute ?? !globalIsSound
                self.videoNode.play()
            }
        }
    }

    private func addPinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }

    private func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.minimumNumberOfTouches = 2
        view.addGestureRecognizer(panGestureRecognizer)
    }


    func getThumbnailURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.jpg?time=0"
            
            return URL(string: urlString)
            
        } else {
            return nil
        }
    }
    
    func getVideoURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8"
            return URL(string: urlString)
            
        } else {
            
            return nil
        }
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        headerNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        contentNode.maximumNumberOfLines = 0
        contentNode.truncationMode = .byWordWrapping
        contentNode.style.flexShrink = 1
        videoNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)

        let headerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 8)
        let headerInsetSpec = ASInsetLayoutSpec(insets: headerInset, child: headerNode)

        let contentInset = UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 70)
        let contentInsetSpec = ASInsetLayoutSpec(insets: contentInset, child: contentNode)

        let verticalStack = ASStackLayoutSpec.vertical()
        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)

        verticalStack.children = [headerInsetSpec]

        if !post.content.isEmpty || ((post.hashtags?.contains(where: { !$0.isEmpty })) != nil) {
            verticalStack.children?.append(contentInsetSpec)
        }

        verticalStack.children?.append(buttonsInsetSpec)

        let verticalStackInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: verticalStack)

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let gradientInsetSpec = ASInsetLayoutSpec(insets: inset, child: gradientNode)

        // Here we have removed the roundedCornerNode and using videoNode directly
        let videoInsetSpec = ASInsetLayoutSpec(insets: inset, child: videoNode)

        let overlay = ASOverlayLayoutSpec(child: videoInsetSpec, overlay: gradientInsetSpec)

        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: verticalStackInsetSpec)
        let finalOverlay = ASOverlayLayoutSpec(child: overlay, overlay: relativeSpec)

        return finalOverlay
        
    }
    
    
    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 45)
        let buttonsInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }
    

 
}


extension VideoNode {
    
    func playProcess() {
        
        if videoNode.isPlaying() {
            videoNode.pause()
        } else {
            videoNode.play()
        }
        
    }

  
    func didTap(_ videoNode: ASVideoNode) {
        if let vc = UIViewController.currentViewController() {
            switch vc {
            case _ as PreviewVC:
                playProcess()
            case let parentVC as ParentViewController:
                if parentVC.isFeed {
                    playProcess()
                } else if !parentVC.stitchViewController.selectPostCollectionView.isHidden {
                    parentVC.stitchViewController.selectPostCollectionView.isHidden = true
                    showAllInfo()
                } else {
                    playProcess()
                }
            default:
                break
            }
        }
    }

    func hideAllInfo() {
        headerNode.isHidden = true
        contentNode.isHidden = true
        sideButtonsView.isHidden = true
        buttonNode.isHidden = true
        label.isHidden = true
    }
    
    func showAllInfo() {
        headerNode.isHidden = false
        contentNode.isHidden = false
        sideButtonsView.isHidden = false
        buttonNode.isHidden = false
        label.isHidden = false
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
     
    }
    
    func videoDidPlay(toEnd videoNode: ASVideoNode) {
    
        shouldCountView = true
       
        
    }
    
    @objc func endVideo(watchTime: Double) {
        guard let _ = _AppCoreData.userDataSource.value, time < 2 else { return }
        
        time += 1
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


    func setVideoProgress(rate: Float, currentTime: TimeInterval, maxDuration: CMTime) {
        if let vc = UIViewController.currentViewController() {
            if let update1 = vc as? ParentViewController {
                
                if update1.isFeed {
                    updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.feedViewController.playTimeBar)
                } else {
                    updateSlider(currentTime: currentTime, maxDuration: maxDuration, playTimeBar: update1.stitchViewController.playTimeBar)
                }
                
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

extension VideoNode {
    
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
                        }, completion: { [weak self]_ in
                            self?.enableScroll()
                })
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
                
            }
            
            
        }

        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
           
            UIView.animate(withDuration: 0.2, animations: {
                        
                    }, completion: { [weak self] _ in
                        self?.enableScroll()
                    })
            
        }
    }
    
    func setScrollEnabled(_ isEnabled: Bool) {
        if let vc = UIViewController.currentViewController() {
            switch vc {
            case let parentVC as ParentViewController:
                if parentVC.isFeed {
                    parentVC.feedViewController.collectionNode.view.isScrollEnabled = isEnabled
                } else {
                    parentVC.stitchViewController.collectionNode.view.isScrollEnabled = isEnabled
                }
            case let selectedPostVC as SelectedPostVC:
                selectedPostVC.collectionNode.view.isScrollEnabled = isEnabled
            default:
                break
            }
        }
    }

    func disableScroll() {
        setScrollEnabled(false)
    }

    func enableScroll() {
        setScrollEnabled(true)
    }


    
}


extension VideoNode: UIGestureRecognizerDelegate {
    
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
    
    @objc func pushToStitchView() {
        if let vc = UIViewController.currentViewController() {
            if vc is ParentViewController {
                if let update1 = vc as? ParentViewController {
                    if update1.isFeed {
                        // Calculate the next page index
                       
                        let offset = CGFloat(1) * update1.scrollView.bounds.width
                        
                        // Scroll to the next page
                        update1.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                        update1.showStitch()
                      
                    }
                }
            }
        }
    }
    
    @objc func viewStitchTapped() {
        if let vc = UIViewController.currentViewController() {
            if vc is ParentViewController {
                if let update1 = vc as? ParentViewController {
                    if !update1.isFeed {
                        hideAllInfo()
                        update1.stitchViewController.selectPostCollectionView.isHidden = false
                      
                    }
                }
            }
        }
    }
    
    
    @objc func backToOriginal() {
        if let vc = UIViewController.currentViewController() {
            if vc is ParentViewController {
                if let update1 = vc as? ParentViewController {
                    if !update1.isFeed {
                        // Calculate the next page index
                       
                        let offset = CGFloat(0) * update1.scrollView.bounds.width
        
                        // Scroll to the next page
                        update1.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                        update1.showFeed()
                       
                    }
                }
            }
        }
    }

    func setupLabel() {
        self.label = ActiveLabel()
        self.contentNode.backgroundColor = .clear
        self.label.backgroundColor = .clear
        self.contentNode.view.addSubview(self.label)
        self.contentNode.view.isUserInteractionEnabled = true
      
        let customType = ActiveType.custom(pattern: "\\*more\\b|\\*hide\\b")
        self.label.customColor[customType] = .lightGray
        self.label.enabledTypes = [.hashtag, .url, customType]
        self.label.numberOfLines = Int(self.contentNode.lineCount)
        self.label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        self.label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        
        self.label.handleCustomTap(for: customType) { [weak self] element in
            guard let self = self else { return }
            element == "*more" ? self.seeMore() : self.hideContent()
        }
        
        self.label.handleHashtagTap { hashtag in
            self.presentPostListWithHashtagVC(for: "#" + hashtag)
        }

        self.label.handleURLTap { [weak self] string in
            self?.handleURLTap(url: string.absoluteString)
        }
        
        setupDefaultContent()
        
    }
    
    func setupViews() {
        // Header View Setup
        self.headerView = PostHeader()
        self.headerNode.view.addSubview(self.headerView)
        addConstraints(to: self.headerView, within: self.headerNode.view)
    
        if post.setting?.allowStitch == false {
            hideStitchViews()
        } else if _AppCoreData.userDataSource.value?.userID == self.post.owner?.id {
            hideStitchViews()
        }


        self.headerView.usernameLbl.text = "@\(post.owner?.username ?? "")"

        // Buttons View Setup
        self.buttonsView = ButtonsHeader()
        self.buttonNode.view.addSubview(self.buttonsView)
        addConstraints(to: self.buttonsView, within: self.buttonNode.view)
        self.buttonsView.shareBtn.setImage(shareImage, for: .normal)
        self.buttonsView.saveBtn.setImage(unsaveImage, for: .normal)
        self.buttonsView.commentBtn.setImage(cmtImage, for: .normal)

        // Gesture Recognizers
        setupGestureRecognizers()
        fillStats()
        loadReaction()
    }
    
    func fillStats() {
        
        likeCount = post.totalLikes
        saveCount = post.totalSave
        
        self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(post.totalLikes)))"
        self.buttonsView.saveCountLbl.text = "\(formatPoints(num: Double(post.totalShares)))"
        self.buttonsView.commentCountLbl.text = "\(formatPoints(num: Double(post.totalComments)))"
        self.buttonsView.shareCountLbl.text = "\(formatPoints(num: Double(post.totalShares)))"
        
    }

    func addConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant).isActive = true
        childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: constant).isActive = true
        childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant).isActive = true
        childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: constant).isActive = true
    }

    func hideStitchViews() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.createStitchView.isHidden = true
            self.headerView.createStitchStack.isHidden = true
            self.headerView.stichBtn.isHidden = true
        }
        
       
    }

    func showStitchViews() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.createStitchView.isHidden = false
            self.headerView.stichBtn.isHidden = false
            self.headerView.createStitchStack.isHidden = false
        }
    
    }

    func setupGestureRecognizers() {
     
        let usernameTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.userTapped))
        self.headerView.usernameLbl.isUserInteractionEnabled = true
        self.headerView.usernameLbl.addGestureRecognizer(usernameTap)
        
        let shareTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.shareTapped))
        self.buttonsView.shareBtn.addGestureRecognizer(shareTap)

        let likeTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.likeTapped))
        self.buttonsView.likeBtn.addGestureRecognizer(likeTap)

        let stitchTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.stitchTapped))
        self.headerView.stichBtn.addGestureRecognizer(stitchTap)

        let saveTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.onClickSave))
        self.buttonsView.saveBtn.addGestureRecognizer(saveTap)

        let commentTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.commentTapped))
        self.buttonsView.commentBtn.addGestureRecognizer(commentTap)

        let doubleTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.likeHandle), taps: 2)
        doubleTap.delaysTouchesBegan = true
        self.view.addGestureRecognizer(doubleTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(VideoNode.settingTapped))
        longPress.minimumPressDuration = 0.65
        longPress.delaysTouchesBegan = true
        self.view.addGestureRecognizer(longPress)
        
    }


    func createTapGestureRecognizer(target: Any, action: Selector, taps: Int = 1) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = taps
        return tap
    }

    func handleURLTap(url: String) {
        if url.contains("https://stitchbox.net/app/account/") || url.contains("https://stitchbox.net/app/post/") {
            if let id = self.getUIDParameter(from: url) {
                url.contains("account") ? self.moveToUserProfileVC(id: id) : self.openPost(id: id)
            }
        } else if let requestUrl = URL(string: url), UIApplication.shared.canOpenURL(requestUrl) {
            UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
        }
    }

    func presentPostListWithHashtagVC(for selectedHashtag: String) {
        guard let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC,
              let vc = UIViewController.currentViewController() else { return }
        
        let nav = UINavigationController(rootViewController: PLHVC)
        PLHVC.searchHashtag = selectedHashtag
        PLHVC.onPresent = true
        nav.navigationBar.barTintColor = .background
        nav.navigationBar.tintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.modalPresentationStyle = .fullScreen
        vc.present(nav, animated: true, completion: nil)
    }
    
    func seeMore() {
        
        setupHideContent()
        setNeedsLayout()
        
    }
    
    func hideContent() {
        
        setupDefaultContent()
        setNeedsLayout()
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
        label.attributedText = attr2
      
        setNeedsLayout()
        layoutIfNeeded()
       
        
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
        label.attributedText = attr2
        
        setNeedsLayout()
        layoutIfNeeded()
       
       
    }
    
    private func processTextForHiding(_ text: String) -> String {
        if text.count > maximumShowing {
            return text + " *hide"
        } else {
            return text
        }
    }
    
    func moveToUserProfileVC(id: String) {
        guard let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC,
              let vc = UIViewController.currentViewController() else { return }

        if general_vc != nil {
            general_vc.viewWillDisappear(true)
            general_vc.viewDidDisappear(true)
        }

        let nav = UINavigationController(rootViewController: UPVC)
        UPVC.userId = id
        UPVC.onPresent = true
        nav.navigationBar.barTintColor = .background
        nav.navigationBar.tintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.modalPresentationStyle = .fullScreen
        vc.present(nav, animated: true, completion: nil)
    }

    
    func openPost(id: String) {
        presentSwiftLoader()

        APIManager.shared.getPostDetail(postId: id) { result in
            DispatchQueue.main.async {
                SwiftLoader.hide()
            }

            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body, !data.isEmpty, let post = PostModel(JSON: data) else {
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.presentSelectedPostVC(with: [post])
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func presentSelectedPostVC(with posts: [PostModel]) {
        guard let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC,
              let vc = UIViewController.currentViewController() else { return }

        if general_vc != nil {
            general_vc.viewWillDisappear(true)
            general_vc.viewDidDisappear(true)
        }

        RVC.onPresent = true
        RVC.posts = posts

        let nav = UINavigationController(rootViewController: RVC)
        nav.navigationBar.barTintColor = .background
        nav.navigationBar.tintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.modalPresentationStyle = .fullScreen

        vc.present(nav, animated: true, completion: nil)
    }

    func getUIDParameter(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return components?.queryItems?.first(where: { $0.name == "uid" })?.value
        } else {
            return nil
        }
    }
    
    private func truncateTextIfNeeded(_ text: String) -> String {
        if text.count > maximumShowing, text.count - maximumShowing >= 20 {
            return String(text.prefix(maximumShowing)) + " ..." + " *more"
        } else {
            return text
        }
    }
    
}

extension VideoNode {
    
    @objc func userTapped() {
        guard let userId = post.owner?.id,
              let username = post.owner?.username,
              !userId.isEmpty,
              !username.isEmpty,
              userId != _AppCoreData.userDataSource.value?.userID else {
            return
        }
        
        showUserProfile(for: userId, with: username)
    }

    private func showUserProfile(for userId: String, with username: String) {
        guard let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC,
              let currentVC = UIViewController.currentViewController() else {
            return
        }

        configureUserProfileVC(UPVC, with: userId, nickname: username)

        let nav = UINavigationController(rootViewController: UPVC)
        configureNavigationController(nav)

        currentVC.present(nav, animated: true, completion: nil)
    }

    private func configureUserProfileVC(_ UPVC: UserProfileVC, with userId: String, nickname: String) {
        UPVC.userId = userId
        UPVC.nickname = nickname
        UPVC.onPresent = true
    }

    private func configureNavigationController(_ navigationController: UINavigationController) {
        navigationController.navigationBar.barTintColor = .background
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController.modalPresentationStyle = .fullScreen
    }

    
    @objc func onClickSave() {
        isSave.toggle()
        if isSave {
            handleSave()
        } else {
            handleUnsave()
        }
    }

    private func handleSave() {
        saveCount += 1
        saveAnimation()
        APIManager.shared.savePost(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("SaveCount: \(error)")
                self.isSave = false
                self.unSaveAnimation()
            case .success(let apiResponse):
                print(apiResponse)
            }
        }
    }

    private func handleUnsave() {
        saveCount -= 1
        unSaveAnimation()
        APIManager.shared.unsavePost(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("SaveCount: \(error)")
                self.isSave = true
                self.saveAnimation()
            case .success(let apiResponse):
                print(apiResponse)
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
                      let getIsSaved = apiResponse.body?["saved"] as? Bool else {
                    return
                }

                DispatchQueue.main.async {
                    self.isSave = getIsSaved
                    if self.isSave {
                        self.saveAnimation()
                    } else {
                        self.unSaveAnimation()
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
                      let countFromQuery = apiResponse.body?["saved"] as? Int else {
                    return
                }

                DispatchQueue.main.async {
                    self.saveCount = countFromQuery
                    self.buttonsView.saveCountLbl.text = "\(formatPoints(num: Double(countFromQuery)))"
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
                      let countFromQuery = apiResponse.body?["data"] as? Int else {
                    print("Error: Invalid or missing data in response")
                    return
                }

                DispatchQueue.main.async {
                    self.buttonsView.shareCountLbl.text = "\(formatPoints(num: Double(countFromQuery)))"
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
        
        createShare(userUID: userUID)
        
        if let loadUsername = userDataSource.userName {
            presentShareController(username: loadUsername)
        }
    }

    private func createShare(userUID: String) {
        APIManager.shared.createShare(postId: post.id, userId: userUID) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func presentShareController(username: String) {
        let items: [Any] = ["Hi I am \(username) from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(post.id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let vc = UIViewController.currentViewController() {
            vc.present(ac, animated: true, completion: nil)
        }
    }

    
    
    @objc func commentTapped() {
        guard let viewController = UIViewController.currentViewController() else { return }

        general_vc = viewController

        let slideVC = CommentVC()
        slideVC.post = self.post
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = viewController
        global_presetingRate = 0.75
        global_cornerRadius = 35

        viewController.present(slideVC, animated: true, completion: nil)
    }

    @objc func stitchTapped() {
        guard let vc = UIViewController.currentViewController(), allowStitch else {
            showStitchError()
            return
        }

        if let updateVC = vc as? ParentViewController{
            if updateVC.isFeed {
                updateVC.feedViewController.editeddPost = post
            } else {
                updateVC.stitchViewController.editeddPost = post
            }
        
        }

        general_vc = vc

        let slideVC = StitchSettingVC()
        slideVC.isFeed = vc is FeedViewController
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = vc.self
        global_presetingRate = 0.25
        global_cornerRadius = 35

        vc.present(slideVC, animated: true, completion: nil)
    }

    private func showStitchError() {
        /*
        guard let vc = UIViewController.currentViewController() as? FeedViewController ?? UIViewController.currentViewController() as? SelectedPostVC, let username = post.owner?.username else { return }

        let myUsername = _AppCoreData.userDataSource.value?.userName
        let title = myUsername != nil ? "Hi \(myUsername!)," : "Oops!"
        let message = "@\(username) have to follow you to enable stitch."

        vc.showErrorAlert(title, msg: message)
        */
    }

    
    @objc func followTap() {
        guard allowProcess else { return }
        
        allowProcess = false
        isFollowingUser ? unfollowUser() : followUser()
    }

    
    
    @objc func likeTapped() {
        isLike ? performUnLike() : performLike()
    }

    
    
    @objc func settingTapped() {
        
        settingBtn?(self)
        
    }

    
    @objc func likeHandle() {
        guard !isLike else { return }
        
        let imgView = createImageView()
        view.addSubview(imgView)
        
        fireworkController.addFirework(sparks: 10, above: imgView)
        fireworkController2.addFireworks(count: 10, sparks: 8, around: imgView)
        
        animateImageView(imgView)
        
        performLike()
    }

    private func createImageView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = popupLikeImage
        imgView.frame.size = CGSize(width: 120, height: 120)
        imgView.contentMode = .scaleAspectFit
        imgView.center = view.center
        return imgView
    }

    private func animateImageView(_ imgView: UIImageView) {
        
        UIView.animate(withDuration: 0.5) {
            imgView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            imgView.removeFromSuperview()
        }
    }

    
    func performLike() {
        likeCount += 1
        updateLikeUI()

        APIManager.shared.likePost(id: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func updateLikeUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = true
        }
    }


    
    func performUnLike() {
        likeCount -= 1
        updateUnlikeUI()

        APIManager.shared.unlikePost(id: post.id) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
                
            }
        }
    }

    private func updateUnlikeUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unlikeAnimation()
            self.buttonsView.likeCountLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
            self.isLike = false
        }
    }
    
    func likeAnimation() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            
            let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.buttonsView.likeBtn.transform = scaleTransform
                self.buttonsView.likeBtn.setImage(likeImage!, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.buttonsView.likeBtn.transform = CGAffineTransform.identity
                })
            })
            
        }
        
    }

    
    func saveAnimation() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            
            let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)

            self.buttonsView.saveCountLbl.text = "\(formatPoints(num: Double(self.saveCount)))"

            UIView.animate(withDuration: 0.1, animations: {
                self.buttonsView.saveBtn.transform = scaleTransform
                self.buttonsView.saveBtn.setImage(saveImage!, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.buttonsView.saveBtn.transform = CGAffineTransform.identity
                })
            })
            
        }
        
    }

    
    func unSaveAnimation() {
        
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            self.buttonsView.saveCountLbl.text = "\(formatPoints(num: Double(self.saveCount)))"

            UIView.animate(withDuration: 0.1, animations: {
                self.buttonsView.saveBtn.transform = scaleTransform
                self.buttonsView.saveBtn.setImage(unsaveImage!, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.buttonsView.saveBtn.transform = CGAffineTransform.identity
                })
            })
        }
        
        
    }

    
    func unlikeAnimation() {
        let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.likeBtn.transform = scaleTransform
            self.buttonsView.likeBtn.setImage(emptyLikeImage!, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.buttonsView.likeBtn.transform = CGAffineTransform.identity
            })
        })
    }
    
    func unfollowUser() {
        guard let userId = post.owner?.id else { return }

        DispatchQueue.main.async { [weak self] in
            self?.headerView.followBtn.setTitle("Follow", for: .normal)
        }

        APIManager.shared.unFollow(params: ["FollowId": userId]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.isFollowingUser = false
                needRecount = true
                self.allowProcess = true

            case .failure:
                DispatchQueue.main.async {
                    self.allowProcess = true
                    self.headerView.followBtn.setTitle("Following", for: .normal)
                    showNote(text: "Something happened!")
                }
            }
        }
    }

    func followUser() {
        guard let userId = post.owner?.id else { return }

        DispatchQueue.main.async { [weak self] in
            self?.headerView.followBtn.setTitle("Following", for: .normal)
        }

        APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.isFollowingUser = true
                self.allowProcess = true

            case .failure:
                DispatchQueue.main.async {
                    self.allowProcess = true
                    self.headerView.followBtn.setTitle("Follow", for: .normal)
                    showNote(text: "Something happened!")
                }
            }
        }
    }

    
    func loadReaction() {
        APIManager.shared.getReactionPost(postId: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                guard let message = apiResponse.body?["message"] as? String,
                      message == "success",
                      let data = apiResponse.body?["data"] as? [String: Any],
                      let isFollower = data["isFollower"] as? Bool,
                      let isFollowing = data["isFollowing"] as? Bool,
                      let isLiked = data["isLike"] as? Bool,
                      let isSaved = data["isSaved"] as? Bool else {
                    print("Error: Invalid or missing data in response")
                    return
                }
                
                self.handleReaction(isFollower: isFollower, isFollowing: isFollowing, isLiked: isLiked, isSaved: isSaved)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleReaction(isFollower: Bool, isFollowing: Bool, isLiked: Bool, isSaved: Bool) {
        self.allowStitch = isFollower
        if !isFollower {
            self.hideStitchViews()
        } else {
            
            if post.setting?.allowStitch == true {
                self.showStitchViews()
            } else {
                self.hideStitchViews()
            }
            
        }

        if isFollowing {
            self.hideFollowBtn()
        } else {
            self.setupFollowBtn()
        }
            
        self.isSave = isSaved
        if isSaved {
            self.saveAnimation()
        } else {
            self.unSaveAnimation()
        }

            self.isLike = isLiked
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let likeImage = isLiked ? likeImage! : emptyLikeImage!
            self.buttonsView.likeBtn.setImage(likeImage, for: .normal)
        }
    }

    func hideFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = true
            self.isFollowingUser = true
        }
        
    }


    func setupFollowBtn() {
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.headerView.followBtn.isHidden = false
            self.isFollowingUser = false
            let followTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(demoNode.followTap))
            followTap.numberOfTapsRequired = 1
            self.headerView.followBtn.addGestureRecognizer(followTap)
            
        }
    }
    
}
