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
import NVActivityIndicatorView


// A node representing a video cell in a list or grid. It handles video playback, UI interactions, and layout.
class VideoNode: ASCellNode, ASVideoNodeDelegate {

    // MARK: - Properties

    // The model representing the post associated with this video node.
    weak var post: PostModel!

    // Video properties and state management variables.
    var videoDuration: Double = 0
    var lastViewTimestamp: TimeInterval = NSDate().timeIntervalSince1970
    var totalWatchedTime: TimeInterval = 0.0
    var previousTimeStamp: TimeInterval = 0.0
    var isViewed = false
    var shouldCountView = true
    var time = 0
    var isActive = false
    
    // UI components and layout related properties.
    private var cellVideoNode: ASVideoNode
    private var cellImageNode: ASNetworkImageNode
    private var timeLbl: UILabel!
    private var blurView: UIView!
    private var spinner: NVActivityIndicatorView!
    private lazy var headerView: PostHeader = PostHeader()
    private lazy var footerView: PostFooter = PostFooter()
    private lazy var buttonView: PostInteractionButtons = PostInteractionButtons()
    private var playTimeBar: CustomSlider!
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    
    // Flags and counters for various states.
    var didSlideEnd = true
    var setupMaxVal = false
    var firstSetup = false
    var spinnerRemoved = true
    var assetReset = false
    var selectedStitch = false
    var isSave = false
    var isFollowingUser = false
    var saveCount = 0
    var likeCount = 0
    var isLike = false
    var allowProcess = true
    var firstItem = false
    private var isPreview: Bool!
    
    // Constants
    private let maximumShowing = 100
    fileprivate let FontSize: CGFloat = 13
    
    // Observer for video playback status.
    var statusObservation: NSKeyValueObservation?

    // Action
    var viewStitchBtn : ((ASCellNode) -> Void)?
    var indexPathSetup: Int?
    
    // MARK: - Initializer
    
    /// Initializes the cell with the provided post model and preview flag.
    /// - Parameters:
    ///   - post: The `PostModel` instance containing the data for the cell.
    ///   - isPreview: A Boolean flag indicating if this is a preview.
    init(with post: PostModel, isPreview: Bool, firstItem: Bool, level: Int, indexPath: Int) {
        
        print("Preparing post for VideoNode: \(level)")
        
        // Assign the provided post and preview flag.
        self.post = post
        self.isPreview = isPreview
        self.firstItem = firstItem
        self.indexPathSetup = indexPath

        // Initialize the image and video nodes.
        self.cellImageNode = ASNetworkImageNode()
        self.cellVideoNode = ASVideoNode()
    
        // Call the superclass initializer.
        super.init()

    }
    
    // MARK: - Node Lifecycle

    override func didLoad() {
        super.didLoad()
        backgroundColor = .black
        setupSpinner()
        setupChildView()
    }

    
    func presetup() {
        // Configure the node based on the presence of a muxPlaybackId.
        // This approach avoids duplicate checks and makes the decision point clear.
        if !post.muxPlaybackId.isEmpty {
            configureVideoNode(with: post)
        } else {
            configureImageNode(with: post)
        }
    }
    
    override func willEnterHierarchy() {
        presetup()
    }
    
    override func didExitHierarchy() {
        cellVideoNode.asset = nil
        cellImageNode.url = nil
        // Removing any observers that were added to avoid memory leaks or unintended behavior.
        removeObservers()
    }


    /// Called when the view controller’s view is no longer visible.
    override func didExitVisibleState() {
        super.didExitVisibleState() // Always call the super implementation of lifecycle methods

        // Pausing the video playback when the view is not visible.
        pauseVideo(shouldSeekToStart: false)

        // Removing any observers that were added to avoid memory leaks or unintended behavior.
        removeObservers()
    }

    /// Called when the view controller’s view becomes visible.
    override func didEnterVisibleState() {
        super.didEnterVisibleState() // Always call the super implementation of lifecycle methods

        // Check if the initial setup for the view controller is completed.
        if !firstSetup {
            firstSetup = true // Marking that the first setup is completed.

            // Logging the completion of the setup. Useful for debugging.
            print("Setup completed for - \(post.id)")
        } else {
            // Logging if the setup was already completed earlier.
            print("Setup already completed for - \(post.id)")
        }
        
    }

