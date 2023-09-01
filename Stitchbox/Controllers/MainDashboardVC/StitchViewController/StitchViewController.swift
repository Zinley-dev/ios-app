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
    @IBOutlet weak var contentView: UIView!
    var lastContentOffsetY: CGFloat = 0

    var currentIndex: Int?
    var newPlayingIndex: Int?
    var hasViewAppeared = false
    var isVideoPlaying = false
    var curPage = 1
  
    let homeButton: UIButton = UIButton(type: .custom)
   
    
    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    
    var editeddPost: PostModel?
    var refresh_request = false
    var startIndex: Int!
    var selectedStitch = false
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

        setupCollectionNode()
        addAnimatedLabelToTop()
        collectionNode.dataSource = self
        collectionNode.delegate = self
        
       
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
        if text == "Back to original!" {
            animatedLabel.text = text + "                                 "
            animatedLabel.restartLabel()
        } else if text != ""  {
            animatedLabel.text = text + "                   "
            animatedLabel.restartLabel()
        } else {
            animatedLabel.text = text
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
        } else if nextIndex == self.posts.count {
            self.applyAnimationText(text: "Back to original!")
        }
        
        
    }
    
}

extension StitchViewController: ASCollectionDelegate {
    
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

extension StitchViewController: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        
        if self.posts.isEmpty {
            
            self.collectionNode.view.setEmptyMessage("No stitch found!", color: .white)
            
            
            return 0
            
        } else {
            
            self.collectionNode.view.restore()
           
            
            return self.posts.count
        }
    
        
    }
    
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        
        return { [weak self] in
            guard let self = self else {
                return ASCellNode()
            }
            
            let node = VideoNode(with: post, at: indexPath.row, isPreview: false, vcType: "stitch", selectedStitch: selectedStitch)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.automaticallyManagesSubnodes = true
            
            return node
        }
         
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if rootId != "", !refresh_request, posts.count <= 50 {
         
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
        }

        let items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !self.posts.contains($0) }
        self.posts.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            collectionNode.insertItems(at: indexPaths)
            //galleryCollectionNode.insertItems(at: indexPaths)
        }
        
        if refresh_request {
            refresh_request = false
        }
    }

    private func clearExistingPosts() {
        posts.removeAll()
        self.collectionNode.reloadData()
        
    }

    private func generateIndexPaths(for items: [PostModel]) -> [IndexPath] {
        let startIndex = self.posts.count - items.count
        return (startIndex..<self.posts.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newPosts) in
        
            if newPosts.isEmpty {
                self?.refresh_request = false
                self?.posts.removeAll()
                
                self?.collectionNode.reloadData()
                //self?.galleryCollectionNode.reloadData()
            
                if self?.posts.isEmpty == true {
                    self?.collectionNode.view.setEmptyMessage("No stitch found!", color: .white)
                } else {
                    self?.collectionNode.view.restore()
                }
            } else {
                self?.insertNewRowsInCollectionNode(newPosts: newPosts)
            }
        }
    }

    @objc func clearAllData() {
        guard rootId != "" else { return }

        animatedLabel?.text = ""
        refresh_request = true
        currentIndex = 0
        curPage = 1
       
        updateData()
    }


}

extension StitchViewController {
    
    func pauseVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
            cell.pauseVideo()
            
        }
        
    }

    
    func updateCellAppearance(_ cell: StitchGalleryNode, isSelected: Bool) {
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = isSelected ? 2 : 0
            cell.layer.borderColor = isSelected ? UIColor.secondary.cgColor : UIColor.clear.cgColor
            cell.isSelected = isSelected
        }
    
    
    func playVideo(index: Int) {
        
        print("StitchViewController: \(index) - play")
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
            
            cell.isActive = true
            handleAnimationTextAndImage(for: index)
            
            if globalSetting.ClearMode == true {
                
                cell.hideAllInfo()
                
            } else {
                
                cell.showAllInfo()
                
            }
            cell.updateStitchCount(text: "\(index + 1)/\(posts.count)")
            cell.playVideo()
            
        }
        
    }
    
    
    @objc func labelTapped() {
        if currentIndex != nil, currentIndex! + 1 < posts.count {
                
            let indexPath = IndexPath(item: currentIndex! + 1, section: 0)
            collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                
        } else if currentIndex! + 1 == posts.count {
            
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
                    } else if let update1 = vc as? SelectedParentVC {
                        if !update1.isRoot {
                            // Calculate the next page index
                           
                            let offset = CGFloat(0) * update1.scrollView.bounds.width
                            
                            // Scroll to the next page
                            update1.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                            update1.showRoot()
                          
                        }
                    }
                }
            }
            
        }
    }
    
}


