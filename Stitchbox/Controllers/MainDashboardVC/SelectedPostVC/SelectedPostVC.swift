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
        navigationController?.hidesBarsOnSwipe = true
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
                playPreviousVideoIfNeed(playIndex: currentIndex)
            }
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if currentIndex != nil {
            
            if posts[currentIndex].muxPlaybackId != "" {
                pausePreviousVideoIfNeed(pauseIndex: currentIndex)
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
    
    // process hashtag list
    
}

extension SelectedPostVC {
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        if !isfirstLoad {
            
            guard let cell = node as? PostNode else { return }
          
            if cell.indexPath?.row == 0 {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
            
            
            willIndex = cell.indexPath?.row
            
        }
        
       
      
      
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        
        
        if !isfirstLoad {
            
            guard let cell = node as? PostNode else { return }
            
            endIndex = cell.indexPath?.row
         
            if posts[endIndex].muxPlaybackId != "" {
                pausePreviousVideoIfNeed(pauseIndex: endIndex)
            }
            
            if willIndex > endIndex {
                
                if posts[endIndex + 1].muxPlaybackId != "" {
                    currentIndex = endIndex + 1
                    playPreviousVideoIfNeed(playIndex: endIndex + 1)
                }
                 
            } else if willIndex < endIndex {
                
                if endIndex - willIndex <= 2 {
                    
                    if posts[endIndex - 1].muxPlaybackId != "" {
                        currentIndex = endIndex - 1
                        playPreviousVideoIfNeed(playIndex: endIndex - 1)
                    }
                    
                }
                
            
            } else {
                
                if posts[willIndex - 1].muxPlaybackId != "" {
                    currentIndex = willIndex - 1
                    playPreviousVideoIfNeed(playIndex: currentIndex)
                }
            }
            
        }
        
        
    }
    
    
}

extension SelectedPostVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: 1000);
        
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
            
                self.settingVideo(item: post)
                  
            }
            
            //
            return node
        }
    }
    
}

extension SelectedPostVC {
    
    
    func loadPosts() {

           guard selectedPost.count > 0 else {
               return
           }
           
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
            
           guard startIndex != nil else {
               return
           }
           
          
           
           DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100000)) {
               
               self.collectionNode.scrollToItem(at: IndexPath(row: self.startIndex, section: 0), at: .centeredVertically, animated: false)
               
               
               self.delayItem.perform(after: 0.25) {
                   self.isfirstLoad = false
                   self.currentIndex = self.startIndex
                   playPreviousVideoIfNeed(playIndex: self.startIndex)
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
            
            pausePreviousVideoIfNeed(pauseIndex: currentIndex)
            EPVC.selectedPost = editeddPost
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
        
    }
    
    @objc func onClickShare(_ sender: AnyObject) {
        
        print("Share requested")
        
    }
    
    @objc func onClickStats(_ sender: AnyObject) {
        
        print("Stats requested")
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StatsVC") as? StatsVC {
            
            
            pausePreviousVideoIfNeed(pauseIndex: currentIndex)
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    @objc func onClickCopyLink(_ sender: AnyObject) {
        
       
        
    }
    
    @objc func onClickDownload(_ sender: AnyObject) {
        
        print("Download requested")
        
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
    
    func settingVideo(item: PostModel) {
        
        let postSettingVC = PostSettingVC()
        postSettingVC.modalPresentationStyle = .custom
        postSettingVC.transitioningDelegate = self
        
        global_presetingRate = Double(0.35)
        global_cornerRadius = 45
        postSettingVC.selectedPost = item
        editeddPost = item
        self.present(postSettingVC, animated: true, completion: nil)
        
    }
    
}