    /// `deinit` is called when the object is about to be deallocated.
    /// This is a crucial place to remove any observers or perform any clean-up to prevent memory leaks.
    deinit {
        // Removing the object as an observer from NotificationCenter.
        // It's important to remove the observer to avoid any retain cycles or crashes due to observers being called after the object is deallocated.
        NotificationCenter.default.removeObserver(self)

        // Logging the deallocation for debugging purposes.
        // This can help identify memory leaks or ensure that objects are being deallocated as expected.
        print("VideoNode is being deallocated.")
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

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // Define common padding values for the video or image node within the cell.
        let videoPadding = UIEdgeInsets(top: 50, left: 8, bottom: 37, right: 8)

        // Determine the child node based on the presence of a muxPlaybackId.
        // Using ternary operator for concise conditional assignment.
        let childNode = post.muxPlaybackId.isEmpty ? cellImageNode : cellVideoNode

        // Apply padding to the chosen child node using ASInsetLayoutSpec.
        // This approach avoids redundant code and enhances readability.
        let paddedVideoSpec = ASInsetLayoutSpec(insets: videoPadding, child: childNode)
        
        // Set the main view inset, keeping the original bottom inset.
        // Using UIEdgeInsets for consistency and clarity.
        let mainViewInset = UIEdgeInsets(top: 48, left: 0, bottom: 8, right: 0)

        // Create an inset layout spec for the main view.
        // This approach provides a clear structure for the layout, making it easy to adjust in the future.
        let insetSpec = ASInsetLayoutSpec(insets: mainViewInset, child: paddedVideoSpec)

        // Return the final layout spec.
        return insetSpec
        
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


// MARK: - VideoNode Extension
extension VideoNode {
    
    // MARK: - Setup
    /// Sets up the play time slider with target-action patterns for different events.
    private func setupFunction() {
        playTimeBar.addTarget(self, action: #selector(VideoNode.sliderDidStartSliding), for: .touchDown)
        playTimeBar.addTarget(self, action: #selector(VideoNode.sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        playTimeBar.addTarget(self, action: #selector(VideoNode.sliderValueDidChange), for: .valueChanged)
    }

    // MARK: - Slider Event Handlers
    
    /// Handles the start of the slider interaction.
    @objc func sliderDidStartSliding() {
        processOnSliding()
        playTimeBar.startLayout()
        didSlideEnd = false
    }
    
    /// Handles the end of the slider interaction.
    @objc func sliderDidEndSliding() {
        processEndedSliding()
        playTimeBar.endLayout()
        didSlideEnd = true
        
        // Update the video playback time based on the slider's value.
        let newVideoTime = CMTimeMakeWithSeconds(Float64(playTimeBar.value), preferredTimescale: Int32(NSEC_PER_SEC))
        cellVideoNode.player?.seek(to: newVideoTime)
    }
    
    /// Updates the video time label as the slider value changes.
    @objc func sliderValueDidChange() {
        timeLbl.text = processTime()
    }

    // MARK: - Helper Methods
    
    /// Calculates and formats the current video time and total duration.
    func processTime() -> String {
        let newVideoTime = CMTimeMakeWithSeconds(Float64(playTimeBar.value), preferredTimescale: Int32(NSEC_PER_SEC))
        let totalSeconds = Int(CMTimeGetSeconds(newVideoTime))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60

        let totalDurationSeconds = Int(playTimeBar.maximumValue)
        let durationSeconds = totalDurationSeconds % 60
        let durationMinutes = totalDurationSeconds / 60

        return String(format: "%02d:%02d / %02d:%02d", minutes, seconds, durationMinutes, durationSeconds)
    }
    
    /// Processes the UI and video player state when sliding begins.
    func processOnSliding() {
        cellVideoNode.pause()
        timeLbl.text = processTime()
        timeLbl.isHidden = false
        blurView.isHidden = false
    }

    /// Processes the UI and video player state when sliding ends.
    func processEndedSliding() {
        cellVideoNode.play()
        timeLbl.isHidden = true
        blurView.isHidden = true
    }
}


// MARK: - VideoNode Extension -  video playback
extension VideoNode {

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
            // Gathering buffer and error details
            let bufferFull = cellVideoNode.currentItem?.isPlaybackBufferFull ?? false
            let bufferEmpty = cellVideoNode.currentItem?.isPlaybackBufferEmpty ?? false
            let likelyToKeepUp = cellVideoNode.currentItem?.isPlaybackLikelyToKeepUp ?? false
            let errorDescription = cellVideoNode.currentItem?.error?.localizedDescription ?? "Unknown error"
            
            // Logging the status and details
            print("\(prefix): Buffer Full: \(bufferFull), Buffer Empty: \(bufferEmpty), Likely to Keep Up: \(likelyToKeepUp), Error: \(errorDescription)")
            
            // Setting buffer duration preference and rechecking status
            cellVideoNode.currentItem?.preferredForwardBufferDuration = 5
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { [weak self] in
                guard let self = self, let status = self.cellVideoNode.currentItem?.status else {
                    print("Playback status check failed - status unavailable")
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
        UIView.animate(withDuration: 0.2) {
            self.cellVideoNode.alpha = 0.0
        } completion: { _ in
            // Replacing the video asset
            self.cellVideoNode.asset = nil
            self.cellVideoNode.asset = AVAsset(url: self.getVideoURL(post: self.post)!)

            // Fading the video node back in and starting playback
            UIView.animate(withDuration: 0.2) {
                self.cellVideoNode.alpha = 1.0
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
            print("Can't play because of \(isActive) or \(cellVideoNode.isPlaying())")
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
            if playTimeBar != nil {
                playTimeBar.setValue(Float(0), animated: true)
            }
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
        playTimeBar.setValue(Float(0), animated: true)
    }

    /// Handles playback based on the current status of the video node.
    /// - Parameters:
    ///   - status: The current status of the video node's item.
    ///   - prefix: Prefix for log messages.
    private func handlePlaybackBasedOn(status: AVPlayerItem.Status, withPrefix prefix: String) {
        switch status {
        case .readyToPlay:
            startPlayback()
            print("\(prefix) - Ready to play")
        case .failed:
            addSpinner()
            print("\(prefix) - Playback failed")
        case .unknown:
            addSpinner()
            print("\(prefix) - Playback status unknown")
        @unknown default:
            addSpinner()
            print("\(prefix) - Unexpected playback status")
        }
    }

    /// Retries or resets playback based on the current status of the video node.
    private func retryOrResetPlaybackBasedOnCurrentStatus() {
        guard let status = cellVideoNode.currentItem?.status else {
            print("Playback status check failed - status unavailable")
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

extension VideoNode {
    
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


extension VideoNode {
    
    /// Configures the image node with a given post model.
    /// - Parameter post: The post model used to configure the image node.
    private func configureImageNode(with post: PostModel) {
        
        // Set up the cell image node's appearance and behavior.
        setupImageNodeAppearance()
        
        // Determine and set the image content mode based on post's metadata.
        determineAndSetImageContentMode(with: post)
        
        // Load the image asset asynchronously.
        loadImageAssetAsync(with: post)
    }
    
    /// Sets up the appearance of cellImageNode.
    private func setupImageNodeAppearance() {
        cellImageNode.cornerRadius = 12
        cellImageNode.clipsToBounds = true
        cellImageNode.backgroundColor = .black
    }
    
    /// Determines and sets the image content mode based on post's metadata.
    /// - Parameter post: The post model with metadata to determine content mode.
    private func determineAndSetImageContentMode(with post: PostModel) {
        if let width = post.metadata?.width, let height = post.metadata?.height, width != 0, height != 0 {
            setImageContentModeFor(width: width, height: height)
        } else {
            setDefaultImageContentMode()
        }
    }
    
    /// Asynchronously loads the image asset for the cellImageNode.
    /// - Parameter post: The post model containing the image URL.
    private func loadImageAssetAsync(with post: PostModel) {
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else { return }
            self.cellImageNode.url = URL(string: post.imageUrl.absoluteString)
        }
    }
    
    /// Sets the image content mode based on the given dimensions.
    /// - Parameters:
    ///   - width: The width of the image.
    ///   - height: The height of the image.
    func setImageContentModeFor(width: CGFloat, height: CGFloat) {
        let aspectRatio = width / height
        // Check for a 9:16 aspect ratio with a margin for error.
        if abs(aspectRatio - (9.0/16.0)) < 0.01 {
            cellImageNode.contentMode = .scaleAspectFill
        } else {
            setDefaultImageContentMode()
        }
    }

    /// Sets the default image content mode for the cellImageNode.
    func setDefaultImageContentMode() {
        cellImageNode.contentMode = .scaleAspectFit
    }
    
}


extension VideoNode {
    
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
        cellVideoNode.backgroundColor = .black
    }
    
    /// Sets up the behavior of cellVideoNode based on the post model.
    /// - Parameter post: The post model used for configuration.
    private func setupCellVideoNodeBehavior(with post: PostModel) {
        cellVideoNode.url = getThumbnailURL(post: post)
        cellVideoNode.shouldAutoplay = false
        cellVideoNode.shouldAutorepeat = true
        if !isPreview {
            cellVideoNode.delegate = self
        }
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
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else { return }
            self.cellVideoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
            // Play video if first item on list.
            if firstItem {
                playVideo()
            }
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

extension VideoNode {
    
    /// Sets up child views of the VideoNode.
    /// This function orchestrates the setup of various subviews including header, footer, and interaction buttons.
    func setupChildView() {
        // Setup different view components of the VideoNode.
        setupHeaderViews()
        setupFooterViews()
        setupInteractionButtonViews()

        // Adjust space based on the width of the view.
        setupSpace(width: self.view.frame.width)

        // Populate the VideoNode with relevant post information.
        fillPostStats()
        fillPostHeaderInfo()
        fillPostFooterInfo()

        // Load and setup reactions and gesture recognizers.
        loadReaction()
        setupGestureRecognizers()
        setupCustomTap()
        
        // Setup the time view if the post contains a muxPlaybackId.
        if !post.muxPlaybackId.isEmpty {
            setupTimeView()
            setupFunction()
        }
        
        if isPreview {
            footerView.stitchBtn.isHidden = true
        }
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
    
    /// Sets up the interaction button views.
    /// This method adds the button view to the node and applies necessary constraints.
    private func setupInteractionButtonViews() {
        self.view.addSubview(self.buttonView)
        addButtonsConstraints(to: self.buttonView, within: self.view)
    }

    // MARK: - Constraint Setup

    /// Adds constraints to the interaction button view.
    /// - Parameters:
    ///   - childView: The child view to which constraints are applied.
    ///   - parentView: The parent view in which the child view resides.
    ///   - constant: An optional constant value for leading and trailing constraints.
    private func addButtonsConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -2),
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: constant),
            childView.heightAnchor.constraint(equalToConstant: 30) // Height of the button view.
        ])
    }

    /// Adds constraints to the header view.
    /// - Parameters:
    ///   - childView: The child view to which constraints are applied.
    ///   - parentView: The parent view in which the child view resides.
    ///   - constant: An optional constant value for leading, trailing, and top constraints.
    private func addHeaderConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 94),
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: constant),
            childView.heightAnchor.constraint(equalToConstant: 80) // Height of the header view.
        ])
    }

    /// Adds constraints to the footer view.
    /// - Parameters:
    ///   - childView: The child view to which constraints are applied.
    ///   - parentView: The parent view in which the child view resides.
    ///   - constant: An optional constant value for leading, trailing, and bottom constraints.
    private func addFooterConstraints(to childView: UIView, within parentView: UIView, constant: CGFloat = 0) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -50), // Offset from the bottom.
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: constant),
            childView.heightAnchor.constraint(equalToConstant: 150) // Height of the footer view.
        ])
    }

    /// Sets up spacing for the button view stack.
    /// - Parameter width: The width of the view which contains the button view.
    private func setupSpace(width: CGFloat) {
        let leftAndRightPadding: CGFloat = 40 * 2 // Total padding for both sides.
        let itemWidth: CGFloat = 50 // Width of each item in the stack view.
        let numberOfItems: CGFloat = 4 // Number of items in the stack view.
        let totalItemWidth: CGFloat = numberOfItems * itemWidth // Total width of all items.
        let totalSpacingWidth: CGFloat = width - totalItemWidth - leftAndRightPadding // Total available width for spacing.
        let spacing: CGFloat = totalSpacingWidth / (numberOfItems - 1) // Spacing between each item.
        buttonView.stackView.spacing = spacing // Applying the calculated spacing.
    }
    
    // MARK: - Post Information Filling

    /// Fills the post statistics like likes, comments, saves, and stitch counts
    func fillPostStats() {
        // Updating local properties with post statistics
        likeCount = post.totalLikes
        saveCount = post.totalSave

        // Filling the button view with post information
        // This includes like count, comment count, save count, and total stitch count
        buttonView.fillInformation(
            likeCount: post.totalLikes,
            cmtCount: post.totalComments,
            saveCount: post.totalSave,
            totalOnChain: post.totalOnChain,
            positionOnChain: post.positionOnChain, 
            postID: post.id
        )
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
        footerView.setFooterInfo(
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
        let usernameTap1 = createTapGestureRecognizer(target: self, action: #selector(VideoNode.userTapped))
        self.headerView.username.isUserInteractionEnabled = true
        self.headerView.username.addGestureRecognizer(usernameTap1)
        
        // Avatar Image Tap Gesture (Header View)
        let usernameTap2 = createTapGestureRecognizer(target: self, action: #selector(VideoNode.userTapped))
        self.headerView.avatarImg.isUserInteractionEnabled = true
        self.headerView.avatarImg.addGestureRecognizer(usernameTap2)
        
        if !isPreview  {
            // Settings Button1 Tap Gesture
            let settingTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.settingTapped))
            self.headerView.settingBtn.addGestureRecognizer(settingTap)
            
            // Settings Button2 Tap Gesture
            let settingTap2 = createTapGestureRecognizer(target: self, action: #selector(VideoNode.settingTapped))
            self.headerView.postTime.addGestureRecognizer(settingTap2)
            self.headerView.postTime.isUserInteractionEnabled = true
            
            // Settings Button3 Tap Gesture
            let settingTap3 = createTapGestureRecognizer(target: self, action: #selector(VideoNode.settingTapped))
            self.headerView.postDate.addGestureRecognizer(settingTap3)
            self.headerView.postDate.isUserInteractionEnabled = true
        }

        // Like Button Tap Gesture
        let likeTap1 = createTapGestureRecognizer(target: self, action: #selector(VideoNode.likeTapped))
        self.buttonView.likeStackView.addGestureRecognizer(likeTap1)
        self.buttonView.likeStackView.isUserInteractionEnabled = true

        // Stitch Button Tap Gesture (Footer View)
        let stitchTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.stitchTapped))
        self.footerView.stitchBtn.addGestureRecognizer(stitchTap)

        // Save Button Tap Gesture
        let saveTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.onClickSave))
        self.buttonView.saveStackView.addGestureRecognizer(saveTap)
        self.buttonView.saveStackView.isUserInteractionEnabled = true
        
        // Comment Button Tap Gesture
        let commentTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.commentTapped))
        self.buttonView.commentStackView.addGestureRecognizer(commentTap)
        self.buttonView.commentStackView.isUserInteractionEnabled = true
        
        // Comment Button Tap Gesture
        let playListTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.playListTapped))
        self.buttonView.playListStackView.addGestureRecognizer(playListTap)
        self.buttonView.playListStackView.isUserInteractionEnabled = true

        // Double Tap Gesture (Like Handler)
        let doubleTap = createTapGestureRecognizer(target: self, action: #selector(VideoNode.likeHandle), taps: 2)
        doubleTap.delaysTouchesBegan = true
        self.view.addGestureRecognizer(doubleTap)
        
        // Long Press Gesture (Settings)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(VideoNode.settingTapped))
        longPress.minimumPressDuration = 0.35
        longPress.delaysTouchesBegan = true
        self.view.addGestureRecognizer(longPress)
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

    /// Presents the `PostListWithHashtagVC` for the given hashtag.
    /// - Parameter selectedHashtag: The hashtag selected by the user.
    func presentPostListWithHashtagVC(for selectedHashtag: String) {
        // Using guard for safe unwrapping and to handle potential errors.
        guard let PLHVC = UIStoryboard(name: "Dashboard", bundle: nil)
                .instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC,
              let vc = UIViewController.currentViewController() else {
            // Error handling if the view controller could not be instantiated.
            print("Error: Unable to instantiate PostListWithHashtagVC from storyboard.")
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

extension VideoNode {

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
                    print("Error: Invalid or missing data in response")
                    return
                }
                
                // Handling the reaction data.
                strongSelf.handleReaction(isFollower: isFollower, isFollowing: isFollowing, isLiked: isLiked, isSaved: isSaved)
            case .failure(let error):
                print("API Error: \(error)")
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

        // Configuring the follow button based on the follower status.
        if isFollower || finalPost.owner?.id == _AppCoreData.userDataSource.value?.userID {
            hideFollowBtn()
        } else {
            setupFollowBtn()
        }

        // Updating save status and animation.
        isSave = isSaved
        isSaved ? saveAnimation() : unSaveAnimation()

        // Updating like status and image.
        isLike = isLiked
        updateLikeButtonImage(isLiked: isLiked)
    }

    /// Updates the like button image based on the like status.
    /// - Parameter isLiked: Indicates whether the current post is liked.
    private func updateLikeButtonImage(isLiked: Bool) {
        let likeImageToUse = isLiked ? likeImage : emptyLikeImage
        guard let likeImage = likeImageToUse else {
            print("Error: likeImage or emptyLikeImage is nil")
            return
        }

        buttonView.setLikeImage(image: likeImage)
    }

    
    /// Processes the status of stitch (following) based on various conditions.
    /// - Parameter isFollowingMe: Boolean indicating if the user is following me.
    func processStitchStatus(isFollowingMe: Bool) {
        footerView.stitchBtn.isHidden = false
    }

    // MARK: - Follow Button Management

    /// Hides the follow button.
    /// This method is called when the follow button should not be displayed.
    func hideFollowBtn() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.headerView.followBtn.isHidden = true
            strongSelf.isFollowingUser = true
        }
    }

    /// Sets up the follow button.
    /// This method makes the follow button visible and sets up its tap gesture recognizer.
    func setupFollowBtn() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.headerView.followBtn.isHidden = false
            strongSelf.isFollowingUser = false
            let followTapped = UITapGestureRecognizer(target: strongSelf, action: #selector(VideoNode.followTap))
            followTapped.numberOfTapsRequired = 1
            strongSelf.headerView.followBtn.addGestureRecognizer(followTapped)
        }
    }
}



