//
//  fistBumpeeVC.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//

import Foundation
import UIKit
import Alamofire
import AsyncDisplayKit

class FistBumpeeVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let group = DispatchGroup()
    
    @IBOutlet weak var contentView: UIView!
    var fistBumpList = [FistBumpUserModel]()
    var tableNode: ASTableNode!
    var currPage = 1
    var inSearchMode = false
    var searchUserList = [FistBumpUserModel]()
    
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

}

extension FistBumpeeVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     FistBumped List", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension FistBumpeeVC {
    
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

extension FistBumpeeVC: ASTableDelegate {
    
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
        print("batchfetching start")
        self.retrieveNextPageWithCompletion { (newFollowees) in
            
            self.insertNewRowsInTableNode(newFistBumpees: newFollowees)
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    
}

extension FistBumpeeVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.fistBumpList.count == 0 {
            
            tableNode.view.setEmptyMessage("No fistbumpees!")
            
        } else {
            tableNode.view.restore()
        }
        
        return inSearchMode ? searchUserList.count : fistBumpList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : fistBumpList[indexPath.row]
        
        return {
            
            let node = FistBumpNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : fistBumpList[indexPath.row]
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            //self.hidesBottomBarWhenPushed = true
            UPVC.userId = user.userID
            UPVC.nickname = user.userName
            self.navigationController?.pushViewController(UPVC, animated: true)
            
        }
        
    }
    
}

extension FistBumpeeVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
            APIManager().getFistBumpee(page: currPage) { result in
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
                        self.currPage += 1
                        print("Successfully retrieved \(data.count) fistBumpees.")
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
    
    
    func insertNewRowsInTableNode(newFistBumpees: [[String: Any]]) {
        // Check if there are new posts to insert
        guard !newFistBumpees.isEmpty else { return }
        

        // Calculate the range of new rows
        let startIndex = fistBumpList.count
        let endIndex = startIndex + newFistBumpees.count
        
        // Create an array of PostModel objects
        let newItems = newFistBumpees.compactMap { FistBumpUserModel(JSON: $0) }
        
        // Append the new items to the existing array
        fistBumpList.append(contentsOf: newItems)
        
        // Create an array of index paths for the new rows
        let insertIndexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        
        // Insert the new rows
        tableNode.insertRows(at: insertIndexPaths, with: .automatic)
       
    }
    
    
}
