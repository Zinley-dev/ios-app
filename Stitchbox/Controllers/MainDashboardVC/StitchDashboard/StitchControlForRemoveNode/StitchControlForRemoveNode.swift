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
import AVFoundation
import AVKit
import NVActivityIndicatorView

fileprivate let FontSize: CGFloat = 12
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

// A node representing a video cell in a list or grid. It handles video playback, UI interactions, and layout.
class StitchControlForRemoveNode: ASCellNode, ASVideoNodeDelegate {

    // MARK: - Properties

    // The model representing the post associated with this video node.
    weak var post: PostModel!

    // Video properties and state management variables.
    var videoDuration: Double = 0
    var lastViewTimestamp: TimeInterval = NSDate().timeIntervalSince1970
    var totalWatchedTime: TimeInterval = 0.0
    var previousTimeStamp: TimeInterval = 0.0
    var isActive = false
    var level = 0
    var unstitchBtn : ((ASCellNode) -> Void)?
    // UI components and layout related properties.
    private var cellVideoNode: ASVideoNode
    private var spinner: NVActivityIndicatorView!
    private lazy var headerView: PostHeader = PostHeader()
    private lazy var footerView: PostFooter = PostFooter()
    private lazy var stitchView: UnStitchView = UnStitchView()
    
    // Flags and counters for various states.
    var didSlideEnd = true
    var setupMaxVal = false
    var firstSetup = false
    var spinnerRemoved = true
    var assetReset = false
    var selectedStitch = false
    var isFollowingUser = false
    var allowProcess = true
    var firstItem = false

    
    // Observer for video playback status.
    var statusObservation: NSKeyValueObservation?
    var stitchTo: Bool
    var infoNode: ASTextNode!
    var buttonNode: ASDisplayNode!
    // MARK: - Initializer
    
    /// Initializes the cell with the provided post model and preview flag.
    /// - Parameters:
    ///   - post: The `PostModel` instance containing the data for the cell.
    ///   - isPreview: A Boolean flag indicating if this is a preview.
    init(with post: PostModel, stitchTo: Bool) {
        
        // Assign the provided post and preview flag.
        self.post = post
        // Initialize the image and video nodes.
        self.cellVideoNode = ASVideoNode()
        self.stitchTo = stitchTo
        self.buttonNode = ASDisplayNode()
        self.infoNode = ASTextNode()
    
        super.init()
        presetup()
        automaticallyManagesSubnodes = true
    }
    
    // MARK: - Node Lifecycle

    override func didLoad() {
        super.didLoad()
        backgroundColor = .white
        setupSpinner()
        setupChildView()
    }

    
    func presetup() {
        // Configure the node based on the presence of a muxPlaybackId.
        // This approach avoids duplicate checks and makes the decision point clear.
        if !post.muxPlaybackId.isEmpty {
            configureVideoNode(with: post)
        }
    }
    

    /// Called when the view controller’s view is no longer visible.
    override func didExitVisibleState() {
        super.didExitVisibleState() // Always call the super implementation of lifecycle methods
        
        guard shouldAllowAfterInactive else {
            return
        }

        // Pausing the video playback when the view is not visible.
        pauseVideo(shouldSeekToStart: false)

        // Removing any observers that were added to avoid memory leaks or unintended behavior.
        removeObservers()
        cleanGesture()
        emptyDelegate()
    }

    /// Called when the view controller’s view becomes visible.
    override func didEnterVisibleState() {
        super.didEnterVisibleState() // Always call the super implementation of lifecycle methods

        guard shouldAllowAfterInactive else {
            return
        }
        
        setupGesture()
        setDelegate()
    }
    /// Checks if the node needs to be set up again.
    /// This method determines if initialization is required and if the cellVideoNode's asset is nil.
    /// - Returns: A Boolean indicating whether setup is needed.
    func checkIfNeedToSetupAgain() -> Bool {
        return cellVideoNode.asset == nil
    }

    /// Checks if the node's resources should be cleaned up.
    /// This method determines if the cellVideoNode's asset is nil, indicating a need for cleanup.
    /// - Returns: A Boolean indicating whether cleanup is needed.
    func checkIfShouldClean() -> Bool {
        return cellVideoNode.asset != nil
    }
    
    override func didEnterDisplayState() {
        super.didEnterPreloadState()
        
        guard shouldAllowAfterInactive else {
            return
        }
        
        if checkIfNeedToSetupAgain()  {
            presetup()
        }
        
        fillInfo()
        configureInfoNode(for: post, stitchTo: stitchTo, fontSize: FontSize)
    }
    