extension VideoNode {
    
    // MARK: - UI Interaction Handling

    /// Disables user interaction with certain UI elements.
    func disableTouching() {
        // Hide buttons and labels in footer and header views
        footerView.stitchBtn.isHidden = true
        footerView.descriptionLbl.isHidden = true
        
        headerView.followBtn.isHidden = true
        headerView.isUserInteractionEnabled = false
        headerView.settingBtn.isHidden = true
    }
    
    /// Hide Footer and buttons on showing playlist
    func hideView() {
        // Hide buttons and labels in footer and header views
        footerView.isHidden = true
        buttonView.isHidden = true
    }
    
    /// Show Footer and buttons on showing playlist
    func showView() {
        // Show buttons and labels in footer and header views
        footerView.isHidden = false
        buttonView.isHidden = false
    }

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

    // MARK: - Save/Unsave Post Handling

    /// Toggles save state and handles the corresponding action.
    @objc func onClickSave() {
        isSave.toggle()
        isSave ? handleSave() : handleUnsave()
    }

    /// Handles saving a post.
    private func handleSave() {
        saveCount += 1
        saveAnimation()
        APIManager.shared.savePost(postId: post.id) { [weak self] result in
            guard let self = self else { return }
            self.processSaveResult(result, isSaving: true)
        }
    }

