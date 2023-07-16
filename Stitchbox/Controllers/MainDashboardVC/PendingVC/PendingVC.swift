//
//  PendingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/15/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class PendingVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!

    var searchController: UISearchController?
    var myPost = [PostModel]()
    var waitPost = [PostModel]()
    var lastContentOffset: CGFloat = 0
    var myCollectionNode: ASCollectionNode!
    var waitCollectionNode: ASCollectionNode!
    var imageIndex: Int?
    var myPage = 1
    var waitPage = 1
    var allowLoadingWaitList = false
    var prevIndexPath: IndexPath?
    var firstLoad = true
    var currentIndex: Int?
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var firstWaitReload = true
    var rootPost: PostModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupBackButton()
        setupNavBar()
        //setupSearchController()
        setupSearchBtn()
        setupCollectionNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        navigationController?.setNavigationBarHidden(false, animated: true)
  
        
        delay(1.25) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
        
        setupNavBar()
        
    }
    
    func setupSearchBtn() {
        

        let searchButton: UIButton = UIButton(type: .custom)
        
      
        searchButton.setImage(UIImage(named: "search"), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
       

        self.navigationItem.rightBarButtonItem = searchBarButton
        
        
    }
    
    func setupNavBar() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
}

extension PendingVC {
    
    func setupButtons() {
        
        setupBackButton()
      
        
    }
    
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back-black") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "Pending stitches"
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .black
        self.searchController?.searchBar.searchTextField.textColor = .black
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for stitched post", attributes: [.foregroundColor: UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = .darkGray
        self.searchController?.searchBar.isUserInteractionEnabled = true
        self.navigationItem.searchController = nil
        self.searchController?.searchBar.isHidden = true
        self.searchController?.searchBar.text = ""
    }
    
}


extension PendingVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func searchBarSetting(_ sender: AnyObject) {
        if searchController?.searchBar.isHidden == true {
            //buttonStackView.isHidden = true
            navigationItem.searchController = searchController
            searchController?.searchBar.isHidden = false
            
            delay(0.025) {
                self.searchController?.searchBar.becomeFirstResponder()
            }
            
        } else {
            //buttonStackView.isHidden = false
            navigationItem.searchController = nil
            searchController?.searchBar.isHidden = true
        }
    }
    
}

extension PendingVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        if collectionNode == myCollectionNode {
            let height = self.contentView.layer.frame.height
            let width = height * 9 / 13.5
            
            let min = CGSize(width: width, height: height)
            let max = CGSize(width: width, height: height)
            
            return ASSizeRangeMake(min, max)
            
        } else {
            
            let height = self.pendingView.layer.frame.height
            let width = self.pendingView.layer.frame.width
            
            let min = CGSize(width: width, height: height)
            let max = CGSize(width: width, height: height)
            
            return ASSizeRangeMake(min, max)
            
        }
        
        
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        if collectionNode == myCollectionNode {
            return true
        } else {
            if allowLoadingWaitList {
                return true
            }
            return false
        }
        
    }
    
}


extension PendingVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        if collectionNode == myCollectionNode {
            
            if self.myPost.isEmpty {
                myCollectionNode.view.setEmptyMessage("No post found")
            } else {
                myCollectionNode.view.restore()
            }
            return self.myPost.count
        } else {
            if self.myPost.isEmpty {
                waitCollectionNode.view.setEmptyMessage("No stitch found")
            } else {
                waitCollectionNode.view.restore()
            }
            return self.waitPost.count
        }
    
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        if collectionNode == myCollectionNode {
            
            let post = self.myPost[indexPath.row]
            
            return {
                let node = OwnerPostSearchNode(with: post, isSave: false)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                //
                return node
            }
            
        } else {
            
            let post = self.waitPost[indexPath.row]
            
            return {
                let node = PendingNode(with: post)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                node.approveBtn = { [weak self] node in
                    self?.approvePost(node: node as! PendingNode, post: post)
                }

                node.declineBtn = { [weak self] node in
                    self?.declinePost(node: node as! PendingNode, post: post)
                }
                
                //
                return node
            }
            
        }
        
        
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        
        if collectionNode == myCollectionNode {
            
            retrieveNextPageForMyPostWithCompletion { [weak self] (newPosts) in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNodeForMyPost(newPosts: newPosts)

                context.completeBatchFetching(true)
            }
            
        } else if collectionNode == waitCollectionNode {
            
            retrieveNextPageForWaitListWithCompletion { [weak self] (newPosts) in
                guard let self = self else { return }
                self.insertNewRowsInCollectionNodeForWaitList(newPosts: newPosts)

                context.completeBatchFetching(true)
            }
            
        } else {
            
            context.completeBatchFetching(true)
            
        }
        
        
        
    }

    
}



