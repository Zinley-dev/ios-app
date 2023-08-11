//
//  StitchViewController.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/9/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage
import ObjectMapper
import MarqueeLabel

class StitchViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    var lastContentOffset: CGFloat = 0
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var lastContentOffsetY: CGFloat = 0
    //let threshold: CGFloat = 100 // Adjust this value as needed.

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
    
    
    @IBOutlet weak var selectPostCollectionView: UIView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var currentIndex: Int?
    var newPlayingIndex: Int?
    var hasViewAppeared = false
    var isVideoPlaying = false
    var curPage = 1
    //let promotionButton = UIButton(type: .custom)
    let homeButton: UIButton = UIButton(type: .custom)
   
    var isfirstLoad = true
    var didScroll = false
    var imageIndex: Int?
    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var galleryCollectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var refresh_request = false
    var startIndex: Int!

    var imageTimerWorkItem: DispatchWorkItem?
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem3 = workItem()
    var firstAnimated = true
    var lastLoadTime: Date?
    var isPromote = false
    var rootId = ""
    var animatedLabel: MarqueeLabel!
    
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let height =  UIScreen.main.bounds.height * 1 / 4
        heightConstraint.constant = height
        
        setupCollectionNode()
        setupGalleryNode()
        addAnimatedLabelToTop()
        collectionNode.dataSource = self
        collectionNode.delegate = self
        galleryCollectionNode.delegate = self
        galleryCollectionNode.dataSource = self
       
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StitchViewController.labelTapped))
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
    
    
    @IBAction func hideBtnPressed(_ sender: Any) {
        
        selectPostCollectionView.isHidden = true
        
        if let index = currentIndex {
            
            if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {

                cell.showAllInfo()
                
            }
            
        }
        
        
        
    }
    
    
}


extension StitchViewController {
    
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
    
}


