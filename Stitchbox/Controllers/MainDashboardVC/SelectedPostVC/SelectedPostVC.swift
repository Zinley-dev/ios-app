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
    
   
    var startIndex: Int!
    var currentIndex: Int!
    var endIndex: Int!
    var willIndex: Int!
    let backButton: UIButton = UIButton(type: .custom)
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        navigationController?.hidesBarsOnSwipe = true
        setupCollectionNode()
        loadPosts()
    }
    
    
}


extension SelectedPostVC {
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
                                                                                                                                      
        
    }
    
}

extension SelectedPostVC {
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        guard let cell = node as? PostNode else { return }
      
        if cell.indexPath?.row == 0 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        if willIndex == nil {
            
            if posts[cell.indexPath!.row].muxPlaybackId != "" {
                playPreviousVideoIfNeed(playIndex: cell.indexPath!.row)
            }
        }
        
        
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
                playPreviousVideoIfNeed(playIndex: endIndex + 1)
            }
             
        } else if willIndex < endIndex {
            
            if endIndex - willIndex <= 2 {
                
                if posts[endIndex - 1].muxPlaybackId != "" {
                    playPreviousVideoIfNeed(playIndex: endIndex - 1)
                }
                
            }
            
        
        } else {
            
            if posts[willIndex].muxPlaybackId != "" {
                playPreviousVideoIfNeed(playIndex: willIndex)
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
               
               self.currentIndex = self.startIndex
               
               self.collectionNode.scrollToItem(at: IndexPath(row: self.startIndex, section: 0), at: .top, animated: false)
               
               if self.currentIndex != 0 {
                   
                   self.delayItem.perform(after: 0.25) {
                       if self.currentIndex != 0, self.currentIndex != nil {
                           
                           playPreviousVideoIfNeed(playIndex: self.currentIndex)
                           
                       }
                       
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
            navigationController.popViewController(animated: true)
        }
    }
    
    
}
