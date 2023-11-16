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
import NVActivityIndicatorView


class VideoNode: ASCellNode, ASVideoNodeDelegate {

    // Deinitializer to remove observers and log deallocation.
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("VideoNode is being deallocated.")
    }

    // MARK: - Properties
    weak var post: PostModel!
    var videoDuration: Double = 0
    var last_view_timestamp = NSDate().timeIntervalSince1970
    var totalWatchedTime: TimeInterval = 0.0
    var previousTimeStamp: TimeInterval = 0.0
    private var cellVideoNode: ASVideoNode
    private var gradientNode: GradienView
    var time = 0
    var shouldCountView = true
    var isViewed = false
    
    var didSlideEnd = true
    var setupMaxVal = false
    var isActive = false
    var firstSetup = false
    var spinnerRemoved = true
    var assetReset = false

    // Additional properties related to UI and video status
    var isFirstItem = false
    var selectedStitch = false
    private var timeLbl: UILabel!
    private var blurView: UIView!
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    private var spinner: NVActivityIndicatorView!
    private lazy var headerView: PostHeader = PostHeader()
    private let maximumShowing = 100
    private var isSave = false
    private var isFollowingUser = false
    private var allowStitch = false
    private var saveCount = 0
    private var likeCount = 0
    private var isLike = false
    private var allowProcess = true
    fileprivate let FontSize: CGFloat = 13
    private var isPreview: Bool!
    private var playTimeBar: CustomSlider!
    var statusObservation: NSKeyValueObservation?

    // MARK: - Initializer
    // Initializes the node with a post, index, preview flag, and other parameters.
    init(with post: PostModel, isPreview: Bool) {
        self.post = post
        self.gradientNode = GradienView()
        self.cellVideoNode = ASVideoNode()
        self.isPreview = isPreview
        super.init()
        configureGradientNode()
        configureVideoNode(with: post)
    }

    
    override func didLoad() {
        super.didLoad()
    
        setupSpinner()
       
     }
    
    func setupSpinner() {
        spinner = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 55, height: 55), type: .circleStrokeSpin, color: .white, padding: 0)
    }
    

    
    private func setupSpace(width: CGFloat) {
        
        let leftAndRightPadding: CGFloat = 20 * 2 // Padding for both sides
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
        //headerView.stackView.spacing = spacing
    }

    private func configureGradientNode() {
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
    }

    private func configureVideoNode(with post: PostModel) {
        
        cellVideoNode.url = getThumbnailURL(post: post)
        
        cellVideoNode.shouldAutoplay = false
        cellVideoNode.shouldAutorepeat = true
        cellVideoNode.backgroundColor = .red
        if !isPreview {
            cellVideoNode.delegate = self
        }
     

        if let width = post.metadata?.width, let height = post.metadata?.height, width != 0, height != 0 {
            setVideoContentModeFor(width: width, height: height)
        } else {
            setDefaultVideoContentMode()
        }
        
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else { return }
            
            self.cellVideoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
            
            if self.isFirstItem == true {
                self.playVideo()
            }
             
        }
        
    }
    
    func setVideoContentModeFor(width: CGFloat, height: CGFloat) {
        
        // Calculate the aspect ratio with a higher precision
        let aspectRatio = width / height

        // Check for exact 9:16 aspect ratio
        if abs(aspectRatio - (9.0/16.0)) < 0.01 {
            // The threshold (0.01) is to allow a tiny margin of error due to floating point precision.
            cellVideoNode.contentMode = .scaleAspectFill
            cellVideoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        } else {
            setDefaultVideoContentMode()
        }
        
    }

    func setDefaultVideoContentMode() {
        cellVideoNode.contentMode = .scaleAspectFit
        cellVideoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
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
            
            let urlString = "https://stream.mux.com/\(post.muxPlaybackId).m3u8?redundant_streams=true&max_resolution=1080p"
            
            return URL(string: urlString)
            
        } else {
            
            return nil
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        let ratioSpec = ASRatioLayoutSpec(ratio:ratio, child: cellVideoNode)
     
        let gradientOverlaySpec = ASOverlayLayoutSpec(child:ratioSpec, overlay: gradientNode)
        
        // Add 16 points of inset to the bottom
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0), child: gradientOverlaySpec)

        return insetSpec
    }

 
}



extension VideoNode {
    
    private func setupFunction() {
        
        playTimeBar.addTarget(self, action: #selector(VideoNode.sliderDidStartSliding), for: .touchDown)
        playTimeBar.addTarget(self, action: #selector(VideoNode.sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        playTimeBar.addTarget(self, action: #selector(VideoNode.sliderValueDidChange), for: .valueChanged)
        
    }

    
    @objc func sliderDidStartSliding() {
        processOnSliding()
        playTimeBar.startLayout()
        didSlideEnd = false
    }
    
    @objc func sliderDidEndSliding() {
        processEndedSliding()
        playTimeBar.endLayout()
        didSlideEnd = true
        
        let newVideoTime = CMTimeMakeWithSeconds(Float64(playTimeBar.value), preferredTimescale: Int32(NSEC_PER_SEC))
        cellVideoNode.player?.seek(to: newVideoTime)
    }
    
    
    @objc func sliderValueDidChange() {
        // Get the new video time
    
        timeLbl.text = processTime()
    
    }

    
    func processTime() -> String {
        
        let newVideoTime = CMTimeMakeWithSeconds(Float64(playTimeBar.value), preferredTimescale: Int32(NSEC_PER_SEC))

        // Calculate the minutes and seconds
        let totalSeconds = Int(CMTimeGetSeconds(newVideoTime))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60

        // Calculate total duration minutes and seconds
        let totalDurationSeconds = Int(playTimeBar.maximumValue)
        let durationSeconds = totalDurationSeconds % 60
        let durationMinutes = totalDurationSeconds / 60

        // Print the time in the format 00:00 / 00:00
        return String(format: "%02d:%02d / %02d:%02d", minutes, seconds, durationMinutes, durationSeconds)
        
    }
    
    func processOnSliding() {
        
        
        cellVideoNode.pause()
        timeLbl.text = processTime()
        timeLbl.isHidden = false
        blurView.isHidden = false
        
    }

    func processEndedSliding() {
    
        cellVideoNode.play()
        timeLbl.isHidden = true
        blurView.isHidden = true
        
    }
    
}


extension VideoNode {

    func playVideo() {
        /*
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
        */
    }

    func addObservers() {
        statusObservation = cellVideoNode.currentItem?.observe(\.status, options: [.new, .initial], changeHandler: { [weak self] (playerItem, change) in
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
            if cellVideoNode.isPlaying() != true {
                cellVideoNode.play()
            }
            
        }
        
    }

    func pauseVideo(shouldSeekToStart: Bool) {
        
        isActive = false
        cellVideoNode.pause()
        removeObservers()
        
        if shouldSeekToStart {
            let time = CMTime(seconds: 0, preferredTimescale: 1)
            cellVideoNode.player?.seek(to: time)
            playTimeBar.setValue(Float(0), animated: true)
        }
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
        pauseVideo(shouldSeekToStart: false)
        removeObservers()
    }


    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        
        isActive = true
        
        if !firstSetup {
            firstSetup = true
            print("Setup completed for - \(post.id)")
        } else {
            print("Setup already completed for - \(post.id)")
        }
        
    }
    
    
}