extension PendingVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        
        let flowLayout2 = UICollectionViewFlowLayout()
        flowLayout2.scrollDirection = .horizontal
        flowLayout2.minimumLineSpacing = 10
        flowLayout2.minimumInteritemSpacing = 10
        
        
        self.myCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout2)
        self.myCollectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.myCollectionNode.leadingScreensForBatching = 2.0
        self.myCollectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.myCollectionNode.dataSource = self
        self.myCollectionNode.delegate = self
        
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(myCollectionNode.view)
        self.myCollectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.myCollectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.myCollectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.myCollectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.myCollectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        self.waitCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.waitCollectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.waitCollectionNode.leadingScreensForBatching = 2.0
        self.waitCollectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.waitCollectionNode.dataSource = self
        self.waitCollectionNode.delegate = self
        
        // Add the collection node's view as a subview and set constraints
        self.pendingView.addSubview(waitCollectionNode.view)
        self.waitCollectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.waitCollectionNode.view.topAnchor.constraint(equalTo: self.pendingView.topAnchor, constant: 0).isActive = true
        self.waitCollectionNode.view.leadingAnchor.constraint(equalTo: self.pendingView.leadingAnchor, constant: 0).isActive = true
        self.waitCollectionNode.view.trailingAnchor.constraint(equalTo: self.pendingView.trailingAnchor, constant: 0).isActive = true
        self.waitCollectionNode.view.bottomAnchor.constraint(equalTo: self.pendingView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        
        // Reload the data on the collection node
        self.myCollectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        
        self.myCollectionNode.view.isPagingEnabled = false
        self.myCollectionNode.view.backgroundColor = UIColor.clear
        self.myCollectionNode.view.showsVerticalScrollIndicator = false
        self.myCollectionNode.view.allowsSelection = true
        self.myCollectionNode.view.contentInsetAdjustmentBehavior = .never
      
        
        
        self.waitCollectionNode.view.isPagingEnabled = true
        self.waitCollectionNode.view.backgroundColor = UIColor.clear
        self.waitCollectionNode.view.showsVerticalScrollIndicator = false
        self.waitCollectionNode.view.allowsSelection = true
        self.waitCollectionNode.view.contentInsetAdjustmentBehavior = .never
       
        
    }

    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        if collectionNode == myCollectionNode {
            
            rootPost = myPost[indexPath.row]
            
            if prevIndexPath == nil || prevIndexPath != indexPath {
                prevIndexPath = indexPath
                allowLoadingWaitList = true
                
                myCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                
                
                if let cell = myCollectionNode.nodeForItem(at: indexPath) as? OwnerPostSearchNode {
                    cell.layer.cornerRadius = 10
                    cell.layer.borderWidth = 2
                    cell.layer.borderColor = UIColor.secondary.cgColor
                }
                
                if !waitPost.isEmpty {
                    waitPost.removeAll()
                    waitPage = 1
                    firstWaitReload = true
                    waitCollectionNode.performBatchUpdates({
                        waitCollectionNode.reloadData()
                    }, completion: nil)
                } else {
                    waitCollectionNode.reloadData()
                }
                
            }
            
            
        }
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        if collectionNode == myCollectionNode {
            
            if let cell = myCollectionNode.nodeForItem(at: indexPath) as? OwnerPostSearchNode {
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            
            
        }
    }
}


extension PendingVC {
    
    
    func retrieveNextPageForMyPostWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
      
        APIManager.shared.getMyWaitlist(page: myPage) { [weak self] result in
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
                    self.myPage += 1
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
        
        
    }
    
    
    
    
    func retrieveNextPageForWaitListWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getSavedPost(page: waitPage) { [weak self] result in
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
                    self.waitPage += 1
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
        
      
    }
    
    
    func insertNewRowsInCollectionNodeForMyPost(newPosts: [[String: Any]]) {

        // checking empty
        guard newPosts.count > 0 else {
            return
        }

        // Create new PostModel objects and append them to the current posts
        var items = [PostModel]()
        for i in newPosts {
            if let item = PostModel(JSON: i) {
                if !self.myPost.contains(item) {
                    self.myPost.append(item)
                    items.append(item)
                }
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.myPost.count - items.count
            let endIndex = startIndex + items.count - 1
            print(startIndex, endIndex)
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
            self.myCollectionNode.insertItems(at: indexPaths)
        }
        
        if firstLoad {
            firstLoad = false

            if  !myPost.isEmpty {
                
                if let cell = myCollectionNode.nodeForItem(at: IndexPath(item: 0, section: 0)) as? OwnerPostSearchNode {
                    
                    cell.layer.cornerRadius = 10
                    cell.layer.borderWidth = 2
                    cell.layer.borderColor = UIColor.secondary.cgColor
                    cell.isSelected = true
                    
                    
                    myCollectionNode.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
                    self.myCollectionNode.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)

                } else {
                    print("Couldn't cast ?")
                }
                
                rootPost = myPost[0]
                
                allowLoadingWaitList = true
                waitCollectionNode.reloadData()
            }
        }
    }

    
    func insertNewRowsInCollectionNodeForWaitList(newPosts: [[String: Any]]) {

        // checking empty
        guard newPosts.count > 0 else {
            return
        }

        // Create new PostModel objects and append them to the current posts
        var items = [PostModel]()
        for i in newPosts {
            if let item = PostModel(JSON: i) {
                if !self.waitPost.contains(item) {
                    self.waitPost.append(item)
                    items.append(item)
                }
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.waitPost.count - items.count
            let endIndex = startIndex + items.count - 1
            print(startIndex, endIndex)
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
            self.waitCollectionNode.insertItems(at: indexPaths)
        }
        
        
        if firstWaitReload {
            firstWaitReload = false
            if !waitPost.isEmpty {
                currentIndex = 0
                playVideo(index: 0)
            }
        }
        
        
    }
    
}

extension PendingVC {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !waitPost.isEmpty, scrollView == waitCollectionNode.view {
            // Check if it's a horizontal scroll
            if lastContentOffset != scrollView.contentOffset.x {
                lastContentOffset = scrollView.contentOffset.x
            } else {
                return
            }
            
            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            
            // Calculate the visible cells.
            let visibleCells = waitCollectionNode.visibleNodes.compactMap { $0 as? PendingNode }
            
            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            
            var foundVisibleVideo = false
            
