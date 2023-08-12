//
//  TrendingHashtagVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class TrendingHashtagVC: UIViewController {

    private var currPage = 1
    var hashtagList = [TrendingHashtag]()
    @IBOutlet weak var contentView: UIView!
    var tableNode: ASTableNode!
    var refresh_request = false
    private var pullControl = UIRefreshControl()
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //must happen before setting up tablenode otherwise data is not enough to render
        setupTableNode()
        // Do any additional setup after loading the view.
        
    }


}


extension TrendingHashtagVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
}

extension TrendingHashtagVC: ASTableDelegate {
    
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
        
        self.retrieveNextPageWithCompletion { [weak self] (newHashtags) in
            guard let self = self else { return }
            self.insertNewRowsInTableNode(newHashtags: newHashtags)
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let selectedHashtag = hashtagList[indexPath.row]
        
        if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
            
            PLWHVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            PLWHVC.searchHashtag = selectedHashtag.hashtag
            self.navigationController?.pushViewController(PLWHVC, animated: true)
            
        }
        
        
    }
    
}

extension TrendingHashtagVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        let array = hashtagList
        
        
        if array.count == 0 {
            
            tableNode.view.setEmptyMessage("Trending hashtags will be shown here")
            
        } else {
            tableNode.view.restore()
        }
        
        return array.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let hashtag = hashtagList[indexPath.row]
        let ranking = indexPath.row + 1

        return {
            var node: TrendingHashtagNode!
            node = TrendingHashtagNode(with: hashtag, rank: ranking)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            return node
        }
    }
    
}


extension TrendingHashtagVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getPostTrendingTag(page: currPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) users.")
                    self.currPage += 1
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

    func insertNewRowsInTableNode(newHashtags: [[String: Any]]) {
        guard newHashtags.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        var newItems: [TrendingHashtag] = []
        for dictionary in newHashtags {
            do {
                let trendingHashtag = try TrendingHashtag(from: dictionary)
                newItems.append(trendingHashtag)
            } catch {
                print("Error creating TrendingHashtag: \(error)")
            }
        }
        
        if !newItems.isEmpty {
            hashtagList.append(contentsOf: newItems)
            let indexPaths = generateIndexPaths(for: newItems)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        let deleteIndexPaths = hashtagList.enumerated().map { IndexPath(row: $0.offset, section: 0) }
        hashtagList.removeAll()
        tableNode.deleteRows(at: deleteIndexPaths, with: .automatic)
    }

    private func generateIndexPaths(for items: [TrendingHashtag]) -> [IndexPath] {
        let startIndex = self.hashtagList.count - items.count
        return (startIndex..<self.hashtagList.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newHashtags) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newHashtags.isEmpty {
                self.refresh_request = false
                self.hashtagList.removeAll()
                self.tableNode.reloadData()
                if self.hashtagList.isEmpty {
                    self.tableNode.view.setEmptyMessage("Trending hashtags will be shown here!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newHashtags: newHashtags)
            }
        }
    }

    @objc func clearAllData() {
      
        refresh_request = true
        currPage = 1
        updateData()
    }

    
}



