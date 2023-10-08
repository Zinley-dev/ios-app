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
import NVActivityIndicatorView

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
    var spinnerRemoved = true
    var assetReset = false
    var buttonNode: ASDisplayNode!
    var post: PostModel!
    private var cellVideoNode: ASVideoNode
    var headerView: PostHeader!
   
    var gradientNode: GradienView
    var label: ActiveLabel!
    var stitchView: UnStitchView!
    var infoNode: ASTextNode!
    let maximumShowing = 100
    var isActive = false
    var unstitchBtn : ((ASCellNode) -> Void)?
    var stitchTo: Bool
    private var didSetup = false
    private var spinner: NVActivityIndicatorView!
    var statusObservation: NSKeyValueObservation?
    
    init(with post: PostModel, stitchTo: Bool) {
        self.post = post
        self.stitchTo = stitchTo
        self.cellVideoNode = ASVideoNode()
        self.gradientNode = GradienView()
        self.buttonNode = ASDisplayNode()
        self.infoNode = ASTextNode()
        super.init()
        
        configureGradientNode()
        configureVideoNode(with: post)
    
        automaticallyManagesSubnodes = true
    
    }
    
    
    override func didLoad() {
        spinner = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 55, height: 55), type: .circleStrokeSpin, color: .white, padding: 0)
    }
    
    override func didEnterVisibleState() {
        isActive = true
        if !didSetup {
            setupLayout()
        }
        
    }
    
    func setupLayout() {
        setupViews()
        setupLabel()
        configureInfoNode(for: post, stitchTo: stitchTo, fontSize: FontSize)
        
        self.cellVideoNode.view.layer.cornerRadius = 10
        self.cellVideoNode.view.clipsToBounds = true
        
        self.gradientNode.cornerRadius = 10
        self.gradientNode.clipsToBounds = true
    }
    

    

    override func layout() {
        super.layout()
        if self.label != nil, self.headerView != nil {
            self.label.frame = self.headerView.contentLbl.bounds
            self.label.numberOfLines = Int(self.headerView.contentLbl.numberOfLines)
        }
        
    }
    
    private func configureGradientNode() {
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
    }
    
    
    func configureInfoNode(for post: PostModel, stitchTo: Bool, fontSize: CGFloat) {
        if stitchTo {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let statusText = post.isApproved ? "Approved" : "Pending"
            
            infoNode.attributedText = NSAttributedString(
                string: statusText,
                attributes: [
                    .font: FontManager.shared.roboto(.Bold, size: fontSize),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ]
            )
            infoNode.cornerRadius = 3
        }
    }


    private func configureVideoNode(with post: PostModel) {
        
        cellVideoNode.url = getThumbnailURL(post: post)
        cellVideoNode.player?.automaticallyWaitsToMinimizeStalling = true
        cellVideoNode.shouldAutoplay = false
        cellVideoNode.shouldAutorepeat = true
        cellVideoNode.delegate = self
        
        if let width = post.metadata?.width, let height = post.metadata?.height, width != 0, height != 0 {
            // Calculate aspect ratio
            let aspectRatio = Float(width) / Float(height)
            
            if aspectRatio >= 0.5 && aspectRatio <= 0.7 { // Close to 9:16 aspect ratio (vertical)
                cellVideoNode.contentMode = .scaleAspectFill
                cellVideoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            } else if aspectRatio >= 1.7 && aspectRatio <= 1.9 { // Close to 16:9 aspect ratio (landscape)
                cellVideoNode.contentMode = .scaleAspectFit
                cellVideoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                
            } else {
                // Default contentMode, adjust as needed
                cellVideoNode.contentMode = .scaleAspectFit
                cellVideoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                
            }
        } else {
            // Default contentMode, adjust as needed
            cellVideoNode.contentMode = .scaleAspectFill
            cellVideoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cellVideoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
        }
        
    }

    
    func setupLabel() {
        self.label = ActiveLabel()
    
        self.label.backgroundColor = .clear
        self.headerView.contentLbl.addSubview(self.label)
        self.headerView.contentLbl.isUserInteractionEnabled = true
        
      
        let customType = ActiveType.custom(pattern: "\\*more\\b|\\*hide\\b")
        self.label.customColor[customType] = .lightGray
        self.label.enabledTypes = [.hashtag, .url, customType]
       
        self.label.hashtagColor = UIColor(red: 208/255, green: 223/255, blue: 252/255, alpha: 1)

        self.label.URLColor = UIColor(red: 60/255, green: 115/255, blue: 180/255, alpha: 1)

        
        self.label.handleCustomTap(for: customType) { [weak self] element in
            guard let self = self else { return }
            element == "*more" ? self.seeMore() : self.hideContent()
        }
        
        self.label.handleHashtagTap { [weak self] hashtag in
            guard let self = self else { return }
            self.presentPostListWithHashtagVC(for: "#" + hashtag)
        }

        self.label.handleURLTap { [weak self] string in
            guard let self = self else { return }
            self.handleURLTap(url: string.absoluteString)
        }
    
        
    
        setupDefaultContent()
        
    }
    
    func setupViews() {
        // Header View Setup
        
        self.headerView = PostHeader()
        self.view.addSubview(self.headerView)
        
        addConstraints(to: self.headerView, within: self.view)
    
        self.headerView.contentLbl.numberOfLines = 0
        self.headerView.contentLbl.lineBreakMode = .byWordWrapping
        
        self.headerView.contentLbl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.headerView.contentLbl.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)


        self.headerView.usernameLbl.text = "@\(post.owner?.username ?? "")"
        self.headerView.stackView.isHidden = true
        self.headerView.stackConstant.constant = 0
        
        //
        self.stitchView = UnStitchView()
        self.stitchView.backgroundColor = .clear
        self.buttonNode.view.addSubview(self.stitchView)
        self.stitchView.translatesAutoresizingMaskIntoConstraints = false
        self.stitchView.topAnchor.constraint(equalTo: self.buttonNode.view.topAnchor, constant: 0).isActive = true
        self.stitchView.bottomAnchor.constraint(equalTo: self.buttonNode.view.bottomAnchor, constant: 0).isActive = true
        self.stitchView.leadingAnchor.constraint(equalTo: self.buttonNode.view.leadingAnchor, constant: 0).isActive = true
        self.stitchView.trailingAnchor.constraint(equalTo: self.buttonNode.view.trailingAnchor, constant: 0).isActive = true
        
        let unstitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.unstitchBtnTapped))
        unstitchTap.numberOfTapsRequired = 1
        self.stitchView.unstitchBtn.addGestureRecognizer(unstitchTap)
        
        
        // Gesture Recognizers
        setupGestureRecognizers()
        
    }

    func addConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        
        let change = self.view.frame.width - ( self.view.frame.height * 9 / 16)
        let padding = change / 2
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant).isActive = true
        childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -60).isActive = true
        childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: padding).isActive = true
        childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: padding).isActive = true
    }
    
    func setupGestureRecognizers() {
        
        let vidTap = createTapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.tapProcess))
        self.headerView.restView.isUserInteractionEnabled = true
        self.headerView.restView.addGestureRecognizer(vidTap)
     
        let usernameTap = createTapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.userTapped))
        self.headerView.usernameLbl.isUserInteractionEnabled = true
        self.headerView.usernameLbl.addGestureRecognizer(usernameTap)

        
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

        headerView.backgroundColor = UIColor.clear

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
            
        self.headerView.contentLbl.attributedText = attr1
        label.attributedText = attr2
          
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()
            
            
            
        }
        
    func setupHideContent() {
            
        headerView.backgroundColor = UIColor.clear
            
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
            
            
        self.headerView.contentLbl.attributedText = attr1
        label.attributedText = attr2
            
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()

           
    }
        
    private func processTextForHiding(_ text: String) -> String {
        if text.count > maximumShowing {
            return text + " *hide"
        } else {
            return text
        }
    }

    private func truncateTextIfNeeded(_ text: String) -> String {
        if text.count > maximumShowing, text.count - maximumShowing >= 20 {
            return String(text.prefix(maximumShowing)) + " ..." + " *more"
        } else {
            return text
        }
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
                
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8?redundant_streams=true&max_resolution=720p"
            return URL(string: urlString)
                
        } else {
                
            return nil
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
        guard let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedParentVC,
              let vc = UIViewController.currentViewController() else { return }

        if general_vc != nil {
            general_vc.viewWillDisappear(true)
            general_vc.viewDidDisappear(true)
        }

        RVC.onPresent = true
        RVC.posts = posts
        RVC.startIndex = 0
        
        let nav = UINavigationController(rootViewController: RVC)


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

    

}