    override func didExitDisplayState() {
        super.didExitDisplayState()
        
        guard shouldAllowAfterInactive else {
            return
        }
        
        if checkIfShouldClean() {
            cleanVideoNode()
        }
        cleanInfo()
        cleanInfoNode()
    }
    
    func configureInfoNode(for post: PostModel, stitchTo: Bool, fontSize: CGFloat) {
        if stitchTo {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let statusText = post.isApproved ? "Approved" : "Pending"
            
            infoNode.attributedText = NSAttributedString(
                string: statusText,
                attributes: [
                    .font: FontManager.shared.roboto(.Bold, size: 10),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ]
            )
            infoNode.cornerRadius = 3
        }
    }
    
    func cleanInfoNode() {
        infoNode.attributedText = nil
    }

    /// Cleans the video node by resetting its asset.
    /// This method sets the asset of cellVideoNode to nil, effectively cleaning up resources.
    func cleanVideoNode() {
        cellVideoNode.asset?.cancelLoading()
        cellVideoNode.asset = nil
    }

    
    func emptyDelegate() {
        cellVideoNode.delegate = nil
    }
    
    func setDelegate() {
        cellVideoNode.delegate = self
    }

    /// `deinit` is called when the object is about to be deallocated.
    /// This is a crucial place to remove any observers or perform any clean-up to prevent memory leaks.
    deinit {
        // Removing the object as an observer from NotificationCenter.
        // It's important to remove the observer to avoid any retain cycles or crashes due to observers being called after the object is deallocated.
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Configuration
    
    /// Sets up the spinner used for indicating loading or processing states.
    /// This method initializes the spinner with specific properties like frame, type, and color.
    private func setupSpinner() {
        // Creating an instance of NVActivityIndicatorView.
        // NVActivityIndicatorView is a customizable activity indicator library.
        spinner = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 55, height: 55), // Setting the frame of the spinner.
            type: .circleStrokeSpin, // Choosing the style/type of the spinner.
            color: .white,           // Setting the color of the spinner.
            padding: 0               // Setting the padding around the spinner.
        )
        // Additional configuration, if needed, can be added here.
    }
    
    // MARK: - Layout
    
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
        let videoInsetSpec = ASInsetLayoutSpec(insets: inset, child: cellVideoNode)
        
        let buttonsInsetSpec = createButtonsInsetSpec(constrainedSize: constrainedSize)
        let verticalStackInset = UIEdgeInsets(top: .infinity, left: 0, bottom: 8, right: 0)
        let verticalStackInsetSpec = ASInsetLayoutSpec(insets: verticalStackInset, child: buttonsInsetSpec)
        let finalOverlay = ASOverlayLayoutSpec(child: videoInsetSpec, overlay: verticalStackInsetSpec)
        
        if stitchTo {
            infoNode.style.preferredSize = CGSize(width: 75, height: 15)
            let stitchCountInsets = UIEdgeInsets(top: .infinity, left: .infinity, bottom: 75, right: padding - 10)
            let stitchCountInsetSpec = ASInsetLayoutSpec(insets: stitchCountInsets, child: infoNode)
            let overlay2 = ASOverlayLayoutSpec(child: finalOverlay, overlay: stitchCountInsetSpec)
            return overlay2
        } else {
            return finalOverlay
        }
    }


    // MARK: - User Interaction

    /// Handles user interaction with the video node.
    /// Toggles between playing and pausing the video based on its current state.
    /// - Parameter videoNode: The video node that was tapped by the user.
    func didTap(_ videoNode: ASVideoNode) {
        if !videoNode.isPlaying() {
            playVideo() // If the video is not playing, start playing.
        } else {
            pauseVideo(shouldSeekToStart: false) // If the video is playing, pause it without seeking to the start.
        }
    }

    // MARK: - Helper Methods

    /// Retrieves the thumbnail URL for a given post.
    /// This method constructs and returns a URL pointing to the thumbnail image of the video.
    /// - Parameter post: The post model containing the video information.
    /// - Returns: A URL for the video's thumbnail, or nil if the post lacks a valid muxPlaybackId.
    func getThumbnailURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            let urlString = "https://image.mux.com/\(post.muxPlaybackId)/thumbnail.jpg?time=0"
            return URL(string: urlString) // Constructing and returning the URL for the thumbnail.
        } else {
            return nil // Returning nil if no valid muxPlaybackId is available.
        }
    }

    /// Retrieves the video URL for a given post.
    /// This method constructs and returns a URL for the video stream.
    /// - Parameter post: The post model containing the video information.
    /// - Returns: A URL for streaming the video, or nil if the post lacks a valid muxPlaybackId.
    func getVideoURL(post: PostModel) -> URL? {
        if post.muxPlaybackId != "" {
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8?redundant_streams=true&max_resolution=1080p"
            return URL(string: urlString) // Constructing and returning the URL for the video.
        } else {
            return nil // Returning nil if no valid muxPlaybackId is available.
        }
    }
    
}


