//
//  SelectedPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/2/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire



class SelectedPostVC: UIViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var playTimeBar: UIProgressView!
    var selectedPost = [PostModel]()
    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
    var startIndex: Int!
    var currentIndex: Int!
    var endIndex: Int!
    var willIndex: Int!
    
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    
    var isfirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupCollectionNode()
        loadPosts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickDelete), name: (NSNotification.Name(rawValue: "delete")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickEdit), name: (NSNotification.Name(rawValue: "edit")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickShare), name: (NSNotification.Name(rawValue: "share")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickStats), name: (NSNotification.Name(rawValue: "stats")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickDownload), name: (NSNotification.Name(rawValue: "download")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedPostVC.onClickCopyLink), name: (NSNotification.Name(rawValue: "copyLink")), object: nil)
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentIndex != nil {
            
            if posts[currentIndex].muxPlaybackId != "" {
                playVideoIfNeed(playIndex: currentIndex)
            }
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if currentIndex != nil {
            
            if posts[currentIndex].muxPlaybackId != "" {
                pauseVideoIfNeed(pauseIndex: currentIndex)
            }
            
        }
        
    }
    
    
}


extension SelectedPostVC {
    
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


extension SelectedPostVC {
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        if !isfirstLoad {
            
            guard let cell = node as? PostNode else { return }
        
            willIndex = cell.indexPath?.row
            
        }

    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
            
        if !isfirstLoad {
            
            // 1. Safely unwrap the indexPath of the cell node.
            guard let postNode = node as? PostNode, let indexPath = postNode.indexPath else { return }
            
            let post = posts[indexPath.row]
            // 2. If the muxPlaybackId property is empty, return immediately.
            guard !post.muxPlaybackId.isEmpty else {
                // 3. If the next item is a video, play it.
                if let willIndex = willIndex, willIndex > indexPath.row {
                    let nextPost = posts[willIndex]
                    if !nextPost.muxPlaybackId.isEmpty {
                        currentIndex = willIndex
                        playVideoIfNeed(playIndex: currentIndex)
                    }
                // 4. If the previous item is a video, play it.
                } else if let willIndex = willIndex, willIndex < indexPath.row {
                    let previousPost = posts[willIndex]
                    if !previousPost.muxPlaybackId.isEmpty {
                        currentIndex = willIndex
                        playVideoIfNeed(playIndex: currentIndex)
                    }
                }
                return
            }
            
            // 5. Pause the video that was previously playing.
            pauseVideoIfNeed(pauseIndex: indexPath.row)
            
            var shouldPlayNextVideo = false
            var shouldPlayPreviousVideo = false
            
            // 6. Check if there is a willIndex value, and if it does not match the current index path.
            if let willIndex = willIndex, willIndex != indexPath.row {
                // 7. If the willIndex is greater than the current index path, check if the next post contains a video.
                if willIndex > indexPath.row && willIndex < posts.count {
                    let nextPost = posts[willIndex]
                    shouldPlayNextVideo = !nextPost.muxPlaybackId.isEmpty
                // 8. If the willIndex is less than the current index path, check if the previous post contains a video.
                } else if willIndex < indexPath.row && willIndex >= 0 {
                    let previousPost = posts[willIndex]
                    shouldPlayPreviousVideo = !previousPost.muxPlaybackId.isEmpty
                }
            // 9. If there is no willIndex value, check if the next or previous post contains a video based on the first visible index path.
            } else if let firstVisibleIndexPath = collectionNode.indexPathsForVisibleItems.first {
                if indexPath.row < firstVisibleIndexPath.row {
                    let previousPost = posts[firstVisibleIndexPath.row]
                    shouldPlayPreviousVideo = !previousPost.muxPlaybackId.isEmpty
                } else if indexPath.row > firstVisibleIndexPath.row {
                    let nextPost = posts[firstVisibleIndexPath.row]
                    shouldPlayNextVideo = !nextPost.muxPlaybackId.isEmpty
                }
            }
            
            // 10. If shouldPlayNextVideo is true, play the next video and set the currentIndex variable to the index path of the next post.
            if shouldPlayNextVideo {
                currentIndex = indexPath.row + 1
                playVideoIfNeed(playIndex: currentIndex)
            // 11. If shouldPlayPreviousVideo is true, play the previous video and set the currentIndex variable to the index path of the previous post.
            } else if shouldPlayPreviousVideo {
                currentIndex = indexPath.row - 1
                playVideoIfNeed(playIndex: currentIndex)
            }
            
            
        }
            
            
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            // User has scrolled to the very top
            currentIndex = 0
            playVideoIfNeed(playIndex: currentIndex!)
            
            
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
       if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
          navigationController?.setNavigationBarHidden(true, animated: true)

       } else {
          navigationController?.setNavigationBarHidden(false, animated: true)
       }
    }


    
}

