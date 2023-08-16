//
//  SelectedRootPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/2/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage
import MarqueeLabel

class SelectedRootPostVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    deinit {
        print("SelectedRootPostVC is being deallocated.")
    }
    
    enum loadingMode {
        case myPost
        case userPost
        case hashTags
        case search
        case save
        case trending
        case none
    }
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
 
    var posts = [PostModel]()
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var startIndex: Int!
    var currentIndex: Int?

    let backButton: UIButton = UIButton(type: .custom)
    var keyword = ""
    var userId = ""
    var hashtag = ""
    var keepLoading = false
    var firstAnimated = true
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var animatedLabel: MarqueeLabel!
    var selectedLoadingMode = loadingMode.none
    var page = 0
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("SelectedRootPostVC did load")
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAnimated {
            firstAnimated = false
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if let path = Bundle.main.path(forResource: "fox2", ofType: "gif") {
                        let gifData = try Data(contentsOf: URL(fileURLWithPath: path))
                        let image = FLAnimatedImage(animatedGIFData: gifData)

                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }

                            self.loadingImage.animatedImage = image
                            self.loadingView.backgroundColor = .white
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }


            
            loadingView.backgroundColor = .white
            navigationController?.setNavigationBarHidden(false, animated: true)
      
            
            
        }
        
        
    }
    
    func hideLoading() {
        
        delay(1) { [weak self] in
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                
                self?.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                
                if self?.loadingView.alpha == 0 {
                    
                    self?.loadingView.isHidden = true
                    self?.loadingImage.stopAnimating()
                    self?.loadingImage.animatedImage = nil
                    self?.loadingImage.image = nil
                    self?.loadingImage.removeFromSuperview()
                }
                
            }
            
        }
        
    }
    
    
}


extension SelectedRootPostVC {
    
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


extension SelectedRootPostVC {
    
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
               

               
               // If there's no current playing video and no visible video, pause the last playing video, if any.
               if !isVideoPlaying && currentIndex != nil {
                   pauseVideo(index: currentIndex!)
                   currentIndex = nil
               }
               
           }
           
           
       }

}

extension SelectedRootPostVC {
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return keepLoading
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
            context.completeBatchFetching(true)
        }
    }
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {

        let handleResponse: (Result) -> Void = { [weak self] result in
            var items: [[String: Any]] = []
            if case .success(let apiResponse) = result,
               let data = apiResponse.body?["data"] as? [[String: Any]],
               !data.isEmpty {
                items = data
                self?.page += 1
                print("Successfully retrieved \(data.count) posts for SelectedRootPostVC")
            }

            DispatchQueue.main.async {
                block(items)
            }
        }

        switch selectedLoadingMode {
        case .hashTags:
            APIManager.shared.getHashtagPost(tag: hashtag, page: page, completion: handleResponse)
        case .myPost:
            APIManager.shared.getMyPost(page: page, completion: handleResponse)
        case .userPost:
            APIManager.shared.getUserPost(userId: self.userId, page: page, completion: handleResponse)
        case .search:
            APIManager.shared.searchPost(query: keyword, page: page, completion: handleResponse)
        case .save:
            APIManager.shared.getSavedPost(page: page, completion: handleResponse)
        case .trending:
            APIManager.shared.getPostTrending(page: page, completion: handleResponse)
        case .none:
            DispatchQueue.main.async {
                block([])
            }
        }
    }



    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }

        let uniquePosts = Set(self.posts)
        let items = newPosts.compactMap { PostModel(JSON: $0) }.filter { !uniquePosts.contains($0) }
        
        guard !items.isEmpty else { return }

        self.posts.append(contentsOf: items)

        let indexPaths = (posts.count - items.count..<posts.count).map { IndexPath(row: $0, section: 0) }
        
        collectionNode.insertItems(at: indexPaths)
        
    }
    
}

extension SelectedRootPostVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.contentView.layer.frame.width, height: 50);
        let max = CGSize(width: self.contentView.layer.frame.width, height: contentView.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    
}

extension SelectedRootPostVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return { [weak self] in
            guard let self = self else {
                return ASCellNode()
            }
            
            let node = VideoNode(with: post, at: indexPath.row, isPreview: false, vcType: "selectedRoot", selectedStitch: false)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
           
            node.isOriginal = true
            node.automaticallyManagesSubnodes = true
            
            return node
            
        }
    }

    
}

extension SelectedRootPostVC {
    
    func loadPosts() {
        // Ensure that there are posts to load
        // Ensure that there are new posts to load
        guard !posts.isEmpty else {
            return
        }
        
        // Create index paths for the new posts
        let indexPaths = (0..<posts.count).map { IndexPath(row: $0, section: 0) }
        
        // Insert items into the collection node at the beginning
        self.collectionNode.performBatchUpdates({
            self.collectionNode.insertItems(at: indexPaths)
        }, completion: nil)
        
        guard let startIndex = self.startIndex else {
            return
        }
        
        // If there's a need to scroll to a particular index after insertion (0 in this case)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(row: startIndex, section: 0)
            
            if startIndex != 0 {
                self.collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
                guard let self = self else { return }
                          
                if let node = self.collectionNode.nodeForItem(at: indexPath) as? VideoNode {
                    
                    mainRootId = node.post.id
                    currentIndex = startIndex
                    newPlayingIndex = startIndex
                    isVideoPlaying = true
                    node.cellVideoNode.muted = shouldMute ?? !globalIsSound
                    node.cellVideoNode.play()
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "observeRootChangeForSelected")), object: nil)
                    handleAnimationTextAndImage(post: node.post)
                    
                }
                

            }
            
        }

    }

    
}

extension SelectedRootPostVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        self.collectionNode.backgroundColor = .black
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        //self.collectionNode.view.isScrollEnabled = false
        
        self.applyStyle()
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
}


extension SelectedRootPostVC {
    
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
                
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "observeRootChangeForSelected")), object: nil)
                
            }
            
        }
        
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectedRootPostVC.labelTapped))
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
    
    @objc func labelTapped() {
        
        if let vc = UIViewController.currentViewController() {
            if vc is SelectedParentVC {
                if let update1 = vc as? SelectedParentVC {
                    if update1.isRoot {
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
