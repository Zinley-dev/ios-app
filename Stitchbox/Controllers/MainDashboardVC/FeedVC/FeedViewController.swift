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

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var contentView: UIView!
    
    let homeButton: UIButton = UIButton(type: .custom)
    
    var post_list = [PostModel]()
    
    var willIndex: Int!
    var endIndex: Int!
    var currentIndex: Int!
    
    var pageRecommend = 1
    var pageUserFeed = 1
    var pageHighTrending = 1
    

    var posts = [PostModel]()
    var selectedIndexPath = 0
    var selected_item: PostModel!
    var collectionNode: ASCollectionNode!
    var editeddPost: PostModel?
   
    var startIndex: Int!
   
    
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        setupButtons()
        setupCollectionNode()
        
        pullControl.tintColor = UIColor.systemOrange
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showMiddleBtn(vc: self)
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
  
        pullControl.endRefreshing()
   
    }
     

}

extension FeedViewController {
    
    @objc func updateProgressBar() {
        
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = true
               
            }
            global_percentComplete = 0.00
            
        } else {
            
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = false
                self.progressBar.progress = (CGFloat(global_percentComplete)/100)
               
            }

        }
        
    }
    
}

extension FeedViewController {
    
    func setupButtons() {
        
        setupHomeButton()
        setupNotiButton()
    }
    
    
    func setupHomeButton() {
        
        // Do any additional setup after loading the view.
        homeButton.setImage(UIImage.init(named: "Logo")?.resize(targetSize: CGSize(width: 35, height: 35)), for: [])
        homeButton.addTarget(self, action: #selector(onClickHome(_:)), for: .touchUpInside)
        homeButton.frame = back_frame
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.setTitle("", for: .normal)
        homeButton.sizeToFit()
        let homeButtonBarButton = UIBarButtonItem(customView: homeButton)
    
        self.navigationItem.leftBarButtonItem = homeButtonBarButton
       
    }
    
    
    func setupNotiButton() {
        
        let notiButton: UIButton = UIButton(type: .custom)
        // Do any additional setup after loading the view.
        notiButton.setImage(UIImage.init(named: "homeNoti")?.resize(targetSize: CGSize(width: 35, height: 35)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = back_frame
        notiButton.setTitleColor(UIColor.white, for: .normal)
        notiButton.setTitle("", for: .normal)
        notiButton.sizeToFit()
        let notiButtonBarButton = UIBarButtonItem(customView: notiButton)
    
        self.navigationItem.rightBarButtonItem = notiButtonBarButton
       
    }
    
}

extension FeedViewController {
    
    @objc func onClickHome(_ sender: AnyObject) {
        print("onClickHome")
    }
    
    @objc func onClickNoti(_ sender: AnyObject) {
        if let NVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            
            NVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(NVC, animated: true)
            
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
    
}


extension FeedViewController {
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        guard let cell = node as? PostNode else { return }
    
        willIndex = cell.indexPath?.row
    
      
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        
        
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
            
            if posts.count > willIndex - 1 {
                if posts[willIndex - 1].muxPlaybackId != "" {
                    currentIndex = willIndex - 1
                    playPreviousVideoIfNeed(playIndex: currentIndex)
                }
            }
            
            
        }
        
        
    }
    
    
}

extension FeedViewController {
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

extension FeedViewController: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.layer.frame.width, height: 50);
        let max = CGSize(width: self.view.layer.frame.width, height: 1000);
        
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
        
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            node.settingBtn = { (node) in
            
                //self.settingVideo(item: post)
                  
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
    
}


extension FeedViewController {
    
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
        self.collectionNode.leadingScreensForBatching = 2
        
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

extension FeedViewController {
    

    func getUserFeed() {
        
    }
    
   
    
}