// MARK: - VideoNode Extension -  video playback
extension StitchControlForRemoveNode {

    /// Plays the video in the video node.
    func playVideo() {
        // Avoid playing if already playing
        if cellVideoNode.isPlaying() {
            return
        }
        

        // Set mute status based on conditions
        cellVideoNode.muted = shouldMute ?? !globalIsSound
        
        // Remove any existing observers to avoid duplication
        removeObservers()
        
        // set isActive
        isActive = true

        // Add observers if the current item is available, otherwise wait and try again
        if cellVideoNode.currentItem != nil {
            addObservers()
        } else {
            // Attempt to add observers after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self, self.cellVideoNode.currentItem != nil else {
                    // Error handling if the video is still not ready
                    return
                }
                self.addObservers()
            }
        }
    }

    /// Adds observers to the video node.
    func addObservers() {
        // Observing the status of the video playback
        statusObservation = cellVideoNode.currentItem?.observe(\.status, options: [.new, .initial]) { [weak self] (playerItem, change) in
            self?.handleStatusChange()
        }
    }
    
    /// Handles changes in the video node's status.
    func handleStatusChange() {
        // Safely unwrapping the status of the current item
        guard let status = cellVideoNode.currentItem?.status else { return }

        // Handling different states of video playback
        switch status {
        case .readyToPlay:
            startPlayback()
        case .failed:
            printStatusDetails(withPrefix: "Playback failed")
        case .unknown:
            printStatusDetails(withPrefix: "Playback status unknown")
        @unknown default:
            printStatusDetails(withPrefix: "Unexpected playback status")
        }
    }

    /// Prints status details along with buffer and error information.
    /// - Parameter prefix: Prefix for the log message.
    func printStatusDetails(withPrefix prefix: String) {
        // Checking network connectivity
        let connectionStatus = ReachabilityManager.shared.reachability.connection

        if connectionStatus == .unavailable {
            // Handling no internet connection
            showNote(text: "No Internet Connection")
        } else {

            // Setting buffer duration preference and rechecking status
            cellVideoNode.currentItem?.preferredForwardBufferDuration = 5
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { [weak self] in
                guard let self = self, let status = self.cellVideoNode.currentItem?.status else {
                    self?.resetAssets()
                    return
                }
                self.handlePlaybackBasedOn(status: status, withPrefix: prefix)
            }
        }
    }
    
    /// Resets the video assets and attempts playback.
    func resetAssets() {
        // Pausing and resetting the video player
        cellVideoNode.player?.pause()
        assetReset = true

        // Fading out the video node before resetting
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.cellVideoNode.alpha = 0.0
        } completion: { _ in
            // Replacing the video asset
            self.cellVideoNode.asset = nil
            self.cellVideoNode.asset = AVAsset(url: self.getVideoURL(post: self.post)!)

            // Fading the video node back in and starting playback
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.cellVideoNode.alpha = 1.0
            } completion: { _ in
                self.playVideo()
            }
        }
    }

    /// Starts the video playback.
    func startPlayback() {
        
        // Removing the spinner before starting playback
        removeSpinner()

        // Starting playback if not already playing
        if !cellVideoNode.isPlaying(), isActive {
            // Adjusting bit rate based on network connection
            adjustBitRateBasedOnNetwork()

            // Starting the video playback
            cellVideoNode.play()
        } else {
           // print("Can't play because of \(isActive) or \(cellVideoNode.isPlaying())")
        }
    }

    /// Adjusts the video bit rate based on the network connection.
    private func adjustBitRateBasedOnNetwork() {
        let connectionStatus = ReachabilityManager.shared.reachability.connection
        switch connectionStatus {
        case .wifi:
            cellVideoNode.currentItem?.preferredPeakBitRate = 6000 * 1000 // 6.0 Mbps for Wi-Fi
        case .cellular:
            cellVideoNode.currentItem?.preferredPeakBitRate = 3000 * 1000 // 3.0 Mbps for Cellular
        default:
            cellVideoNode.currentItem?.preferredPeakBitRate = 2000 * 1000 // 2 Mbps for unknown network
        }
    }

    /// Pauses the video playback and seeks to start if required.
    /// - Parameter shouldSeekToStart: Indicates if the video should seek to the beginning.
    func pauseVideo(shouldSeekToStart: Bool) {
        cellVideoNode.pause()
        removeObservers()

        // Seeking to the start of the video if required
        if shouldSeekToStart {
            let startTime = CMTime(seconds: 0, preferredTimescale: 1)
            cellVideoNode.player?.seek(to: startTime)
        }
    }

    /// Unmutes the video.
    func unmuteVideo() {
        cellVideoNode.muted = false
        shouldMute = false
    }
    
    /// Unmutes the video.
    func muteVideo() {
        cellVideoNode.muted = true
        shouldMute = true
    }
    
    /// Removes all observers from the video node.
    func removeObservers() {
        statusObservation?.invalidate()
        statusObservation = nil
        isActive = false
    }
    
    /// Seek to zero time
    func seekToZero() {
        let time = CMTime(seconds: 0, preferredTimescale: 1)
        cellVideoNode.player?.seek(to: time)
    }

    /// Handles playback based on the current status of the video node.
    /// - Parameters:
    ///   - status: The current status of the video node's item.
    ///   - prefix: Prefix for log messages.
    private func handlePlaybackBasedOn(status: AVPlayerItem.Status, withPrefix prefix: String) {
        switch status {
        case .readyToPlay:
            startPlayback()
            //print("\(prefix) - Ready to play")
        case .failed:
            addSpinner()
            //print("\(prefix) - Playback failed")
        case .unknown:
            addSpinner()
            //print("\(prefix) - Playback status unknown")
        @unknown default:
            addSpinner()
            //print("\(prefix) - Unexpected playback status")
        }
    }

    /// Retries or resets playback based on the current status of the video node.
    private func retryOrResetPlaybackBasedOnCurrentStatus() {
        guard let status = cellVideoNode.currentItem?.status else {
            //print("Playback status check failed - status unavailable")
            resetAssets()
            return
        }
        
        switch status {
        case .readyToPlay:
            startPlayback()
        case .failed, .unknown:
            if shouldRetryPlayback() {
                resetAssets()
            } else {
                handlePlaybackBasedOn(status: status, withPrefix: "Retry failed")
            }
        @unknown default:
            handlePlaybackBasedOn(status: status, withPrefix: "Retry default")
        }
    }

    /// Determines whether playback should be retried based on buffer state.
    /// - Returns: Boolean indicating if playback should be retried.
    private func shouldRetryPlayback() -> Bool {
        guard let currentItem = cellVideoNode.currentItem else { return false }
        let likelyToKeepUp = currentItem.isPlaybackLikelyToKeepUp
        let loadedTimeRanges = currentItem.loadedTimeRanges

        if !likelyToKeepUp && bufferIsEmpty(loadedTimeRanges: loadedTimeRanges) {
            return assetReset == false
        } else {
            return false
        }
    }
}

