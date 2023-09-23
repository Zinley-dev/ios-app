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
    
    var timer: Timer?
    var isDraggingEnded: Bool = false
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    var lastContentOffsetY: CGFloat = 0
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var currentIndex: Int? = 0
    var newPlayingIndex: Int? = 0
    var isVideoPlaying = false
    
    var lastScrollTime: TimeInterval = 0
    var throttleTime: TimeInterval = 0.5 // Time in seconds
    
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
    var readyToLoad = false
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
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
        
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
            //animatedLabel.restartLabel()
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if !posts.isEmpty, scrollView == collectionNode.view, !refresh_request {
            
            let pageHeight: CGFloat = scrollView.bounds.height
            let currentOffset: CGFloat = scrollView.contentOffset.y
            let targetOffset: CGFloat = targetContentOffset.pointee.y
            var newTargetOffset: CGFloat = 0

            if targetOffset > currentOffset {
                newTargetOffset = ceil(currentOffset / pageHeight) * pageHeight
            } else {
                newTargetOffset = floor(currentOffset / pageHeight) * pageHeight
            }

            if newTargetOffset < 0 {
                newTargetOffset = 0
            } else if newTargetOffset > scrollView.contentSize.height - pageHeight {
                newTargetOffset = scrollView.contentSize.height - pageHeight
            }

            // Adjust the target content offset to the new target offset
            targetContentOffset.pointee.y = newTargetOffset
            
            // Set the flag
            isDraggingEnded = true
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !posts.isEmpty, scrollView == collectionNode.view, !refresh_request {
            
            if isDraggingEnded {
                    // Skip scrollViewDidScroll logic if we have just ended dragging
                    isDraggingEnded = false
                    return
                }

            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)

            // Calculate the visible cells.
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? VideoNode }

            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            var foundVisibleVideo = false
            var newPlayingIndex: Int?

            for cell in visibleCells {
                if let indexPath = cell.indexPath {
                    let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distanceFromCenter = abs(cellCenter.y - visibleRect.midY)
                    
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = indexPath.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            }

            if let index = newPlayingIndex, !posts[index].muxPlaybackId.isEmpty {
                foundVisibleVideo = true
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
            
            let node = VideoNode(with: post, at: indexPath.row, isPreview: false, vcType: "mainFeed", selectedStitch: false)
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
        
        if refresh_request == false, posts.count <= 200, readyToLoad {
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
        self.collectionNode.view.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    
}

extension FeedViewController {
    

    @objc func clearAllData() {
        refresh_request = true
        currentIndex = 0
        isfirstLoad = true
        updateData()
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] newPosts in
            guard let self = self else { return }

            self.insertNewRowsInCollectionNode(newPosts: newPosts)

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
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
        }

        let uniquePosts = Set(self.posts)  // Make a Set from existing posts for quick lookup
        var newUniquePosts: [PostModel] = []  // Array to store new unique posts

        // Convert newPosts to PostModel and filter out the duplicates
        for newPost in newPosts {
            if let postModel = PostModel(JSON: newPost) {
                if !uniquePosts.contains(postModel) {
                    newUniquePosts.append(postModel)
                }
            }
        }

        guard !newUniquePosts.isEmpty else { return }  // Make sure we have new unique posts

        // Append new unique posts to self.posts
        self.posts.append(contentsOf: newUniquePosts)

        // Generate the index paths for the new items
        let indexPaths = (posts.count - newUniquePosts.count..<posts.count).map { IndexPath(row: $0, section: 0) }

        // Insert the new unique items into the collection node
        collectionNode.insertItems(at: indexPaths)

        if refresh_request {
            refresh_request = false
        }
    }



    func clearExistingPosts() {
        posts.removeAll()
        collectionNode.reloadData()
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
            
            cell.pauseVideo()
            
        }
        
    }

    
    func playVideo(index: Int) {
        print("VideoNode: \(posts.count)")
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            handleAnimationTextAndImage(post: cell.post)
            cell.isActive = true
            cell.playVideo()
            mainRootId = cell.post.id
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "observeRootChangeForFeed")), object: nil)
            
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


