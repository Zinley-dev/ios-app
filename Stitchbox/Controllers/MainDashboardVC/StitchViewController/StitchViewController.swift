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
    
    
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.copyPost), name: (NSNotification.Name(rawValue: "copy_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.reportPost), name: (NSNotification.Name(rawValue: "report_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.removePost), name: (NSNotification.Name(rawValue: "remove_post")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.sharePost), name: (NSNotification.Name(rawValue: "share_post")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.createPostForStitch), name: (NSNotification.Name(rawValue: "create_new_for_stitch")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.stitchToExistingPost), name: (NSNotification.Name(rawValue: "stitch_to_exist_one")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.onClickDelete), name: (NSNotification.Name(rawValue: "delete")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.onClickEdit), name: (NSNotification.Name(rawValue: "edit")), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.onClickDownload), name: (NSNotification.Name(rawValue: "download")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StitchViewController.onClickStats), name: (NSNotification.Name(rawValue: "stats")), object: nil)
        
        
        let height =  UIScreen.main.bounds.height * 1 / 4
        heightConstraint.constant = height
        
        setupCollectionNode()
        setupGalleryNode()
        
        collectionNode.dataSource = self
        collectionNode.delegate = self
        galleryCollectionNode.delegate = self
        galleryCollectionNode.dataSource = self
       
    }

    
    @objc func clearAllData() {
        
        
        if rootId != "" {
            
            refresh_request = true
            currentIndex = 0
            curPage = 1
            isfirstLoad = true
            didScroll = false
            imageIndex = nil
            updateData()
            
        }
        
        
        
    }
    
    func updateData() {
        
        self.retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            
            if newPosts.count > 0 {
                
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
                
                
            } else {
                
                
                self.refresh_request = false
                
                if !posts.isEmpty {
                    
                    self.posts.removeAll()
                    self.collectionNode.reloadData()
                    self.galleryCollectionNode.reloadData()
                    
                }
                
                if self.posts.isEmpty == true {
                    
                    self.collectionNode.view.setEmptyMessage("No stitch found!", color: .white)
                    
                    
                } else {
                    
                    self.collectionNode.view.restore()
                    
                }
                
            }
            
           
        }
        
        
    }
    
    
    @IBAction func hideBtnPressed(_ sender: Any) {
        
        
        selectPostCollectionView.isHidden = true
        
        
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
                node.collectionNode = self.collectionNode
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
        
        if rootId != "" {
            
            APIManager.shared.getUserFeed { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                        return
                    }
                    if !data.isEmpty {
                        self.lastLoadTime = Date()
                        print("Successfully retrieved \(data.count) posts.")
                        let items = data
                    
                        DispatchQueue.main.async {
                            block(items)
                        }
                    } else {
                        
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                    }
                case .failure(let error):
                    print(error)
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                }
            }
            
            /*
            APIManager.shared.getSuggestStitch(rootId: rootId, page: curPage) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let apiResponse):

                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                        return
                    }
                    if !data.isEmpty {
                        print("Successfully retrieved \(data.count) posts.")
                        let items = data
                        curPage += 1
                        DispatchQueue.main.async {
                            block(items)
                        }
                    } else {
                        
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                    }
                case .failure(let error):
                    print(error)
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                }
            }*/
            
        } else {
            
            let item = [[String: Any]]()
            DispatchQueue.main.async {
                block(item)
            }
            
        }
        
    }
    
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {

        // checking empty
        guard newPosts.count > 0 else {
            return
        }

        if refresh_request {

            refresh_request = false

            if !posts.isEmpty {
                var delete_indexPaths: [IndexPath] = []
                for row in 0..<self.posts.count {
                    let path = IndexPath(row: row, section: 0) // single indexpath
                    delete_indexPaths.append(path) // append
                }
                
                posts.removeAll()
                collectionNode.deleteItems(at: delete_indexPaths)
                galleryCollectionNode.deleteItems(at: delete_indexPaths)
            }
        }

        // Create new PostModel objects and append them to the current posts
        var items = [PostModel]()
        for i in newPosts {
           
            if let item = PostModel(JSON: i) {
               
                if !self.posts.contains(item) {
                    self.posts.append(item)
                    items.append(item)
                }
                
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.posts.count - items.count
            let endIndex = startIndex + items.count - 1
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
           collectionNode.insertItems(at: indexPaths)
           galleryCollectionNode.insertItems(at: indexPaths)
           items.removeAll()
        }
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
    
    @objc func onClickDelete(_ sender: AnyObject) {
        
        
        if let vc = UIViewController.currentViewController() {
            if vc is StitchViewController {
                
                presentSwiftLoader()
                
                if let id = editeddPost?.id, id != "" {
                    
                    
                    APIManager.shared.deleteMyPost(pid: id) { result in
                        switch result {
                        case .success(_):
                            needReloadPost = true
                            
                            SwiftLoader.hide()
                            
                            Dispatch.main.async {
                                
                                self.removePost()
                                
                            }
                            
                            
                          case .failure(let error):
                            print(error)
                            SwiftLoader.hide()
                            
                            delay(0.1) {
                                Dispatch.main.async {
                                    self.showErrorAlert("Oops!", msg: "Unable to delete this posts \(error.localizedDescription), please try again")
                                }

                            }
                            
                        }
                      }
                    
                } else {
                
                    delay(0.1) {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Unable to delete this posts, please try again")
                    }
                    
                }
                
            }
        }
  

    }
    
    @objc func removePost() {
        
        if let deletingPost = editeddPost {
           
            if let indexPath = posts.firstIndex(of: deletingPost) {
                
                posts.removeObject(deletingPost)

                // check if there are no more posts
                if posts.isEmpty {
                    collectionNode.reloadData()
                } else {
                    collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                   
                }
            } else {
                
                if currentIndex != nil {
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? VideoNode {
                        /*
                        if let indexPath = node.posts.firstIndex(of: deletingPost) {
                            
                            node.posts.removeObject(deletingPost)

                            node.mainCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            //node.galleryCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            //node.selectPostCollectionView.collectionView.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            
                            // return the next index if it exists
                            if indexPath < node.posts.count {
                                node.playVideo(index: indexPath)
                            } else if node.posts.count == 1 {
                                node.playVideo(index: 0)
                            }

                        }*/
                        
                    }
                    
                }
               
                
            }
            
        }
        
        
    }
    
    @objc func onClickEdit(_ sender: AnyObject) {
        
        if let vc = UIViewController.currentViewController() {
            if vc is StitchViewController {
                
                print("Edit requested")
                if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as? EditPostVC {
                    
                    navigationController?.setNavigationBarHidden(false, animated: true)
                    EPVC.selectedPost = editeddPost
                    self.navigationController?.pushViewController(EPVC, animated: true)
                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    @objc func onClickStats(_ sender: AnyObject) {
        
        
        if let vc = UIViewController.currentViewController() {
            if vc is StitchViewController {
                
                print("Stats requested")
                if let VVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ViewVC") as? ViewVC {
                    
                    
                    VVC.selected_item = editeddPost
                    delay(0.1) {
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.navigationController?.pushViewController(VVC, animated: true)
                    }
                    
                }
                
            }
            
        }
        
        
        
    }
    
    @objc func onClickDownload(_ sender: AnyObject) {
        
        if let vc = UIViewController.currentViewController() {
            if vc is StitchViewController {
                
                if let post = editeddPost {
                    
                    if post.muxPlaybackId != "" {
                        
                        let url = "https://stream.mux.com/\(post.muxPlaybackId)/high.mp4"
                       
                        downloadVideo(url: url, id: post.muxAssetId)
                        
                    } else {
                        
                        if let data = try? Data(contentsOf: post.imageUrl) {
                            
                            downloadImage(image: UIImage(data: data)!)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
        
       
    }
    
    func downloadVideo(url: String, id: String) {
        
        
        AF.request(url).downloadProgress(closure : { (progress) in
       
            self.swiftLoader(progress: "\(String(format:"%.2f", Float(progress.fractionCompleted) * 100))%")
            
        }).responseData{ (response) in
            
            switch response.result {
            
            case let .success(value):
                
                
                let data = value
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent("\(id).mp4")
                do {
                    try data.write(to: videoURL)
                } catch {
                    print("Something went wrong!")
                }
          
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { saved, error in
                    
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                    }
                    
                    if (error != nil) {
                        
                        
                        DispatchQueue.main.async {
                            print("Error: \(error!.localizedDescription)")
                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                        }
                        
                    } else {
                        
                        
                        DispatchQueue.main.async {
                        
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
     
                        
                    }
                }
                
            case let .failure(error):
                print(error)
                
        }
           
           
        }
        
    }
    
    func downloadImage(image: UIImage) {
        
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: image)
        
    }
    
    
    func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }

        @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Save finished!")
    }
    
    @objc func copyPost() {
        
        if let id = self.editeddPost?.id {
            
            let link = "https://stitchbox.net/app/post/?uid=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        } else {
            showNote(text: "Post link is unable to be copied")
        }
        
    }
    
    @objc func copyProfile() {
        
        if let id = self.editeddPost?.owner?.id {
            
            let link = "https://stitchbox.net/app/account/?uid=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "User profile link is copied")
            
        } else {
            showNote(text: "User profile link is unable to be copied")
        }
        
    }
    
 
    
    @objc func reportPost() {
        
        let slideVC =  reportView()
        
        slideVC.post_report = true
        slideVC.postId = editeddPost?.id ?? ""
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = Double(0.75)
        global_cornerRadius = 35
        
        delay(0.1) {[weak self] in
            guard let self = self else { return }
            self.present(slideVC, animated: true, completion: nil)
        }
        
    }
    
    @objc func sharePost() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        let loadUsername = userDataSource.userName
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(editeddPost?.id ?? "")")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            
        }
        
        delay(0.1) {[weak self] in
            guard let self = self else { return }
            self.present(ac, animated: true, completion: nil)
        }
        
    }
    
    @objc func createPostForStitch() {
        
        if let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC {
            
            
            PNVC.modalPresentationStyle = .fullScreen
            
            if let rootvc = PNVC.viewControllers[0] as? PostVC {
                rootvc.stitchPost = editeddPost
            } else {
                printContent(PNVC.viewControllers[0])
            }
            
            delay(0.1) {
                
                self.present(PNVC, animated: true)
            }
            
        }
        
    }
    
    
    @objc func stitchToExistingPost() {
        
        if let ASTEVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddStitchToExistingVC") as? AddStitchToExistingVC {
            
            ASTEVC.hidesBottomBarWhenPushed = true
            ASTEVC.stitchedPost = editeddPost
            hideMiddleBtn(vc: self)
            
            delay(0.1) {
                self.navigationController?.pushViewController(ASTEVC, animated: true)
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
            playTimeBar.setValue(Float(0), animated: false)
            
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
    
    
}