extension StitchControlForRemoveNode {
    
    /// Adds a spinner to indicate loading or buffering.
    func addSpinner() {
        // Ensuring spinner is only added once
        if spinnerRemoved {
            spinner.center = view.center
            view.addSubview(spinner)
            spinner.startAnimating()
            spinnerRemoved = false
        }

        // Remove spinner or retry playback based on status after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }

            // Continue playback if already playing
            if self.cellVideoNode.isPlaying() {
                self.removeSpinner()
                return
            }

            // Retry or reset based on current item's status and buffer state
            self.retryOrResetPlaybackBasedOnCurrentStatus()
        }
    }

    /// Checks if the buffer is empty.
    /// - Parameter loadedTimeRanges: Array of loaded time ranges.
    /// - Returns: Boolean indicating if the buffer is empty.
    func bufferIsEmpty(loadedTimeRanges: [NSValue]) -> Bool {
        // Calculating buffer end time and comparing with current time
        guard let lastTimeRange = loadedTimeRanges.last as? CMTimeRange else {
            return true
        }
        let bufferEndTime = CMTimeAdd(lastTimeRange.start, lastTimeRange.duration)
        let currentTime = cellVideoNode.player?.currentTime() ?? CMTime.zero
        return bufferEndTime < currentTime
    }

    /// Removes the spinner from the view.
    func removeSpinner() {
        spinnerRemoved = true
        if spinner != nil {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
        
    }
    
}


extension StitchControlForRemoveNode {
    
    /// Configures the video node with a given post model.
    /// - Parameter post: The post model used to configure the video node.
    private func configureVideoNode(with post: PostModel) {
        
        // Set up the cell video node's appearance and behavior.
        setupCellVideoNodeAppearance()
        setupCellVideoNodeBehavior(with: post)
        
        // Determine and set the video content mode based on post's metadata.
        determineAndSetVideoContentMode(with: post)
        
        // Load the video asset asynchronously.
        loadVideoAssetAsync(with: post)
        
    }
    
