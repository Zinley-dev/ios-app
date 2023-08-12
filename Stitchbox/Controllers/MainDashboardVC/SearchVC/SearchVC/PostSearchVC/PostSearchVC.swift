//
//  PostSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire

class PostSearchVC: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    deinit {
        print("PostSearchVC is being deallocated.")
    }
    
    @IBOutlet weak var contentview: UIView!
    
    var page = 1
    var keyword = ""
    var prev_keyword = ""
    var post_list = [PostModel]()
    
  
    var isfirstLoad = true
    
    var posts = [PostModel]()
    var collectionNode: ASCollectionNode!
    var refresh_request = false
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCollectionNode()
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            collectionNode.view.refreshControl = pullControl
        } else {
            collectionNode.view.addSubview(pullControl)
        }
        
        
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    

}


extension PostSearchVC {
    
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


extension PostSearchVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let size = self.collectionNode.view.layer.frame.width/2 - 7
        let min = CGSize(width: size, height: size * 1.75)
        let max = CGSize(width: size, height: size * 1.75)
        
        return ASSizeRangeMake(min, max)
    }

    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
}


extension PostSearchVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = PostSearchNode(with: post, keyword: self.keyword)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"

            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
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



extension PostSearchVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumInteritemSpacing = 7 // Set minimum spacing between items to 0
        flowLayout.minimumLineSpacing = 7 // Set minimum line spacing to 0
        
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        
        // Add the collection node's view as a subview and set constraints
        self.contentview.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentview.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentview.leadingAnchor, constant: -1).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentview.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentview.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.wireDelegates()
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
    func searchRequest() {
        
        
        if prev_keyword == "" || prev_keyword != keyword {
            
            prev_keyword = keyword
            clearAllData()
            
        }
        
        
        
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let selectedPostVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedParentVC") as? SelectedParentVC {
            
            // Find the index of the selected post
            let currentIndex = indexPath.row
            
            // Determine the range of posts to include before and after the selected post
            let beforeIndex = max(currentIndex - 5, 0)
            let afterIndex = min(currentIndex + 5, posts.count - 1)

            // Include up to 5 posts before and after the selected post in the sliced array
            selectedPostVC.posts = Array(posts[beforeIndex...afterIndex])
            
            // Set the startIndex to the position of the selected post within the sliced array
            selectedPostVC.startIndex = currentIndex - beforeIndex
            
            selectedPostVC.page = page
            selectedPostVC.selectedLoadingMode = .search
            selectedPostVC.keyword = keyword
            selectedPostVC.keepLoading = true
           
            self.navigationController?.pushViewController(selectedPostVC, animated: true)
        }
    }


    
}



extension PostSearchVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        if keyword != "" {
            
           
            APIManager.shared.searchPost(query: keyword, page: page) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                        print("Successfully retrieved \(data.count) posts.")
                        self.page += 1
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
            
        } else {
            
            self.completeWithEmptyData(block)
            
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
        }
    }

    private func clearExistingPosts() {
        let deleteIndexPaths = posts.enumerated().map { IndexPath(row: $0.offset, section: 0) }
        posts.removeAll()
        collectionNode.deleteItems(at: deleteIndexPaths)
    }

    private func generateIndexPaths(for items: [PostModel]) -> [IndexPath] {
        let startIndex = self.posts.count - items.count
        return (startIndex..<self.posts.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newPosts.isEmpty {
                self.refresh_request = false
                self.posts.removeAll()
                self.collectionNode.reloadData()
                if self.posts.isEmpty {
                    self.collectionNode.view.setEmptyMessage("No post found!", color: .white)
                } else {
                    self.collectionNode.view.restore()
                }
            } else {
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
            }
        }
    }

    @objc func clearAllData() {
      
        refresh_request = true
        page = 1
        updateData()
    }

    
    
}
