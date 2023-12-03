//
//  SavePostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/5/23.
//


import UIKit
import FLAnimatedImage
import AsyncDisplayKit
import AlamofireImage
import Alamofire

class SavePostVC: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    deinit {
        print("SavePostVC is being deallocated.")
        NotificationCenter.default.removeObserver(self)
        collectionNode.delegate = nil
        collectionNode.dataSource = nil
        
    }


    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var contentView: UIView!
   
    //====================================
    
    
    var isfirstLoad = true
   
    var posts = [PostModel]()
    var page = 1
    var collectionNode: ASCollectionNode!
    var refresh_request = false
   
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Saved posts"
        
        
        //todo: customized search to search only in hashtag_list
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
        
        setupNavBar()
        setupButtons()
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupNavBar()
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
}


extension SavePostVC {
    
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
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        
        pop()
        
    }
    
    func pop() {
        if let navigationController = self.navigationController {
            
            let transparentAppearance = UINavigationBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            transparentAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            transparentAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = transparentAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = transparentAppearance
            
            navigationController.popViewController(animated: true)
        }
    }
    
    
}


extension SavePostVC {
    
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

extension SavePostVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {

        let size = self.collectionNode.view.layer.frame.width/2 - 2
        let min = CGSize(width: size, height: size * 1.75)
        let max = CGSize(width: size, height: size * 1.75)
        
        return ASSizeRangeMake(min, max)
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    
}


extension SavePostVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        if self.posts.count == 0 {
            
            collectionNode.view.setEmptyMessage("No post found!", color: .black)
            
        } else {
            collectionNode.view.restore()
        }
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = OwnerPostSearchNode(with: post, isSave: true)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            //
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



extension SavePostVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumInteritemSpacing = 0 // Set minimum spacing between items to 0
        flowLayout.minimumLineSpacing = 0// Set minimum line spacing to 0
        
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.collectionNode.leadingScreensForBatching = 2.0
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
        
        self.applyStyle()
       
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.view.allowsMultipleSelection = true
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let selectedPostVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedRootPostVC") as? SelectedRootPostVC {
            
            // Find the index of the selected post
            let currentIndex = indexPath.row
            
            if posts.count <= 12 {
                selectedPostVC.startIndex = currentIndex
                selectedPostVC.posts = posts
            } else {
                let beforeIndex = max(currentIndex - 5, 0)
                let afterIndex = min(currentIndex + 5, posts.count - 1)
                selectedPostVC.startIndex = currentIndex - beforeIndex
                selectedPostVC.posts = Array(posts[beforeIndex...afterIndex])
            }
            
            selectedPostVC.page = page
            selectedPostVC.selectedLoadingMode = .save
            selectedPostVC.keepLoading = true
            
            self.navigationController?.pushViewController(selectedPostVC, animated: true)
        }
    }



}


extension SavePostVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getSavedPost(page: page) { [weak self] result in
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
        }
        
        if refresh_request {
            refresh_request = false
        }
    }

    /// Clears existing posts from the collection node.
    func clearExistingPosts() {
        // Calculate the total number of posts before removal.
        let total = posts.count

        // Iterate through each index and clear posts in each cell.
        for index in 0..<total {
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? RootNode {
                // Clear the posts array for each cell.
                cell.clearExistingPosts()
            }
        }

        // Clear the main posts array.
        posts.removeAll()
        // Reload the main collection node to reflect the changes.
        collectionNode.reloadData()
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