    /// Sets up the appearance of cellVideoNode.
    private func setupCellVideoNodeAppearance() {
        cellVideoNode.cornerRadius = 12
        cellVideoNode.clipsToBounds = true
        cellVideoNode.backgroundColor = .blue
    }
    
    /// Sets up the behavior of cellVideoNode based on the post model.
    /// - Parameter post: The post model used for configuration.
    private func setupCellVideoNodeBehavior(with post: PostModel) {
        cellVideoNode.url = getThumbnailURL(post: post)
        cellVideoNode.shouldAutoplay = false
        cellVideoNode.shouldAutorepeat = true
    }
    
    /// Determines and sets the video content mode based on post's metadata.
    /// - Parameter post: The post model with metadata to determine content mode.
    private func determineAndSetVideoContentMode(with post: PostModel) {
        if let width = post.metadata?.width, let height = post.metadata?.height, width != 0, height != 0 {
            setVideoContentModeFor(width: width, height: height)
        } else {
            setDefaultVideoContentMode()
        }
    }
    
    /// Asynchronously loads the video asset for the cellVideoNode.
    /// - Parameter post: The post model containing the video URL.
    private func loadVideoAssetAsync(with post: PostModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Ensure URL is valid
            guard let videoURL = self.getVideoURL(post: post) else {
                // Handle invalid URL case
                return
            }

            self.cellVideoNode.asset = AVAsset(url: videoURL)
        }
    }
    
    /// Sets the video content mode based on the given dimensions.
    /// - Parameters:
    ///   - width: The width of the video.
    ///   - height: The height of the video.
    func setVideoContentModeFor(width: CGFloat, height: CGFloat) {
        let aspectRatio = width / height
        // Check for a 9:16 aspect ratio with a margin for error.
        if abs(aspectRatio - (9.0/16.0)) < 0.01 {
            cellVideoNode.contentMode = .scaleAspectFill
            cellVideoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        } else {
            setDefaultVideoContentMode()
        }
    }

    /// Sets the default video content mode for the cellVideoNode.
    func setDefaultVideoContentMode() {
        cellVideoNode.contentMode = .scaleAspectFit
        cellVideoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
    }
    
}

// MARK: - Subview Setup

extension StitchControlForRemoveNode {
    
    /// Sets up child views of the VideoNode.
    /// This function orchestrates the setup of various subviews including header, footer, and interaction buttons.
    func setupChildView() {
        // Setup different view components of the VideoNode.
        setupHeaderViews()
        setupFooterViews()
        setupStitchView()
        headerView.setLayoutForDashboard()
        footerView.stitchBtn.isHidden = true
    }
    
    func fillInfo() {
        // Populate the VideoNode with relevant post information.
        fillPostHeaderInfo()
        fillPostFooterInfo()

        // Load and setup reactions and gesture recognizers.
        loadReaction()
        
    }
    
    func cleanInfo() {
        headerView.cleanup()
        footerView.cleanup()
        
    }

    func cleanGesture() {
        cleanupCustomTap()
        removeGestureRecognizers()
    }
    
    func setupGesture() {
        setupGestureRecognizers()
        setupCustomTap()
    }
    
    /// Sets up the header views.
    /// This method adds the header view to the node and applies necessary constraints.
    private func setupHeaderViews() {
        self.view.addSubview(self.headerView)
        addHeaderConstraints(to: self.headerView, within: self.view)
    }
    
    /// Sets up the footer views.
    /// This method adds the footer view to the node and applies necessary constraints.
    private func setupFooterViews() {
        self.view.addSubview(self.footerView)
        addFooterConstraints(to: self.footerView, within: self.view)
    }
    

    /// Adds constraints to the header view.
    /// - Parameters:
    ///   - childView: The child view to which constraints are applied.
    ///   - parentView: The parent view in which the child view resides.
    ///   - constant: An optional constant value for leading and trailing constraints.
    private func addHeaderConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        childView.translatesAutoresizingMaskIntoConstraints = false

        // Determining the top constraint based on the presence of a notch
        let topConstraintConstant = 2
        
        let change = view.frame.width - ( view.frame.height * 9 / 16)
        let padding = change / 2