extension StitchControlForRemoveNode {
    
    private func createButtonsInsetSpec(constrainedSize: ASSizeRange) -> ASInsetLayoutSpec {
        
        let change = constrainedSize.max.width - ( constrainedSize.max.height * 9 / 16)
        let padding = change / 2
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 55)
        let buttonsInset = UIEdgeInsets(top: 10, left: padding - 1, bottom: -10, right: padding - 1)
        return ASInsetLayoutSpec(insets: buttonsInset, child: buttonNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let change = constrainedSize.max.width - ( constrainedSize.max.height * 9 / 16)
        let padding = change / 2
        
        let inset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        let gradientInsetSpec = ASInsetLayoutSpec(insets: inset, child: gradientNode)
        let videoInsetSpec = ASInsetLayoutSpec(insets: inset, child: cellVideoNode)
        let overlay = ASOverlayLayoutSpec(child: videoInsetSpec, overlay: gradientInsetSpec)
        
        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)
        let verticalStackInset = UIEdgeInsets(top: .infinity, left: 0, bottom: 8, right: 0)
        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: buttonsInsetSpec)
        let finalOverlay = ASOverlayLayoutSpec(child: overlay, overlay: verticalStackInsetSpec)
        
        if stitchTo {
            infoNode.style.preferredSize = CGSize(width: 75, height: 15)
            let stitchCountInsets = UIEdgeInsets(top: 8, left: 8 + padding, bottom: .infinity, right: .infinity)
            let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: infoNode)
            let overlay2 = ASOverlayLayoutSpec(child: finalOverlay, overlay: stitchCountInsetSpec)
            return overlay2
        } else {
            return finalOverlay
        }
    }
    
  
}

