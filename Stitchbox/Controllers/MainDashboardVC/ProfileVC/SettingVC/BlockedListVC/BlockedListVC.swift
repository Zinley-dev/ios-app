//
//  BlockedListVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import FLAnimatedImage

class BlockedListVC: UIViewController {
    
    deinit {
        print("BlockedListVC is being deallocated.")
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var blockList = [BlockUserModel]()
    var tableNode: ASTableNode!
    var firstAnimated = true
    var currentPage = 1
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        setupTableNode()
        
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
        
        
        if firstAnimated {
            
            do {
                
                let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
                let gifData = try NSData(contentsOfFile: path) as Data
                let image = FLAnimatedImage(animatedGIFData: gifData)
                
                
                self.loadingImage.animatedImage = image
                
            } catch {
                print(error.localizedDescription)
            }
            
            loadingView.backgroundColor = self.view.backgroundColor
            
        }
        
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
}

extension BlockedListVC {
    
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
        navigationItem.title = "Blocked List"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension BlockedListVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 1.0
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        
    }
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = true
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        //
    }
    
}

extension BlockedListVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { (newBlocks) in
            
            self.insertNewRowsInTableNode(newBlocks: newBlocks)
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    
}

extension BlockedListVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.blockList.count == 0 {
            
            tableNode.view.setEmptyMessage("No blocked user!")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.blockList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = self.blockList[indexPath.row]
        
        return {
            
            let node = BlockNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
}

extension BlockedListVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getBlocks(page: currentPage) { [weak self] result in
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
                    self.currentPage += 1
                    print("Successfully retrieved \(data.count) blocks.")
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
    
    
    func insertNewRowsInTableNode(newBlocks: [[String: Any]]) {
        
        guard newBlocks.count > 0 else {
            hideAnimation()
            return
        }
        
        let section = 0
        var items = [BlockUserModel]()
        var indexPaths: [IndexPath] = []
        let total = self.blockList.count + newBlocks.count
        
        for row in self.blockList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newBlocks {
            
            let item = BlockUserModel(JSON: i)
            items.append(item!)
            
        }
        
        
        self.blockList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
        hideAnimation()
        
    }
    
    func hideAnimation() {
        
        if firstAnimated {
            
            firstAnimated = false
            
            UIView.animate(withDuration: 0.5) {
                
                Dispatch.main.async {
                    self.loadingView.alpha = 0
                }
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
            
        }
        
    }
    
}