    /// Handles unsaving a post.
    private func handleUnsave() {
        saveCount -= 1
        unSaveAnimation()
        APIManager.shared.unsavePost(postId: post.id) { [weak self] result in
            guard let self = self else { return }
            self.processSaveResult(result, isSaving: false)
        }
    }

    /// Processes the result of save/unsave operation.
    private func processSaveResult(_ result: Result, isSaving: Bool) {
        switch result {
        case .failure(let error):
            print("Error in \(isSaving ? "saving" : "unsaving") post: \(error)")
            isSave = !isSaving
            isSaving ? unSaveAnimation() : saveAnimation()
        case .success(let apiResponse):
            print(apiResponse)
        }
    }


    // MARK: - Share Handling

    /// Handles the share action.
    @objc func shareTapped() {
        guard let userDataSource = _AppCoreData.userDataSource.value,
              let userUID = userDataSource.userID, !userUID.isEmpty else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        createShare(userUID: userUID)
        
        if let loadUsername = userDataSource.userName {
            presentShareController(username: loadUsername)
        }
    }

    /// Creates a share action with API call.
    private func createShare(userUID: String) {
        APIManager.shared.createShare(postId: post.id, userId: userUID) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print("Error creating share: \(error)")
            }
        }
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
    
    // MARK: - playList Handling

    /// Handles the comment action.
    @objc func playListTapped() {
        viewStitchBtn?(self)
    }

    // MARK: - Comment Handling

    /// Handles the comment action.
    @objc func commentTapped() {
        guard let viewController = UIViewController.currentViewController() else { return }
        presentCommentViewController(from: viewController)
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

    // MARK: - Stitch Handling

    /// Handles the stitch action.
    @objc func stitchTapped() {
        guard let viewController = UIViewController.currentViewController() else {
            showStitchError()
            return
        }
        
        presentStitchSettingViewController(from: viewController)
    }

    /// Presents the stitch setting view controller.
    private func presentStitchSettingViewController(from viewController: UIViewController) {
        let stitchSettingVC = StitchSettingVC()
        configureStitchSettingVC(stitchSettingVC, presentingFrom: viewController)
        
        viewController.present(stitchSettingVC, animated: true)
    }

    /// Configures the StitchSettingVC with appropriate data.
    private func configureStitchSettingVC(_ stitchSettingVC: StitchSettingVC, presentingFrom viewController: UIViewController) {
        stitchSettingVC.modalPresentationStyle = .custom
        stitchSettingVC.transitioningDelegate = viewController
        global_presetingRate = 0.25
        global_cornerRadius = 35
        
        // Configure view controller based on its type
        if let feedVC = viewController as? FeedViewController {
            updateFeedViewController(feedVC, with: stitchSettingVC)
        } else if let selectedVC = viewController as? SelectedRootPostVC {
            updateSelectedViewController(selectedVC, with: stitchSettingVC)
        }
    }

    // Helper methods to update the view controller
    private func updateFeedViewController(_ viewController: FeedViewController, with stitchSettingVC: StitchSettingVC) {
        stitchSettingVC.isSelected = false
        viewController.editeddPost = post
    }

    private func updateSelectedViewController(_ viewController: SelectedRootPostVC, with stitchSettingVC: StitchSettingVC) {
        stitchSettingVC.isSelected = true
        viewController.editeddPost = post
    }

    /// Displays an error related to stitching functionality.
    private func showStitchError() {
        // Ensure a view controller is available.
        guard let vc = UIViewController.currentViewController() else {
            return
        }

        // Check if the post's owner's username is available.
        if let stitchUsername = post.owner?.username {
            // Fetch the current user's username.
            let myUsername = _AppCoreData.userDataSource.value?.userName
            // Determine the title based on the availability of myUsername.
            let title = myUsername != nil ? "Hi \(myUsername!)," : "Oops!"
            // Construct the error message.
            let message = "@\(stitchUsername) has to follow you to enable stitch or a technical issue has occurred"
            
            // Show error in the viewController, if applicable.
            if let update1 = vc as? FeedViewController {
                update1.showErrorAlert(title, msg: message)
            } else if let update1 = vc as? SelectedRootPostVC {
                update1.showErrorAlert(title, msg: message)
            }
        }
    }

    /// Handles the follow button tap action.
    @objc func followTap() {
        // Check if processing is allowed.
        guard allowProcess else { return }
        
        allowProcess = false
        // Toggle between follow and unfollow based on the current state.
        isFollowingUser ? unfollowUser() : followUser()
    }

    /// Handles the like button tap action.
    @objc func likeTapped() {
        // Toggle between like and unlike based on the current state.
        isLike ? performUnLike() : performLike()
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

    /// Handles the like action.
    @objc func likeHandle() {
        // Guard against already liked state.
        guard !isLike else { return }
        
        let imgView = createImageView()
        view.addSubview(imgView)
        
        // Add fireworks effects to the image view.
        fireworkController.addFirework(sparks: 10, above: imgView)
        fireworkController2.addFireworks(count: 10, sparks: 8, around: imgView)
        
        // Animate the image view and perform the like action.
        animateImageView(imgView)
        performLike()
    }

    /// Creates an image view for the like animation.
    private func createImageView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = popupLikeImage
        imgView.frame.size = CGSize(width: 120, height: 120)
        imgView.contentMode = .scaleAspectFit
        imgView.center = view.center
        return imgView
    }

    /// Animates the fading out of the image view.
    private func animateImageView(_ imgView: UIImageView) {
        UIView.animate(withDuration: 0.5) {
            imgView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            imgView.removeFromSuperview()
        }
    }

    /// Performs the action to like a post.
    func performLike() {
        likeCount += 1
        updateLikeUI()
        
        // Call API to like the post and handle the response.
        APIManager.shared.likePost(id: post.id) { [weak self] result in
            self?.handleAPIResponse(result)
        }
    }

    /// Updates the UI upon liking a post.
    private func updateLikeUI() {
        DispatchQueue.main.async { [weak self] in
            self?.likeAnimation()
            self?.buttonView.setLikeCount(likeCount: self?.likeCount ?? 0)
            self?.isLike = true
        }
    }

    /// Performs the action to unlike a post.
    func performUnLike() {
        likeCount -= 1
        updateUnlikeUI()
        
        // Call API to unlike the post and handle the response.
        APIManager.shared.unlikePost(id: post.id) { [weak self] result in
            self?.handleAPIResponse(result)
        }
    }

    /// Updates the UI upon unliking a post.
    private func updateUnlikeUI() {
        DispatchQueue.main.async { [weak self] in
            self?.unlikeAnimation()
            self?.buttonView.setLikeCount(likeCount: self?.likeCount ?? 0)
            self?.isLike = false
        }
    }

    /// Handles the API response for both liking and unliking a post.
    private func handleAPIResponse(_ result: Result) {
        switch result {
        case .success(let apiResponse):
            print(apiResponse)
        case .failure(let error):
            print(error)
        }
    }

    /// Performs the save button animation.
    func saveAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buttonView.setSaveCount(saveCount: self.saveCount)
            self.animateButton(self.buttonView.saveBtn, withImage: saveImage)
        }
    }

    /// Performs the unsave button animation.
    func unSaveAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buttonView.setSaveCount(saveCount: self.saveCount)
            self.animateButton(self.buttonView.saveBtn, withImage: unsaveImage)
        }
    }
    
    /// Performs the like button animation.
    func likeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.animateButton(self.buttonView.likeBtn, withImage: likeImage)
        }
    }

    /// Performs the unlike button animation.
    func unlikeAnimation() {
        animateButton(buttonView.likeBtn, withImage: emptyLikeImage)
    }

    /// Animates a button with a scaling effect and changes its image.
    /// - Parameters:
    ///   - button: The UIButton to animate.
    ///   - image: The UIImage to set on the button.
    private func animateButton(_ button: UIButton, withImage image: UIImage?) {
        let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: 0.1, animations: {
            button.transform = scaleTransform
            button.setImage(image, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform.identity
            }
        })
    }

}