extension StitchViewController {

 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !posts.isEmpty, scrollView == collectionNode.view {
            // Check if it's a horizontal scroll
            if lastContentOffset != scrollView.contentOffset.x {
                lastContentOffset = scrollView.contentOffset.x
            } else {
                return
            }
            
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
                    let distanceFromCenter = abs(cellCenter.x - visibleRect.midX) // Use the x-coordinate for horizontal scroll
                    
                    // Only switch video if the distance from center is less than the min distance
                    // and also less than the threshold.
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = cell.indexPath!.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            
            if newPlayingIndex != nil {
                
                if newPlayingIndex! < posts.count {
                    
                    if !posts[newPlayingIndex!].muxPlaybackId.isEmpty {
                        foundVisibleVideo = true
                        //playTimeBar.isHidden = false
                        imageIndex = nil
                    } else {
                        //playTimeBar.isHidden = true
                        imageIndex = newPlayingIndex
                    }
                    
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
                    } else {
                        // Do nothing if the current index is the same as newPlayingIndex
                    }
                }
                
                // If the video is stuck, reset the buffer by seeking to the current playback time.
                if let currentIndex = currentIndex, let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? VideoNode {
                    if let playerItem = cell.videoNode.currentItem, !playerItem.isPlaybackLikelyToKeepUp {
                        if let currentTime = cell.videoNode.currentItem?.currentTime() {
                            cell.videoNode.player?.seek(to: currentTime)
                        } else {
                            cell.videoNode.player?.seek(to: CMTime.zero)
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
    
    func handleAnimationTextAndImage(for index: Int) {
        
        let nextIndex = index + 1
        let postCount = self.posts.count
        
        if nextIndex < postCount {
            let item = self.posts[nextIndex]
            if let nextUsername = item.owner?.username {
                
                if item.stitchedTo {
                    self.applyAnimationText(text: "Up next: @\(nextUsername)'s original!")
                } else {
                    self.applyAnimationText(text: "Up next: @\(nextUsername)'s stitch!")
                }
               
            }
        } else {
            self.applyAnimationText(text: "")
        }
        
        
    }
    
}

extension StitchViewController: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        if collectionNode == galleryCollectionNode {
                    
            let height =  UIScreen.main.bounds.height * 1 / 4 - 70
            let width = height * 9 / 13.5
                    
            let min = CGSize(width: width, height: height)
            let max = CGSize(width: width, height: height)
                
            return ASSizeRangeMake(min, max)
                    
        } else {
            
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
        
        
        

    }

    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        if collectionNode == galleryCollectionNode {
            return false
        }
        
        return true
        

    }
    
}

extension StitchViewController: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        
        if self.collectionNode == collectionNode {
            
            if self.posts.isEmpty {
                
                self.collectionNode.view.setEmptyMessage("No stitch found!", color: .white)
                playTimeBar.isHidden = true
                
            } else {
                
                self.collectionNode.view.restore()
                playTimeBar.isHidden = false
                
            }
            
        }
        
    
        return self.posts.count
        
    }
    
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        
        if collectionNode == galleryCollectionNode {
                   
            return {
                let node = StitchControlNode(with: post)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                node.automaticallyManagesSubnodes = true
                       //
                return node
            }
                   
        } else {
            
            return {
              
                let node = VideoNode(with: post, at: indexPath.row)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                node.automaticallyManagesSubnodes = true
                 
                return node
            }
            
        }
        
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if rootId != "" {
         
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


extension StitchViewController {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
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
        self.collectionNode.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
       
        self.applyStyle()
     
    }
    
    func setupGalleryNode() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12
        galleryCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        galleryView.addSubview(galleryCollectionNode.view)
        galleryCollectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionNode.view.topAnchor.constraint(equalTo: galleryView.topAnchor, constant: 0).isActive = true
        galleryCollectionNode.view.leadingAnchor.constraint(equalTo: galleryView.leadingAnchor, constant: 0).isActive = true
        galleryCollectionNode.view.trailingAnchor.constraint(equalTo: galleryView.trailingAnchor, constant: 0).isActive = true
        galleryCollectionNode.view.bottomAnchor.constraint(equalTo: galleryView.bottomAnchor, constant: 0).isActive = true
        galleryCollectionNode.backgroundColor = .red
        
        galleryCollectionNode.view.isPagingEnabled = false
        galleryCollectionNode.view.backgroundColor = UIColor.clear
        galleryCollectionNode.view.showsVerticalScrollIndicator = false
        galleryCollectionNode.view.allowsSelection = true
        galleryCollectionNode.allowsMultipleSelection = false
        galleryCollectionNode.view.contentInsetAdjustmentBehavior = .never
        galleryCollectionNode.needsDisplayOnBoundsChange = true
       
        galleryCollectionNode.allowsMultipleSelection = false
        
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        
        
    }
    
    
}

extension StitchViewController {
    
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        guard rootId != "" else {
            completeWithEmptyData(block)
            return
        }

        APIManager.shared.getSuggestStitch(rootId: rootId, page: curPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) posts.")
                    curPage += 1
                    DispatchQueue.main.async {
                        block(data)
                    }
                } else {
                    self.completeWithEmptyData(block)
                }
            case .failure(let error):
                print(error)
                self.completeWithEmptyData(block)
            }
        }
    }

    private func completeWithEmptyData(_ block: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            block([])
        }
    }

    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard newPosts.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        var items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !self.posts.contains($0) }
        self.posts.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            collectionNode.insertItems(at: indexPaths)
            galleryCollectionNode.insertItems(at: indexPaths)
        }
    }

    private func clearExistingPosts() {
        let deleteIndexPaths = posts.enumerated().map { IndexPath(row: $0.offset, section: 0) }
        posts.removeAll()
        collectionNode.deleteItems(at: deleteIndexPaths)
        galleryCollectionNode.deleteItems(at: deleteIndexPaths)
    }

    private func generateIndexPaths(for items: [PostModel]) -> [IndexPath] {
        let startIndex = self.posts.count - items.count
        return (startIndex..<self.posts.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }

            if newPosts.isEmpty {
                self.refresh_request = false
                self.posts.removeAll()
                self.collectionNode.reloadData()
                self.galleryCollectionNode.reloadData()
                if self.posts.isEmpty {
                    self.collectionNode.view.setEmptyMessage("No stitch found!", color: .white)
                } else {
                    self.collectionNode.view.restore()
                }
            } else {
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
            }
        }
    }

    @objc func clearAllData() {
        guard rootId != "" else { return }

        animatedLabel?.text = ""
        refresh_request = true
        currentIndex = 0
        curPage = 1
        isfirstLoad = true
        didScroll = false
        imageIndex = nil
        updateData()
    }


    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        if collectionNode == galleryCollectionNode {
            
            if let currentIndex = currentIndex, abs(currentIndex - indexPath.row) > 1 {
                var prev = IndexPath(item: currentIndex, section: 0)
                
                // If the user is moving forward
                if indexPath.row > currentIndex {
                    prev = IndexPath(item: indexPath.row - 1, section: 0)
                }
                
                // If the user is moving backward
                if indexPath.row < currentIndex {
                    prev = IndexPath(item: indexPath.row + 1, section: 0)
                }
                
                self.collectionNode.scrollToItem(at: prev, at: .centeredVertically, animated: false)
                self.collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                print("scroll: scroll1")
            } else {
                self.collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                print("scroll: scroll2")
            }
            
            
        }
        
        
    }


}