extension SelectedPostVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath)) as! HashtagCell
        let item = posts[collectionView.tag]
        
     
        cell.hashTagLabel.text = item.hashtags[indexPath.row]
        
        return cell
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return posts[collectionView.tag].hashtags.count
        
    }
    
}

extension SelectedPostVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: view.bounds.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return false
    }
    
}

extension SelectedPostVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            node.settingBtn = { (node) in
            
                self.settingPost(item: post)
                  
            }
            
            delay(0.3) {
                if node.headerView != nil {
                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                }
            }
            
            //
            return node
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedHashtag = posts[collectionView.tag].hashtags[indexPath.row]
        
        if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
            
            PLWHVC.searchHashtag = selectedHashtag
            self.navigationController?.pushViewController(PLWHVC, animated: true)
            
        }
        
        
        
    }
    
}

extension SelectedPostVC {
    
    
    func loadPosts() {
        // 1. Check if the `selectedPost` array has any items. If it does not, return immediately.
        guard selectedPost.count > 0 else {
            return
        }
        
        // 2. If the `selectedPost` array has more than 150 items, remove the items beyond the 150th index based on the current index.
        if selectedPost.count > 150 {
            let count = selectedPost.count
            if currentIndex - 0 <= 75 {
                selectedPost.removeSubrange(150...count-1)
            } else {
                if (0...selectedPost.count - 151).contains(currentIndex) == false {
                    selectedPost.removeSubrange(0...selectedPost.count - 151)
                }
            }
        }
        
        // 3. Append the `selectedPost` items to the `posts` array, and update the `indexPaths` array with the new index paths.
        let section = 0
        var items = [PostModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + selectedPost.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for item in selectedPost {
            items.append(item)
        }
        
        self.posts.append(contentsOf: items)
        self.collectionNode.reloadData()
        
        // 4. If the `startIndex` is not `nil`, scroll to the item at the `startIndex` index path, and delay the play of the video for 0.25 seconds.
        guard startIndex != nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100000)) {
            self.collectionNode.scrollToItem(at: IndexPath(row: self.startIndex, section: 0), at: .centeredVertically, animated: false)
            
            self.delayItem.perform(after: 0.25) {
                // 5. Set the `isfirstLoad`, `currentIndex`, and `willIndex` variables based on the `startIndex`.
                self.isfirstLoad = false
                self.currentIndex = self.startIndex
                playVideoIfNeed(playIndex: self.startIndex)
                self.willIndex = self.startIndex
                
                if self.startIndex > 0 {
                    self.endIndex = self.startIndex - 1
                }
            }
        }
    }



    
}

extension SelectedPostVC {
    
    func setupCollectionNode() {
        
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.wireDelegates()
        
    }
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
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


extension SelectedPostVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
      
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupTitle() {
        
        self.navigationItem.title = "Posts"
       
       
    }
    
}


extension SelectedPostVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "delete")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "edit")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "share")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "stats")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "download")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copyLink")), object: nil)
            
            //copyLink
            
            navigationController.popViewController(animated: true)
        }
    }
    
    
    @objc func onClickDelete(_ sender: AnyObject) {
        
        print("Delete requested")
        
    }
    
    @objc func onClickEdit(_ sender: AnyObject) {
        
        print("Edit requested")
        if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as? EditPostVC {
            
            pauseVideoIfNeed(pauseIndex: currentIndex)
            EPVC.selectedPost = editeddPost
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
        
    }
    
    @objc func onClickShare(_ sender: AnyObject) {
        
        print("Share requested")
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        if let postID = editeddPost?.id, postID != "" {
            
            let items: [Any] = ["Hi I am \(userDataSource.userName ?? "") from Stitchbox, let's check out this with me!", URL(string: "https://dualteam.page.link/dual?p=\(postID)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                           
                
            }
           
            delay(0.1) {
                self.present(ac, animated: true, completion: nil)
            }
           
            
        } else {
            print("Can't get postID")
        }
    
        
    }
    
    @objc func onClickStats(_ sender: AnyObject) {
        
        print("Stats requested")
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StatsVC") as? StatsVC {
            
            
            pauseVideoIfNeed(pauseIndex: currentIndex)
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    @objc func onClickCopyLink(_ sender: AnyObject) {
        
        if let postID = editeddPost?.id, postID != "" {
            
            let link = "https://dualteam.page.link/dual?p=\(postID)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        } else {
            print("Can't get postID")
        }
       
        
    }
    
    @objc func onClickDownload(_ sender: AnyObject) {
        
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
    
    
}


extension SelectedPostVC {
    
    func settingPost(item: PostModel) {
        
        let postSettingVC = PostSettingVC()
        postSettingVC.modalPresentationStyle = .custom
        postSettingVC.transitioningDelegate = self
        
        global_presetingRate = Double(0.35)
        global_cornerRadius = 45
        editeddPost = item
        self.present(postSettingVC, animated: true, completion: nil)
        
    }
    
}