            for cell in visibleCells {
                    let cellRect = cell.view.convert(cell.bounds, to: waitCollectionNode.view)
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distanceFromCenter = abs(cellCenter.x - visibleRect.midX) // Use the x-coordinate for horizontal scroll
                    
                    // Only switch video if the distance from center is less than the min distance
                    // and also less than the threshold.
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = cell.indexPath!.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            
            if newPlayingIndex! < waitPost.count {
                
                if !waitPost[newPlayingIndex!].muxPlaybackId.isEmpty {
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
                    
                    
                } else {
                    // Do nothing if the current index is the same as newPlayingIndex
                }
            } else {

            }
            
            // If the video is stuck, reset the buffer by seeking to the current playback time.
            if let currentIndex = currentIndex, let cell = waitCollectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PendingNode {
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
    
    func pauseVideo(index: Int) {
        
        if let cell = self.waitCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? PendingNode {
            
            // Seek to the beginning of the video
            cell.videoNode.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
             
            // Pause the video
            cell.videoNode.pause()
            
        }
        
    }

    
    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.waitCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? PendingNode {
            
            cell.videoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func playVideo(index: Int) {
        
        if let cell = self.waitCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? PendingNode {
            
            cell.videoNode.muted = shouldMute ?? !globalIsSound
            cell.videoNode.play()
            
        }
        
    
    }
    
    
    func approvePost(node: PendingNode, post: PostModel) {
        
        print("approvePost")
        
        if rootPost != nil {
            
            presentSwiftLoader()
            
            APIManager.shared.acceptStitch(rootId: rootPost.id, memberId: post.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    Dispatch.main.async { [weak self]  in
                        guard let self = self else { return }
                        SwiftLoader.hide()
                        if let indexPath = waitPost.firstIndex(of: post) {
                            
                            waitPost.removeObject(post)
                            
                            waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            // return the next index if it exists
                            if indexPath < waitPost.count {
                                playVideo(index: indexPath)
                            }
                            
                        }
                    }
                   
                case .failure(let error):
                    Dispatch.main.async { [weak self]  in
                        guard let self = self else { return }
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Couldn't approve stitch at this time, please try again. \(error.localizedDescription)")
                        
                    }
                    
                }
            }
            
            if let indexPath = waitPost.firstIndex(of: post) {
                
                waitPost.removeObject(post)
                
                waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                
                // return the next index if it exists
                if indexPath < waitPost.count {
                    playVideo(index: indexPath)
                }

            }
            
        } else {
            
            showErrorAlert("Oops!", msg: "Couldn't approve stitch at this time, please try again")
            
        }

    }
    
    
    func declinePost(node: PendingNode, post: PostModel) {
        
        print("declinePost")
        
        if rootPost != nil {
            
            presentSwiftLoader()
            
            APIManager.shared.deniedStitch(rootId: rootPost.id, memberId: post.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    Dispatch.main.async { [weak self]  in
                        guard let self = self else { return }
                        SwiftLoader.hide()
                        if let indexPath = waitPost.firstIndex(of: post) {
                            
                            waitPost.removeObject(post)
                            
                            waitCollectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                            
                            // return the next index if it exists
                            if indexPath < waitPost.count {
                                playVideo(index: indexPath)
                            }
                            
                        }
                    }
                   
                case .failure(let error):
                    Dispatch.main.async { [weak self]  in
                        guard let self = self else { return }
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again. \(error.localizedDescription)")
                        
                    }
                    
                }
            }
            
        } else {
            
            showErrorAlert("Oops!", msg: "Couldn't remove stitch at this time, please try again")
            
        }
        
       
        


    }
}