// MARK: - VideoNode Extension Follow
extension VideoNode {
    
    /// Initiates the unfollow action for the post's owner.
    func unfollowUser() {
        guard let userId = post.owner?.id else { return }

        updateFollowButtonTitle(with: "+ Follow")

        APIManager.shared.unFollow(params: ["FollowId": userId]) { [weak self] result in
            self?.handleFollowResult(result, isFollowing: false, successButtonTitle: "Following")
        }
    }

    /// Initiates the follow action for the post's owner.
    func followUser() {
        guard let userId = post.owner?.id else { return }

        updateFollowButtonTitle(with: "Following")

        APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
            self?.handleFollowResult(result, isFollowing: true, successButtonTitle: "+ Follow")
        }
    }

    /// Updates the follow button's title.
    /// - Parameter title: The new title for the follow button.
    private func updateFollowButtonTitle(with title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.headerView.followBtn.setTitle(title, for: .normal)
        }
    }

    /// Handles the result of a follow/unfollow API request.
    /// - Parameters:
    ///   - result: The result of the API call.
    ///   - isFollowing: The follow status to be set on success.
    ///   - successButtonTitle: The button title to be set on failure.
    private func handleFollowResult(_ result: Result, isFollowing: Bool, successButtonTitle: String) {
        switch result {
        case .success:
            isFollowingUser = isFollowing
            allowProcess = true

        case .failure:
            DispatchQueue.main.async { [weak self] in
                self?.allowProcess = true
                self?.headerView.followBtn.setTitle(successButtonTitle, for: .normal)
                showNote(text: "Something happened!")
            }
        }
    }

}