extension StitchViewController {
    
    func pauseVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
            cell.videoNode.pause()
            
            let time = CMTime(seconds: 0, preferredTimescale: 1)
            cell.videoNode.player?.seek(to: time)
           // playTimeBar.setValue(Float(0), animated: false)
            
        }
        
    }

    
    
    func seekVideo(index: Int, time: CMTime) {
        
        print("StitchViewController: \(index) - seek")
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
          
            cell.videoNode.player?.seek(to: time)
            
            
        }
        
    }
    
    func updateCellAppearance(_ cell: StitchControlNode, isSelected: Bool) {
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = isSelected ? 2 : 0
            cell.layer.borderColor = isSelected ? UIColor.secondary.cgColor : UIColor.clear.cgColor
            cell.isSelected = isSelected
        }
    
    
    func playVideo(index: Int) {
        
        print("StitchViewController: \(index) - play")
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
            handleAnimationTextAndImage(for: index)
            
            if selectPostCollectionView.isHidden == false {
                
                cell.hideAllInfo()
                
            } else {
                
                if globalSetting.ClearMode == true {
                    
                    cell.hideAllInfo()
                    
                } else {
                    
                    cell.showAllInfo()
                    
                }
              
            }
            
            // Cell selection/deselection logic
            let indexPath = IndexPath(row: index, section: 0)
            if let imgCell = galleryCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode {
                updateCellAppearance(imgCell, isSelected: true)
                galleryCollectionNode.selectItem(at: indexPath, animated: false, scrollPosition: [])
                galleryCollectionNode.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

                // Deselect all other cells
                for i in 0..<galleryCollectionNode.numberOfItems(inSection: 0) {
                    if i != index, let otherCell = galleryCollectionNode.nodeForItem(at: IndexPath(row: i, section: 0)) as? StitchControlNode {
                        updateCellAppearance(otherCell, isSelected: false)
                    }
                }
            } else {
                print("Couldn't cast ?")
            }
            
            if !cell.videoNode.isPlaying() {
                
                cell.updateStitchCount(text: "\(index + 1)/\(posts.count)")

                
                if let muteStatus = shouldMute {
                    
                    
                    if muteStatus {
                        cell.videoNode.muted = true
                    } else {
                        cell.videoNode.muted = false
                    }
                    
                    cell.videoNode.play()
                    
                } else {
                    
                    if globalIsSound {
                        cell.videoNode.muted = false
                    } else {
                        cell.videoNode.muted = true
                    }
                    
                    cell.videoNode.play()
                    
                }
                
                
            }
            
        }
        
    }
    
    
    @objc func labelTapped() {
        if currentIndex != nil, currentIndex! + 1 < posts.count {
                
            let indexPath = IndexPath(item: currentIndex! + 1, section: 0)
            collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                
        }
    }
    
}