extension StitchControlForRemoveNode {

    @objc func tapProcess() {
        
        if let vc = UIViewController.currentViewController() {
            switch vc {
            case let dashboard as StitchDashboardVC:
                
                if dashboard.StitchToVC.view.isHidden != true || dashboard.ApprovedStitchVC.view.isHidden != true {
                    playProcess()
                }
            
            default:
                break
            }
        }
        
    }
    
    func playProcess() {
        
        if cellVideoNode.isPlaying() {
            cellVideoNode.pause()
        } else {
            cellVideoNode.play()
        }
        
    }

  
    func didTap(_ videoNode: ASVideoNode) {
        tapProcess()
    }

    
    @objc func unstitchBtnTapped() {
            
        unstitchBtn?(self)
            
    }
    
    
}

extension StitchControlForRemoveNode {

    func playVideo() {
        // Check if video is already playing
        if cellVideoNode.isPlaying() {
            return
        }

        // Determine if the video should be muted
        if let muteStatus = shouldMute {
            cellVideoNode.muted = muteStatus
        } else {
            cellVideoNode.muted = !globalIsSound
        }
        
        // Remove existing observers
        removeObservers()

        // Check if currentItem is available
        if let _ = cellVideoNode.currentItem {
            addObservers()
        } else {
            // Delay to ensure currentItem becomes available
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if let _ = self?.cellVideoNode.currentItem {
                    self?.addObservers()
                } else {
                    // Handle or log error - still not ready
                }
            }
        }
    }

    func addObservers() {
        statusObservation = cellVideoNode.currentItem?.observe(\.status, options: [.new, .initial], changeHandler: { [weak self] (playerItem, change) in
            print("statusObservation called for: \(self?.post.id) - \(playerItem.status.rawValue)")
            self?.handleStatusChange()
        })
    }
    
    func handleStatusChange() {
        guard let status = cellVideoNode.currentItem?.status else { return }

        switch status {
        case .readyToPlay:
            startPlayback()
        case .failed:
            printStatusDetails(withPrefix: "FAILED TO play failed")
        case .unknown:
            printStatusDetails(withPrefix: "FAILED TO play unknown")
        @unknown default:
            printStatusDetails(withPrefix: "FAILED TO play default")
        }
    }


    func printStatusDetails(withPrefix prefix: String) {
        
        let connectionStatus = ReachabilityManager.shared.reachability.connection

        if connectionStatus == .unavailable {
            showNote(text: "No Internet Connection")
        } else {
            let bufferFull = cellVideoNode.currentItem?.isPlaybackBufferFull ?? false
            let bufferEmpty = cellVideoNode.currentItem?.isPlaybackBufferEmpty ?? false
            let likelyToKeepUp = cellVideoNode.currentItem?.isPlaybackLikelyToKeepUp ?? false
            let error = cellVideoNode.currentItem?.error?.localizedDescription ?? "Unknown error"
            
            print("\(prefix): \(bufferFull) - \(bufferEmpty) - \(likelyToKeepUp) - \(error)")
            
            cellVideoNode.currentItem?.preferredForwardBufferDuration = 5
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                
                guard let status = self?.cellVideoNode.currentItem?.status else {
                    print("FAILED - status null")
                    self?.resetAssets()
                    return
                }
                
                switch status {
                case .readyToPlay:
                    self?.startPlayback()
                    print("FAILED - Ready to play")
                case .failed:
                    //self?.resetAssets()
                    self?.addSpinner()
                    print("FAILED TO play failed")
                case .unknown:
                    //self?.resetAssets()
                    self?.addSpinner()
                    print("FAILED TO play unknown")
                @unknown default:
                    //self?.resetAssets()
                    self?.addSpinner()
                    print("FAILED TO play default")
                }
                
            }
        }

        
    }
    
    func addSpinner() {
        
        if spinnerRemoved {
            
            spinner.center = view.center
            view.addSubview(spinner)
            spinner.startAnimating()
            spinnerRemoved = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            if self?.cellVideoNode.isPlaying() == true {
                self?.removeSpinner()
                return
            }
            
            guard let status = self?.cellVideoNode.currentItem?.status else {
                print("FAILED - status null")
                self?.resetAssets()
                return
            }
            
            switch status {
            case .readyToPlay:
                self?.startPlayback()
                print("FAILED - Ready to play")
            case .failed, .unknown:
                if let likelyToKeepUp = self?.cellVideoNode.currentItem?.isPlaybackLikelyToKeepUp,
                   !likelyToKeepUp,
                   let loadedTimeRanges = self?.cellVideoNode.currentItem?.loadedTimeRanges,
                   self?.bufferIsEmpty(loadedTimeRanges: loadedTimeRanges) == true {
                    
                    if self?.assetReset == false {
                        self?.resetAssets()
                    } else {
                        self?.handleStatusChange()
                    }
            
                } else {
                    self?.handleStatusChange()
                }
                
                print("FAILED TO play failed")
            @unknown default:
                
                if let likelyToKeepUp = self?.cellVideoNode.currentItem?.isPlaybackLikelyToKeepUp,
                   !likelyToKeepUp,
                   let loadedTimeRanges = self?.cellVideoNode.currentItem?.loadedTimeRanges,
                   self?.bufferIsEmpty(loadedTimeRanges: loadedTimeRanges) == true {
                    
                    if self?.assetReset == false {
                        self?.resetAssets()
                    } else {
                        self?.handleStatusChange()
                    }
                    
                } else {
                    self?.handleStatusChange()
                }
                
                print("FAILED TO play failed")
                
            }
            
        }
        
    }

    func bufferIsEmpty(loadedTimeRanges: [NSValue]) -> Bool {
        guard let lastTimeRange = loadedTimeRanges.last as? CMTimeRange else {
            return true
        }
        let bufferEndTime = CMTimeAdd(lastTimeRange.start, lastTimeRange.duration)
        let currentTime = self.cellVideoNode.player?.currentTime() ?? CMTime.zero
        return bufferEndTime < currentTime
    }


    
    func removeSpinner() {
        spinnerRemoved = true
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    
    func resetAssets() {
        // Pause player
        cellVideoNode.player?.pause()
        assetReset = true
        // Fade out the video node
        UIView.animate(withDuration: 0.2, animations: {
            self.cellVideoNode.alpha = 0.0
        }) { (completed) in
            // Replace asset
            self.cellVideoNode.asset = nil
            self.cellVideoNode.asset = AVAsset(url: self.getVideoURL(post: self.post)!)

            UIView.animate(withDuration: 0.2, animations: {
                self.cellVideoNode.alpha = 1.0
            }) { (completed) in
                self.playVideo()
            }

        }
        
    }


    func startPlayback() {
        
        removeSpinner()
        
        if isActive {
            DispatchQueue.main.async() { [weak self] in
                if self?.cellVideoNode.isPlaying() != true {
                    self?.cellVideoNode.play()
                }
            }
            
        }
        
    }

    func pauseVideo() {
        
        isActive = false
        cellVideoNode.pause()
        let time = CMTime(seconds: 0, preferredTimescale: 1)
        cellVideoNode.player?.seek(to: time)
        removeObservers()
    }
    
    func unmuteVideo() {
        
        cellVideoNode.muted = false
        shouldMute = false
        
    }
    
    func removeObservers() {
        statusObservation?.invalidate()
        statusObservation = nil
    }

    override func didExitVisibleState() {
        super.didExitVisibleState()
        pauseVideo()
        removeObservers()
    }

    
    
}