        // Activating constraints
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: CGFloat(topConstraintConstant)),
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: padding - 10),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -padding + 10), // Negative for trailing
            childView.heightAnchor.constraint(equalToConstant: 80) // Fixed height of the header view.
        ])
    }


    /// Adds constraints to the footer view.
    /// - Parameters:
    ///   - childView: The child view to which constraints are applied.
    ///   - parentView: The parent view in which the child view resides.
    ///   - constant: An optional constant value for leading, trailing, and bottom constraints.
    private func addFooterConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        let change = view.frame.width - ( view.frame.height * 9 / 16)
        let padding = change / 2
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -50), // Offset from the bottom.
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: padding - 10),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: constant),
            childView.heightAnchor.constraint(equalToConstant: 150) // Height of the footer view.
        ])
    }

    /// Fills the header with information about the post's owner
    func fillPostHeaderInfo() {
        // Check if the post has an owner and fill the header view accordingly
        if let owner = post.owner {
            // Set header information including the username, post creation time, and avatar URL
            headerView.setHeaderInfo(
                username: owner.username,
                postTime: post.createdAt!, // Force unwrapping is risky here, consider safe unwrapping
                avatarURL: owner.avatar
            )
        }
        // Consider adding an else block to handle the case where post.owner is nil
    }

    /// Fills the footer with information about the post
    func fillPostFooterInfo() {
        // Setting footer information with post content and additional description
        // 'post.content' is used for the title, and a static extra description is added
        footerView.setFooterInfoForDashboard(
            title: post.content,
            description: "extra description will go here! ^^"
        )

        // Note: Consider making the extra description dynamic or configurable
        // if different posts require different footer descriptions.
    }
    
    // MARK: - Gesture Recognizer Setup

    /// Sets up gesture recognizers for various interactive elements in the view
    func setupGestureRecognizers() {
        // Username Tap Gesture (Header View)
        let usernameTap1 = createTapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.userTapped))
        self.headerView.username.isUserInteractionEnabled = true
        self.headerView.username.addGestureRecognizer(usernameTap1)
        
        // Avatar Image Tap Gesture (Header View)
        let usernameTap2 = createTapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.userTapped))
        self.headerView.avatarImg.isUserInteractionEnabled = true
        self.headerView.avatarImg.addGestureRecognizer(usernameTap2)
        
        let unstitchTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchControlForRemoveNode.unstitchBtnTapped))
        unstitchTap.numberOfTapsRequired = 1
        self.stitchView.unstitchBtn.addGestureRecognizer(unstitchTap)
    }
    
    func setupStitchView() {
        self.stitchView.backgroundColor = .clear
        self.buttonNode.view.addSubview(self.stitchView)
        self.stitchView.translatesAutoresizingMaskIntoConstraints = false
        self.stitchView.topAnchor.constraint(equalTo: self.buttonNode.view.topAnchor, constant: 0).isActive = true
        self.stitchView.bottomAnchor.constraint(equalTo: self.buttonNode.view.bottomAnchor, constant: 0).isActive = true
        self.stitchView.leadingAnchor.constraint(equalTo: self.buttonNode.view.leadingAnchor, constant: 0).isActive = true
        self.stitchView.trailingAnchor.constraint(equalTo: self.buttonNode.view.trailingAnchor, constant: 0).isActive = true
    }
    
    
    func removeGestureRecognizers() {
        // Remove gesture recognizers from header view elements
        self.headerView.username.gestureRecognizers?.forEach(self.headerView.username.removeGestureRecognizer)
        self.headerView.avatarImg.gestureRecognizers?.forEach(self.headerView.avatarImg.removeGestureRecognizer)
        self.headerView.settingBtn.gestureRecognizers?.forEach(self.headerView.settingBtn.removeGestureRecognizer)
        self.headerView.postTime.gestureRecognizers?.forEach(self.headerView.postTime.removeGestureRecognizer)
        self.headerView.postDate.gestureRecognizers?.forEach(self.headerView.postDate.removeGestureRecognizer)

        // Remove gesture recognizers from footer view elements
        self.footerView.stitchBtn.gestureRecognizers?.forEach(self.footerView.stitchBtn.removeGestureRecognizer)
        
        self.stitchView.unstitchBtn.gestureRecognizers?.forEach(self.stitchView.unstitchBtn.removeGestureRecognizer)

        // Remove gesture recognizers from the view
        self.view.gestureRecognizers?.forEach(self.view.removeGestureRecognizer)
    }

    /// Creates and returns a UITapGestureRecognizer with specified target, action, and number of taps
    /// - Parameters:
    ///   - target: The object that is the recipient of the action message.
    ///   - action: The action to be called when the gesture is recognized.
    ///   - taps: The number of taps required for the gesture to be recognized.
    /// - Returns: Configured UITapGestureRecognizer.
    func createTapGestureRecognizer(target: Any, action: Selector, taps: Int = 1) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = taps
        return tap
    }

    // MARK: - Custom Tap Setup

    /// Sets up a custom tap gesture for the footer view.
    func setupCustomTap() {
        // Configuring a custom tap handler for the label in the footer view.
        // The handler is specifically for the type of custom interaction defined in footerView.customType.
        footerView.label.handleCustomTap(for: footerView.customType) { [weak self] hashtag in
            // The closure is called with the tapped hashtag.
            // 'self' is captured weakly to prevent retain cycles.
            self?.presentPostListWithHashtagVC(for: hashtag)
        }
    }

    func cleanupCustomTap() {
        footerView.label.handleCustomTap(for: footerView.customType) { _ in }
    }

    
    /// Presents the `PostListWithHashtagVC` for the given hashtag.
    /// - Parameter selectedHashtag: The hashtag selected by the user.
    func presentPostListWithHashtagVC(for selectedHashtag: String) {
        // Using guard for safe unwrapping and to handle potential errors.
        guard let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil)
                .instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC,
              let vc = UIViewController.currentViewController() else {
            // Error handling if the view controller could not be instantiated.
            //print("Error: Unable to instantiate PostListWithHashtagVC from storyboard.")
            return
        }
        
        // Configuring the view controller with the selected hashtag.
        PLHVC.searchHashtag = selectedHashtag
        PLHVC.onPresent = true

        // Setting the modal presentation style and presenting the view controller.
        let navController = UINavigationController(rootViewController: PLHVC)
        navController.modalPresentationStyle = .fullScreen
        vc.present(navController, animated: true, completion: nil)
    }


}


