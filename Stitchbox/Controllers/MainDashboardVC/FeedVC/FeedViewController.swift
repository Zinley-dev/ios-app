//
//  FeedViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage
import ObjectMapper
import MarqueeLabel

class FeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var lastContentOffsetY: CGFloat = 0

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var currentIndex: Int?
    var newPlayingIndex: Int?
    var isVideoPlaying = false
    
    var isfirstLoad = true
    var posts = [PostModel]()
   
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var refresh_request = false

    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem3 = workItem()
    var firstAnimated = true
    var lastLoadTime: Date?
    var animatedLabel: MarqueeLabel!
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        setupCollectionNode()
        addAnimatedLabelToTop()
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            collectionNode.view.refreshControl = pullControl
        } else {
            collectionNode.view.addSubview(pullControl)
        }
        
        //self.navigationController?.hidesBarsOnSwipe = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if firstAnimated {
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if let path = Bundle.main.path(forResource: "fox2", ofType: "gif") {
                        let gifData = try Data(contentsOf: URL(fileURLWithPath: path))
                        let image = FLAnimatedImage(animatedGIFData: gifData)

                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }

                            self.loadingImage.animatedImage = image
                            self.loadingView.backgroundColor = self.view.backgroundColor
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }
   
        
    }
    
    
    func addAnimatedLabelToTop() {
        animatedLabel = MarqueeLabel(frame: CGRect.zero, rate: 30.0, fadeLength: 10.0)
        animatedLabel.translatesAutoresizingMaskIntoConstraints = false
        animatedLabel.backgroundColor = UIColor.clear
        animatedLabel.type = .continuous
        animatedLabel.leadingBuffer = 15.0
        animatedLabel.trailingBuffer = 10.0
        animatedLabel.animationDelay = 0.0
        animatedLabel.textAlignment = .center
        animatedLabel.font = FontManager.shared.roboto(.Bold, size: 16)
        animatedLabel.textColor = UIColor.white
        animatedLabel.layer.masksToBounds = true
        animatedLabel.layer.cornerRadius = 10 // Round the corners for a cleaner look

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(container)
        container.addSubview(animatedLabel)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 100),
            container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100),
            container.topAnchor.constraint(equalTo: self.view.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 55),
            animatedLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10), // Add padding around the text
            animatedLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10), // Add padding around the text
            animatedLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10), // Add padding around the text
            animatedLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10) // Add padding around the text
        ])
        
        // Make the label tappable
        container.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedViewController.labelTapped))
        tap.numberOfTapsRequired = 1
        container.addGestureRecognizer(tap)
        
    }
    
    func applyAnimationText(text: String) {
        if text != "" {
            animatedLabel.text = text + "                   "
            animatedLabel.restartLabel()
        } else {
            //animatedLabel.pauseLabel()
            animatedLabel.text = text
        }
           
    }
    
    @objc private func refreshListData(_ sender: Any) {
        // Call API
        
        self.clearAllData()
        
    }
    
    
}

extension FeedViewController {
    
    @objc func updateProgressBar() {
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.progressBar.isHidden = true
                
            }
            global_percentComplete = 0.00
            
        } else {
            
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.progressBar.isHidden = false
                self.progressBar.progress = (CGFloat(global_percentComplete)/100)
                
            }
            
        }
        
    }
    
    
}



extension FeedViewController {

 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !posts.isEmpty, scrollView == collectionNode.view {
            
            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            
            // Calculate the visible cells.
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? VideoNode }
            
            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            
            var foundVisibleVideo = false
            
            for cell in visibleCells {
                
                let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
                let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                let distanceFromCenter = abs(cellCenter.y - visibleRect.midY)
                if distanceFromCenter < minDistanceFromCenter {
                    newPlayingIndex = cell.indexPath!.row
                    minDistanceFromCenter = distanceFromCenter
                }
            }
            
            
            if !posts[newPlayingIndex!].muxPlaybackId.isEmpty {
                
                foundVisibleVideo = true
                playTimeBar.isHidden = false
               
            }
            
            
            if foundVisibleVideo {
                
                // Start playing the new video if it's different from the current playing video.
                if let newPlayingIndex = newPlayingIndex, currentIndex != newPlayingIndex {
                    // Pause the current video, if any.
                    if let currentIndex = currentIndex {
                        pauseVideo(index: currentIndex)
                    }
                    // Play the new video.
                    currentIndex = newPlayingIndex
                    playVideo(index: currentIndex!)
                    isVideoPlaying = true
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? VideoNode {
                        
                        resetView(cell: node)
                        
                    }
                    
                }
                
            } else {
                
                if let currentIndex = currentIndex {
                    pauseVideo(index: currentIndex)
                }

                
                
                // Reset the current playing index.
                currentIndex = nil
                
            }
            
            
            // If the video is stuck, reset the buffer by seeking to the current playback time.
            if let currentIndex = currentIndex, let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? VideoNode {
                if let playerItem = cell.cellVideoNode.currentItem, !playerItem.isPlaybackLikelyToKeepUp {
                    if let currentTime = cell.cellVideoNode.currentItem?.currentTime() {
                        cell.cellVideoNode.player?.seek(to: currentTime)
                    } else {
                        cell.cellVideoNode.player?.seek(to: CMTime.zero)
                    }
                }
            }
            