// MARK: - VideoNode Extension

extension VideoNode {
    
    /// Sets up the time view for the video node.
    func setupTimeView() {
        // Initialize and configure the time label.
        timeLbl = UILabel()
        timeLbl.isHidden = true
        timeLbl.textColor = .white
        timeLbl.font = FontManager.shared.roboto(.Bold, size: 17)
        timeLbl.translatesAutoresizingMaskIntoConstraints = false

        // Initialize and configure the blur view.
        blurView = UIView()
        blurView.isHidden = true
        blurView.backgroundColor = .black
        blurView.alpha = 0.6
        blurView.translatesAutoresizingMaskIntoConstraints = false

        // Initialize the play time bar with updated constraints.
        playTimeBar = CustomSlider()
        playTimeBar.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews to the video node's view.
        [blurView, timeLbl, playTimeBar].forEach { self.view.addSubview($0) }

        // Activate constraints in a batch.
        NSLayoutConstraint.activate([
            // Constraints for the blur view.
            blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            
            // Constraints for the time label.
            timeLbl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            timeLbl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            // Updated constraints for the play time bar.
            playTimeBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -37),
            playTimeBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            playTimeBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            playTimeBar.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    /// Handles the video node's playback to a specific time interval.
    /// - Parameters:
    ///   - videoNode: The `ASVideoNode` instance playing the video.
    ///   - timeInterval: The current playback time interval.
    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        // Perform certain actions only under specific conditions.
        if didSlideEnd, !isPreview, let _ = blurView, let _ = videoNode.currentItem {
            // Initialize video duration if not already set.
            if videoDuration == 0 {
                videoDuration = videoNode.currentItem?.duration.seconds ?? 0
            }

            // Update the total watched time.
            if timeInterval >= previousTimeStamp {
                totalWatchedTime += timeInterval - previousTimeStamp
            }
            previousTimeStamp = timeInterval

            // Calculate watched percentage and define minimum watched percentage.
            let watchedPercentage = totalWatchedTime / videoDuration
            let minimumWatchedPercentage = determineMinimumWatchedPercentage(forDuration: videoDuration)
            
            // Check for minimum watched criteria and count the view if criteria are met.
            let minimumWatchedTime = 5.0
            if shouldCountView && totalWatchedTime >= minimumWatchedTime && watchedPercentage >= minimumWatchedPercentage {
                shouldCountView = false
                endVideo(watchTime: Double(totalWatchedTime))
            }
            
            // Update the slider with the current time.
            updateSlider(currentTime: timeInterval)
        }
    }

    /// Handles actions when the video plays to its end.
    func videoDidPlay(toEnd videoNode: ASVideoNode) {
        shouldCountView = true
    }

    /// Ends the video playback and performs necessary actions.
    /// - Parameter watchTime: The total watch time of the video.
    func endVideo(watchTime: Double) {
        // Perform actions if certain conditions are met.
        guard let finalPost = post, let _ = _AppCoreData.userDataSource.value, time < 2 else { return }
        
        time += 1
        lastViewTimestamp = NSDate().timeIntervalSince1970
        isViewed = true
        
        // Call API to create a view record.
        APIManager.shared.createView(post: finalPost.id, watchTime: watchTime) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
            case .failure(let error):
                print(error)
            }
        }
    }

    /// Updates the slider to reflect the current playback time.
    /// - Parameter currentTime: The current time of the video playback.
    func updateSlider(currentTime: TimeInterval) {
        // Ensure that playTimeBar is available.
        guard let playTimeBar = playTimeBar else { return }

        // Set the maximum value of the slider if it hasn't been set yet.
        if !setupMaxVal, let max = cellVideoNode.currentItem?.duration {
            let maxDurationSeconds = CMTimeGetSeconds(max)
            // Check if max duration is a valid number and set it as the maximum value of the slider.
            if !maxDurationSeconds.isNaN {
                playTimeBar.maximumValue = Float(maxDurationSeconds)
                setupMaxVal = true
            }
        }
        
        // Set the current value of the slider to the current playback time.
        playTimeBar.setValue(Float(currentTime), animated: false)
    }


    /// Determines the minimum watched percentage for counting a view, based on video duration.
    /// - Parameter duration: The total duration of the video in seconds.
    /// - Returns: The minimum percentage of the video that should be watched.
    private func determineMinimumWatchedPercentage(forDuration duration: Double) -> Double {
        switch duration {
        case 0..<15:
            return 0.8 // 80% for videos shorter than 15 seconds.
        case 15..<30:
            return 0.7 // 70% for videos between 15 and 30 seconds.
        case 30..<60:
            return 0.6 // 60% for videos between 30 and 60 seconds.
        case 60..<90:
            return 0.5 // 50% for videos between 60 and 90 seconds.
        case 90..<120:
            return 0.4 // 40% for videos between 90 and 120 seconds.
        default:
            return 0.5 // A default value for videos longer than 120 seconds.
        }
    }

}