// MARK: - Reaction Handling

extension StitchControlForRemoveNode {

    /// Loads reaction data for the post.
    /// This method fetches reaction data such as like and save statuses from the server.
    func loadReaction() {
        APIManager.shared.getReactionPost(postId: post.id) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let apiResponse):
                // Parsing the API response to extract reaction data.
                guard let message = apiResponse.body?["message"] as? String,
                      message == "success",
                      let data = apiResponse.body?["data"] as? [String: Any],
                      let isFollower = data["isFollower"] as? Bool,
                      let isFollowing = data["isFollowing"] as? Bool,
                      let isLiked = data["isLike"] as? Bool,
                      let isSaved = data["isSaved"] as? Bool else {
                    //print("Error: Invalid or missing data in response")
                    return
                }
                
                // Handling the reaction data.
                strongSelf.handleReaction(isFollower: isFollower, isFollowing: isFollowing, isLiked: isLiked, isSaved: isSaved)
            case .failure(_):
                return
                //print("API Error: \(error)")
            }
        }
    }
    
    // MARK: - Reaction Handling

    /// Handles updating the UI elements for reactions like follow, like, and save.
    /// - Parameters:
    ///   - isFollower: Indicates whether the current user is a follower.
    ///   - isFollowing: Indicates whether the current user is following.
    ///   - isLiked: Indicates whether the current post is liked.
    ///   - isSaved: Indicates whether the current post is saved.
    func handleReaction(isFollower: Bool, isFollowing: Bool, isLiked: Bool, isSaved: Bool) {
        guard let finalPost = post else { return }
        
        hideFollowBtn()
        
    }

    // MARK: - Follow Button Management

    /// Hides the follow button.
    /// This method is called when the follow button should not be displayed.
    func hideFollowBtn() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.headerView.followBtn.isUserInteractionEnabled = false
            strongSelf.headerView.followBtn.setTitle("", for: .normal)
            strongSelf.isFollowingUser = true
        }
    }

}



extension StitchControlForRemoveNode {

    // MARK: - User Profile Handling

    /// Handles the user tap action.
    @objc func userTapped() {
        // Ensure valid user data before proceeding
        guard let userId = post.owner?.id,
              let username = post.owner?.username,
              !userId.isEmpty,
              !username.isEmpty,
              userId != _AppCoreData.userDataSource.value?.userID else {
            return
        }
        
        // Show user profile if the data is valid
        showUserProfile(for: userId, with: username)
    }

    /// Displays the user profile.
    private func showUserProfile(for userId: String, with username: String) {
        // Instantiate UserProfileVC from storyboard
        guard let userProfileVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC,
              let currentVC = UIViewController.currentViewController() else {
            return
        }

        // Configure and present UserProfileVC
        configureUserProfileVC(userProfileVC, with: userId, nickname: username)
        let navigationController = UINavigationController(rootViewController: userProfileVC)
        configureNavigationController(navigationController)
        currentVC.present(navigationController, animated: true)
    }