            // If there's no current playing video and no visible video, pause the last playing video, if any.
            if !isVideoPlaying && currentIndex != nil {
                pauseVideo(index: currentIndex!)
                currentIndex = nil
            }
            
        }
        
        
    }

 
}

extension FeedViewController: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let frameWidth = self.collectionNode.frame.width
        let frameHeight = self.collectionNode.frame.height
        
        // Check for excessively large sizes
        guard frameWidth < CGFloat.greatestFiniteMagnitude,
              frameHeight < CGFloat.greatestFiniteMagnitude else {
            print("Frame width or height is too large")
            return ASSizeRangeMake(CGSize.zero, CGSize.zero)
        }
        
        let min = CGSize(width: frameWidth, height: 50);
        let max = CGSize(width: frameWidth, height: frameHeight);
        
        return ASSizeRangeMake(min, max);
    }

    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
}

extension FeedViewController: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
        
    }
    
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return { [weak self] in
            guard let self = self else {
                return ASCellNode()
            }
            
            let node = VideoNode(with: post, at: indexPath.row)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
           
            node.isOriginal = true
            node.automaticallyManagesSubnodes = true
            
            if isfirstLoad, indexPath.row == 0 {
                isfirstLoad = false
                node.isFirstItem = true
                mainRootId = post.id
                currentIndex = 0
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "observeRootChangeForFeed")), object: nil)
                
                Dispatch.main.async() { [weak self] in
                    guard let self = self else {
                        return
                    }
                    handleAnimationTextAndImage(post: post)
                }
               
            
            }
            
            
            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
            retrieveNextPageWithCompletion { [weak self] (newPosts) in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                
                context.completeBatchFetching(true)
            }
        } else {
            context.completeBatchFetching(true)
        }
    }
    

}


extension FeedViewController {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0
       
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        
        self.collectionNode.reloadData()
       
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        
    }
    
    
}

extension FeedViewController {

    @objc func clearAllData() {
        refresh_request = true
        currentIndex = 0
        isfirstLoad = true
        shouldMute = nil
        updateData()
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] newPosts in
            guard let self = self else { return }

            self.insertNewRowsInCollectionNode(newPosts: newPosts)

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }

            self.delayItem.perform(after: 0.75) { [weak self] in
                self?.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
            }
        }
    }

    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getUserFeed { [weak self] result in
            var items: [[String: Any]] = []
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    items = data
                    
                    self?.lastLoadTime = Date()
                    print("Successfully retrieved \(data.count) posts.")
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                block(items)
            }
        }
    }

    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }

        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let uniquePosts = Set(self.posts)
        let items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !uniquePosts.contains($0) }
        
        guard !items.isEmpty else { return }

        self.posts.append(contentsOf: items)

        let indexPaths = (posts.count - items.count..<posts.count).map { IndexPath(row: $0, section: 0) }
        
        
        if firstAnimated {
                firstAnimated = false
                delay(0.15) { [weak self] in
                    UIView.animate(withDuration: 0.5) {
                        self?.loadingView.alpha = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if self?.loadingView.alpha == 0 {
                            self?.loadingView.isHidden = true
                        }
                    }
                }
            }

        collectionNode.insertItems(at: indexPaths)
        
    }


    private func clearExistingPosts() {
        let deleteIndexPaths = posts.enumerated().map { IndexPath(row: $0.offset, section: 0) }
        posts.removeAll()
        collectionNode.deleteItems(at: deleteIndexPaths)
    }

    
    
}


extension FeedViewController {
    
    func switchToProfileVC() {
    
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![4]
        
    }
    
    
    func handleAnimationTextAndImage(post: PostModel) {
        
        let total = post.totalStitchTo + post.totalMemberStitch
        
        if total > 0 {
            if total == 1 {
                applyAnimationText(text: "Up next: one new stitch!")
            } else {
                applyAnimationText(text: "Up next: \(total) stitches!")
            }
            
           
        } else {
            applyAnimationText(text: "")
        }
         
    }


}


extension FeedViewController {
    
    func pauseVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
            cell.cellVideoNode.pause()
            
            let time = CMTime(seconds: 0, preferredTimescale: 1)
            cell.cellVideoNode.player?.seek(to: time)
           // playTimeBar.setValue(Float(0), animated: false)
            
        }
        
    }

    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
           
            cell.cellVideoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func playVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
            if !cell.cellVideoNode.isPlaying() {

                handleAnimationTextAndImage(post: cell.post)
                
                if globalSetting.ClearMode == true {
                    
                    cell.hideAllInfo()
                    
                } else {
                    
                    cell.showAllInfo()
                    
                }
                
                if let muteStatus = shouldMute {
                    
                    
                    if muteStatus {
                        cell.cellVideoNode.muted = true
                    } else {
                        cell.cellVideoNode.muted = false
                    }
                    
                    cell.cellVideoNode.play()
                    
                } else {
                    
                    if globalIsSound {
                        cell.cellVideoNode.muted = false
                    } else {
                        cell.cellVideoNode.muted = true
                    }
                    
                    cell.cellVideoNode.play()
                    
                }
                
                mainRootId = cell.post.id
                
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "observeRootChangeForFeed")), object: nil)
                
            }
            
        }
        
    }
    
    
}

extension FeedViewController {
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader(progress: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: progress, animated: true)
        
        
    }
    
    @objc func labelTapped() {
        
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
    
}


