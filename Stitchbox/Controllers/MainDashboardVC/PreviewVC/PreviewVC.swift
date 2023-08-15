//
//  PreviewVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/14/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage

class PreviewVC: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var playTimeBar: CustomSlider!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!

    let backButton: UIButton = UIButton(type: .custom)
    var currentIndex: Int?
    var isfirstLoad = true
    var posts = [PostModel]()
    var collectionNode: ASCollectionNode!
    var startIndex: Int!
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var selectedPost = [PostModel]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        
        setupButtons()
        setupCollectionNode()
        setupNavBar()
        blurView.isHidden = true
        delay(0.05) { [weak self] in
            guard let self = self else { return }
            self.loadPosts()
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if newPlayingIndex != nil {
            
            pauseVideo(index: currentIndex!)
            
        }
        
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
        
        loadingView.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
  
        
        delay(1) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
        
        if currentIndex != nil {
            //newPlayingIndex
            playVideo(index: currentIndex!)
            
        }
        
        setupNavBar()

    }


    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.backgroundImage = UIImage()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundEffect = nil

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    
    func loadPosts() {
        // 1. Check if the `selectedPost` array has any items. If it does not, return immediately.
        guard selectedPost.count > 0 else {
            return
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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(10000)) { [weak self] in
            guard let self = self else { return }
            self.collectionNode.scrollToItem(at: IndexPath(row: self.startIndex, section: 0), at: .centeredVertically, animated: false)
            
            if !self.posts[self.startIndex].muxPlaybackId.isEmpty {

                if let currentCell = collectionNode.nodeForItem(at: IndexPath(item: self.startIndex, section: 0)) as? VideoNode {
                    
                    if !currentCell.post.muxPlaybackId.isEmpty {
                        currentIndex = 0
                        newPlayingIndex = 0
                       
                        delay(0.25) { [weak self] in
                            guard let self = self else { return }
                            self.playVideo(index: 0)
                        }
                    }
                    
                }
                
            } else {
                self.isVideoPlaying = false
                self.playTimeBar.isHidden = true
            }
            
        }
    
    }
  
    
}


extension PreviewVC {
    
    func setupButtons() {
        
        setupBackButton()
        
        
    }
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back_icn_white") {
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
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }

        
    }
    
    
}


extension PreviewVC {
    
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


extension PreviewVC {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if this is the first visible cell and it contains a video.
        
        if isfirstLoad {
            isfirstLoad = false
            let post = posts[0]
            if !post.muxPlaybackId.isEmpty {
                currentIndex = 0
                newPlayingIndex = 0
                playVideo(index: currentIndex!)
                isVideoPlaying = true
            }
            
        }
    }
    
  
}

extension PreviewVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: contentView.frame.height);
        let max = CGSize(width: self.view.layer.frame.width, height: contentView.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    
}

extension PreviewVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = VideoNode(with: post, at: indexPath.row, isPreview: true)
            //node.collectionNode = self.collectionNode
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.isOriginal = true
            node.automaticallyManagesSubnodes = true
            //
            
            return node
        }
        
    }

    
}


extension PreviewVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
       
        
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        //self.collectionNode.view.isScrollEnabled = false
        self.applyStyle()
        self.wireDelegates()
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
       
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
}


extension PreviewVC {
    
    
    func pauseVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
         
            
            cell.cellVideoNode.pause()
            
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
                
                
                cell.disableTouching()
                
                cell.setNeedsLayout()
                

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
                
                
            }
            
        }
        
    }
    
}