    /// Configures UserProfileVC with user details.
    private func configureUserProfileVC(_ userProfileVC: UserProfileVC, with userId: String, nickname: String) {
        userProfileVC.userId = userId
        userProfileVC.nickname = nickname
        userProfileVC.onPresent = true
    }

    /// Configures the navigation controller for presenting UserProfileVC.
    private func configureNavigationController(_ navigationController: UINavigationController) {
        navigationController.modalPresentationStyle = .fullScreen
    }

    /// Presents the share controller with the provided username.
    private func presentShareController(username: String) {
        let shareURLString = "https://stitchbox.net/app/post/?uid=\(post.id)"
        guard let shareURL = URL(string: shareURLString) else { return }
        
        let items: [Any] = ["Hi, I am \(username) from Stitchbox, let's check out this!", shareURL]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let currentVC = UIViewController.currentViewController() {
            currentVC.present(activityController, animated: true)
        }
    }

    /// Presents the comment view controller.
    private func presentCommentViewController(from viewController: UIViewController) {
        let commentVC = CommentVC()
        commentVC.post = self.post
        commentVC.modalPresentationStyle = .custom
        commentVC.transitioningDelegate = viewController
        global_presetingRate = 0.75
        global_cornerRadius = 35

        viewController.present(commentVC, animated: true)
    }


    /// Handles the settings button tap action.
    @objc func settingTapped() {
        // Ensure a view controller is currently available.
        guard let vc = UIViewController.currentViewController() else { return }

        // Update global corner radius.
        global_cornerRadius = 45

        // Check if the post owner is the current user.
        if post.owner?.id == _AppCoreData.userDataSource.value?.userID {
            // Present PostSettingVC for the post owner.
            presentVC(vc, using: PostSettingVC())
            // Update global presenting rate for the owner.
            global_presetingRate = 0.35
        } else {
            // Update global presenting rate for non-owners.
            global_presetingRate = 0.30

            // Configure and present NewsFeedSettingVC for non-owners.
            let newsFeedSettingVC = NewsFeedSettingVC()
            newsFeedSettingVC.modalPresentationStyle = .custom
            newsFeedSettingVC.transitioningDelegate = vc
            newsFeedSettingVC.isInformationHidden = headerView.isHidden

            // Check the type of the current view controller and present accordingly.
            if let updateVC = vc as? FeedViewController {
                updateVC.editeddPost = post
                setOwnership(for: newsFeedSettingVC)
                updateVC.present(newsFeedSettingVC, animated: true)
            } else if let updateVC = vc as? SelectedRootPostVC {
                newsFeedSettingVC.isSelected = true
                updateVC.editeddPost = post
                setOwnership(for: newsFeedSettingVC)
                updateVC.present(newsFeedSettingVC, animated: true)
            }
        }
    }

    /// Sets the ownership status of a NewsFeedSettingVC based on the post owner.
    /// - Parameter vc: The NewsFeedSettingVC to set ownership for.
    func setOwnership(for vc: NewsFeedSettingVC) {
        // Determine the ownership status based on the post's owner ID.
        vc.isOwner = post.owner?.id == _AppCoreData.userDataSource.value?.userID
    }

    
    /// Presents a PostSettingVC on the specified view controller.
    /// - Parameters:
    ///   - viewController: The UIViewController on which to present.
    ///   - postSettingVC: The PostSettingVC to be presented.
    func presentVC(_ viewController: UIViewController, using postSettingVC: PostSettingVC) {
        // Configure the presentation style and delegate for the PostSettingVC.
        postSettingVC.modalPresentationStyle = .custom
        postSettingVC.transitioningDelegate = viewController
        postSettingVC.isInformationHidden = headerView.isHidden

        // Present the PostSettingVC based on the type of the parent view controller.
        if let updateVC = viewController as? FeedViewController {
            // Assign the edited post based on the view controller's type.
            updateVC.editeddPost = post
            // Present the PostSettingVC.
            updateVC.present(postSettingVC, animated: true)
        } else if let updateVC = viewController as? SelectedRootPostVC {
            // Mark the post setting as selected for SelectedParentVC.
            postSettingVC.isSelected = true
            // Assign the edited post based on the view controller's root status.
            updateVC.editeddPost = post
            // Present the PostSettingVC.
            updateVC.present(postSettingVC, animated: true)
        }
    }

}

extension StitchControlForRemoveNode {
    @objc func unstitchBtnTapped() {
                
            unstitchBtn?(self)
                
        }
}
